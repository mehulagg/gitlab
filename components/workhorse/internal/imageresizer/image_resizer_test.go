package imageresizer

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"os"
	"testing"

	"gitlab.com/gitlab-org/gitlab-workhorse/internal/config"

	"gitlab.com/gitlab-org/labkit/log"

	"github.com/stretchr/testify/require"

	"gitlab.com/gitlab-org/gitlab-workhorse/internal/testhelper"
)

func TestMain(m *testing.M) {
	if err := testhelper.BuildExecutables(); err != nil {
		log.WithError(err).Fatal()
	}

	os.Exit(m.Run())
}

func TestUnpackParametersReturnsParamsInstanceForValidInput(t *testing.T) {
	r := Resizer{}
	inParams := resizeParams{Location: "/path/to/img", Width: 64, ContentType: "image/png"}

	outParams, err := r.unpackParameters(encodeParams(t, &inParams))

	require.NoError(t, err, "unexpected error when unpacking params")
	require.Equal(t, inParams, *outParams)
}

func TestUnpackParametersReturnsErrorWhenLocationBlank(t *testing.T) {
	r := Resizer{}
	inParams := resizeParams{Location: "", Width: 64, ContentType: "image/jpg"}

	_, err := r.unpackParameters(encodeParams(t, &inParams))

	require.Error(t, err, "expected error when Location is blank")
}

func TestUnpackParametersReturnsErrorWhenContentTypeBlank(t *testing.T) {
	r := Resizer{}
	inParams := resizeParams{Location: "/path/to/img", Width: 64, ContentType: ""}

	_, err := r.unpackParameters(encodeParams(t, &inParams))

	require.Error(t, err, "expected error when ContentType is blank")
}

func TestTryResizeImageSuccess(t *testing.T) {
	r := Resizer{}
	inParams := resizeParams{Location: "/path/to/img", Width: 64, ContentType: "image/png"}
	inFile := testImage(t)
	req, err := http.NewRequest("GET", "/foo", nil)
	require.NoError(t, err)

	reader, cmd, err := r.tryResizeImage(
		req,
		inFile,
		os.Stderr,
		&inParams,
		int64(config.DefaultImageResizerConfig.MaxFilesize),
		config.DefaultImageResizerConfig,
	)

	require.NoError(t, err)
	require.NotNil(t, cmd)
	require.NotNil(t, reader)
	require.NotEqual(t, inFile, reader)
}

func TestTryResizeImageSkipsResizeWhenSourceImageTooLarge(t *testing.T) {
	r := Resizer{}
	inParams := resizeParams{Location: "/path/to/img", Width: 64, ContentType: "image/png"}
	inFile := testImage(t)
	req, err := http.NewRequest("GET", "/foo", nil)
	require.NoError(t, err)

	reader, cmd, err := r.tryResizeImage(
		req,
		inFile,
		os.Stderr,
		&inParams,
		int64(config.DefaultImageResizerConfig.MaxFilesize)+1,
		config.DefaultImageResizerConfig,
	)

	require.Error(t, err)
	require.Nil(t, cmd)
	require.Equal(t, inFile, reader, "Expected output streams to match")
}

func TestTryResizeImageFailsWhenContentTypeNotMatchingFileContents(t *testing.T) {
	r := Resizer{}
	inParams := resizeParams{Location: "/path/to/img", Width: 64, ContentType: "image/jpeg"}
	inFile := testImage(t) // this is a PNG file; the image scaler should fail fast in this case
	req, err := http.NewRequest("GET", "/foo", nil)
	require.NoError(t, err)

	_, cmd, err := r.tryResizeImage(
		req,
		inFile,
		os.Stderr,
		&inParams,
		int64(config.DefaultImageResizerConfig.MaxFilesize),
		config.DefaultImageResizerConfig,
	)

	require.NoError(t, err)
	require.Error(t, cmd.Wait(), "Expected to fail due to content-type mismatch")
}

func TestServeImage(t *testing.T) {
	inFile := testImage(t)
	var writer bytes.Buffer

	bytesWritten, err := serveImage(inFile, &writer, nil)

	require.NoError(t, err)
	require.Greater(t, bytesWritten, int64(0))
	require.Equal(t, int64(len(writer.Bytes())), bytesWritten)
}

// The Rails applications sends a Base64 encoded JSON string carrying
// these parameters in an HTTP response header
func encodeParams(t *testing.T, p *resizeParams) string {
	json, err := json.Marshal(*p)
	if err != nil {
		require.NoError(t, err, "JSON encoder encountered unexpected error")
	}
	return base64.StdEncoding.EncodeToString(json)
}

func testImage(t *testing.T) *os.File {
	f, err := os.Open("../../testdata/image.png")
	require.NoError(t, err)
	return f
}
