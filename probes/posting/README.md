# Native posting probe (S08)

Standalone capability probe for the Forever modern auction house. Runtime
acceptance is pending. No dependency on Auctionator, scan data or imported history.
It posts real items only from the **Post once** button; no slash command posts.

## Run

```sh
cp -R probes/posting/addons/CopperwisePostingProbe '/Applications/World of Warcraft/_forever_/Interface/AddOns/'
```

Enable Copperwise Posting Probe and reload. Visit an auctioneer, let other AH
work finish, then `/cwpost`. The **CW posting** native bottom tab contains the
preview, Post once and Cancel preview buttons. Use an operator-supplied ordinary
trade-good sample and operator-selected terms. Disable the scanning probe for
this first run to isolate native tab/coexistence behavior.

Prepare with `/cwpost prepare <bag> <slot> <quantity> <price copper> <duration>`.
Bags are 0–4, slots start at 1; duration indices 1/2/3 are expected to mean
12/24/48 hours (confirm against native Sell in this client). For example,
`/cwpost prepare 0 1 1 123 1` previews one unit in backpack slot 1 at 123 copper;
this is syntax illustration, not a suggested price or item selection.

Read the actual item link, stack count, quantity, unit/single-item buyout, total,
duration and native calculated deposit. Commodity prices are per unit;
noncommodity samples are restricted to quantity 1 with a buyout and no bid.
Quantity may not exceed the selected stack. No cross-stack aggregation,
multisell policy, automatic price selection or duration recommendation is implied.
Changing inventory, locks, money or tabs discards the preview. Reprepare once
updates settle. Item eligibility, identity, count and deposit are rechecked on
Post once. A changed stack or deposit refuses dispatch.

Click **Post once** only after reviewing the chosen terms. Every dispatch,
including an API exception, consumes the one-attempt allowance for that AH visit.
A return value is not success: inspect the native **Auctions** tab and compare
item, quantity, price and duration, alongside bag changes. Record the actual
outcome with `/cwpost note <short observation>` and `/cwpost status`. Closing
and reopening permits another deliberate attempt but does not resolve an
uncertain previous outcome. Inspect before retrying. No timed or event-driven
submission, queue, purchase or auction cancellation is implemented.

If the API requires an extra native confirmation, the probe reports it without
calling ConfirmPost APIs or modifying native sell-frame pending state. Record
that limitation; inspect any native dialog/owned listing before continuing.
Cancel preview never cancels a request already sent or an existing auction.
Native event logs are supporting evidence only: they have no reliable per-probe
request identity. Another observed Post/ConfirmPost invalidates the preview and
locks this visit; the probe does not block or alter the other caller.

## Actual-client acceptance (agreed public UI/API seam)

Record evidence in [REPORT.md](REPORT.md). Do not replace it with fake-client
or private helper tests. Keep all ticket checkboxes open until observed.

1. Capture `/cwpost status`, client/build/interface, realm/faction/region,
   `sw_vers`, `uname -m`, enabled AH addons and sample item/slot/stack.
2. Away from AH, opening/preparing must refuse. At AH, verify the tab, labels,
   normal UI scale and native Buy/Sell/Auctions navigation. First prepare and
   cancel: no listing or bag change. Switching tabs must discard the preview.
3. Attempt preparation for an empty or invalid slot (or an ineligible item).
   Record refusal and unchanged bags/owned auctions. Prepare a valid item, move
   it, verify invalidation and no later automatic post. Do not intentionally
   post on invalid terms to create an error.
4. Compare the chosen duration and calculated deposit with native Sell. Return
   to CW posting, prepare and review again, then click Post once. Capture call
   and native event lines. Compare native Auctions item/quantity/buyout/duration
   and bag decrement; record an auction ID if visible. An observed listing is
   posting evidence, never evidence of a completed sale. If results are delayed
   or ambiguous, record unknown; do not infer completion from a click/event.
5. A second click or new prepare in the same visit must not send another post.
   Verify close/reopen and tab changes never submit anything. Exercise failure
   or cancellation via step 2/3; record server failure only if encountered.
6. Repeat native tab/browsing checks with Auctionator enabled and idle, and with
   it disabled if feasible. Never run simultaneous transactions or interrupt
   its work. Record unsupported API/frame behavior and UI overlap. Native tab
   placement follows the M18 pattern; simultaneous probe load ordering has not
   been validated. Auctionator is not used as a fallback without evidence.

SavedVariables `CopperwisePostingEvidence` retains five sessions of 200 lines,
900 characters per line. Log out to persist. Notes must omit personal data.
Disable the probe after investigation. Evidence is bounded diagnostics, not a
market history or a production transaction ledger.

## Checks and source basis

```sh
luajit -e 'assert(loadfile("probes/posting/addons/CopperwisePostingProbe/Probe.lua"))'
env CGO_ENABLED=1 go vet ./...
env CGO_ENABLED=0 go test ./...
```

Lua compilation checks syntax only; no typed addon code was added. Go checks
cover the existing pipeline, not posting behavior. Runtime acceptance remains
pending even when all repository checks pass.

[Forever native API definitions](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/AuctionHouseDocumentation.lua)
provide eligibility, commodity classification, deposit, PostItem/PostCommodity
and confirmation signatures. Installed Auctionator 346
`Source_ModernAH/Tabs/Selling/Mixins/SaleItem.lua` corroborates price arguments
and the extra-confirmation return path. Sources are hypotheses until tested
against the actual client; no legacy fallback or unsupported bypass is included.
