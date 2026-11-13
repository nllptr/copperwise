// Command delivery is an isolated feasibility probe, not a production transport.
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"time"
)

type dataset struct {
	Revision   int64 `json:"revision"`
	ObservedAt int64 `json:"observedAt"`
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("usage: delivery backend|companion [flags]")
	}
	var err error
	switch os.Args[1] {
	case "backend":
		err = backend(os.Args[2:])
	case "companion":
		err = companion(os.Args[2:])
	default:
		err = fmt.Errorf("unknown command %q", os.Args[1])
	}
	if err != nil {
		log.Fatal(err)
	}
}

func backend(args []string) error {
	flags := flag.NewFlagSet("backend", flag.ContinueOnError)
	address := flags.String("listen", "127.0.0.1:8765", "HTTP listen address")
	fixture := flags.String("fixture", "", "optional controlled upstream JSON file; otherwise synthetic revisions every 15s")
	if err := flags.Parse(args); err != nil {
		return err
	}
	started := time.Now()
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/dataset" || r.Method != http.MethodGet {
			http.NotFound(w, r)
			return
		}
		data := dataset{Revision: int64(time.Since(started)/(15*time.Second)) + 1, ObservedAt: started.Unix()}
		data.ObservedAt += (data.Revision - 1) * 15
		if *fixture != "" {
			bytes, err := os.ReadFile(*fixture)
			if err != nil {
				http.Error(w, "fixture unavailable", 503)
				return
			}
			if err := json.Unmarshal(bytes, &data); err != nil {
				http.Error(w, "invalid fixture", 503)
				return
			}
		}
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Cache-Control", "no-store")
		_ = json.NewEncoder(w).Encode(data)
	})
	listener, err := net.Listen("tcp", *address)
	if err != nil {
		return err
	}
	if err := json.NewEncoder(os.Stdout).Encode(map[string]string{"URL": "http://" + listener.Addr().String() + "/dataset"}); err != nil {
		_ = listener.Close()
		return err
	}
	server := &http.Server{Handler: handler, ReadHeaderTimeout: 5 * time.Second}
	return server.Serve(listener)
}

func companion(args []string) error {
	flags := flag.NewFlagSet("companion", flag.ContinueOnError)
	url := flags.String("url", "http://127.0.0.1:8765/dataset", "probe backend dataset URL")
	out := flags.String("out", ".scratch/delivery-run", "cache and addon staging directory")
	interval := flags.Duration("interval", 2*time.Second, "poll interval")
	once := flags.Bool("once", false, "fetch and export once")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if *interval <= 0 {
		return fmt.Errorf("interval must be positive")
	}
	client := &http.Client{Timeout: 5 * time.Second}
	for {
		err := download(client, *url, *out)
		if *once {
			return err
		}
		if err != nil {
			log.Printf("download/export failed; prior files retained: %v", err)
		}
		time.Sleep(*interval)
	}
}

func download(client *http.Client, url, out string) error {
	response, err := client.Get(url)
	if err != nil {
		return err
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("backend HTTP %d", response.StatusCode)
	}
	var data dataset
	if err := json.NewDecoder(http.MaxBytesReader(nil, response.Body, 4096)).Decode(&data); err != nil {
		return err
	}
	// Integers only: downloaded bytes are never interpolated as executable code.
	if data.Revision <= 0 || data.ObservedAt <= 0 {
		return fmt.Errorf("invalid revision or source timestamp")
	}
	downloadedAt := time.Now().Unix()
	cache, err := json.Marshal(data)
	if err != nil {
		return err
	}
	if err := atomicWrite(filepath.Join(out, "cache.json"), cache); err != nil {
		return err
	}
	exportedAt := time.Now().Unix()
	lua := fmt.Sprintf("CopperwiseDeliveryPayload = { revision = %d, observedAt = %d, downloadedAt = %d, exportedAt = %d }\n", data.Revision, data.ObservedAt, downloadedAt, exportedAt)
	if err := atomicWrite(filepath.Join(out, "CopperwiseDeliveryData", "Data.lua"), []byte(lua)); err != nil {
		return err
	}
	log.Printf("exported revision=%d observedAt=%d downloadedAt=%d exportedAt=%d; addon receipt UNKNOWN; import requires login or /reload", data.Revision, data.ObservedAt, downloadedAt, exportedAt)
	return nil
}

func atomicWrite(path string, data []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		return err
	}
	file, err := os.CreateTemp(filepath.Dir(path), ".delivery-*")
	if err != nil {
		return err
	}
	defer os.Remove(file.Name())
	if _, err := file.Write(data); err != nil {
		_ = file.Close()
		return err
	}
	if err := file.Close(); err != nil {
		return err
	}
	return os.Rename(file.Name(), path)
}
