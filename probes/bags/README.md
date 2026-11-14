# Bag quantities and vendor sell values (S03)

Standalone read-only target-client probe. No backend, credentials or other addon
required. Runtime acceptance is pending; installed Auctionator source corroborates
the chosen API shape but cannot establish actual client behavior.

With the game closed, copy `addons/CopperwiseBagProbe` from this directory to
`/Applications/World of Warcraft/_forever_/Interface/AddOns/`, enable the addon,
then log in. Interface 16001 follows the existing capability probe; record the
running build rather than treating the manifest as build evidence.

`/cwbags` prints fresh counts for Peacebloom (2447), Copper Ore (2770), and Sharp
Arrow (2515). `/cwbags sample <item ID>` adds up to three further samples for the
session. Bag updates and item-cache notifications also refresh observations.
Every refresh rebuilds totals from backpack and bag IDs 0–4. Slot coordinates,
stack quantities and lock flags help inspect changes. Cursor items, equipment,
bank, alts and any additional bag IDs are excluded. Counts during a drag can
temporarily drop; compare settled snapshots after placing the item.

Vendor sell metadata is return 11 of `C_Item.GetItemInfo` (global fallback only
when the namespaced function is absent), in copper per unit. Numeric zero with
available item metadata is displayed as zero; uncached/missing metadata is
unavailable. No vendor purchase price is read. Item identity groups by numeric
item ID, suitable for these sample trade goods; it does not distinguish random
suffixes, bonus variants, durability, charges or other instance-specific value.
Displayed totals are metadata estimates, not a sale quote or transaction proof.

## Actual-client checklist

Record results and failures in [REPORT.md](REPORT.md):

1. Capture the login build/API lines; record `sw_vers` and `uname -m` separately.
2. Choose at least two owned sample types (add IDs as needed). Compare printed
   slot quantities and totals against the open bags, including multiple stacks.
3. Move a stack between bags; after settling, total must stay unchanged. Split
   a stack, then merge it back; record before/after slot lines and totals. Repeat
   `/cwbags` to check totals do not accumulate. Do these actions manually using
   ordinary game controls; the probe never moves items.
4. Compare a sample's unit sell metadata with the game's vendor sell tooltip.
   Add an owned item with known zero sell metadata and record explicit zero.
   Inspect a genuinely unavailable/uncached item if obtainable; do not claim
   this path passed if the cache is already warm. Cache notifications should
   replace unavailable metadata when the client supplies it.
5. Record errors, missing events/APIs, and identity/coverage limitations. Confirm
   ordinary bag interactions still work. Use `/cwbags note <short outcome>` for
   manual evidence, avoiding character/account names.

Log out to persist `CopperwiseBagEvidence` in the account SavedVariables file
`CopperwiseBagProbe.lua` (five sessions, 180 bounded entries each). Copy only
relevant entries into the report. Sample selections reset on reload. Disable
the probe after verification. No automated pass declaration is made.

Repository checks: LuaJIT `loadfile` syntax compilation, `go vet ./...`, and
`go test ./...`. There is no statically typed addon code. The pre-agreed test
seam is actual-client observation; syntax and Go checks do not pass S03.
