# S07 queue and ownership rules

Status: completed — owner approved the rules through the S07 walkthrough.

Scope: one current character's sale and craft intent, with inspectable examples.
No transaction implementation, automatic crafting or cross-character holdings.
Sources: [S07](issues/07-decide-queue-and-ownership-rules.md),
[approved Crafting exploration](issues/02-prototype-crafting-screen.md),
[bank runtime evidence](../../probes/bank/REPORT.md), and
[ranking decisions](ranking-bases.md).

## Quantities and lifecycle — approved

- **Approved:** Enter whole **crafts**, displaying the corresponding output count using known
  fixed yield. Two crafts yielding three outputs each means six planned outputs.
  Unknown/variable yields cannot promise an exact output count.
- Sale intent uses item units, independent of bag-stack boundaries. Default a
  newly marked item to its currently observed bag quantity; allow explicit edits.
  Bank-held units require withdrawal before posting. Posting stack sizes and
  terms remain S08/S16 decisions.
  For a bank-only row, require an explicit sale quantity rather than silently
  marking zero; show the dated holding and withdrawal requirement before adding.
- Adding the same recipe/item adds to its existing intended quantity; editing
  replaces that quantity. Require positive whole numbers; removal is explicit.
  Changing detail-preview quantity alone does not edit an existing queue entry.
- **Approved:** Keep both queues across tab/window changes, AH visits, reload and logout,
  scoped to the character. Restore intent, then revalidate observations; saved
  quantities never prove current bag availability. Display intended and currently
  executable quantities separately rather than silently discarding shortages.
- Removing sale intent does not cancel an auction already posted. Removing craft
  intent does not undo purchases or discard owned ingredients.

## Bank eligibility — approved

**Approved:** Provide an **Include bank** checkbox for planning. Allocate bag
materials first, then bank materials when inclusion is enabled. Any craft-queue
row whose covered crafts depend on bank materials gets a warning icon, alongside
its coverage indication. The tooltip lists the bank ingredients and quantities
requiring withdrawal, plus observation age and coverage. Coverage using bank
materials does not mean immediately craftable from bags.
Propagate the warning to later rows relying on projected outputs whose producer
requires bank materials, so the dependency is not hidden.

**Approved:** Retain the checkbox setting per character. When enabled away from
the bank, use the latest valid observed bank snapshot with its age visible in
the tooltip. Start unchecked on first use, then remember the user’s choice.
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

The checkbox controls both queue coverage and generated shopping requirements.
The owner approved dated cached-count eligibility when inclusion is enabled.

## Shared materials — approved

Aggregate requirements by comparable ingredient identity across the craft queue.
Only units verified as the same supported ingredient may share credit; ambiguous
variants or alternative ingredients remain unresolved rather than interchangeable.
Subtract eligible bag units once, then eligible bank units once, clamping remaining
need at zero. Keep vendor and AH shopping destinations distinct; unresolved source
selection remains explicitly unresolved. Do not subtract ownership once per recipe.

**Approved:** Walk the craft queue from top to bottom, allocating ingredients once
and adding the guaranteed outputs of covered crafts to projected supply for later
entries. Allow explicit reordering and immediately recalculate coverage. Editing
or removing a producer recalculates downstream needs. These are planning
allocations, not physical reservations or observed ownership.
New entries append to the queue. Duplicate additions increase the existing entry
in place; editing retains its position, removing releases its allocation, and
removing then readding puts it last.
Independent recipe-list estimates retain S06's one-craft comparison and do not
reserve materials across alternative recipes.

**Approved:** Pending sale intent excludes its allocated owned units from craft-material credit,
so the plan cannot promise those same units for sale and crafting. Sale intent
takes precedence: allocate observed bags first, then valid bank holdings when
bank planning is enabled; show any uncovered sale quantity separately. Only the
bag allocation is immediately postable. When bank planning is off, bank sale
intent retains its withdrawal warning but supplies no counted bank allocation.
Removing sale intent releases its planning allocation for crafting. Completing
a sale requires fresh ownership reconciliation rather than releasing sold units
as though they were still owned.

