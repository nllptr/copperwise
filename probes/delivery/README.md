# Login and reload delivery probe

The backend publishes synthetic revisions, the companion caches and exports them,
then WoW loads the exported dataset through ordinary addon loading at login or
user-initiated `/reload`. The addon never polls files or calls `LoadAddOn` or
`ReloadUI`. `/cwprobe` only reports the snapshot already loaded into memory.
This is a capability probe, not market data or a production delivery contract.

## Build and install

From the repository root:

```sh
go build -o /private/tmp/copperwise-delivery ./probes/delivery
```

Fully quit WoW before updating the probe: the earlier version used load-on-demand
metadata. Copy both addon directories into the Forever AddOns folder:

```sh
cp -R probes/delivery/addons/CopperwiseDeliveryProbe probes/delivery/addons/CopperwiseDeliveryData '/Applications/World of Warcraft/_forever_/Interface/AddOns/'
```

Only these two experimental addons are installed. The data addon now loads
normally, and the probe declares it as a required dependency. Enable both in the
AddOns list. Do not use the previous repeated-load probe for this acceptance run.

## Start the real backend and companion

In one terminal:

```sh
/private/tmp/copperwise-delivery backend
```

In another terminal:

```sh
/private/tmp/copperwise-delivery companion -out '/Applications/World of Warcraft/_forever_/Interface/AddOns'
```

The synthetic backend advances its revision every 15 seconds; the companion polls
every two seconds. Keep both processes running throughout the test. Wait for a
successful companion export before logging in. Exports replace
`CopperwiseDeliveryData/Data.lua` atomically; `cache.json` is also stored in the
output directory. Cache and export writes are individually atomic, not one transaction.
Source observation, download, and export timestamps are separate fields; export
time means the start of the successful export write, not an addon acknowledgment.
A successful export log never claims that WoW has imported it.

## In-client acceptance (about two minutes)

1. Launch Forever and log into a character with both probe addons enabled.
   Record the `client=... build=... interface=...` line and the initial
   `LOADED revision=...` line. Call that revision A. If the probe reports `NO DATA`
   or a dependency/load error, stop and check installation/export setup.
2. Wait at least 20 seconds and confirm the companion logs a revision newer
   than A. Type `/cwprobe`. It must still show A and the same `importedAt`, with
   increased `sourceAgeSeconds`. It must not claim knowledge of newer exports.
3. Type `/reload` yourself. Record the new `LOADED` line (revision B). B must be
   newer than A. It should match a recent successful export; another export may
   happen during loading, so do not require it to equal the terminal's newest
   line printed after the import.
4. Wait another 20 seconds and confirm exports newer than B. Type `/cwprobe`
   again: it must still show B and its original import time.
5. Type `/reload` again. Record revision C, newer than B. These are multiple
   explicit import boundaries, not automatic updates within one addon lifetime.
6. Optional: stop the companion, then type `/cwprobe`. The loaded revision stays
   available and connection state remains `UNKNOWN`. Reloading can still load
   the last successful export; it does not imply that the companion is alive.
7. Log out after recording observations to persist SavedVariables. The probe
   stores five addon lifetimes (login or reload), at most 300 events each, in
   `_forever_/WTF/Account/<account>/SavedVariables/CopperwiseDeliveryProbe.lua`.
   No character/account names are captured by the probe. Do not commit account
   paths or unrelated SavedVariables. Report the build, A/B/C lines, unchanged
   checks, and any errors; copy those observations into the evidence report.
8. Stop both terminal processes with Ctrl-C and disable the probe addons.

A pass requires actual in-client observations of login, two newer revisions after
explicit reloads, and unchanged revisions between those imports on macOS Intel.
File exports, tests, or a Lua harness cannot substitute for this evidence.
Dependent full implementation remains gated until the revised gate passes or the
owner explicitly chooses an evidenced alternative. Technical success does not
constitute Blizzard approval or a guarantee about account enforcement.

## Controlled fixtures and repository verification

`backend -fixture /path/to/upstream.json` serves a controlled snapshot:

```json
{"revision":1,"observedAt":1700000000}
```

Replace that file with successive revisions to control publication. `companion
-once` performs one download/export and exits nonzero on failure. Regular mode
retries; invalid/failed downloads leave the prior files in place. CLI flags are
probe-only and define no product API.

```sh
go test ./probes/delivery
go vet ./...
go test ./...
```

The CLI integration test checks three controlled revisions through the real HTTP
backend, companion cache, and Lua export, including separate download/export
metadata. It does not establish client import behavior or runtime API compatibility.
