package main

import (
	"./internal/errorpage"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestIfErrorPageIsPresented(t *testing.T) {
	dir, err := ioutil.TempDir("", "error_page")
	if err != nil {
		t.Fatal(err)
	}
	defer os.RemoveAll(dir)

	errorPage := "ERROR"
	ioutil.WriteFile(filepath.Join(dir, "404.html"), []byte(errorPage), 0600)

	w := httptest.NewRecorder()
	h := http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(404)
		fmt.Fprint(w, "Not Found")
	})
	errorpage.Inject(dir, h)(w, nil)
	w.Flush()

	assertResponseCode(t, w, 404)
	assertResponseBody(t, w, errorPage)
}

func TestIfErrorPassedIfNoErrorPageIsFound(t *testing.T) {
	dir, err := ioutil.TempDir("", "error_page")
	if err != nil {
		t.Fatal(err)
	}
	defer os.RemoveAll(dir)

	w := httptest.NewRecorder()
	errorResponse := "ERROR"
	h := http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(404)
		fmt.Fprint(w, errorResponse)
	})
	errorpage.Inject(dir, h)(w, nil)
	w.Flush()

	assertResponseCode(t, w, 404)
	assertResponseBody(t, w, errorResponse)
}
