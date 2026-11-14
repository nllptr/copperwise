# Upstream probe (Phase 0)

This backend-only command captures one authenticated API response at a time as
JSON on stdout. It does not install anything in the game or publish a product
dataset. Market IDs and endpoint schemas remain hypotheses until verified; see
[REPORT.md](REPORT.md). No credentials are written into captures.

Build from the repository root:

```sh
go build -o /private/tmp/copperwise-upstream ./probes/upstream
```

Provide a short-lived backend bearer token as `BLIZZARD_ACCESS_TOKEN` in the
process environment, obtained through your registered Blizzard API application's
OAuth client-credentials flow. Do not paste the token into command arguments or
commit it. The probe makes no authentication calls itself. It refuses redirects
and only sends credentials to `https://eu.api.blizzard.com`. An explicit
`-fixture-base http://127.0.0.1:PORT` uses a local controlled source without auth.

When ready to register, open the [Blizzard Developer Portal](https://develop.battle.net/),
sign in, and use API Access / Clients to register this backend application. Follow
the portal's current [OAuth client-credentials instructions](https://develop.battle.net/documentation/guides/using-oauth)
to obtain a bearer token using the client ID and secret. Exact portal navigation
and Forever access eligibility must be checked at registration time. Store the
secret in a backend-only local secret store; only the short-lived access token
is needed by this probe. Do not put either in an addon or companion export.

Start with discovery, keeping captures in a private temporary directory outside
the repository (shell redirection permissions depend on your environment):

```sh
/private/tmp/copperwise-upstream -path /data/wow/ruleset/index
```

Follow discovered paths manually using `-path`, preserving trailing slashes.
Inspect ruleset detail, auction-house index, house detail and the linked listing
and commodity paths. Never assume an index entry is a listing. Names default to
`en_GB`; namespace defaults to `dynamic-forever-eu`. For item metadata, use
`-namespace static-forever-eu -path /data/wow/item/ITEM_ID`.

`-listings` explicitly interprets the response as a listing snapshot. It requires
an actual `auctions` array; a missing/null field is unknown, not zero supply.
The command emits candidate per-unit prices as exact rational copper values:
`buyout / quantity`, or `unit_price / 1`. This interpretation is not proof of
Forever semantics. Zero/absent buyout is treated as bid-only; its units still
contribute to stock. Full item objects remain attached to each listing so
contexts, bonuses, modifiers and unknown fields are never silently merged.
There is no supported-item classifier or price summary in this probe.

To compare two successful captures from the same endpoint, namespace and mode,
pass the older capture using `-previous /private/tmp/previous.json`. The comparison
uses canonical listing content (order-insensitive), preserving IDs and full
listing fields. Header or retrieval-time changes alone do not create a new
snapshot. A changed hash only establishes changed content, never sales evidence.
Expired captures (30 days from collection) are rejected for comparison. The
operator owns deletion of captures, redirected stdout and backups within the
retention cap; this command does not maintain a cache or implement an expiry job.

Each capture records collection time, response status, selected cache/rate
headers, raw successful JSON, and content hashes. `Last-Modified` is labelled as
an HTTP representation timestamp; source observation time remains unknown until
its meaning is verified. Non-200, invalid JSON, invalid quantities and malformed
listings exit nonzero; failed bodies are not stored as observations. Retry-After
is recorded on errors; there are no automatic retries or polling.

For cadence research, repeat captures manually at a conservative interval (start
with several minutes) over a stated window. Record first changed content and
source timestamps independently. Do not infer an upstream update guarantee from
your sampling interval. Confirm any reported ruleset duplicates and correlate
the selected house with the actual EU RP Alliance client before passing the gate.

Repository checks:

```sh
go vet ./...
go test ./probes/upstream
go test ./...
```
