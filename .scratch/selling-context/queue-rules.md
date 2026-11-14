# S07 queue and ownership rules

Status: proposed — awaiting owner decisions. None of the defaults below is approved.

Scope: one current character's sale and craft intent, with inspectable examples.
No transaction implementation, automatic crafting or cross-character holdings.
Sources: [S07](issues/07-decide-queue-and-ownership-rules.md),
[approved Crafting exploration](issues/02-prototype-crafting-screen.md),
[bank runtime evidence](../../probes/bank/REPORT.md), and
[ranking decisions](ranking-bases.md).

## Quantities and lifecycle — proposed default

- Enter whole **crafts**, displaying the corresponding output count using known
  fixed yield. Two crafts yielding three outputs each means six planned outputs.
  Unknown/variable yields cannot promise an exact output count.
- Sale intent uses item units, independent of bag-stack boundaries. Default a
  newly marked item to its currently observed bag quantity; allow explicit edits.
  Bank-held units require withdrawal before posting. Posting stack sizes and
  terms remain S08/S16 decisions.
- Adding the same recipe/item adds to its existing intended quantity; editing
  replaces that quantity. Require positive whole numbers; removal is explicit.
  Changing detail-preview quantity alone does not edit an existing queue entry.
- Keep both queues across tab/window changes, AH visits, reload and logout,
  scoped to the character. Restore intent, then revalidate observations; saved
  quantities never prove current bag availability. Display intended and currently
  executable quantities separately rather than silently discarding shortages.
- Removing sale intent does not cancel an auction already posted. Removing craft
  intent does not undo purchases or discard owned ingredients.

## Bank eligibility — proposed default

Use bags by default. Offer an explicit **Count observed bank materials** option
for planning, off by default and retained with the character's queue preferences.
When enabled, count the latest valid snapshot of the verified first character
bank tab, whether confirmed during access or cached afterwards. Always show its
observation time, age, coverage and withdrawal needs. There is no invented age
threshold: a cached count remains an explicitly uncertain planning assumption.
Unknown, failed/loading reads and invalid legacy coverage supply no eligible bank
credit; they must remain unknown rather than display as observed zero.

On bank access or material movement, suspend affected combined ownership credits
until a settled, consistently scoped bag/bank observation is available. Never
combine a newer withdrawal into bags with its old bank count. If consistency
cannot be established, exclude affected bank credit and show why. This is a
required future behavior, not an atomicity capability established by S04.
Closing/reloading must not advance the bank observation timestamp.

Alternative for owner choice: always exclude cached bank counts from subtraction,
showing them only as possible holdings to verify. This yields a more conservative
shopping list away from the bank.

## Shared materials — proposed default

Aggregate requirements by comparable ingredient identity across the craft queue.
Subtract eligible bag units once, then eligible bank units once, clamping remaining
need at zero. Keep vendor and AH shopping destinations distinct; unresolved source
selection remains explicitly unresolved. Do not subtract ownership once per recipe.

Use queue insertion order to explain each recipe's allocation of shared holdings.
Edits retain that position; removal releases its allocation; removing and readding
puts it last. These are planning allocations, not physical reservations.
Independent recipe-list estimates retain S06's one-craft comparison and do not
reserve materials across alternative recipes.

Pending sale intent excludes its allocated bag units from craft-material credit,
so the plan cannot promise those same units for sale and crafting. Sale intent
takes precedence, capped at observed bags; show any sale shortage separately.
This cross-queue priority is a proposal requiring owner approval.

## Walkthrough — synthetic units

Recipe A needs three herbs/craft and yields two outputs. Recipe B needs four
herbs/craft and yields one output. Queue A ×2, then B ×1: total need is ten herbs.
There are five in bags and three in a valid dated bank snapshot.

| Scenario | Bag credit | Bank credit | Withdraw | Remaining to acquire |
| --- | ---: | ---: | ---: | ---: |
| Default, bank excluded | 5 | 0 | 0 | 5 |
| Bank explicitly included | 5 | 3 | 3 | 2 |
| Bank unknown | 5 | unavailable | unknown | 5 known unmet by bags; bank unverified |
| Bank included, two bag herbs marked for sale | 3 | 3 | 3 | 4 |
| Bank included, A reduced to one craft (need seven) | 5 | 2 | 2 | 0 |
| Bank included, A removed (need four) | 4 | 0 | 0 | 0 |
| Need ten, twelve available in bags | 10 | 0 | 0 | 0 |

With bank included and no sale marks, A receives five bag herbs plus one bank
herb; B receives two bank herbs and needs two more. Swapping recipe order changes
that explanation, not the combined need or total credit. The edit/removal rows
are independent variations of the original queue, not cumulative operations.

## Actions and completion — proposed default

| Event | Effect on pending intent |
| --- | --- |
| Queue/edit/remove or close window | Recalculate planning only; no game action |
| Cancelled/failed post | No completed quantity; retain intended remainder |
| Sale intent eight, confirmed post three | Five remain; revalidate bag availability |
| Uncertain posting result | Keep unresolved intent, block retry until reconciled; do not infer success |
| Need two herbs, confirmed purchase one | One acquired, but no ownership credit until reconciled with bag observations |
| Bag update reflecting that purchase | Credit the unit once, never both a purchase counter and bag count |
| Cancelled/failed purchase | No acquired credit; preserve current remaining need |
| Purchased ingredients then craft intent removed | Ingredients remain owned; requirements disappear |
| Craft actually completed | Decrement only confirmed craft executions; preserve uncompleted crafts |

Purchases satisfy material needs, not craft completion. Automatic craft execution
is excluded. Future completion handling must use supported confirmed execution
evidence; if unavailable, require explicit user reconciliation rather than infer
crafts from a bag delta. Unlearned recipes remain planning references. An
unresolved purchase likewise requires reconciliation before a retry can duplicate
it. Transaction evidence and exact UI actions remain S08/S09/S16/S20 work.

## Owner review

Choose or amend: (1) crafts and sale units plus additive duplicates; (2) persistent
character queues; (3) opt-in dated cached-bank planning versus confirmed-only
credit; (4) insertion-order allocations and sale-before-craft priority; (5) the
completion/reconciliation rules above. S07 remains incomplete until agreed.
