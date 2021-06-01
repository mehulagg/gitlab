package main

import (
	"archive/tar"
	"bufio"
	"bytes"
	"compress/gzip"
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/gob"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"html/template"
	"io"
	"io/ioutil"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/docker/docker/pkg/namesgenerator"

	"github.com/docker/distribution"

	"github.com/opencontainers/go-digest"

	"github.com/docker/distribution/reference"
	"github.com/docker/distribution/registry/client"
	"github.com/docker/docker/api/types"
	dockerClient "github.com/docker/docker/client"
	"github.com/docker/docker/pkg/archive"
	"github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
)

const (
	layerSize       = 1 << 20 // 1MB
	fileMode        = 0o100644
	numUniqueLayers = 5
	buildGob        = "build.gob"
)

var (
	baseDir string
	stage   int
	delay   time.Duration
)

var rootCmd = &cobra.Command{
	Use:   "online-gc-tester",
	Short: "`online-gc-tester`",
	Long:  "`online-gc-tester`",
	Run:   root,
}

var generateCmd = &cobra.Command{
	Use:   "generate",
	Short: "`generate` generates random layers and Dockerfiles",
	Long:  "`generate` generates random layers and Dockerfiles",
	Run:   generate,
}

var buildCmd = &cobra.Command{
	Use:   "build",
	Short: "`build` builds images from build context",
	Long:  "`build` builds images from build context",
	Run:   build,
}

var pushCmd = &cobra.Command{
	Use:   "push",
	Short: "`push` pushes images to registry",
	Long:  "`push` pushes images to registry",
	Run:   push,
}

var pullCmd = &cobra.Command{
	Use:   "pull",
	Short: "`pull` pulls images from the registry",
	Long:  "`pull` pulls images from the registry",
	Run:   pull,
}

var testCmd = &cobra.Command{
	Use:   "test",
	Short: "`test` tests online gc",
	Long:  "`test` tests online gc",
	Run:   test,
}

func init() {
	generateCmd.Flags().StringVarP(&baseDir, "base-dir", "d", ".", "base directory to place generated artifacts")
	rootCmd.AddCommand(generateCmd)
	buildCmd.Flags().StringVarP(&baseDir, "base-dir", "d", ".", "base directory to source generated artifacts")
	rootCmd.AddCommand(buildCmd)
	pushCmd.Flags().StringVarP(&baseDir, "base-dir", "d", ".", "base directory to source generated artifacts")
	rootCmd.AddCommand(pushCmd)
	pullCmd.Flags().StringVarP(&baseDir, "base-dir", "d", ".", "base directory to source generated artifacts")
	rootCmd.AddCommand(pullCmd)
	testCmd.Flags().StringVarP(&baseDir, "base-dir", "d", ".", "base directory to source generated artifacts")
	testCmd.Flags().IntVarP(&stage, "stage", "s", 0, "test stage")
	testCmd.Flags().DurationVar(&delay, "delay", 0, "the amount of time to wait before each validation")
	rootCmd.AddCommand(testCmd)
}

func root(cmd *cobra.Command, _ []string) {
	if err := cmd.Usage(); err != nil {
		panic(err)
	}
}

type layer struct {
	Path     string
	TarGzSum string
}

type image struct {
	Ref            string
	Tag            string
	TagRef         string
	Dockerfile     string
	Layers         []layer
	ConfigDigest   string
	ManifestDigest string
	SkipPush       bool
}

type buildCtx struct {
	Layers []layer
	Images []*image
}

