---
stage: Release
group: Release
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Create redirects for GitLab Pages

> - [Introduced](https://gitlab.com/gitlab-org/gitlab-pages/-/issues/24) in GitLab Pages 1.25.0 and GitLab 13.4 behind a feature flag, disabled by default.
> - [Became enabled by default](https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/367) in GitLab 13.5.

WARNING:
This feature might not be available to you. Check the **version history** note above for details.

In GitLab Pages, you can configure rules to forward one URL to another using
[Netlify style](https://docs.netlify.com/routing/redirects/#syntax-for-the-redirects-file)
HTTP redirects.

## Supported features

GitLab Pages only supports the
[`_redirects` plain text file syntax](https://docs.netlify.com/routing/redirects/#syntax-for-the-redirects-file),
and `.toml` files are not supported.

Redirects are only supported at a basic level. GitLab Pages doesn't support all
[special options offered by Netlify](https://docs.netlify.com/routing/redirects/redirect-options/).

Note that supported paths must start with a forward slash `/`.

| Feature | Supported | Example |
| ------- | --------- | ------- |
| [Redirects (`301`, `302`)](#redirects) | **{check-circle}** Yes | `/wardrobe.html /narnia.html 302`
| [Rewrites (`200`)](#rewrites) | **{dotted-circle}** Yes | `/* / 200` |
| Rewrites (other than `200`) | **{dotted-circle}** No | `/en/* /en/404.html 404` |
| [Splats](#splats) | **{check-circle}** Yes | `/news/*  /blog/:splat` |
| Placeholders | **{dotted-circle}** No | `/news/:year/:month/:date/:slug  /blog/:year/:month/:date/:slug` |
| Query parameters | **{dotted-circle}** No | `/store id=:id  /blog/:id  301` |
| Force ([shadowing](https://docs.netlify.com/routing/redirects/rewrites-proxies/#shadowing)) | **{dotted-circle}** No | `/app/  /app/index.html  200!` |
| Domain-level redirects | **{dotted-circle}** No | `http://blog.example.com/* https://www.example.com/blog/:splat 301` |
| Redirect by country or language | **{dotted-circle}** No | `/  /anz     302  Country=au,nz` |
| Redirect by role | **{dotted-circle}** No | `/admin/*  200!  Role=admin` |

## Create redirects

To create redirects,
create a configuration file named `_redirects` in the `public/` directory of your
GitLab Pages site.

If your GitLab Pages site uses the default domain name (such as
`namespace.gitlab.io/projectname`) you must prefix every rule with the project name:

```plaintext
/projectname/redirect-portal.html /projectname/magic-land.html 301
/projectname/cake-portal.html /projectname/still-alive.html 302
/projectname/wardrobe.html /projectname/narnia.html 302
/projectname/pit.html /projectname/spikes.html 302
```

If your GitLab Pages site uses [custom domains](custom_domains_ssl_tls_certification/index.md),
no project name prefix is needed. For example, if your custom domain is `example.com`,
your `_redirect` file would look like:

```plaintext
/redirect-portal.html /magic-land.html 301
/cake-portal.html /still-alive.html 302
/wardrobe.html /narnia.html 302
/pit.html /spikes.html 302
```

## Redirects

### Permanent (301) redirects

To create a permanent redirect (`301`), create a rule that includes a `from`
path, a `to` path, and a `301` status code:

```plaintext
/old/file.html /new/file.html 301
```

A default status code of `301` is applied if no status code is provided, so this
rule can be simplified to:

```plaintext
/old/file.html /new/file.html
```

### Temporary (302) redirects

Temporary redirect (`302`) rules are similar to permanent redirect rules:

```plaintext
/old/file.html /new/file.html 302
```

## Rewrites

Provide a status code of `200` to serve the content of the `to` path when the
request matches the `from`:

```plaintext
/old/file.html /new/file.html 200
```

This is typically used in combination with [splat rules](#splats) to dynamically
rewrite the URL.

## Splats

A rule with an asterisk (`*`) - or "splat" - in its `from` path will match
anything at the start, middle, or end of requested path.

```plaintext
/old/* /new/file.html 200
```

## Splat placeholders

The content matched by a `*` in a rule's `from` path can be injected
into the `to` path using the `:splat` placeholder:

```plaintext
/old/* /new/:splat 200
```

For example, using the configuration above, a request to `/old/file.html` would
serve the contents of `new/file.html` with a `200`.

### Valid examples

The following are examples of valid splat rules:

```plaintext
# Valid rules

/old/* /new/file.html 200
/old/* /new/file.html 302
/old/* /new/:splat
/old/*/path /new/:splat/location
/*/old/path /:splat/new/location
```

### Invalid examples

The follow are examples of **invalid** splat rules:

```plaintext
# Invalid rules

# Multiple splats are not allowed
/multiple/*/splats/* /new/path.html

# Multiple splat placeholders are not allowed
/old/path /multiple/:splat/placeholders/:splat

# Splat replacements must have a matching splat
/old/path /new/path/:splat

# No splats in the "to" url
/old/path /to/*

# No splat placeholders in the "from" url
/:splat/path /to/path
```

### Rewrite all requests to a root `index.html`

Single page applications (SPAs) often perform their own routing using client-side
routes. For these applications, it's important that _all_ requests are rewritten
to the root `index.html` so that the routing logic can be handled by the
JavaScript application. This is easily accomplished with a `_redirects` file
like this:

```plaintext
/* / 200
```

## Files override redirects

Files take priority over redirects. If a file exists on disk, GitLab Pages serves
the file instead of your redirect. For example, if the files `hello.html` and
`world.html` exist, and the `_redirects` file contains the following line, the redirect
is ignored because `hello.html` exists:

```plaintext
/projectname/hello.html /projectname/world.html 302
```

GitLab doesn't support Netlify's
[force option](https://docs.netlify.com/routing/redirects/rewrites-proxies/#shadowing)
to change this behavior.

## Debug redirect rules

If a redirect isn't working as expected, or you want to check your redirect syntax, visit
`https://[namespace.gitlab.io]/projectname/_redirects`, replacing `[namespace.gitlab.io]` with
your domain name. The `_redirects` file isn't served directly, but your browser
displays a numbered list of your redirect rules, and whether the rule is valid or invalid:

```plaintext
11 rules
rule 1: valid
rule 2: valid
rule 3: error: splats are not supported
rule 4: valid
rule 5: error: placeholders are not supported
rule 6: valid
rule 7: error: no domain-level redirects to outside sites
rule 8: error: url path must start with forward slash /
rule 9: error: no domain-level redirects to outside sites
rule 10: valid
rule 11: valid
```

## Disable redirects

Redirects in GitLab Pages is under development, and is deployed behind a feature flag
that is **enabled by default**.

To disable redirects, for [Omnibus installations](../../../administration/pages/index.md), define the
`FF_ENABLE_REDIRECTS` environment variable in the
[global settings](../../../administration/pages/index.md#global-settings).
Add the following line to `/etc/gitlab/gitlab.rb` and
[reconfigure the instance](../../../administration/restart_gitlab.md#omnibus-gitlab-reconfigure).

```ruby
gitlab_pages['env']['FF_ENABLE_REDIRECTS'] = 'false'
```

For [source installations](../../../administration/pages/source.md), define the
`FF_ENABLE_REDIRECTS` environment variable, then
[restart GitLab](../../../administration/restart_gitlab.md#installations-from-source):

```shell
export FF_ENABLE_REDIRECTS="false"
/path/to/pages/bin/gitlab-pages -config gitlab-pages.conf
```