For example, with zero bag herbs and three eligible bank herbs, marking two
herbs for sale leaves one bank herb eligible for crafting and two requiring
withdrawal for sale. With bank planning off, neither queue receives bank credit;
sale intent still records two units awaiting withdrawal and revalidation.

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

## Actions and completion — approved behavior

Owner approved reducing pending quantities only by completed actions, removing
entries at zero, and retaining any unfinished remainder after cancellation or
interruption. Five queued crafts with two completed leave three; eight sale
units with three successfully posted leave five. Purchases reduce shopping need
once reflected in bags; they do not reduce the number of queued crafts.
Manual removal changes intent, not purchases or already posted auctions.
Exact evidence/reconciliation mechanisms below remain future implementation work.

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

### Queued outputs and coverage — approved

2026-11-14 owner input: crafts do not fail; possible extra yields may become
relevant later. Do not describe craft failure as a planning risk. Queued crafts
can still be unfinished or removed, so their outputs are not observed ownership.
Use only supported guaranteed output quantities for planning; possible bonus
outputs are not promised supply. Actual observed outputs can update ownership.

2026-11-14: Owner approved one row per recipe with border colors and a concise
coverage count: green for all crafts covered, yellow for partial coverage (for
example, **2 of 5 crafts covered**), red for none. Tooltips explain owned,
projected and missing ingredients. The earlier parenthesized notation is not
adopted. Color is accompanied by text rather than being the only indicator.

Only the covered portion contributes output to the current coverage projection.
An uncovered entry does not prevent an independent later recipe being covered.
Order matters: smelting above forging supplies it; smelting below does not.
Reconcile projected output with observed ownership once after actual crafting.

**Generate shopping list** calculates additional inputs needed to complete the
whole ordered queue, including currently uncovered crafts. For this calculation,
account for guaranteed outputs of earlier explicitly queued producers after
their missing inputs are supplied. For example, smelting two crafts produces
four bars, then forging consumes three. With no ore or bars owned, the list asks
for the ore required for both smelts, not three additional bars. Current coverage
remains red until supplies are available; generating a list does not change it.
With ore for only one smelt, its two projected bars count toward later coverage,
and shopping asks for the missing ore for the second smelt. A later producer
cannot supply an earlier entry unless the user reorders them.

This extends planning to manually queued producers; automatic recipe insertion,
recursive subcraft discovery and automatic craft execution remain excluded.
This is approved design, not implemented or runtime-verified queue behavior.

2026-11-14: Owner approved entering craft counts rather than desired outputs.
Later decisions below settle the remaining quantity and lifecycle policies.

2026-11-14: Owner subsequently approved persistent current-character sale and
craft queues across reload/logout. Revalidate holdings and recalculate coverage
on return; preserve intended quantities until edited, removed or completed.
For example, five queued crafts remain five even if changed holdings now cover
only two, yielding a yellow **2 of 5 crafts covered** row.

2026-11-14: Owner requested a bank-inclusion checkbox, bag-first allocation and
a warning on queue rows that require bank materials, even when fully covered.

2026-11-14: Owner approved sale-before-craft priority. With ten owned herbs,
six marked for sale and crafting requiring eight, crafting credits four and
shopping needs four. Removing the sale mark makes those six eligible again.

2026-11-14: Owner approved completion bookkeeping and automatic removal at zero,
including partial completion, cancellation/interruption, and purchases changing
shopping needs only when ingredients arrive in bags.

2026-11-14: Owner approved the final defaults: mark currently observed bag units
for sale with editable quantity, require explicit bank-only sale quantity, start
Include bank unchecked and remember it, and add duplicate queue quantities
rather than replace them. S07 is complete as a decision document and walkthrough.