func generate(_ *cobra.Command, _ []string) {
	randomRepoName := namesgenerator.GetRandomName(-1)

	baseDir, err := filepath.Abs(baseDir)
	if err != nil {
		logrus.WithError(err).Fatal("error expanding base dir path")
	}
	if _, err := os.Stat(baseDir); os.IsNotExist(err) {
		logrus.WithError(err).WithField("path", baseDir).Fatal("base dir does not exist")
	}

	// Docker's build context relies on the current directory, so we need to cd into base dir
	if err := os.Chdir(baseDir); err != nil {
		logrus.WithError(err).Fatal("error changing current working dir")
	}

	// Generate layers
	layerSubDir := "layers"
	if _, err := os.Stat(layerSubDir); os.IsNotExist(err) {
		if err := os.Mkdir(layerSubDir, os.ModePerm); err != nil {
			logrus.WithError(err).WithField("path", layerSubDir).Fatal("error creating layers dir")
		}
	}

	ll, err := generateRandomLayers(layerSubDir, numUniqueLayers, layerSize)
	if err != nil {
		logrus.WithError(err).Fatal("error creating random layers")
	}
	for _, l := range ll {
		logrus.WithFields(logrus.Fields{"path": l.Path, "tar_gz_checksum": l.TarGzSum}).Info("layer generated")
	}

	bCtx := &buildCtx{Layers: ll}

	// online-gc-tester/repo-a:1.0.0 with L1, L2
	layerSet := ll[:2]
	df, err := generateDockerfile(baseDir, layerSet)
	if err != nil {
		logrus.WithError(err).Fatal("error generating Dockerfile")
	}
	logrus.WithField("path", filepath.Base(df)).Info("Dockerfile generated")
	bCtx.Images = append(bCtx.Images, &image{
		Ref:        path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-a"),
		Tag:        "1.0.0",
		TagRef:     path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-a:1.0.0"),
		Dockerfile: df,
		Layers:     layerSet,
	})

	// online-gc-tester/repo-a:pending with L1
	layerSet = []layer{ll[0]}
	df, err = generateDockerfile(baseDir, layerSet)
	if err != nil {
		logrus.WithError(err).Fatal("error generating Dockerfile")
	}
	logrus.WithField("path", filepath.Base(df)).Info("Dockerfile generated")
	bCtx.Images = append(bCtx.Images, &image{
		Ref:        path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-a"),
		Tag:        "pending",
		TagRef:     path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-a:pending"),
		Dockerfile: df,
		Layers:     layerSet,
		SkipPush:   true,
	})

	// online-gc-tester/repo-a:2.0.0 with L1, L2, L3
	layerSet = ll[:3]
	df, err = generateDockerfile(baseDir, layerSet)
	if err != nil {
		logrus.WithError(err).Fatal("error generating Dockerfile")
	}
	logrus.WithField("path", filepath.Base(df)).Info("Dockerfile generated")
	bCtx.Images = append(bCtx.Images, &image{
		Ref:        path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-a"),
		Tag:        "2.0.0",
		TagRef:     path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-a:2.0.0"),
		Dockerfile: df,
		Layers:     layerSet,
	})

	// online-gc-tester/repo-a:latest with L1, L2, L3
	// same as df2
	bCtx.Images = append(bCtx.Images, &image{
		Ref:        path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-a"),
		Tag:        "latest",
		TagRef:     path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-a:latest"),
		Dockerfile: df,
		Layers:     layerSet,
	})

	// online-gc-tester/repo-b:latest with L1, L4, L5
	layerSet = append([]layer{ll[0]}, ll[3:]...)
	df, err = generateDockerfile(baseDir, layerSet)
	if err != nil {
		logrus.WithError(err).Fatal("error generating Dockerfile")
	}
	logrus.WithField("path", filepath.Base(df)).Info("Dockerfile generated")
	bCtx.Images = append(bCtx.Images, &image{
		Ref:        path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-b"),
		Tag:        "latest",
		TagRef:     path.Join(os.Getenv("CI_REGISTRY_IMAGE"), "online-gc-tester", randomRepoName, "repo-b:latest"),
		Dockerfile: df,
		Layers:     layerSet,
	})

	// encode build context
	var buf bytes.Buffer
	enc := gob.NewEncoder(&buf)
	if err := enc.Encode(bCtx); err != nil {
		logrus.WithError(err).Fatal("error encoding build context")
	}
	if err := ioutil.WriteFile(buildGob, buf.Bytes(), fileMode); err != nil {
		logrus.WithError(err).Fatal("error writing build context")
	}
	logrus.WithField("path", buildGob).Info("build context generated")
}

func generateRandomLayers(dir string, n int, size int) ([]layer, error) {
	ll := make([]layer, 0, n)

	for i := 0; i < n; i++ {
		fp, err := randomFile(dir, size)
		if err != nil {
			return nil, err
		}
		sum, err := tarGzChecksum(fp)
		if err != nil {
			return nil, err
		}
		ll = append(ll, layer{
			Path:     fp,
			TarGzSum: sum,
		})
	}

	return ll, nil
}

// randomFile creates a securely generated random file with size size in dir.
func randomFile(dir string, size int) (string, error) {
	f, err := ioutil.TempFile(dir, "")
	if err != nil {
		return "", fmt.Errorf("creating temporary file: %w", err)
	}
	defer f.Close()

	b, err := randomBytes(size)
	if err != nil {
		return "", fmt.Errorf("generating random bytes: %w", err)
	}
	if _, err := f.Write(b); err != nil {
		return "", fmt.Errorf("writing to temporary file: %w", err)
	}

	if err := f.Chmod(fileMode); err != nil {
		return "", err
	}

	return f.Name(), nil
}

