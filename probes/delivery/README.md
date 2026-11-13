# Automatic delivery capability probe

This isolated experiment tests repeated `LoadAddOn` calls against a companion-written
load-on-demand addon. It is **not an established transport**. A successful file
export or `LoadAddOn` return value is not proof of a new import. Only distinct
`VISIBLE revision=` lines in the same addon session count.

## Run on macOS Intel

From the repository root:

```sh
go build -o /private/tmp/copperwise-delivery ./probes/delivery
```

Fully quit WoW. Copy both directories under `probes/delivery/addons/` into
`/Applications/World of Warcraft/_forever_/Interface/AddOns/`. These are separate,
uniquely named experimental addons. Keep other addons unchanged.

Start the synthetic backend in one terminal:

```sh
/private/tmp/copperwise-delivery backend
```

Start the companion in a second terminal, pointing exports at the installed addons:

```sh
/private/tmp/copperwise-delivery companion -out '/Applications/World of Warcraft/_forever_/Interface/AddOns'
```

The backend creates a synthetic revision every 15 seconds. This is test data,
not market history. The companion polls every two seconds, keeps `cache.json`
in its output directory, and atomically replaces `CopperwiseDeliveryData/Data.lua`.
It never claims the addon received an export. Failures retain previously written
files; cache and export are individually atomic, not one transaction.

1. Launch Forever, enable **Copperwise Delivery Probe** and **Copperwise Delivery
   Data Probe** in AddOns, and log into a character. No chat with other players is needed.
2. Watch `Copperwise probe:` chat lines for three minutes. Every five seconds the
   addon attempts to load the same data addon and reports the visible revision.
3. Keep the companion running and confirm it exports at least three distinct
   revisions while the addon is running. Do not reload, relog, or restart WoW.
4. Record the client/build/interface line, the first visible revision, any later
   visible revisions, and the final attempts. A repeated `loaded=true` with an
   unchanged revision does **not** pass. Any load error makes the experiment
   inconclusive until setup/API compatibility is checked.
5. Optionally stop the companion after observing revisions. The addon should
   continue reporting only what it can observe, never a live connection claim.
6. Log out **after** the observation window to persist evidence in
   `_forever_/WTF/Account/<account>/SavedVariables/CopperwiseDeliveryProbe.lua`.
   Do not commit account paths or unrelated SavedVariables. The addon keeps five
   sessions, at most 300 messages per session. Each login/reload starts a new
   evidence session; do not combine revisions across sessions.
7. Stop terminal processes with Ctrl-C. Disable the two probe addons after testing.

Pass requires the second and subsequent distinct payloads becoming visible without
reload, plus verification that the mechanism is supported for the target client.
Failure of this candidate is not evidence that every possible transport fails.
Do not proceed to dependent full implementation while the overall gate is unresolved.

## Controlled fixtures and verification

`backend -fixture /path/to/upstream.json` serves a controlled synthetic snapshot:

```json
{"revision":1,"observedAt":1700000000}
```

Replace that file with successive revisions to control publication. `companion
-once` performs one download/export and exits with a nonzero status on failure.
The regular mode keeps retrying. CLI flags are probe-only and define no product API.

```sh
go test ./probes/delivery
go vet ./...
go test ./...
```

The command integration test exercises three fixture revisions through the real
HTTP backend, companion cache, and Lua export. It does not emulate WoW or assert
that generated Lua is imported by a running client.
