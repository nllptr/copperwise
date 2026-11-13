# 12: Bootstrap and expire retained history

**What to build:** A new companion receives accumulated retained history, and backend and companion honor configurable expiry within the verified retention cap.

**Blocked by:** 07: Accumulate and browse seven-day history.

**Status:** ready-for-agent

- [ ] A newly initialized companion receives backend history accumulated before installation and exports it for addon browsing at login or user-initiated `/reload`.
- [ ] Support configurable retention initially capped at 30 days, tightened where verified upstream requirements demand it.
- [ ] At controlled time boundaries, expired API-derived history is no longer retained or served by the backend or retained in companion caches.
- [ ] Browsing reflects retained coverage honestly after expiry and after the companion resumes following an offline interval, using the updated export at the next login or user-initiated `/reload`.

## Comments

2026-11-14: Reconciled with the owner-approved login and user-initiated `/reload` import model; ticket number and blocking edges retained.