// randomBytes returns n securely generated random bytes.
func randomBytes(n int) ([]byte, error) {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		return nil, err
	}

	return b, nil
}

func tarGzChecksum(fp string) (string, error) {
	tmpDir, err := ioutil.TempDir("", "")
	if err != nil {
		return "", err
	}
	defer os.RemoveAll(tmpDir)

	tarPath, err := createTarGzip(fp, tmpDir)
	if err != nil {
		return "", err
	}
	tf, err := os.Open(tarPath)
	if err != nil {
		return "", err
	}
	h := sha256.New()
	if _, err := io.Copy(h, tf); err != nil {
		return "", err
	}
	tarSum := hex.EncodeToString(h.Sum(nil))

	if err := tf.Close(); err != nil {
		return "", err
	}

	return tarSum, nil
}

func build(_ *cobra.Command, _ []string) {
	baseDir, err := filepath.Abs(baseDir)
	if err != nil {
		logrus.WithError(err).Fatal("error expanding base dir path")
	}
	if _, err := os.Stat(baseDir); os.IsNotExist(err) {
		logrus.WithError(err).WithField("path", baseDir).Fatal("base dir does not exist")
	}

	// Docker's build context relies on the current directory, so we need to cd into base dir
	if err := os.Chdir(baseDir); err != nil {
		logrus.WithError(err).Fatal("error changing current working dir")
	}

	if _, err := os.Stat(buildGob); os.IsNotExist(err) {
		logrus.WithError(err).Fatal("build context not found")
	}

	b, err := ioutil.ReadFile(buildGob)
	if err != nil {
		logrus.WithError(err).Fatal("error reading build gob")
	}

	dec := gob.NewDecoder(bytes.NewBuffer(b))

	var bCtx buildCtx
	if err := dec.Decode(&bCtx); err != nil {
		logrus.WithError(err).Fatal("error decoding build gob")
	}

	///////////////////////////////////////////////////////
	c, err := dockerClient.NewClientWithOpts(dockerClient.FromEnv, dockerClient.WithAPIVersionNegotiation())
	if err != nil {
		logrus.WithError(err).Fatal("error building docker client")
	}

	for _, img := range bCtx.Images {
		log := logrus.WithFields(logrus.Fields{"ref": img.TagRef, "dockerfile": filepath.Base(img.Dockerfile)})
		log.Info("building image")

		buildOpts := types.ImageBuildOptions{
			Dockerfile: filepath.Base(img.Dockerfile),
			Tags:       []string{img.TagRef},
			Remove:     true,
		}

		buildContext, err := archive.TarWithOptions(baseDir, &archive.TarOptions{})
		if err != nil {
			logrus.WithError(err).Fatal("error creating tar")
		}
		res, err := c.ImageBuild(context.Background(), buildContext, buildOpts)
		if err != nil {
			logrus.WithError(err).Fatal("error building image")
		}

		b, err := ioutil.ReadAll(res.Body)
		if bytes.Contains(b, []byte(`Successfully built`)) {
			re := regexp.MustCompile(`{"aux":{"ID":"(.*?)"}}`)
			match := re.FindStringSubmatch(string(b))
			img.ConfigDigest = match[1]
			log.WithField("config_digest", img.ConfigDigest).Info("built successfully")
		} else {
			fmt.Print(string(b))
			log.Fatal("failed to build")
		}
	}

	// update build context
	var buf bytes.Buffer
	enc := gob.NewEncoder(&buf)

	if err := enc.Encode(bCtx); err != nil {
		logrus.WithError(err).Fatal("error encoding build context")
	}
	if err := ioutil.WriteFile(buildGob, buf.Bytes(), fileMode); err != nil {
		logrus.WithError(err).Fatal("error writing build context")
	}
	logrus.WithField("path", buildGob).Info("build context updated")
}

