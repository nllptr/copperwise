# Ticket 01 evidence

## Current outcome

**Revised login/reload probe implemented; actual in-client acceptance pending.**
The owner explicitly replaced continuous in-session imports with login and
user-initiated `/reload` imports. The previous repeated-load experiment was not
accepted in-client and is not evidence for the revised gate. Dependent full
implementation remains gated.

## Observed local environment

Platform and installed client rechecked on 2026-11-14:

- macOS 26.6.2, build 25G83, x86_64.
- Installed `.build.info`: active EU `wowf`, version 1.60.1.70938.
- Installed Auctionator: version 346, TOC includes interface 16001.
- Go: go1.26.5 darwin/amd64.

The probe uses interface 16001 as an initial candidate. Record `GetBuildInfo()`
from the running client below; installed files do not establish runtime acceptance.

## Implementation and observable state

The companion writes a numeric payload into an ordinary, enabled data addon.
The probe requires that addon as a dependency, captures the already loaded data
at `PLAYER_LOGIN`, and records the actual client build and import time. There
are no load-on-demand calls, file polling, automatic reloads, client modifications,
network interception, or input automation. `/cwprobe` reports the captured snapshot
and its current source age; it neither rereads files nor imports data.

The companion records source observation time, download completion, and export
write start separately. These timestamps can coincide at one-second resolution.
The addon records local import time separately. Payload timestamps are companion
claims, not independent verification. These fixtures contain no market listings.
The addon cannot observe newer exports, backend failures, or current companion
connectivity. It reports connection and newer-export state as unknown. Successful
companion exports do not claim addon receipt.

[TSM's own refresh documentation](https://support.tradeskillmaster.com/en_US/addon/why-does-my-addon-keep-telling-me-no-recent-auctiondb-scan-data-found)
describes using `/reload` to populate newer desktop pricing data. This informs the
chosen workflow; it establishes neither target-client runtime compatibility nor
Blizzard approval of Copperwise.

## Runtime evidence to complete

Follow the README's login, unchanged, reload, unchanged, reload sequence:

| Observation | Actual result |
| --- | --- |
| Running client version / build / interface | Pending |
| Platform build / architecture for acceptance run | Pending |
| Login: revision A and source / download / export / import times | Pending |
| Newer companion export while A remains loaded (`/cwprobe`) | Pending |
| First user `/reload`: revision B, newer than A | Pending |
| Newer companion export while B remains loaded (`/cwprobe`) | Pending |
| Second user `/reload`: revision C, newer than B | Pending |
| Optional companion-stop behavior | Pending |
| Errors / limitations | Pending |
| Gate verdict | Pending actual observations |

## Repository verification

- Timestamp check failed against the old export, then passed after separate
  download and export fields were added.
- Targeted CLI integration test and full `go test ./... -count=1` passed with
  permission to open the local loopback HTTP listener.
- `go build`, `go vet ./...`, LuaJIT bytecode compilation (syntax check only),
  and `git diff --check` passed.
- Independent code-review standards axis: zero findings.
- Independent code-review spec axis: zero actionable deviations; actual
  target-client acceptance remains pending.

The CLI integration test covers only backend publication, caching, export contents,
and separate timestamps. Syntax checks and review are not game-client acceptance.

## If the revised import gate fails

First distinguish installation/export errors from a client capability failure;
record actual errors and builds. Do not attempt to bypass restrictions or restore
repeated load-on-demand polling. A companion-only viewer or more restrictive
restart-based imports would change the agreed experience and require the owner's
explicit decision. Report evidence before proceeding to dependent implementation.
