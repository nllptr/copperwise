# Brainstorming: local observations, offline history and personal sales

Date: 2026-11-14
Status: discussion notes — not approved implementation scope

Saved at the owner's request. These notes preserve ideas discussed after the
workflow specification and tickets were approved. They do not amend that spec,
change blocking edges, create implementation commitments or establish client
capabilities. The owner explicitly requested discussion without formal decisions.

## A standalone scan-and-sell path

The owner sees two distinct roles:

- In-game scanning could supply recent observed prices and quantities for
  selling, posting and ingredient shopping through supported client mechanisms.
- The backend collects market history while the player is away; the companion
  delivers that accumulated history to the addon.

This suggests that backend history is an enhancement dependency for the native
scan-and-sell experience, rather than a technical prerequisite for its local
transactions. The owner agreed with that distinction during the discussion.
Actual scanning, buying and posting still need target-client capability evidence.
The API/backend history path retains its own feasibility requirements.

Potential follow-up: revisit the production dependency on the full backend
Phase 0 milestone if a standalone scan-and-sell release is desired first. The
existing tickets retain their approved blockers until an explicit revision.
No release sequencing decision was made in this brainstorming.

## Exporting local scans to the companion and backend

The owner asked whether locally scanned data could travel in the opposite
direction: addon to companion to backend.

Candidate supported flow:

1. The addon collects a manual scan in memory.
2. It retains selected results in SavedVariables.
3. The game normally flushes SavedVariables on logout or user-initiated `/reload`.
4. The companion reads the completed on-disk save and can upload those results.

This is a technical hypothesis to verify in the actual Forever client, not a
completed transport probe. Standard addon APIs do not provide general arbitrary
file writes or HTTP requests, so do not assume immediate background uploads
while the player continues playing. Do not introduce client modification,
automatic reloads or unsupported filesystem/network access to force it.

Preserve market identity, local observation time, scan coverage/completeness and
provenance independently of save time, upload time and backend observation time.
An incomplete local scan is not a complete market snapshot and must not silently
replace backend history or fill offline gaps. Reconciliation, duplication,
retention and publication policy would need a separate design.

The incoming login/reload boundary and proposed outgoing save boundary describe
supported loading/persistence mechanisms. They do not establish that Blizzard
objects specifically to frequent disk access, or establish Blizzard's motivation
for addon restrictions. Applicable rules and target-client behavior still need
evidence; no policy approval was inferred from technical feasibility.

## Bounded addon memory and persistence

The owner highlighted that scan data held until logout/reload could consume
memory. Candidate approaches discussed:

- Process scan results incrementally rather than keeping unnecessary duplicate
  representations of a full response.
- Retain only the detail needed for a feature. Buying may need listing-level
  detail while history views may use compact summaries.
- Replace superseded current-market results rather than retaining every scan
  indefinitely. Any retained history or pending upload queue needs explicit bounds.
- Measure representative scans on the actual client before selecting memory,
  retention or serialization limits; no numeric limits were agreed.

SavedVariables tables also occupy addon memory during play; they are not an
independent disk cache. Large retained tables can affect memory use and save/load
time. Scan results since the last successful save may be lost on a crash. The
owner considered that limitation acceptable for this discussion; no durable
live-export requirement was established.

## Sampling personal time-to-sell

The owner expects API observations to help describe listed quantities, but does
not expect them to establish when a particular item sells. They noted in-game
auction-sale notifications/chat messages and proposed sampling personal sale
timings as potentially valuable data.

Candidate investigation: record an observed posting event and match it to a
later verified sale notification using supported client events and available
identifiers. Where an actual sale timestamp is available, compare it with the
posting timestamp. Keep these observations distinct from market-wide listing
snapshots and from estimates of future sale speed.

Questions and limitations to investigate:

- Does the target client expose a usable structured sale event, timestamp and
  identifier, or only text that may vary by locale? A notification alone does
  not establish a reliable match.
- Can identical item/price/quantity listings be distinguished? What happens
  with stack sizes, partial sales where supported, and repeated postings?
- How are sold, expired and cancelled auctions distinguished? Do not count every
  disappearance as a sale or every attempted post as a confirmed listing.
- What is observable when sales occur offline or notifications are delayed?
  Time observed at login is not necessarily the sale time. Record unknown or
  bounded timing explicitly rather than an exact invented duration.
- What about auctions still listed at the end of an observation period? A sample
  of successful notifications alone would omit unsold outcomes and must not be
  presented as an unbiased estimate of sale speed.
- Could bounded local observations be saved and later exported through the
  SavedVariables path? Identify missing events or crash losses rather than
  silently claiming complete personal history.

This would be evidence about the player's own observed auctions, not proof of
market-wide sales, guaranteed future sale times or realized profit. Disappearance
from an API or local snapshot alone could reflect cancellation or expiry and is
not sufficient sale evidence. Personal sale tracking/accounting remains outside
the approved implementation scope until explicitly reconsidered.

## Possible next conversations or probes

- Decide whether to revise the backend gate for a standalone native release.
- Verify a bounded scan save followed by companion read after logout/reload.
- Measure scan memory and save/load behavior before selecting caps.
- Inspect target-client posting/sale events and attempt one unambiguous personal
  timing observation, retaining unknowns instead of promising exact measurements.

These are candidate follow-ups, not newly published tickets or accepted defaults.
