# Native posting probe (S08)

Standalone investigation for the Forever modern auction house. Direct posting
from Copperwise was blocked by the client. Native manual Sell succeeded for the
same sample/terms with the probe disabled. The current probe investigates a
**preparation-only handoff to native Sell**; it never calls transaction APIs or
clicks a native button. One commodity handoff and posting is verified in the actual client. See
[REPORT.md](REPORT.md) for evidence and remaining limitations.

## Install and prepare

```sh
cp -R probes/posting/addons/CopperwisePostingProbe '/Applications/World of Warcraft/_forever_/Interface/AddOns/'
```

Enable Copperwise Posting Probe, reload and visit an auctioneer. Disable the
scanning probe for the first run; let other AH addons finish their work.
Run `/cwpost` to open the CW posting tab. No login/slash-command action posts.

Use `/cwpost prepare <bag> <slot> <quantity> <price copper> <duration>`.
Bags are 0–4; slots start at 1. Native duration indices 1/2/3 mean 2/8/24 hours,
as observed on client 1.60.1/build 70938. For example,
`/cwpost prepare 0 1 1 15 2` previews one unit in backpack slot 1 at 15 copper
for 8 hours. Use an operator-selected item and terms, not this example blindly.

The preview shows item link, selected stack count, quantity, unit/total buyout,
duration and native calculated deposit. Deposits use the client calculation,
not a hardcoded formula. Inventory/lock/money/tab changes discard the preview.
Quantity may not exceed the selected stack. Commodity handoff is supported for
investigation; noncommodity handoff refuses. No cross-stack or batch policy,
automatic pricing, purchase or cancellation of existing auctions is implemented.

**Cancel preview** discards the Copperwise preparation. **Review native Sell**
revalidates the item/count/deposit, transfers the item to the visible native Sell
surface, populates quantity/price/duration, and reads them back. It sends no post
request. This consumes one handoff allowance for that AH visit, even on an error.
Close/reopen AH for another deliberate handoff after inspecting current native
state. Cancel preview cannot clear an already transferred native Sell item;
clear that in native Sell yourself. No event or timer submits anything.

After handoff, review **all native fields and deposit again**, allowing startup
search results to settle. Native selection/search can change the displayed price;
readback immediately after handoff is not a guarantee of later unchanged terms.
Only your click on Blizzard's native **Post** button posts. Do not invoke the
button from a macro/script or via Copperwise. Native confirmation dialogs remain
entirely under native control. Inspect native Auctions afterwards; a click,
API return or shared event is never counted as confirmed success.

Do not transact with another addon while preparing. There are no hooks on
restricted posting functions or claims of exclusive transaction ownership.
`/cwpost status` repeats build/context/state; `/cwpost note <observation>` records
a short operator note. Evidence is bounded to five sessions, 200 lines/session,
900 characters/line. Chat output is deferred to OnUpdate outside synchronous
native event stacks. Log out to persist SavedVariables; omit personal data in notes.

## Actual-client checklist (agreed public UI/API seam)

1. Capture version/build/interface, OS/architecture, realm/faction/region and
   enabled AH addons. Verify away-from-AH refusal, tab/native navigation and scale.
2. Prepare a chosen commodity and cancel. Confirm disabled handoff button,
   unchanged bag quantity and no listing. Exercise empty/invalid slot and moving
   the selected item: refusal/invalidation, no automatic action.
3. Prepare, compare native duration/deposit, then click Review native Sell.
   Confirm the native item/quantity/price/duration/deposit. Start with a different
   native duration to verify the dropdown label updates. **Stop here on the
   first revised run** and record whether the handoff fields are correct.
4. With the operator's deliberate transaction terms reviewed in native Sell,
   use native Post once. Compare the actual owned listing and bag decrement.
   Record auction ID if visible. A native control run without Copperwise does
   not establish this integrated handoff. A listing is not a completed sale.
5. Confirm a second handoff cannot be initiated that visit and AH lifecycle
   changes never submit. Record errors/blocked actions as failures, not success.
   Check native browsing and Auctionator idle coexistence; repeat without it if
   feasible. Do not run concurrent transactions or abort another addon's work.

Use [REPORT.md](REPORT.md) for actual observations. No mocked runtime/private
helper test replaces this seam. Direct-custom-post failures remain limitations;
this handoff does not establish a fully integrated custom-tab posting solution.

## Repository checks and source basis

```sh
luajit -e 'assert(loadfile("probes/posting/addons/CopperwisePostingProbe/Probe.lua"))'
env CGO_ENABLED=1 go vet ./...
env CGO_ENABLED=0 go test ./...
```

Compilation checks Lua syntax only. Existing Go tests cover the pipeline, not
posting. No typed addon code is added. Acceptance requires actual-client evidence.

The Forever [native frame implementation](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_AuctionHouseUI/Shared/Blizzard_AuctionHouseFrame.lua)
provides SetPostItem; the [native Sell controls](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_AuctionHouseUI/Shared/Blizzard_AuctionHouseSellFrame.lua)
provide quantity/price/duration preparation. Source inspection supports the
candidate handoff only; it does not establish target-client behavior. No legacy
fallback, restriction bypass or Auctionator dependency is included.
