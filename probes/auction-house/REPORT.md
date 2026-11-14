# M18 native scan evidence

Status: partial runtime evidence — native tab, full Peacebloom/Copper Ore queries
and build/context recorded; remaining acceptance checks pending.

## Repository and research evidence

- Standalone `CopperwiseAuctionProbe`, interface loading target 16001, with
  native display-mode tab and bounded user-triggered sample searches.
- Modern API path supported by Forever UI source; installed Auctionator 346
  ships modern and legacy code. Owner scan output now demonstrates the modern
  query/event/completeness path for one sample.
- Samples: Peacebloom 2447, Copper Ore 2770, Rough Stone 2835. Per-unit buyout,
  covered units, bid-only units, local receipt time and completeness are shown.
- Limits: three requests per observation, 500 processed rows/update, 15-second
  response timeout, two-second quiet-start guard. No transactions or full scan.
- Source inspection establishes intended behavior only. It does not establish
  quantity semantics, result completeness, tab usability or safe coexistence.

## Local platform

Development host: macOS 26.6.2, build 25G83, x86_64 (from `sw_vers`, `uname -m`).
This is not a measurement of the running game's build or runtime behavior.

## Repository validation

2026-11-14: LuaJIT `loadfile` syntax compilation passed; `env CGO_ENABLED=1 go
vet ./...` and `env CGO_ENABLED=0 go test ./...` passed for the existing Go probes.
Installed the standalone addon into the local Forever AddOns folder for operator
testing. No actual-client acceptance follows from these checks or installation.

## Runtime observations

Owner screenshot confirms the Copperwise panel opens inside the native auction
window with Auctionator enabled, with sample selection and scan controls visible.
It shows no scan result, so query/quantity/completeness acceptance remains pending.
Owner reports addon tabs belong beside Buy/Sell/Auctions at the bottom: the probe
incorrectly anchored above the window and Auctionator's row followed it rightward.
Native Classic tab XML establishes `parentArray="Tabs"`; LibAHTab anchors its
row to the last native tab. Corrected Copperwise to follow `AuctionsTab` with
native spacing and registered its index/display mode. Corrected layout and tab
switching were subsequently demonstrated by the owner's screenshots below.

### Owner screenshots: bottom tabs and Peacebloom scan

- Bottom-row placement verified. Owner reports an initial selected-tab texture
  showing behind the unselected Copperwise tab while Buy is selected. Selecting
  Copperwise and then another tab clears it. Added explicit initial
  `PanelTemplates_DeselectTab`; the fix still requires a reload/reopen check.
- Selected Copperwise and subsequently selected Buy screenshots demonstrate
  the expected selected/unselected appearances after interaction. This is tab
  switching evidence, not exhaustive coexistence acceptance.
- Peacebloom, item 2447: state **complete**, one of three allowed requests,
  23 covered rows, 2,439 covered units, lowest covered buyout **38 copper/unit**,
  bid-only units 0, full selected-key results true.
- Start and result observation both display **2026-11-14 22:38:03 CET**.
  These are receipt/start timestamps, not evidence of source publication time or
  measured subsecond latency.
- This demonstrates visible query results and full-result state for one sample.
  The screenshots do not supply the game build, market diagnostics, commodity
  classification, raw listing fields or independent native quantity/price
  comparison. Zero bid-only units does not exercise bid-only handling.

2026-11-14: Owner independently checked the displayed Peacebloom price and
confirmed it is correct (38 copper/unit). This verifies the observed sample's
price result, not an independent stock count or every normalization path.
A further screenshot at 22:40:37 CET shows complete Peacebloom results with
23 rows, 2,457 units and the same 38 copper/unit minimum. Clicking More after
completion sent no request and preserved that observation, but produced an
unhelpful refusal. Disabled More except for partial results within the local
request cap, and clarified the request counter as a probe cap. Retest pending.

Continue the [acceptance checklist](README.md#actual-client-acceptance-pre-agreed-test-seam).
Record game build, market context, enabled addons, sample IDs, actions, raw
results, coverage and outcomes. Do not copy account paths or unrelated saves.

### Saved probe evidence inspected during follow-up

Read only the dedicated `CopperwiseAuctionProbe.lua` evidence, excluding account
paths and unrelated saves. It records client **1.60.1/build 70938/interface
16001/macOS**, Auctionator loaded, realm **CAMWOW EU5 Realm 10 RP**, faction
**Alliance**, region **3**. This is native context, not verified upstream mapping.

Both sample keys record `commodity=true`, suffix/pet zero; the generated keys
report item levels 5 (Peacebloom) and 10 (Copper Ore). The tested path is commodity
unit-price aggregation, not noncommodity stack-total division or bid-only rows.

| Item | Observation epoch | Rows | Covered units | Minimum copper/unit | Full | Result elapsed |
| --- | ---: | ---: | ---: | ---: | --- | ---: |
| Peacebloom 2447 | 1794692437 | 23 | 2,457 | 38 | true | 0.19s |
| Copper Ore 2770 | 1794692840 | 33 | 5,396 | 88 | true | 0.15s |

Each used one `SendSearchQuery`. Copper Ore raw rows include 739 units at 88c,
174 at 89c, 438 at 90c, 601 at 100c and 97 at 104c. These are the first five
rows only, not the whole stock export. The recorded elapsed values are samples,
not a latency guarantee. Independent stock comparison remains outstanding;
only Peacebloom's price has owner confirmation.

## Unverified paths

Owner cancellation-macro screenshot: Peacebloom 2447, started 2026-11-14
23:00:20 CET, state cancelled after one request, no observed result timestamp,
rows/stock/price unavailable, full=false. This verifies immediate local
cancellation without inventing an empty result. Persistence after the late
response and successful scan after close/reopen still await owner confirmation.

2026-11-14 owner screenshot after the updated one-click Rough Stone instructions:
item 2835, state complete, one request, 16 covered rows, 1,615 covered units,
minimum 9 copper/unit, bid-only units 0, full=true. Start and observation both
display 22:57:25 CET. More results is visibly disabled after completion.
This verifies another full sample result and the completed-state button fix.
The screenshot does not establish whether metadata was initially uncached or
whether loading continuation was exercised. Owner subsequently confirms this
scan completed with one click and no errors, and the native AH shows the same
price and stock: 9 copper/unit and 1,615 units. Rough Stone price and covered
stock comparison therefore pass for this observation.

Owner subsequently reports Copper Ore initially refused due to uncached metadata,
then returned a good result on another click a few seconds later. Saved probe
evidence subsequently supplies quantities/price/raw fields as recorded above;
independent Copper Ore comparison remains outstanding.
This establishes a metadata-loading usability issue and an owner-reported
successful second-sample query, not a verified second-sample price/stock result.

Implementation follow-up: added bounded cancellable metadata loading with one
search dispatched after metadata becomes ready, rather than requiring another
click. Metadata timeout is explicitly not-sent and does not require AH reopening;
only uncertain outstanding searches require reopening. `/cwah status` now repeats
game build/market context and result classification for operator evidence.
These changes still need actual-client testing; no mocked runtime is substituted.

Remaining unverified paths: initial-highlight fix, new metadata continuation,
independent stock/Copper Ore price comparison, noncommodity stack normalization,
bid-only stock, empty/partial results, More on partial results, cooldowns, cancellation,
timeouts/errors, late responses, bounds and Auctionator coexistence.
No M18 runtime acceptance is claimed by repository checks or installation.
