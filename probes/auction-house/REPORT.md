# M18 native scan evidence

Status: runtime acceptance pending — probe implemented, no target-client query
result has been supplied or observed yet.

## Repository and research evidence

- Standalone `CopperwiseAuctionProbe`, interface loading target 16001, with
  native display-mode tab and bounded user-triggered sample searches.
- Modern API path supported by Forever UI source; installed Auctionator 346
  ships modern and legacy code. Running-client availability remains unverified.
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
switching remain pending another actual-client check.

Continue the [acceptance checklist](README.md#actual-client-acceptance-pre-agreed-test-seam).
Record game build, market context, enabled addons, sample IDs, actions, raw
results, coverage and outcomes. Do not copy account paths or unrelated saves.

## Unverified paths

All target-client paths remain unverified: native tab creation, query dispatch,
matching event delivery, commodity versus item rows, stack normalization,
bid-only stock, full/empty/partial results, More, cooldowns, cancellation,
timeouts/errors, late responses, bounds and Auctionator coexistence.
No M18 runtime acceptance is claimed by repository checks or installation.
