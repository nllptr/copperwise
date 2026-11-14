# Bank observations and freshness (S04)

Standalone, read-only current-character capability probe. No backend, credentials,
Auctionator dependency or transactions. **Actual-client acceptance is pending.**

With the game closed, copy `addons/CopperwiseBankProbe` to
`/Applications/World of Warcraft/_forever_/Interface/AddOns/`, enable it and log in.
Interface 16001 follows the verified client probe; capture the running build.
Installation into the game directory is separate from the repository change.

`/cwbank` prints bag and bank observations separately for Peacebloom (2447),
Copper Ore (2770) and Bogling Root (5206). `/cwbank sample <item ID>` adds up to
three session-only samples. `/cwbank note <short outcome>` records manual evidence;
avoid character/account names. Bank and bag events also produce snapshots.

The probe uses `C_Container.GetContainerNumSlots/GetContainerItemInfo`, numeric
item IDs, and `stackCount`. Installed Auctionator corroborates the container API
shape for bags, **not bank availability or event timing**. Bank IDs -1 and 5–11
are a classic-client hypothesis to verify against the actual bank. Each output
records container slot coverage, sample slot coordinates and observation time.
A zero-slot main bank, locked slot, invalid quantity or missing occupied-item
identity rejects the whole location read. A failed bank read retains the last
observation as cached. Zero-slot bank bags are recorded and assumed unequipped;
verify this against purchased/equipped bank bags before accepting coverage.
There is no fallback to `GetItemCount` or unseen client-cached bank totals.

Bank labels mean:

- `unknown`: no successful observation, or a selected sample has no saved row.
  Unknown is never printed as a zero count.
- `confirmed`: a successful slot read during access reported by
  `BANKFRAME_OPENED`; this describes an observation, not an atomic or continuously
  current inventory guarantee. Compare settled results with the visible bank.
- `cached`: a previous successful observation after access closes, after a read
  fails, or following login/reload. The original observation time is preserved.
  Closed-bank status commands and bag events never refresh bank observation time.

Reload always starts with access unobserved. If the bank stays visible, close and
reopen it to obtain a new open event. SavedVariables are character scoped:
`CopperwiseBankEvidence` in the character's `SavedVariables/CopperwiseBankProbe.lua`.
Only the latest bank snapshot (at most six sample rows) and five sessions of 180
bounded evidence entries are retained. Saved data is flushed by normal client
logout/reload. Extra sample selections reset on reload; re-add an ID to inspect a
cached row if it was included in the last successful bank snapshot.

## Actual-client checks

Record visible results and failures in [REPORT.md](REPORT.md). These are the
pre-agreed public UI/API tests; repository checks cannot pass them.

1. On a character with no previous probe data, log in away from the bank. Capture
   the build/API lines, `sw_vers` and `uname -m`. `/cwbank` must show bank unknown
   with unknown counts/time, separately from observed bag counts. Choose an owned
   sample and one visibly absent sample; add IDs as needed.
2. Open the ordinary personal bank. Capture the open-event and settled manual
   snapshot. Compare sample totals and slot lines against the visible main bank
   and every equipped bank bag. Record bank-bag count/capacities and whether empty
   or unavailable containers are distinguished correctly. An absent sample may
   now have confirmed count zero only within verified coverage.
3. Manually deposit a known quantity, wait for movement to settle, then `/cwbank`.
   Record before/after bag and bank counts, observation times, event order and
   slots. Withdraw a known quantity and repeat. Compare event snapshots with
   settled manual results; report intermediate over/undercounts and locks. Earlier
   S03 evidence shows that even unlocked snapshots can be transiently wrong.
4. Close the bank and `/cwbank`. Bank must become cached with the same last
   successful observation time/counts. Change bags away from the bank and repeat;
   bag counts should change while bank time/counts remain cached. Add a previously
   unsampled item here: its bank count must be unknown, not zero.
5. While away, use a user-initiated `/reload`. Confirm cached bank counts and the
   original timestamp survive. Re-add custom sample IDs if needed. Reopen the
   bank: a successful observation should become confirmed with a new time. Also
   try reload while the bank is open; record lifecycle/event behavior and follow
   the close/reopen instruction if access is unobserved.
6. On another character with no probe data, bank must start unknown. Do not copy
   evidence between characters. Record missing APIs/events, Lua errors, failed
   reads and coexistence with installed addons. If failures cannot be triggered,
   mark those paths untested. Confirm ordinary manual bank actions still work.

No withdrawal, transfer, other-character inventory, subtraction eligibility or
production persistence policy is selected. Numeric IDs collapse instance variants;
coverage excludes cursor, equipment, guild/shared banks and all other characters.
Disable the probe after verification.

Repository validation: LuaJIT `loadfile` syntax compilation, `go vet ./...` and
`go test ./...`. There is no statically typed addon code. No fake-client test or
automated runtime acceptance declaration is provided.
