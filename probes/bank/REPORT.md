# S04 evidence

Status: bank/keyring mapping identified; corrected scoped probe runtime retest pending.

## Repository evidence

- Standalone read-only addon with `/cwbank`, bounded character-scoped evidence
  and a dated latest bank snapshot. Bags and bank are printed separately.
- Closed/unobserved access cannot refresh saved bank counts. Login/reload starts
  unconfirmed; successful open-bank reads distinguish observed zero from unknown.
- Installed Forever Auctionator uses the namespaced container API for bag slots.
  Source inspection does not verify bank IDs, events, completeness or freshness.
- The initial classic bank coverage hypothesis (-1 and 5–11) was wrong in the
  target client. Corrected code uses Enum.BagIndex.CharacterBankTab_1 only;
  old mixed-coverage snapshots are discarded while evidence logs are retained.

## Runtime evidence

Owner-reported runtime failure (2026-11-14, 17:44:06): registering
`PLAYERBANKBAGSLOTS_CHANGED` raises an unknown-event error, preventing login
initialization and leaving `/cwbank` silent. Removed that unsupported event;
remaining registrations are protected and report unavailable events rather than
aborting startup. Subsequent owner-provided output verifies startup now succeeds.

### Owner-provided runtime output (2026-11-14)

- Client 1.60.1, build 70938, interface 16001, macOS. Architecture and full
  installed-addon context were not supplied for this run.
- First character at 1794674736–1794674746: separate observed bags and unknown
  bank counts/time. Owner then switched characters to perform the bank checks.
- Second character at 1794674798–1794674815: bank still unknown; bags contain
  one Peacebloom (2447) in 0:15 and two Bogling Roots (5206) in 2:3.
- Opening at 1794674856 reports main-bank container -1 with 32 slots. Bank bag
  6 initially reports zero slots, then 48 at 1794674857. Other bank bag IDs
  5 and 7–11 report zero. NUM_BANKBAGSLOTS is nil. This establishes delayed
  capacity availability: an early `confirmed` read is not proof of full coverage.
- After closing at 1794674859, manual output at 1794674864 retains cached bank
  counts and observation time 1794674857.
- Deposit sequence: at 1794674922 Peacebloom is bags 1 / bank 0. At
  BAG_UPDATE_DELAYED 1794674925 and manual snapshot 1794674931 it is bags 0 /
  bank 1 in 6:1. Container 6 was initially described as a bank bag; subsequent
  owner visual evidence contradicts that assumed mapping (see below).
- Withdrawal sequence: at BAG_UPDATE_DELAYED 1794674953 and manual snapshot
  1794674958 Peacebloom is bags 1 in 0:15 / bank 0. No persistent double count
  is visible in these supplied settled observations.
- Closing at 1794674984 and manual snapshot 1794674996 show cached bank counts
  with observation time 1794674958. After user reload, PLAYER_LOGIN 1794675037,
  BAG_UPDATE_DELAYED 1794675038 and manual 1794675042 preserve that exact bank
  timestamp and cached counts while bag observations receive new timestamps.
- Reopening at 1794675077 restores confirmed bank state; manual snapshot at
  1794675083 refreshes observation time to 1794675083, still bags 1 / bank 0
  for Peacebloom. No new Lua error is present in these excerpts.

### Remaining checks and limitations

- Owner confirms Peacebloom is visibly in bags and absent from bank after the
  withdrawal. The visible bank has 48 main slots, no unlocked bank bag slots
  and no equipped 32-slot bank bag. The API's -1:32 container is invisible in
  that UI. Container 6:48 matches the visible capacity and held the moved sample,
  but its mapping and the meaning of -1 remain unresolved. The assumed classic
  main-bank/bank-bag mapping is contradicted; summing both is not validated.
  Do not claim 80 visible slots or confirmed combined bank holdings.
- Follow-up owner enum output identifies `CharacterBankTab_1 6` and `Keyring -1`.
  This resolves the invisible 32-slot container as the keyring. The probe now
  excludes it and all other unverified containers, explicitly covering only
  the first character bank tab. Zero-slot bank tab reads are rejected. The
  corrected scope and cache invalidation require runtime retesting; prior
  mixed totals must not be reused as correctly scoped bank observations.
- Open-bank event reads can precede capacity loading, and unlocked item reads
  are not atomic. The `confirmed` label means an open-access API observation,
  not a completeness/stability guarantee. Production must handle loading states.
- Reload with bank open, away-from-bank bag mutations, newly selected unknown
  sample rows and read-failure handling remain untested in this run.
- Two characters started unknown before either had a saved bank observation;
  switching back after establishing the second character's cache has not been
  tested. Character-scoped storage is implemented but not fully runtime verified.

## Acceptance boundary

The supplied runtime output establishes the tested deposit/withdrawal refresh and
closed-bank/reload/reopen freshness cycle and the owner confirms the final
Peacebloom location. Bank/keyring mapping is now identified; corrected first-tab
coverage and cache round trip remain to be retested before closing S04. No atomicity, complete
coverage or production readiness claim follows. Cached-bank subtraction policy,
automatic withdrawals/transfers and cross-character tracking remain out of scope.
