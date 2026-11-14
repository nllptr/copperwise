# S04 evidence

Status: implementation ready; actual-client verification pending.

## Repository evidence

- Standalone read-only addon with `/cwbank`, bounded character-scoped evidence
  and a dated latest bank snapshot. Bags and bank are printed separately.
- Closed/unobserved access cannot refresh saved bank counts. Login/reload starts
  unconfirmed; successful open-bank reads distinguish observed zero from unknown.
- Installed Forever Auctionator uses the namespaced container API for bag slots.
  Source inspection does not verify bank IDs, events, completeness or freshness.
- Classic bank coverage (-1 and 5–11) remains a hypothesis requiring visible
  main-bank and equipped-bank-bag comparison. Slot coverage is printed explicitly.

## Runtime evidence

Owner-reported runtime failure (2026-11-14, 17:44:06): registering
`PLAYERBANKBAGSLOTS_CHANGED` raises an unknown-event error, preventing login
initialization and leaving `/cwbank` silent. Removed that unsupported event;
remaining registrations are protected and report unavailable events rather than
aborting startup. Runtime retest pending. This is not successful bank evidence.

Follow README.md and record:

- Client version/build/interface, platform/architecture and installed addon context.
- Before-bank unknown counts, sample IDs, visible bag/bank counts and capacities.
- Deposit/withdrawal quantities, event order, settled observations and timestamps.
- After-close and after-reload cached counts/time; successful reopening refresh.
- Another-character unknown state, any unavailable APIs/events or read failures,
  transient discrepancies and manual-interaction/coexistence limitations.

## Acceptance boundary

No S04 runtime criterion is marked complete. Syntax/repository checks and prior
bag-probe evidence do not establish bank access, saved-cache correctness, event
timing or complete coverage in the actual client. Cached-bank subtraction policy,
automatic withdrawals/transfers and cross-character tracking remain out of scope.
