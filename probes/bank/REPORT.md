# S04 evidence

Status: complete — sample bank observations and freshness verified for CharacterBankTab_1.

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
- Opening at 1794674856 reports container -1 with 32 slots (later identified as
  keyring). Container 6 initially reports zero slots, then 48 at 1794674857. Other container IDs
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

### Corrected probe runtime verification

- At 1794675586 the corrected probe discards its legacy mixed-coverage cache
  and displays unknown bank counts/time. Enum lookup reports CharacterBankTab_1=6.
- Open at 1794675599 and manual snapshot 1794675604 report only `6:48`, matching
  the owner's visible 48-slot bank, with Peacebloom bags 1 / bank 0.
- Deposit: BAG_UPDATE_DELAYED 1794675663 and manual 1794675671 show bags 0 /
  bank 1 in 6:1. Closing at 1794675729 and manual 1794675735 retain count 1
  as cached with observation time 1794675671.
- After reload, login 1794675757 and manual 1794675760 preserve count 1,
  coverage `6:48` and observation time 1794675671. A further login at 1794675861
  also retains those values. No legacy-cache discard recurs.
- Reopening at 1794675864 confirms count 1 with a fresh observation time.
  After withdrawal, BAG_UPDATE_DELAYED 1794675868 shows bags 1 in 0:15 /
  bank 0. Closing at 1794675869 and manual 1794675873 preserve cached zero
  and observation time 1794675868. The last manual snapshot was after closing,
  so its cached state is expected; the preceding event captured open-bank refresh.
- No new Lua error is supplied. These observations establish the selected sample's
  settled location changes and persistent freshness states, not atomic inventory.

### Limitations and checks not exercised

- Owner confirms Peacebloom is visibly in bags and absent from bank after the
  withdrawal. The visible bank has 48 main slots, no unlocked bank bag slots
  and no equipped 32-slot bank bag. The API's -1:32 container is invisible in
  that UI. Container 6:48 matches the visible capacity and held the moved sample,
  and subsequent enum output resolves the mapping. The assumed classic
  main-bank/bank-bag mapping was wrong; summing both is invalid.
  Do not claim 80 visible slots or confirmed combined bank holdings.
- Follow-up owner enum output identifies `CharacterBankTab_1 6` and `Keyring -1`.
  This resolves the invisible 32-slot container as the keyring. The probe now
  excludes it and all other unverified containers, explicitly covering only
  the first character bank tab. Zero-slot bank tab reads are rejected. The
  corrected scope and cache invalidation are verified above; prior
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

S04 is complete as a read-only capability investigation for the selected samples
in the visible first character bank tab. Corrected runtime output establishes
deposit/withdrawal refresh and the closed-bank/reload/reopen freshness cycle;
the owner independently confirmed the bank capacity and an earlier withdrawal's
visible Peacebloom location. No claim of all-tab coverage, atomicity or production
readiness follows. Cached-bank subtraction policy,
automatic withdrawals/transfers and cross-character tracking remain out of scope.
