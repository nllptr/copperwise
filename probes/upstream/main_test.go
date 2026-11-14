package main_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
)

func TestListingCapture(t *testing.T) {
	binary := filepath.Join(t.TempDir(), "upstream")
	if out, err := exec.Command("go", "build", "-o", binary, ".").CombinedOutput(); err != nil {
		t.Fatalf("build: %s: %v", out, err)
	}
	source := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/data/wow/test" || r.URL.Query().Get("namespace") != "dynamic-forever-eu" || r.Header.Get("Authorization") != "" {
			t.Errorf("unexpected request: %s", r.URL)
		}
		w.Header().Set("Last-Modified", "Sat, 14 Nov 2026 10:00:00 GMT")
		_, _ = w.Write([]byte(`{"auctions":[{"id":1,"item":{"id":2447},"quantity":3,"buyout":100},{"id":2,"item":{"id":2447,"context":2},"quantity":7,"bid":20},{"id":3,"item":{"id":2447},"quantity":4,"unit_price":25}]}`))
	}))
	defer source.Close()
	out, err := exec.Command(binary, "-fixture-base", source.URL, "-path", "/data/wow/test", "-listings").CombinedOutput()
	if err != nil {
		t.Fatalf("capture: %s: %v", out, err)
	}
	var got struct {
		Stock    int64
		Listings []struct {
			UnitPrice *struct{ Numerator, Denominator int64 }
			Item      map[string]any
		}
		SourceObservedAt *string
		Headers          map[string]string
	}
	if err := json.Unmarshal(out, &got); err != nil {
		t.Fatal(err)
	}
	if got.Stock != 14 || len(got.Listings) != 3 {
		t.Fatalf("stock/listings: %s", out)
	}
	if got.Listings[0].UnitPrice.Numerator != 100 || got.Listings[0].UnitPrice.Denominator != 3 || got.Listings[1].UnitPrice != nil || got.Listings[2].UnitPrice.Numerator != 25 || got.Listings[2].UnitPrice.Denominator != 1 {
		t.Fatalf("prices: %s", out)
	}
	if got.Listings[1].Item["context"] != float64(2) || got.SourceObservedAt != nil || got.Headers["Last-Modified"] == "" {
		t.Fatalf("identity/times: %s", out)
	}
}

func TestSnapshotEvidence(t *testing.T) {
	binary := filepath.Join(t.TempDir(), "upstream")
	if out, err := exec.Command("go", "build", "-o", binary, ".").CombinedOutput(); err != nil {
		t.Fatalf("build: %s: %v", out, err)
	}
	body := `{"auctions":[{"id":1,"item":{"id":2447},"quantity":2,"buyout":30},{"id":2,"item":{"id":2447},"quantity":1,"bid":5}]}`
	status := 200
	source := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Retry-After", "300")
		w.WriteHeader(status)
		_, _ = w.Write([]byte(body))
	}))
	defer source.Close()
	run := func(previous string) (map[string]any, []byte, error) {
		args := []string{"-fixture-base", source.URL, "-path", "/data/wow/test", "-listings"}
		if previous != "" {
			args = append(args, "-previous", previous)
		}
		command := exec.Command(binary, args...)
		out, err := command.Output()
		var got map[string]any
		if e := json.Unmarshal(out, &got); e != nil {
			t.Fatalf("JSON: %s: %v", out, e)
		}
		return got, out, err
	}
	_, first, err := run("")
	if err != nil {
		t.Fatal(err)
	}
	previous := filepath.Join(t.TempDir(), "previous.json")
	if err := os.WriteFile(previous, first, 0600); err != nil {
		t.Fatal(err)
	}
	body = `{"auctions":[{"quantity":1,"bid":5,"item":{"id":2447},"id":2},{"buyout":30,"quantity":2,"item":{"id":2447},"id":1}]}`
	got, _, err := run(previous)
	if err != nil || got["unchanged"] != true {
		t.Fatalf("reordered snapshot: %v %v", got, err)
	}
	body = `{"auctions":[{"id":1,"item":{"id":2447},"quantity":2,"buyout":31}]}`
	got, _, err = run(previous)
	if err != nil || got["unchanged"] != false {
		t.Fatalf("changed snapshot: %v %v", got, err)
	}
	for _, tc := range []struct {
		name, body string
		status     int
		ok         bool
	}{
		{"empty", `{"auctions":[]}`, 200, true},
		{"missing", `{}`, 200, false},
		{"null", `{"auctions":null}`, 200, false},
		{"failed", `{"auctions":[]}`, 503, false},
		{"invalid JSON", `{`, 200, false},
		{"invalid quantity", `{"auctions":[{"id":1,"item":{"id":2447},"quantity":0,"buyout":10}]}`, 200, false},
		{"missing prices", `{"auctions":[{"id":1,"item":{"id":2447},"quantity":2,"buyout":30},{"id":2,"item":{"id":2447},"quantity":1}]}`, 200, false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			body = tc.body
			status = tc.status
			got, _, err := run("")
			if (err == nil) != tc.ok {
				t.Fatalf("result: %v %v", got, err)
			}
			if tc.ok {
				if got["stock"] != float64(0) {
					t.Fatal(got)
				}
			} else if got["error"] == nil || got["sha256"] != nil || got["listings"] != nil || got["raw"] != nil {
				t.Fatalf("failure masquerades as observation: %v", got)
			}
		})
	}
}
