# S03 evidence

Status: complete — settled bag counts and vendor metadata verified, with transient observation limitations.

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

The initial excerpt has no login build/API line or move/split evidence.
The screenshot alone does not establish IDs of the other visible stacks.

## Bogling Root split/merge and vendor comparison

Owner-provided follow-up evidence identifies Bogling Root as item 5206:

- At 1794662340: count 2, `2:3x2`, sell metadata 37 copper/unit and 74 total.
- At 1794662376 during splitting: transient count 3, `2:3x2,2:4x1`.
  This is an observed overcount; settled correctness does not pass the
  no-double-counting criterion for intermediate observations.
- At 1794662377 and 1794662405: settled count 2, `2:3x1,2:4x1`, 74 total.
- At 1794662459 and 1794662474 after merging: count 2, `2:3x2`, 74 total.
- Owner confirmed the game vendor sell tooltip matches 37 copper per item /
  74 copper for the stack of two.

This establishes settled split/merge quantities and a real vendor sell tooltip
comparison. It does not establish atomic intermediate container observations.

## Build and between-bag evidence

- Owner's `GetBuildInfo()` output: client 1.60.1, build 70938, built Nov 12
  2026, interface 16001.
- Local `sw_vers` / `uname -m`: macOS 26.6.2 (25G83), x86_64.
- At 1794662767 the original stack is locked, followed by count 1 in `2:3x1`
  while moving. At 1794662768 and the later explicit snapshot 1794662781,
  count is 2 across `2:3x1,4:1x1`, with 74 copper total.
- Supplied excerpts contain no Lua error. Successful manual split, merge and
  placement provide evidence for those ordinary interactions, not every bag UI
  interaction or addon combination.

## Conclusion and production boundary

S03 is complete as a read-only capability investigation: the tested settled
counts reflect stack splits, merges and movement between bags without persistent
double counting. Numeric zero and unavailable metadata are distinct, and an
owned item's vendor sell value was independently confirmed.

Intermediate observations can overcount or undercount during mutations; even an
unlocked snapshot and BAG_UPDATE_DELAYED are not sufficient proof of stability
(the overcount had no lock marker). Production inventory must handle updating
states before publishing actionable totals. No atomic-count guarantee is claimed.
The cache-notification filter change still needs runtime verification; it does
not change the demonstrated slot summation or establish production readiness.
Numeric item IDs collapse instance variants, and coverage excludes cursor,
equipment, bank and alts. No transaction or production inventory claim is made.