func push(_ *cobra.Command, _ []string) {
	baseDir, err := filepath.Abs(baseDir)
	if err != nil {
		logrus.WithError(err).Fatal("error expanding base dir path")
	}
	if _, err := os.Stat(baseDir); os.IsNotExist(err) {
		logrus.WithError(err).WithField("path", baseDir).Fatal("base dir does not exist")
	}

	// Docker's build context relies on the current directory, so we need to cd into base dir
	if err := os.Chdir(baseDir); err != nil {
		logrus.WithError(err).Fatal("error changing current working dir")
	}

	if _, err := os.Stat(buildGob); os.IsNotExist(err) {
		logrus.WithError(err).Fatal("build context not found")
	}

	b, err := ioutil.ReadFile(buildGob)
	if err != nil {
		logrus.WithError(err).Fatal("error reading build gob")
	}

	dec := gob.NewDecoder(bytes.NewBuffer(b))

	var bCtx buildCtx
	if err := dec.Decode(&bCtx); err != nil {
		logrus.WithError(err).Fatal("error decoding build gob")
	}

	var authConfig = types.AuthConfig{
		ServerAddress: os.Getenv("CI_REGISTRY"),
		Username:      os.Getenv("CI_REGISTRY_USER"),
		Password:      os.Getenv("CI_REGISTRY_PASSWORD"),
	}
	authConfigBytes, _ := json.Marshal(authConfig)
	authConfigEncoded := base64.URLEncoding.EncodeToString(authConfigBytes)

	pushOpts := types.ImagePushOptions{RegistryAuth: authConfigEncoded}

	c, err := dockerClient.NewClientWithOpts(dockerClient.FromEnv, dockerClient.WithAPIVersionNegotiation())
	if err != nil {
		logrus.WithError(err).Fatal("error building docker client")
	}

	for _, img := range bCtx.Images {
		log := logrus.WithFields(logrus.Fields{"ref": img.TagRef, "registry": authConfig.ServerAddress})
		if img.SkipPush {
			log.Info("skipping image push")
			continue
		}
		log.Info("pushing image")

		ctx, cancel := context.WithTimeout(context.Background(), time.Second*120)
		defer cancel()

		res, err := c.ImagePush(ctx, img.TagRef, pushOpts)
		if err != nil {
			logrus.WithError(err).Fatal("push error")
		}
		defer res.Close()

		b, err := ioutil.ReadAll(res)
		re := regexp.MustCompile(`"aux":{"Tag":.*,"Digest":"(.*?)",.*}`)
		if re.Match(b) {
			match := re.FindStringSubmatch(string(b))
			img.ManifestDigest = match[1]
			log.WithField("manifest_digest", img.ManifestDigest).Info("pushed successfully")
		} else {
			fmt.Print(string(b))
			log.Fatal("failed to push")
		}
	}

	// update build context
	var buf bytes.Buffer
	enc := gob.NewEncoder(&buf)

	if err := enc.Encode(bCtx); err != nil {
		logrus.WithError(err).Fatal("error encoding build context")
	}
	if err := ioutil.WriteFile(buildGob, buf.Bytes(), fileMode); err != nil {
		logrus.WithError(err).Fatal("error writing build context")
	}
	logrus.WithField("path", buildGob).Info("build context updated")
}

func pull(_ *cobra.Command, _ []string) {
	baseDir, err := filepath.Abs(baseDir)
	if err != nil {
		logrus.WithError(err).Fatal("error expanding base dir path")
	}
	if _, err := os.Stat(baseDir); os.IsNotExist(err) {
		logrus.WithError(err).WithField("path", baseDir).Fatal("base dir does not exist")
	}

	// Docker's build context relies on the current directory, so we need to cd into base dir
	if err := os.Chdir(baseDir); err != nil {
		logrus.WithError(err).Fatal("error changing current working dir")
	}

	if _, err := os.Stat(buildGob); os.IsNotExist(err) {
		logrus.WithError(err).Fatal("build context not found")
	}

	b, err := ioutil.ReadFile(buildGob)
	if err != nil {
		logrus.WithError(err).Fatal("error reading build gob")
	}

	dec := gob.NewDecoder(bytes.NewBuffer(b))

	var bCtx buildCtx
	if err := dec.Decode(&bCtx); err != nil {
		logrus.WithError(err).Fatal("error decoding build gob")
	}

	var authConfig = types.AuthConfig{
		ServerAddress: os.Getenv("CI_REGISTRY"),
		Username:      os.Getenv("CI_REGISTRY_USER"),
		Password:      os.Getenv("CI_REGISTRY_PASSWORD"),
	}
	authConfigBytes, _ := json.Marshal(authConfig)
	authConfigEncoded := base64.URLEncoding.EncodeToString(authConfigBytes)

	pullOpts := types.ImagePullOptions{RegistryAuth: authConfigEncoded}

	c, err := dockerClient.NewClientWithOpts(dockerClient.FromEnv, dockerClient.WithAPIVersionNegotiation())
	if err != nil {
		logrus.WithError(err).Fatal("error building docker client")
	}

	for _, img := range bCtx.Images {
		log := logrus.WithFields(logrus.Fields{"ref": img.TagRef, "registry": authConfig.ServerAddress})
		if img.SkipPush {
			log.Info("skipping image pull")
			continue
		}

		log.Info("pulling image")

		ctx, cancel := context.WithTimeout(context.Background(), time.Second*120)
		defer cancel()

		res, err := c.ImagePull(ctx, img.TagRef, pullOpts)
		if err != nil {
			logrus.WithError(err).Fatal("pull error")
		}
		defer res.Close()

		b, err := ioutil.ReadAll(res)
		re := regexp.MustCompile(`{"status":"Digest: (.*?)"}`)
		if re.Match(b) {
			match := re.FindStringSubmatch(string(b))
			if img.ManifestDigest == match[1] {
				log.WithField("manifest_digest", img.ManifestDigest).Info("pulled successfully")
			} else {
				log.Fatalf("expected digest to be %q, got %q", img.ManifestDigest, match[1])
			}
		} else {
			fmt.Print(string(b))
			log.Fatal("failed to pull")
		}
	}
}

