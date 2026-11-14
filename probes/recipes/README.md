# Recipe metadata and discovery (S05)

Read-only standalone target-client probe. No crafting, purchases, filter changes,
recipe selection hooks, backend or Auctionator dependency. Runtime acceptance is
pending. Copy `addons/CopperwiseRecipeProbe` to the Forever `Interface/AddOns`
directory with the game closed, enable it, and log in. Manifest interface 16001
is a loading target, not evidence of the running build.

Open your own profession window, wait for its list to load, then run:

```
/cwrecipes status
/cwrecipes list
/cwrecipes list 16
/cwrecipes recipe <recipe ID from a printed row>
/cwrecipes note <short observed outcome>
```

List pages contain 15 recipes. Totals use `GetAllRecipeIDs`, not a filtered list;
no filters are changed. Missing APIs, nil metadata and failed commands remain
explicitly incomplete. No returned list is declared a complete profession
catalog. `learned=false` is planning metadata, not an executable craft. The
context diagnostics distinguish linked/guild/NPC views where supported; absent
context APIs leave ownership unconfirmed. Only compare your own professions.

Recipe details print output identity, raw minimum/maximum yield, required and
optional slots, quantities and alternative identities. Alternatives are not
summed. Currency inputs, non-item outputs, variable quantities, missing output
IDs and unequal/unknown yields require further investigation, not an assumed
one-output recipe. Recipe `sourceType` is not an ingredient acquisition source.
Item names/sell prices can be uncached: wait and rerun the same command. Item
identity is numeric ID only; variants/qualities are not normalized for costing.

At an open vendor, `/cwrecipes merchant` (or `merchant 16`) records offers in
pages of 15: item IDs, bundle purchase price/count, availability, purchasability
and extended costs. Copper/unit is calculated only for known non-extended
offers with a positive bundle count; zero remains zero. Compare to the merchant
UI and note discounts, stock and any currency requirements. This is a dated
offer from this vendor, not a universal price or proof of sufficient stock.
Vendor sell metadata is separate from purchase quotes. The probe never labels
an unobserved ingredient AH-only, and does not choose a dual-source policy.

## Actual-client acceptance

Record evidence in [REPORT.md](REPORT.md). No simulated client tests substitute
for this pre-agreed public boundary:

1. Record login build, interface and platform; run `sw_vers` and `uname -m`
   separately. Open an owned profession and save context and catalog totals.
2. Inspect a learned recipe. Compare every required ingredient ID/quantity,
   output ID and yield to the native recipe/tooltips. Record names and IDs;
   capture multiple-output or variable-yield examples if available. Do not craft.
3. Inspect an unlearned recipe and compare native learned state. Repeat after
   changing native learned/unlearned/search filters yourself; record whether
   `GetAllRecipeIDs` totals change. Try another owned profession. No unlearned
   results is an observed limitation, not proof no such recipes exist. Record
   unavailable/incomplete discovery and alternatives (learned-only scope or a
   separately investigated catalog) for owner review.
4. Visit a reagent vendor manually. Match one recipe ingredient to an observed
   merchant item ID; compare bundle and normalized unit price to the native UI.
   Record unavailable purchase metadata for unmatched ingredients. Note potential
   dual-source cases without claiming AH availability unless independently
   observed. Missing vendor observations do not establish AH-only sourcing.
5. Close profession/vendor windows and rerun their commands; stale contexts must
   be refused. Reopen and retry. Record missing APIs/events, incomplete metadata,
   errors and unexercised paths. If logged in before enabling, reload then open
   the profession again so its SHOW event is observed.

Log out to persist `CopperwiseRecipeEvidence` in the account SavedVariables file
`CopperwiseRecipeProbe.lua`: five sessions, latest 400 lines each, 900 characters
per line. Long names/notes can be truncated; evidence is bounded, not a complete
catalog export. Copy relevant entries promptly. Notes should omit account and
character names. Disable the probe when done.

## Research and repository checks

The [Forever API definitions](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/TradeSkillUIDocumentation.lua)
and [data structures](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/TradeSkillUITypesDocumentation.lua)
describe recipe info and schematics. Installed Auctionator's
`Source_Mainline/CraftingInfo/Professions.lua` corroborates schematic usage;
`Source/CraftingInfo/Main.lua` corroborates merchant bundle normalization and
the `C_MerchantFrame.GetItemInfo` compatibility path. These are research,
not actual-client proof. Runtime diagnostics also check discovery/context APIs
that may be unavailable in this build.

LuaJIT syntax compilation checks addon syntax. `go vet ./...` and `go test ./...`
cover the existing Go probes; no statically typed code is added. The accepted
S05 test seam is the actual profession/merchant UI/API boundary above.
