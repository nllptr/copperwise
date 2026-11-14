# S03 evidence

Status: partial runtime evidence received; remaining verification pending.

## Repository evidence

- Installed Forever Auctionator uses `C_Container.GetContainerItemInfo` fields
  `stackCount`, `hyperlink`, and `C_Item.GetItemInfo` return 11 for sell value.
- A standalone probe and manual acceptance procedure are provided.

## Owner-provided runtime evidence (2026-11-14)

Chat excerpts at timestamps 1794662083–1794662103 show:

- Peacebloom (2447): count 1, slot `0:15x1`, consistent with the single
  Peacebloom icon in the supplied combined-backpack screenshot.
- Copper Ore (2770) and Sharp Arrow (2515): count 0.
- Initial metadata: unavailable for all three. Subsequent cache notifications
  resolve to sell values of 10, 5 and 0 copper/unit respectively. This observes
  unavailable-to-known transitions and distinguishes numeric zero, although
  Sharp Arrow is not owned and tooltip comparison remains pending.
- A later manual snapshot repeats the same counts and values.
- Excessive identical cache-triggered snapshots were observed. The probe now
  filters notifications to unresolved selected samples; runtime retest pending.

The supplied excerpt has no login build/API line and no move/split evidence.
The screenshot alone does not establish IDs of the other visible stacks.

## Actual-client evidence to collect

- Client version/build/interface, OS version and architecture:
- Selected IDs, slot counts and independent bag comparison:
- Move/split/merge before and after snapshots:
- Vendor sell tooltip comparison, numeric zero, unavailable metadata:
- Cache update behavior, errors and ordinary bag interaction outcomes:
- Item identity and coverage limitations encountered:

All acceptance criteria remain open until the corresponding runtime evidence
is recorded. No bank, alt, transaction or production inventory claim is made.