func test(_ *cobra.Command, _ []string) {
	baseDir, err := filepath.Abs(baseDir)
	if err != nil {
		logrus.WithError(err).Fatal("error expanding base dir path")
	}
	if _, err := os.Stat(baseDir); os.IsNotExist(err) {
		logrus.WithError(err).WithField("path", baseDir).Fatal("base dir does not exist")
	}

	// Docker's build context relies on the current directory, so we need to cd into base dir
	if err := os.Chdir(baseDir); err != nil {
		logrus.WithError(err).Fatal("error changing current working dir")
	}

	if _, err := os.Stat(buildGob); os.IsNotExist(err) {
		logrus.WithError(err).Fatal("build context not found")
	}

	b, err := ioutil.ReadFile(buildGob)
	if err != nil {
		logrus.WithError(err).Fatal("error reading build gob")
	}

	dec := gob.NewDecoder(bytes.NewBuffer(b))

	var bCtx buildCtx
	if err := dec.Decode(&bCtx); err != nil {
		logrus.WithError(err).Fatal("error decoding build gob")
	}

	switch stage {
	case 1:
		testStage1(&bCtx)
	case 2:
		testStage2(&bCtx)
	case 3:
		testStage3(&bCtx)
	case 4:
		testStage4(&bCtx)
	case 5:
		testStage5(&bCtx)
	default:
		logrus.Fatal("invalid test stage")
	}
}

// Delete tag `online-gc-tester/repo-a:latest`. This should not cause the deletion of anything, as the underlying
// manifest is still referenced by the `2.0.0` tag.
// The validation should only be done after a given delay (NEEDS FINE TUNING!!).
func testStage1(bCtx *buildCtx) {
	// pick `online-gc-tester/repo-a:latest` image data
	img := bCtx.Images[3]
	repo, _ := reference.WithName(strings.SplitN(img.Ref, "/", 2)[1]) // hack: SplitN is to throw away the host:port part

	// delete tag
	r, err := client.NewRepository(repo, os.Getenv("CI_REGISTRY"), nil)
	if err != nil {
		logrus.WithError(err).Fatal("failed to build repository client")
	}

	ctx := context.Background()
	log := logrus.WithField("ref", img.TagRef)
	tags := r.Tags(ctx)

	if err := tags.Untag(ctx, img.Tag); err != nil {
		log.WithError(err).Fatal("failed to delete tag")
	}
	log.Info("tag deleted")

	// validate
	if delay > 0 {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in")
		time.Sleep(delay)
	} else {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in, press 'Enter' to continue")
		bufio.NewReader(os.Stdin).ReadBytes('\n')
	}

	// check that the manifest that is common to `2.0.0` and `latest` (now deleted) tags is still there
	validateManifestExists(repo, img.ManifestDigest)
	// check that the layers referenced by that manifest are still linked to `online-gc-tester/repo-a`
	for _, l := range img.Layers {
		validateBlobExists(repo, l.TarGzSum)
	}
}

