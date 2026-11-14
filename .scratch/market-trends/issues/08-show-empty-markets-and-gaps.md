# 08: Represent empty markets and collection gaps honestly

**What to build:** The history viewer distinguishes observed empty supply from missing observations throughout collection, delivery, and rendering.

**Blocked by:** 07: Accumulate and browse seven-day history.

**Status:** ready-for-agent

- [ ] A successful empty-market observation displays zero stock and no fabricated zero asking price.
- [ ] Collection failures and missing observations produce explicit gaps without invented continuity.
- [ ] Show actual coverage and source observation age separately from collection, download, and import times.
- [ ] Controlled sequences verify visible empty, missing, unchanged, and resumed observations through the real pipeline at login or user-initiated `/reload`.

## Comments

2026-11-14: Ticket 17's [synthetic UI study](../../../probes/ui-history/README.md)
distinguishes missing observations (break both series), observed empty supply
(zero stock and absent price), and a supported item with no loaded history
(explicit message). Compare fixtures at 24 hours. These are proposed visible
states; end-to-end acceptance remains pending.

2026-11-14: Reconciled with the owner-approved login and user-initiated `/reload` import model; ticket number and blocking edges retained.
