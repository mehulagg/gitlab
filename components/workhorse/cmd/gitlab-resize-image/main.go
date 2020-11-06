package main

import (
	"fmt"
	"image"
	"mime"
	"os"
	"strconv"

	"github.com/disintegration/imaging"
)

func main() {
	if err := _main(); err != nil {
		fmt.Fprintf(os.Stderr, "%s: fatal: %v\n", os.Args[0], err)
		os.Exit(1)
	}
}

func _main() error {
	widthParam := os.Getenv("GL_RESIZE_IMAGE_WIDTH")
	requestedWidth, err := strconv.Atoi(widthParam)
	if err != nil {
		return fmt.Errorf("GL_RESIZE_IMAGE_WIDTH: %w", err)
	}
	contentType := os.Getenv("GL_RESIZE_IMAGE_CONTENT_TYPE")
	if contentType == "" {
		return fmt.Errorf("GL_RESIZE_IMAGE_CONTENT_TYPE is empty")
	}

	src, extension, err := image.Decode(os.Stdin)
	if err != nil {
		return fmt.Errorf("decode: %w", err)
	}
	if detectedType := mime.TypeByExtension("." + extension); detectedType != contentType {
		return fmt.Errorf("MIME types do not match; requested: %s; actual: %s", contentType, detectedType)
	}
	format, err := imaging.FormatFromExtension(extension)
	if err != nil {
		return fmt.Errorf("find imaging format: %w", err)
	}

	image := imaging.Resize(src, requestedWidth, 0, imaging.Lanczos)
	return imaging.Encode(os.Stdout, image, format)
}