// Delete tag `online-gc-tester/repo-a:2.0.0`. This should cause the deletion of the underlying manifest, as there are
// no tags left for it. It should also cause the deletion of the layer that was exclusively referenced by this manifest.
// The validation should only be done after a given delay (NEEDS FINE TUNING!!).
func testStage2(bCtx *buildCtx) {
	// pick `online-gc-tester/repo-a:2.0.0` image data
	img := bCtx.Images[2]
	repo, _ := reference.WithName(strings.SplitN(img.Ref, "/", 2)[1]) // hack: SplitN is to throw away the host:port part

	// delete tag
	r, err := client.NewRepository(repo, os.Getenv("CI_REGISTRY"), nil)
	if err != nil {
		logrus.WithError(err).Fatal("failed to build repository client")
	}

	ctx := context.Background()
	log := logrus.WithField("ref", img.TagRef)
	tags := r.Tags(ctx)

	if err := tags.Untag(ctx, img.Tag); err != nil {
		log.WithError(err).Fatal("failed to delete tag")
	}
	log.Info("tag deleted")

	// validate
	if delay > 0 {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in")
		time.Sleep(delay)
	} else {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in, press 'Enter' to continue")
		bufio.NewReader(os.Stdin).ReadBytes('\n')
	}

	// check that the underlying manifest was deleted, as both its tags (latest and 2.0.0) were deleted already
	validateManifestDoesNotExist(repo, img.ManifestDigest)
	// check that the layer referenced exclusively by that manifest is gone but the others are still there
	validateBlobExists(repo, img.Layers[0].TarGzSum)
	validateBlobExists(repo, img.Layers[1].TarGzSum)
	validateBlobDoesNotExist(repo, img.Layers[2].TarGzSum)
}

// Delete manifest `online-gc-tester/repo-b:latest`. This should cause the review of its layers and the deletion of the
// ones referenced exclusively by it. The remaining layer in common with `online-gc-tester/repo-a:1.0.0` should remain.
// The validation should only be done after a given delay (NEEDS FINE TUNING!!).
func testStage3(bCtx *buildCtx) {
	// pick `online-gc-tester/repo-b:latest` image data
	img := bCtx.Images[4]
	repo, _ := reference.WithName(strings.SplitN(img.Ref, "/", 2)[1]) // hack: SplitN is to throw away the host:port part

	// delete tag
	r, err := client.NewRepository(repo, os.Getenv("CI_REGISTRY"), nil)
	if err != nil {
		logrus.WithError(err).Fatal("failed to build repository client")
	}

	ctx := context.Background()
	log := logrus.WithField("ref", img.TagRef)
	ms, _ := r.Manifests(ctx)

	if err := ms.Delete(ctx, digest.Digest(img.ManifestDigest)); err != nil {
		log.WithError(err).Fatal("failed to delete manifest")
	}
	log.Info("manifest deleted")

	// validate
	if delay > 0 {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in")
		time.Sleep(delay)
	} else {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in, press 'Enter' to continue")
		bufio.NewReader(os.Stdin).ReadBytes('\n')
	}

	// check that the underlying manifest was deleted, as both its tags (latest and 2.0.0) were deleted already
	validateManifestDoesNotExist(repo, img.ManifestDigest)
	// check that the layers referenced exclusively by that manifest is gone but the other are still there
	validateBlobExists(repo, img.Layers[0].TarGzSum)
	validateBlobDoesNotExist(repo, img.Layers[1].TarGzSum)
	validateBlobDoesNotExist(repo, img.Layers[2].TarGzSum)
}

