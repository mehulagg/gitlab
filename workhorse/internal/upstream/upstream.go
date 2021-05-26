/*
The upstream type implements http.Handler.

In this file we handle request routing and interaction with the authBackend.
*/

package upstream

import (
	"fmt"
	"os"

	"net/http"
	"net/url"
	"strings"

	"github.com/sirupsen/logrus"
	"gitlab.com/gitlab-org/labkit/correlation"

	apipkg "gitlab.com/gitlab-org/gitlab-workhorse/internal/api"
	"gitlab.com/gitlab-org/gitlab-workhorse/internal/config"
	"gitlab.com/gitlab-org/gitlab-workhorse/internal/helper"
	"gitlab.com/gitlab-org/gitlab-workhorse/internal/log"
	"gitlab.com/gitlab-org/gitlab-workhorse/internal/rejectmethods"
	"gitlab.com/gitlab-org/gitlab-workhorse/internal/upload"
	"gitlab.com/gitlab-org/gitlab-workhorse/internal/upstream/roundtripper"
	"gitlab.com/gitlab-org/gitlab-workhorse/internal/urlprefix"
)

var (
	DefaultBackend         = helper.URLMustParse("http://localhost:8080")
	requestHeaderBlacklist = []string{
		upload.RewrittenFieldsHeader,
	}
)

type upstream struct {
	config.Config
	URLPrefix            urlprefix.Prefix
	Routes               []routeEntry
	RoundTripper         http.RoundTripper
	CableRoundTripper    http.RoundTripper
	GeoProxyBackend      *url.URL
	GeoProxyRoutes       []routeEntry
	GeoProxyRoundTripper http.RoundTripper
	GeoProxyUpstream     http.Handler
	accessLogger         *logrus.Logger
}

func NewUpstream(cfg config.Config, accessLogger *logrus.Logger) http.Handler {
	return newUpstream(cfg, accessLogger, configureRoutes)
}

func newUpstream(cfg config.Config, accessLogger *logrus.Logger, routesCallback func(*upstream)) http.Handler {
	up := upstream{
		Config:       cfg,
		accessLogger: accessLogger,
	}
	if up.Backend == nil {
		up.Backend = DefaultBackend
	}
	if up.CableBackend == nil {
		up.CableBackend = up.Backend
	}
	if up.CableSocket == "" {
		up.CableSocket = up.Socket
	}
	up.RoundTripper = roundtripper.NewBackendRoundTripper(up.Backend, up.Socket, up.ProxyHeadersTimeout, cfg.DevelopmentMode)
	up.CableRoundTripper = roundtripper.NewBackendRoundTripper(up.CableBackend, up.CableSocket, up.ProxyHeadersTimeout, cfg.DevelopmentMode)
	up.configureURLPrefix()
	routesCallback(&up)

	var correlationOpts []correlation.InboundHandlerOption
	if cfg.PropagateCorrelationID {
		correlationOpts = append(correlationOpts, correlation.WithPropagation())
	}

	handler := correlation.InjectCorrelationID(&up, correlationOpts...)
	// TODO: move to LabKit https://gitlab.com/gitlab-org/gitlab-workhorse/-/issues/339
	handler = rejectmethods.NewMiddleware(handler)
	return handler
}

func (u *upstream) configureURLPrefix() {
	relativeURLRoot := u.Backend.Path
	if !strings.HasSuffix(relativeURLRoot, "/") {
		relativeURLRoot += "/"
	}
	u.URLPrefix = urlprefix.Prefix(relativeURLRoot)
}

func (u *upstream) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	logWithRequest := log.WithRequest(r)
	helper.FixRemoteAddr(r)

	helper.DisableResponseBuffering(w)

	// Drop RequestURI == "*" (FIXME: why?)
	if r.RequestURI == "*" {
		helper.HTTPError(w, r, "Connection upgrade not allowed", http.StatusBadRequest)
		return
	}

	// Disallow connect
	if r.Method == "CONNECT" {
		helper.HTTPError(w, r, "CONNECT not allowed", http.StatusBadRequest)
		return
	}

	// Check URL Root
	URIPath := urlprefix.CleanURIPath(r.URL.EscapedPath())
	prefix := u.URLPrefix
	if !prefix.Match(URIPath) {
		helper.HTTPError(w, r, fmt.Sprintf("Not found %q", URIPath), http.StatusNotFound)
		return
	}

	var route *routeEntry
	cleanedPath := prefix.Strip(URIPath)

	// Developing behind GEO_SECONDARY_PROXY environment variable
	// See https://gitlab.com/groups/gitlab-org/-/epics/5914#note_564974130
	if os.Getenv("GEO_SECONDARY_PROXY") == "1" {
		geoProxyURL, err := getGeoProxyURL(u)
		if err != nil {
			logWithRequest.WithError(err).Error("Error calling Geo Proxy API. Falling back to normal routing.")
		} else if geoProxyURL != nil {
			// For now, just output debug logging.
			logWithRequest.Info("This is a Geo Proxy that should proxy many requests to: ", geoProxyURL)

			route, err = matchGeoProxyRoute(cleanedPath, r, u, geoProxyURL)
			if err != nil {
				logWithRequest.WithError(err).Error("Error during matchGeoProxyRoute. Falling back to normal routing.")
			}
		}
	}

	// Look for a matching normal route if one is not already found
	if route == nil {
		for _, ro := range u.Routes {
			if ro.isMatch(cleanedPath, r) {
				route = &ro
				break
			}
		}
	}

	if route == nil {
		// The protocol spec in git/Documentation/technical/http-protocol.txt
		// says we must return 403 if no matching service is found.
		helper.HTTPError(w, r, "Forbidden", http.StatusForbidden)
		return
	}

	for _, h := range requestHeaderBlacklist {
		r.Header.Del(h)
	}

	route.handler.ServeHTTP(w, r)
}

// TODO: Cache the result of the API requests
// See https://gitlab.com/gitlab-org/gitlab/-/issues/329671
func getGeoProxyURL(u *upstream) (geoProxyURL *url.URL, err error) {
	api := apipkg.NewAPI(
		u.Backend,
		u.Version,
		u.RoundTripper,
	)

	geoProxyURLString, err := api.GetGeoProxyURL()
	if err != nil {
		return nil, err
	}

	geoProxyURL, err = helper.URLMustParse(geoProxyURLString)
	if err != nil {
		return nil, err
	}

	return geoProxyURL, nil
}

func matchGeoProxyRoute(cleanedPath string, req *http.Request, u *upstream, geoProxyURL *url.URL) (route routeEntry, err error) {
	err = setGeoProxyUpstream(u, geoProxyURL)
	if err != nil {
		return nil, err
	}

	// Look for matching Geo Proxy route
	for _, ro := range u.GeoProxyRoutes {
		if ro.isMatch(cleanedPath, req) {
			route = &ro
			break
		}
	}

	return route, nil
}

// Make sure that the proxy used in GeoProxyRoutes is set up and pointing to the
// correct URL (it can change!)
func setGeoProxyUpstream(u *upstream, geoProxyURL *url.URL) (err error) {
	if u.GeoProxyBackend != geoProxyURL {
		// Update GeoProxyBackend, GeoProxyRoundTripper, and GeoProxyUpstream
		u.GeoProxyBackend = geoProxyURL
	}

	if u.GeoProxyUpstream == nil {
		return fmt.Errorf("failed to set Geo Proxy upstream handler")
	}

	return nil
}
