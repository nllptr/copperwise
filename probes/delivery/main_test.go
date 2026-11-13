package main_test

import (
	"encoding/json"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// This checks the runnable probe's public boundary, not game-client behavior.
func TestBackendRevisionsReachCompanionExport(t *testing.T) {
	dir := t.TempDir()
	binary := filepath.Join(dir, "delivery")
	if output, err := exec.Command("go", "build", "-o", binary, ".").CombinedOutput(); err != nil {
		t.Fatalf("build: %s: %v", output, err)
	}
	fixture := filepath.Join(dir, "upstream.json")
	backend := exec.Command(binary, "backend", "-listen", "127.0.0.1:0", "-fixture", fixture)
	stdout, err := backend.StdoutPipe()
	if err != nil {
		t.Fatal(err)
	}
	if err := backend.Start(); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = backend.Process.Kill(); _ = backend.Wait() })
	var address struct{ URL string }
	if err := json.NewDecoder(stdout).Decode(&address); err != nil {
		t.Fatal(err)
	}
	for _, revision := range []string{"1", "2", "3"} {
		if err := os.WriteFile(fixture, []byte(`{"revision":`+revision+`,"observedAt":1700000000}`), 0600); err != nil {
			t.Fatal(err)
		}
		command := exec.Command(binary, "companion", "-url", address.URL, "-out", dir, "-once")
		if output, err := command.CombinedOutput(); err != nil {
			t.Fatalf("companion: %s: %v", output, err)
		}
		cache, err := os.ReadFile(filepath.Join(dir, "cache.json"))
		if err != nil {
			t.Fatal(err)
		}
		var data struct {
			Revision int `json:"revision"`
		}
		if err := json.Unmarshal(cache, &data); err != nil {
			t.Fatal(err)
		}
		if string(rune('0'+data.Revision)) != revision {
			t.Fatalf("cache: %s", cache)
		}
		exported, err := os.ReadFile(filepath.Join(dir, "CopperwiseDeliveryData", "Data.lua"))
		if err != nil {
			t.Fatal(err)
		}
		if !strings.Contains(string(exported), "revision = "+revision+",") {
			t.Fatalf("export: %s", exported)
		}
	}
}