// Switch `online-gc-tester/repo-a:1.0.0` (M1) tag to `online-gc-tester/repo-a:pending` (M4). This should cause the review of the
// M1, which should be deleted as it has no other tags. L1 and L2 should be reviewed, but only L2 should be deleted.
// The validation should only be done after a given delay (NEEDS FINE TUNING!!).
func testStage4(bCtx *buildCtx) {
	// pick `online-gc-tester/repo-a:pending` image data
	src := bCtx.Images[1]
	// pick `online-gc-tester/repo-a:1.0.0` image data
	dst := bCtx.Images[0]

	// re-tag
	src.Tag = dst.Tag
	src.TagRef = dst.TagRef

	log := logrus.WithFields(logrus.Fields{"ref": src.TagRef, "dockerfile": filepath.Base(src.Dockerfile)})
	log.Info("building image")

	buildOpts := types.ImageBuildOptions{
		Dockerfile: filepath.Base(src.Dockerfile),
		Tags:       []string{src.TagRef},
		Remove:     true,
	}

	buildContext, err := archive.TarWithOptions(baseDir, &archive.TarOptions{})
	if err != nil {
		logrus.WithError(err).Fatal("error creating tar")
	}

	c, err := dockerClient.NewClientWithOpts(dockerClient.FromEnv, dockerClient.WithAPIVersionNegotiation())
	if err != nil {
		logrus.WithError(err).Fatal("error building docker client")
	}
	res, err := c.ImageBuild(context.Background(), buildContext, buildOpts)
	if err != nil {
		logrus.WithError(err).Fatal("error building image")
	}

	b, err := ioutil.ReadAll(res.Body)
	if bytes.Contains(b, []byte(`Successfully built`)) {
		re := regexp.MustCompile(`{"aux":{"ID":"(.*?)"}}`)
		match := re.FindStringSubmatch(string(b))
		src.ConfigDigest = match[1]
		log.WithField("config_digest", src.ConfigDigest).Info("built successfully")
	} else {
		fmt.Print(string(b))
		log.Fatal("failed to build")
	}

	var authConfig = types.AuthConfig{
		ServerAddress: os.Getenv("CI_REGISTRY"),
		Username:      os.Getenv("CI_REGISTRY_USER"),
		Password:      os.Getenv("CI_REGISTRY_PASSWORD"),
	}
	authConfigBytes, _ := json.Marshal(authConfig)
	authConfigEncoded := base64.URLEncoding.EncodeToString(authConfigBytes)

	pushOpts := types.ImagePushOptions{RegistryAuth: authConfigEncoded}

	log.Info("pushing image")

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*120)
	defer cancel()

	rd, err := c.ImagePush(ctx, src.TagRef, pushOpts)
	if err != nil {
		logrus.WithError(err).Fatal("push error")
	}
	defer rd.Close()

	b, err = ioutil.ReadAll(rd)
	re := regexp.MustCompile(`"aux":{"Tag":.*,"Digest":"(.*?)",.*}`)
	if re.Match(b) {
		match := re.FindStringSubmatch(string(b))
		src.ManifestDigest = match[1]
		log.WithField("manifest_digest", src.ManifestDigest).Info("pushed successfully")
	} else {
		fmt.Print(string(b))
		log.Fatal("failed to push")
	}

	// validate
	if delay > 0 {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in")
		time.Sleep(delay)
	} else {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in, press 'Enter' to continue")
		bufio.NewReader(os.Stdin).ReadBytes('\n')
	}

	repo, _ := reference.WithName(strings.SplitN(dst.Ref, "/", 2)[1]) // hack: SplitN is to throw away the host:port part

	// check that the manifest that 1.0.0 was pointing to before this was deleted, as there were no tags for it
	validateManifestDoesNotExist(repo, dst.ManifestDigest)
	// check that the layers referenced exclusively by that manifest is gone but the other are still there
	validateBlobExists(repo, dst.Layers[0].TarGzSum)
	validateBlobDoesNotExist(repo, dst.Layers[1].TarGzSum)

	// update build context (just for persisting the pending manifest digest
	var buf bytes.Buffer
	enc := gob.NewEncoder(&buf)

	if err := enc.Encode(bCtx); err != nil {
		logrus.WithError(err).Fatal("error encoding build context")
	}
	if err := ioutil.WriteFile(buildGob, buf.Bytes(), fileMode); err != nil {
		logrus.WithError(err).Fatal("error writing build context")
	}
	logrus.WithField("path", buildGob).Info("build context updated")
}

// Delete tag `online-gc-tester/repo-a:1.0.0`. This should cause the review of the manifest, which will be dangling, as
// will the layers.
// The validation should only be done after a given delay (NEEDS FINE TUNING!!).
func testStage5(bCtx *buildCtx) {
	// pick `online-gc-tester/repo-a:pending` image data
	img := bCtx.Images[1]                                             // we should look for the `pending` manifest and its layers, as those are what are now referenced by this tag
	repo, _ := reference.WithName(strings.SplitN(img.Ref, "/", 2)[1]) // hack: SplitN is to throw away the host:port part

	// delete tag
	r, err := client.NewRepository(repo, os.Getenv("CI_REGISTRY"), nil)
	if err != nil {
		logrus.WithError(err).Fatal("failed to build repository client")
	}

	ctx := context.Background()
	log := logrus.WithField("ref", bCtx.Images[0].TagRef)
	tags := r.Tags(ctx)

	if err := tags.Untag(ctx, bCtx.Images[0].Tag); err != nil {
		log.WithError(err).Fatal("failed to delete tag")
	}
	log.Info("tag deleted")

	// validate
	if delay > 0 {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in")
		time.Sleep(delay)
	} else {
		log.WithField("delay", delay).Info("sleeping before validation to allow time for GC to kick in, press 'Enter' to continue")
		bufio.NewReader(os.Stdin).ReadBytes('\n')
	}

	// check that the underlying manifest was deleted, as both its tags (latest and 2.0.0) were deleted already
	validateManifestDoesNotExist(repo, img.ManifestDigest)
	// check that the layer referenced by that manifest are gone
	for _, l := range img.Layers {
		validateBlobDoesNotExist(repo, l.TarGzSum)
	}
}

