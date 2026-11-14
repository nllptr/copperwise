# Target-client capability probe (ticket 03)

This standalone addon uses **synthetic data only**. It needs no backend,
companion, API credentials, Auctionator, or delivery-probe addon. It establishes
no market mapping or production price rules. Runtime acceptance is pending until
the checks below are exercised in the actual Forever client.

## Install

With WoW closed, copy the addon into the Forever AddOns directory:

```sh
cp -R probes/client/addons/CopperwiseClientProbe '/Applications/World of Warcraft/_forever_/Interface/AddOns/'
```

Enable **Copperwise Client Probe** in the AddOns list and log in. The TOC targets
interface 16001, matching locally installed Forever addon manifests; this is
not evidence of the running client build. No game settings, existing keybindings,
or other addons are changed automatically.

## In-client acceptance

Record each result and any error in [REPORT.md](REPORT.md). A successful load or
API-presence diagnostic alone does not pass a capability.

1. Record the login `client=... build=... interface=... platform=...` chat line.
   Record actual macOS version and architecture separately with `sw_vers` and
   `uname -m` (no account names/paths). Acceptance targets macOS 26 Intel. The
   addon cannot reliably establish OS version or CPU architecture itself.
2. Go somewhere away from the auction house. Run `/cwclient`. Expect a movable
   sample-history window with two aligned graphs, five shared hourly positions,
   and readable local time labels plus timezone. The upper graph is synthetic
   median asking price and middle-50% spread bounds; the lower is listed units.
   Verify the first/last timestamps and point positions align across both graphs.
   Confirm the timezone and displayed times match your computer. Record scale,
   resolution and readability; source inspection cannot establish usability.
3. Enter `Peacebloom` and press Enter (or click **Find sample**). Expect sample
   item 2447 and both graphs to redraw. Enter `Copper Ore`: expect sample 2770
   with different values. Partial aliases and item IDs also work. Localized names
   are included once the client has cached them; use **Find sample** again after
   `GET_ITEM_INFO_RECEIVED`. Only these two sample items have histories. A missing
   match must say so and hide the previous graphs. English aliases always work;
   Lua case folding is not a complete Unicode search implementation.
4. In the game's Key Bindings interface, find **Copperwise Client Probe**. Assign
   an unused key to **Toggle sample history window**, save/apply using the game's
   controls, and close settings. Verify open/close away from the auction house,
   and persistence after a user-initiated `/reload`. Record the key and outcome.
   The addon never calls SetBinding/SaveBindings and never chooses keys for you.
5. Hover a real Peacebloom or Copper Ore item (bag, chat link, or other ordinary
   item tooltip). Expect a clearly labelled synthetic Copperwise addition with
   sample median, spread, stock, and sample age. Check both ordinary GameTooltip
   and a clicked chat-link ItemRefTooltip, repeated hovers, tooltip rebuilds and
   comparisons. There should be one addition, no growing duplicates, and no
   change to the game's item text. Other items get no fabricated history.
6. Assign another unused key to **Open hovered sample item**. While a supported
   GameTooltip is visibly showing, press it: the selected sample history should
   open. Without an item tooltip or for another item, expect an explanatory chat
   message and no invented selection. It reads only the currently visible
   GameTooltip; it is not a general mouse-focus or clickable-tooltip claim.
7. Check existing interactions with the probe enabled: normal bag clicks,
   Shift-click linking into chat, Ctrl-click dressing-room preview on a suitable
   equipment item, and existing auction/addon shortcuts where applicable.
   Optionally Alt-click an item and inspect `/cwclient status`: a secure post-hook
   records that HandleModifiedItemClick was observed, but does not open a window,
   replace its return value, or consume the gesture. No Alt-click shortcut is
   promised by the probe. Record which paths actually invoke that hook and
   whether original behavior remains intact. Repeat key checks in combat; report
   blocked actions, taint warnings and errors rather than bypassing protections.
8. `/cwclient status` prints build, API/hook diagnostics and recent action results.
   `/cwclient note <short outcome>` records your manual observations, e.g.
   `/cwclient note PASS graph alignment and local times`. Notes are operator
   evidence, not automatic pass declarations. Avoid character/account names or
   other personal data. Log out to persist SavedVariables.

Evidence is stored in `CopperwiseClientEvidence` under the account's
`SavedVariables/CopperwiseClientProbe.lua`: at most five sessions and 120 bounded
events each. It records build identifiers and sample IDs, not character names or
real auction data. Copy only relevant entries into the report, never account
paths or unrelated SavedVariables. Disable the probe after the acceptance run.

## Repository checks and limits

Use a Lua 5.1-compatible parser to compile both Lua files without executing them
(LuaJIT `loadfile` is sufficient), and parse `Bindings.xml` as XML. The existing
Go checks remain `go vet ./...` and `go test ./...`. There is no TypeScript or other
statically typed addon code. Parser checks and Go tests cannot validate frame APIs,
graph appearance, keybinding dispatch, tooltip readability or interaction safety.

The graph path requires `CreateLine`; missing/failing APIs are reported while
keeping the window/status command available. Tooltip setup prefers the item
post-call processor and otherwise tries a supported legacy OnTooltipSetItem
hook. Missing capabilities and runtime failures are recorded explicitly. The
probe uses ordinary addon APIs and user-triggered bindings; it does not reload
the UI, intercept item clicks, or alter protected game behavior.
