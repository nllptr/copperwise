# Ticket 01 evidence

## Current outcome

**Pending in-client observation. No supported automatic transport demonstrated.**
Dependent full implementation must remain gated. Runnable backend, companion,
and addon probes are provided; runtime acceptance is incomplete.

## Observed local environment (2026-11-13)

- `sw_vers`: macOS 26.6.2, build 25G83.
- `uname -m`: x86_64.
- Installed `.build.info`: active EU `wowf`, version 1.60.1.70938.
- Installed Auctionator: version 346, TOC includes interface 16001.
- Probe TOC uses 16001 as an initial candidate. `GetBuildInfo()` from the running
  client must confirm the actual build and interface; installed files alone do not.
- Go: go1.26.5 darwin/amd64.

## Candidate and evidence limits

The companion writes numeric payloads into a load-on-demand addon. The main addon
attempts `C_AddOns.LoadAddOn` (or legacy `LoadAddOn`) every five seconds for three
minutes, recording visible revisions and import times. This tests whether the same
addon can reread a changed file in-session; it does not preallocate a finite bank
of one-shot data addons or accept login-only imports.

[Blizzard-generated API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/AddOnsDocumentation.lua)
lists addon loading APIs, but this live-branch reference is not target-build runtime
evidence. Installed Auctionator initializes an addon-message prefix; that only
establishes source usage, not external desktop access to the messaging transport.

[TSM's own troubleshooting](https://support.tradeskillmaster.com/en_US/addon/why-does-my-addon-keep-telling-me-no-recent-auctiondb-scan-data-found)
recommends a reload to populate newer desktop pricing. This is evidence against
using TSM desktop imports as proof of the required automatic behavior, not proof
that all target-client mechanisms are impossible.

The addon can report payload contents, local import time, load return values and
new visible revisions. It cannot infer current backend health, successful exports,
or a live companion connection from a previously loaded payload. Observation and
download timestamps are payload claims; these fixtures contain no actual listings.

## Runtime evidence to complete

- Running client version/build/interface:
- Companion revisions exported during one session:
- Distinct revisions visibly imported in that same session:
- Load return values/errors:
- Behavior after companion stops:
- Supported transport verdict and justification:

## Repository verification

- Real CLI integration test passed: three controlled upstream revisions reached
  the HTTP backend, companion cache, and Lua export. Local loopback permission
  was required; sandboxed execution could not bind the HTTP listener.
- `go build`, `go vet ./...`, and the full `go test ./...` suite passed.
- Independent standards review: no findings. Independent spec review: no code
  deviations; running-client acceptance remains pending.

## Alternatives if this candidate fails

- A companion-only history viewer can use ordinary HTTP and local caching, but
  changes the required in-game experience and needs an explicit owner decision.
- Reload-based addon imports are a conventional candidate, but are explicitly
  rejected by the current spec and require an explicit scope decision.
- Continue research for a documented, target-client-supported ingress. Addon chat
  messages require an in-game sender; the desktop cannot be assumed to be one.

No alternative is selected here. A failed candidate should be reported with its
recorded runtime evidence before any dependent full implementation proceeds.
