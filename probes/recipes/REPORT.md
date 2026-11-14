# S05 runtime evidence

Status: in progress — owner supplied catalog and learned-recipe runtime output;
native UI comparisons and merchant observations remain pending.

## Repository verification (2026-11-14)

- LuaJIT `loadfile` syntax compilation: passed.
- `go vet ./...`: passed.
- Full `env CGO_ENABLED=0 go test ./...`: passed outside the sandbox; the
  sandboxed run could not bind local HTTP test ports.
- `git diff --check`: passed.
- Separate code-review axes against pre-work commit `2a83cf7`: Standards 0
  findings; Spec 0 actionable defects. Runtime acceptance remains pending.
- Installed `CopperwiseRecipeProbe` into the local Forever AddOns directory.

## Environment

- Owner-provided login at t=1794677117: client 1.60.1, build 70938,
  interface 16001, macOS. OS build/architecture not supplied for this run.
- At t=1794677167 and t=1794677191: Leatherworking, profession ID 165,
  skill 65; IsTradeSkillLinked, IsTradeSkillGuild, IsTradeSkillGuildMember
  and IsNPCCrafting all false. Own context confirmed by these API results.

## Learned recipe

At t=1794677191, recipe 2881 (Light Leather) reports learned=true,
craftable=true, disabled=false and unavailable recipe sourceType. Schematic:

- Output item 2318, Light Leather, yield min=1/max=1; vendor sell 15 copper/unit.
- One required ingredient slot, quantity 3, reagentType=1, no variable-quantity
  entries, one alternative: item 2934, Ruined Leather Scraps, vendor sell
  7 copper/unit. No currency ID supplied.
- Ingredient acquisition source and vendor purchase price remain unknown.

Pending: owner comparison against the native UI of the learned state, three
Ruined Leather Scraps input and one Light Leather output. Optional, alternative,
currency and variable-yield paths were not exercised by this sample.

## Unlearned discovery

At t=1794677167, GetAllRecipeIDs returned 592 IDs: 13 learned, 579 unlearned,
0 unknown. Printed unlearned examples include recipe 461653 (Brilliant Chromatic
Cloak), 461690 (Mastercrafted Shifting Cloak) and 3817 (Cured Medium Hide).
Learned examples include 1229432 (Camp Tent), 3816 (Cured Light Hide) and 2881
(Light Leather). This establishes unlearned-state discovery in the current
Leatherworking data source, not catalog completeness or current availability
of every returned recipe in the target environment.

Pending: inspect an unlearned schematic, compare native UI learned state,
change native filters and compare totals; second profession where available.

## Ingredient sources and merchant prices

Owner-provided run at t=1794679275 again reports client 1.60.1/build 70938,
interface 16001, macOS. MERCHANT_SHOW observed at t=1794679293.
At t=1794679330 the open merchant returned these offers (all bundle-count=1,
extended-cost=false, available=-1, purchasable=true; copper/unit equals bundle
price):

| Item ID | Item | Copper/unit |
| --- | --- | ---: |
| 7005 | Skinning Knife | 9 |
| 4289 | Salt | 45 |
| 2320 | Coarse Thread | 9 |
| 2321 | Fine Thread | 90 |
| 4291 | Silken Thread | 450 |
| 8343 | Heavy Silken Thread | 1800 |
| 14341 | Rune Thread | 4500 |
| 2325 | Black Dye | 900 |
| 6260 | Blue Dye | 45 |
| 2604 | Red Dye | 45 |
| 2605 | Green Dye | 90 |
| 4340 | Gray Dye | 315 |
| 4341 | Yellow Dye | 450 |
| 6261 | Orange Dye | 900 |
| 4342 | Purple Dye | 2250 |

These are observed purchase quotes, not inferred from vendor sell metadata.
The run does not independently identify which vendor modifiers apply; prices
must not become universal constants. Only the first 15 offers were supplied.
Multi-item bundles and extended-cost offers were not exercised.

Pending: ingredient ID matched to an inspected recipe and native merchant UI
price comparison. Salt (4289) is a candidate to compare with recipe 3817's
schematic; that recipe's ingredients have not yet been supplied as evidence.
Vendor sell metadata does not establish purchase cost. Unmatched ingredients
have unknown sources and purchase prices; dual-source selection is unresolved.

## Failures and limitations

- At t=1794677132, the command correctly refused access before the profession
  window opened. TRADE_SKILL_SHOW, LIST_UPDATE and DATA_SOURCE_CHANGED events
  were observed at t=1794677144. Close/reopen refusal remains untested.

- No runtime acceptance criteria passed by source inspection or syntax checks.
- Numeric item identity does not settle variant/quality handling.
- No crafting, purchasing, AH source classification or costing policy selected.
- Bounded saved evidence can evict old rows; preserve relevant samples promptly.
- Context loading, cache misses, unsupported APIs/events, variable yields,
  merchant discounts/currencies and non-item outputs need observed outcomes.
