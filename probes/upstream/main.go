// Command upstream is a backend-only Phase 0 evidence probe, not a product API.
package main

import (
	"crypto/sha256"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"math"
	"net"
	"net/http"
	"net/url"
	"os"
	"sort"
	"strings"
	"time"
)

type price struct {
	Numerator   int64 `json:"numerator"`
	Denominator int64 `json:"denominator"`
}
type listing struct {
	ID        int64           `json:"id"`
	Item      json.RawMessage `json:"item"`
	Quantity  int64           `json:"quantity"`
	UnitPrice *price          `json:"unitPrice"`
}
type capture struct {
	URL              string            `json:"url"`
	Namespace        string            `json:"namespace"`
	ListingMode      bool              `json:"listingMode"`
	CollectedAt      time.Time         `json:"collectedAt"`
	Status           int               `json:"status"`
	Headers          map[string]string `json:"headers"`
	SourceObservedAt *time.Time        `json:"sourceObservedAt"`
	Raw              json.RawMessage   `json:"raw,omitempty"`
	SHA256           string            `json:"sha256,omitempty"`
	Unchanged        *bool             `json:"unchanged,omitempty"`
	Stock            int64             `json:"stock"`
	Listings         []listing         `json:"listings,omitempty"`
	Error            string            `json:"error,omitempty"`
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run() error {
	path := flag.String("path", "/data/wow/ruleset/index", "discovered /data/wow/ path (no query)")
	namespace := flag.String("namespace", "dynamic-forever-eu", "API namespace")
	fixture := flag.String("fixture-base", "", "loopback HTTP fixture source; never sends credentials")
	listings := flag.Bool("listings", false, "require a listing array and emit candidate unit prices")
	previous := flag.String("previous", "", "previous successful capture from the same endpoint")
	flag.Parse()
	if flag.NArg() != 0 {
		return errors.New("unexpected positional arguments")
	}
	p, err := url.Parse(*path)
	if err != nil || p.IsAbs() || p.Host != "" || p.RawQuery != "" || p.Fragment != "" || !strings.HasPrefix(p.Path, "/data/wow/") {
		return errors.New("path must be a /data/wow/ path without query or fragment")
	}
	base := "https://eu.api.blizzard.com"
	token := ""
	if *fixture != "" {
		u, err := url.Parse(*fixture)
		if err != nil || u.Scheme != "http" || u.User != nil || u.RawQuery != "" || u.Fragment != "" || (u.Path != "" && u.Path != "/") {
			return errors.New("fixture base must be a loopback HTTP origin")
		}
		ip := net.ParseIP(u.Hostname())
		if ip == nil || !ip.IsLoopback() {
			return errors.New("fixture base must use a loopback IP")
		}
		base = strings.TrimSuffix(*fixture, "/")
	} else {
		token = os.Getenv("BLIZZARD_ACCESS_TOKEN")
		if token == "" {
			return errors.New("set backend-only BLIZZARD_ACCESS_TOKEN; no live request made")
		}
	}
	u, _ := url.Parse(base + p.EscapedPath())
	q := u.Query()
	q.Set("namespace", *namespace)
	q.Set("locale", "en_GB")
	u.RawQuery = q.Encode()
	req, err := http.NewRequest(http.MethodGet, u.String(), nil)
	if err != nil {
		return errors.New("invalid request")
	}
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	client := &http.Client{Timeout: 30 * time.Second, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	resp, err := client.Do(req)
	if err != nil {
		return errors.New("request failed (transport error; no observation)")
	}
	defer resp.Body.Close()
	c := capture{URL: u.String(), Namespace: *namespace, ListingMode: *listings, CollectedAt: time.Now().UTC(), Status: resp.StatusCode, Headers: map[string]string{}}
	for _, k := range []string{"Date", "Age", "Last-Modified", "ETag", "Cache-Control", "Expires", "Retry-After", "X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset"} {
		if v := resp.Header.Get(k); v != "" {
			c.Headers[k] = v
		}
	}
	failure := func(message string) error {
		c.Raw = nil
		c.SHA256 = ""
		c.Listings = nil
		c.Stock = 0
		c.Error = message
		_ = json.NewEncoder(os.Stdout).Encode(c)
		return errors.New(message)
	}
	if resp.StatusCode != http.StatusOK {
		return failure(fmt.Sprintf("HTTP %d; no observation", resp.StatusCode))
	}
	const maxBody = 32 << 20
	body, err := io.ReadAll(io.LimitReader(resp.Body, maxBody+1))
	if err != nil || len(body) > maxBody {
		return failure("unreadable or oversized response; no observation")
	}
	// Decode numbers without float rounding and reject non-object responses/trailing JSON.
	var object map[string]json.RawMessage
	if err := json.Unmarshal(body, &object); err != nil || object == nil {
		return failure("expected JSON object; no observation")
	}
	canonical, _ := json.Marshal(object)
	if *listings {
		var rows []json.RawMessage
		raw, ok := object["auctions"]
		if !ok || json.Unmarshal(raw, &rows) != nil || rows == nil {
			return failure("missing or invalid auctions array; empty market not established")
		}
		seen := map[int64]bool{}
		parts := make([]string, 0, len(rows))
		for _, row := range rows {
			var a struct {
				ID        int64           `json:"id"`
				Item      json.RawMessage `json:"item"`
				Quantity  int64           `json:"quantity"`
				Buyout    *int64          `json:"buyout"`
				Bid       *int64          `json:"bid"`
				UnitPrice *int64          `json:"unit_price"`
			}
			if json.Unmarshal(row, &a) != nil || a.ID <= 0 || a.Quantity <= 0 || seen[a.ID] {
				return failure("invalid or duplicate listing; no observation")
			}
			seen[a.ID] = true
			var item map[string]json.RawMessage
			var itemID int64
			if json.Unmarshal(a.Item, &item) != nil || json.Unmarshal(item["id"], &itemID) != nil || itemID <= 0 {
				return failure("invalid item identity; no observation")
			}
			if (a.Buyout != nil && *a.Buyout < 0) || (a.UnitPrice != nil && *a.UnitPrice <= 0) || (a.UnitPrice != nil && a.Buyout != nil) {
				return failure("invalid or ambiguous price; no observation")
			}
			if a.Bid != nil && *a.Bid < 0 {
				return failure("invalid bid; no observation")
			}
			if a.UnitPrice == nil && (a.Buyout == nil || *a.Buyout == 0) && (a.Bid == nil || *a.Bid == 0) {
				return failure("missing asking price or bid; no observation")
			}
			var unit *price
			if a.UnitPrice != nil {
				unit = &price{*a.UnitPrice, 1}
			} else if a.Buyout != nil && *a.Buyout > 0 {
				unit = &price{*a.Buyout, a.Quantity}
			}
			if c.Stock > math.MaxInt64-a.Quantity {
				return failure("stock overflow; no observation")
			}
			c.Stock += a.Quantity
			c.Listings = append(c.Listings, listing{a.ID, a.Item, a.Quantity, unit})
			// Recursively canonicalize objects while preserving exact JSON numbers.
			var value any
			dec := json.NewDecoder(strings.NewReader(string(row)))
			dec.UseNumber()
			_ = dec.Decode(&value)
			normalized, _ := json.Marshal(value)
			parts = append(parts, string(normalized))
		}
		sort.Strings(parts)
		canonical, _ = json.Marshal(parts)
	}
	c.Raw = body
	c.SHA256 = fmt.Sprintf("%x", sha256.Sum256(canonical))
	if *previous != "" {
		data, err := os.ReadFile(*previous)
		var old capture
		if err != nil || json.Unmarshal(data, &old) != nil || old.Status != 200 || old.Error != "" || old.SHA256 == "" || old.URL != c.URL || old.Namespace != c.Namespace || old.ListingMode != c.ListingMode || old.CollectedAt.IsZero() || time.Since(old.CollectedAt) > 30*24*time.Hour || old.CollectedAt.After(c.CollectedAt) {
			return failure("previous capture is incompatible, expired or invalid")
		}
		equal := old.SHA256 == c.SHA256
		c.Unchanged = &equal
	}
	return json.NewEncoder(os.Stdout).Encode(c)
}
