# Upstream feasibility evidence

Ticket 02 is **pending live verification**, not passed. No authenticated Blizzard
responses or measured cadence have been collected yet. Controlled fixtures cannot
establish the target market, actual stack semantics, or source cadence.

## Research, 2026-11-14

- Official API entry point: https://develop.battle.net/documentation/world-of-warcraft/game-data-apis
  redirects to the Community Developer Portal. Its JavaScript documentation was
  not readable through the research tool; no Forever endpoint contract was
  verified from it.
- OAuth entry point: https://develop.battle.net/documentation/guides/using-oauth
  also redirects; the research tool could not retrieve its contents. The probe
  accepts an operator-supplied bearer token through the backend environment.
  Obtain it using a registered backend application's client-credentials flow;
  keep both the client secret and access token out of client distributions.
- Legal source: https://www.blizzard.com/en-us/legal/a2989b50-5f16-43b1-abec-2ae17cc09dd6/blizzard-developer-api-terms-of-use
  Search-indexed official text specifies a maximum 30-day TTL for API data and
  36,000 calls/hour, subject to Blizzard changing limits. Direct retrieval returned
  403. Recheck the full current terms before deployment. Apply the retention cap
  conservatively to raw responses and derived history; no aggregate exemption
  has been established. A refreshed download of an old snapshot must not reset
  the lifetime of historical observations. Credentials must remain confidential.

## Discovery hypotheses, not verified identifiers

A firsthand third-party report on Blizzard's forum describes
`dynamic-forever-eu`, `/data/wow/ruleset/index`, ruleset 3 for Roleplay,
`/data/wow/ruleset/{id}/auctions/` (including its trailing slash), house detail,
and per-house commodities. It also reports duplicate listings across rulesets
and multiple Alliance houses. These are research leads, **not evidence that any
one house is the owner's EU RP Alliance market**. Never select a house solely
from those guessed numeric IDs or merge houses/rulesets indiscriminately.

Source: https://us.forums.blizzard.com/en/blizzard/t/wow-forever-api-what-works-so-far-plus-a-ts-client/60334
(posts dated November 5–6, 2026). This is a community observation, not an official
API contract. Independently verify with authenticated discovery and target-client
comparison. It is not used as authority for normalization semantics.

## Evidence still required

1. Authenticated ruleset index, selected ruleset detail, auction-house index and
   candidate house details. Record exact paths, namespaces, IDs and names. Compare
   candidate house listing identities across rulesets and houses. Correlate a
   distinctive ordinary trade-good listing with the target client; if filtering
   cannot be established, fail the market gate and report the ambiguity.
2. Selected ordinary trade-good item metadata and raw listing samples, including
   partial stacks, bid-only, variants and commodity responses where applicable.
   Establish whether `buyout` is a stack total and `unit_price` is per unit before
   accepting the probe's candidate normalization. Do not merge variant identities.
3. Successful explicit empty lists versus HTTP errors, malformed responses and
   missing listing fields. Missing fields alone do not prove an empty market.
4. Repeated captures of the same endpoint across actual source changes. Record
   Last-Modified, ETag, Date, Age, Retry-After and collection time separately.
   Last-Modified is an HTTP representation timestamp, not automatically the time
   each listing was observed. Absence of source time remains unknown. Changes in
   retrieval time or headers alone must not create a new market observation.
5. Measured update intervals over a stated observation window, unchanged responses,
   endpoint-specific cache/rate headers and applicable limits. Do not provoke
   throttling to discover quotas. No fixed freshness threshold is established.
6. Review current complete terms, record retrieval date and any stricter storage
   obligations. Keep captures outside the repository and delete within the cap.

## Verdict

Market mapping, live quantity/price semantics, source-time semantics and cadence
remain unverified. Ticket 04 remains blocked on this ticket; Phase 0 has not passed.