func manifestExists(repo reference.Named, dgst string) bool {
	r, err := client.NewRepository(repo, os.Getenv("CI_REGISTRY"), nil)
	if err != nil {
		logrus.WithError(err).Fatal("failed to build repository client")
	}

	ctx := context.Background()
	ms, _ := r.Manifests(ctx)

	log := logrus.WithFields(logrus.Fields{"repo": repo, "digest": dgst})

	ok, err := ms.Exists(ctx, digest.Digest(dgst))
	if err != nil {
		log.WithError(err).Fatal("failed to check manifest")
	}
	return ok
}

func validateManifestExists(repo reference.Named, dgst string) {
	log := logrus.WithFields(logrus.Fields{"repo": repo, "digest": dgst})
	if !manifestExists(repo, dgst) {
		log.Fatal("manifest does not exist")
	}
	log.Info("manifest found")
}

func validateManifestDoesNotExist(repo reference.Named, dgst string) {
	log := logrus.WithFields(logrus.Fields{"repo": repo, "digest": dgst})
	if manifestExists(repo, dgst) {
		log.Fatal("manifest exists")
	}
	log.Info("manifest not found")
}

func blobExists(repo reference.Named, dgst string) bool {
	r, err := client.NewRepository(repo, os.Getenv("CI_REGISTRY"), nil)
	if err != nil {
		logrus.WithError(err).Fatal("failed to build repository client")
	}

	ctx := context.Background()
	bs := r.Blobs(ctx)

	log := logrus.WithFields(logrus.Fields{"repo": repo, "digest": dgst})

	if _, err = bs.Stat(ctx, digest.Digest("sha256:"+dgst)); err != nil {
		if errors.Is(err, distribution.ErrBlobUnknown) {
			return false
		}
		log.WithError(err).Fatal("failed to check blob")
	}
	return true
}

func validateBlobExists(repo reference.Named, dgst string) {
	log := logrus.WithFields(logrus.Fields{"repo": repo, "digest": dgst})
	if !blobExists(repo, dgst) {
		log.Fatal("blob does not exist")
	}
	log.Info("blob found")
}

func validateBlobDoesNotExist(repo reference.Named, dgst string) {
	log := logrus.WithFields(logrus.Fields{"repo": repo, "digest": dgst})
	if blobExists(repo, dgst) {
		log.Fatal("blob found")
	}
	log.Info("blob does not exist")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		panic(err)
	}
}

func generateDockerfile(dir string, layers []layer) (string, error) {
	tmpl := "FROM scratch{{range .}}\nADD {{.Path}} /{{end}}"
	t := template.Must(template.New("").Parse(tmpl))
	b := bytes.NewBuffer(make([]byte, 0))

	if err := t.Execute(b, layers); err != nil {
		return "", err
	}

	f, err := ioutil.TempFile(dir, "Dockerfile.*")
	if err != nil {
		return "", err
	}
	defer f.Close()

	if _, err := f.WriteString(b.String()); err != nil {
		return "", err
	}

	return f.Name(), nil
}

func createTarGzip(fp string, dir string) (string, error) {
	out, err := os.Create(filepath.Join(dir, filepath.Base(fp)) + ".tar.gz")
	if err != nil {
		return "", err
	}
	defer out.Close()

	// chain tar and gzip writers
	gw := gzip.NewWriter(out)
	defer gw.Close()
	tw := tar.NewWriter(gw)
	defer tw.Close()

	if err := addToTar(tw, fp); err != nil {
		return "", err
	}

	return out.Name(), nil
}

func addToTar(tw *tar.Writer, fp string) error {
	f, err := os.Open(fp)
	if err != nil {
		return err
	}
	defer f.Close()

	info, err := f.Stat()
	if err != nil {
		return err
	}

	h := &tar.Header{
		Typeflag: tar.TypeReg,
		Name:     info.Name(),
		Size:     info.Size(),
		Mode:     0o100644,
		ModTime:  info.ModTime().Truncate(time.Second),
		Format:   tar.FormatUSTAR,
	}
	if err := tw.WriteHeader(h); err != nil {
		return err
	}
	if _, err := io.Copy(tw, f); err != nil {
		return err
	}

	return nil
}

func readTarGzip(fp string) error {
	f, err := os.Open(fp)
	if err != nil {
		return err
	}
	defer f.Close()

	gr, err := gzip.NewReader(f)
	if err != nil {
		return err
	}
	tr := tar.NewReader(gr)
	for true {
		header, err := tr.Next()
		if err == io.EOF {
			break
		}
		fmt.Println(header)
	}
	return nil
}
