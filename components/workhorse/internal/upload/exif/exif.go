package exif

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"os/exec"
	"regexp"

	"gitlab.com/gitlab-org/labkit/log"
)

var ErrRemovingExif = errors.New("error while removing EXIF")

type cleaner struct {
	ctx      context.Context
	cmd      *exec.Cmd
	stdout   io.Reader
	stderr   bytes.Buffer
	waitDone chan struct{}
	waitErr  error
}

func NewCleaner(ctx context.Context, stdin io.Reader) (io.Reader, error) {
	c := &cleaner{
		ctx:      ctx,
		waitDone: make(chan struct{}),
	}

	if err := c.startProcessing(stdin); err != nil {
		return nil, err
	}

	return c, nil
}

func (c *cleaner) Read(p []byte) (int, error) {
	n, err := c.stdout.Read(p)
	if err == io.EOF {
		if waitErr := c.wait(); waitErr != nil {
			log.WithContextFields(c.ctx, log.Fields{
				"command": c.cmd.Args,
				"stderr":  c.stderr.String(),
				"error":   waitErr.Error(),
			}).Print("exiftool command failed")
			return n, ErrRemovingExif
		}
	}

	return n, err
}

func (c *cleaner) startProcessing(stdin io.Reader) error {
	var err error

	whitelisted_tags := []string{
		"-ResolutionUnit",
		"-XResolution",
		"-YResolution",
		"-YCbCrSubSampling",
		"-YCbCrPositioning",
		"-BitsPerSample",
		"-ImageHeight",
		"-ImageWidth",
		"-ImageSize",
		"-Copyright",
		"-CopyrightNotice",
		"-Orientation",
	}

	args := append([]string{"-all=", "--IPTC:all", "--XMP-iptcExt:all", "-tagsFromFile", "@"}, whitelisted_tags...)
	args = append(args, "-")
	c.cmd = exec.CommandContext(c.ctx, "exiftool", args...)

	c.cmd.Stderr = &c.stderr
	c.cmd.Stdin = stdin

	c.stdout, err = c.cmd.StdoutPipe()
	if err != nil {
		return fmt.Errorf("failed to create stdout pipe: %v", err)
	}

	if err = c.cmd.Start(); err != nil {
		return fmt.Errorf("start %v: %v", c.cmd.Args, err)
	}
	go func() {
		c.waitErr = c.cmd.Wait()
		close(c.waitDone)
	}()

	return nil
}

func (c *cleaner) wait() error {
	<-c.waitDone
	return c.waitErr
}

func IsExifFile(filename string) bool {
	filenameMatch := regexp.MustCompile(`(?i)\.(jpg|jpeg|tiff)$`)

	return filenameMatch.MatchString(filename)
}
