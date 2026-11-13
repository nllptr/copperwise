# 07: Accumulate and browse seven-day history

**What to build:** Continuous backend collection builds shared history independently of game sessions, and the addon displays a seven-day default history view.

**Blocked by:** 06: Collect and display one live item observation.

**Status:** ready-for-agent

- [ ] Collection continues while the game and companion are closed, following verified source cadence and limits.
- [ ] The companion retrieves, caches, and exports accumulated history. New revisions become visible at the next login or user-initiated `/reload`, while the loaded revision stays unchanged between imports.
- [ ] Render aligned price and stock graphs with seven days as the default requested range and actual coverage disclosed.
- [ ] Controlled sequences verify that repeated unchanged upstream snapshots do not create new observations or new sales evidence.

## Comments

2026-11-14: Reconciled with the owner-approved login and user-initiated `/reload` import model; ticket number and blocking edges retained.
