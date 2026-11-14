# 19: Make shopping requirements bank-aware

**What to build:** The player sees bank-owned ingredients explicitly counted or excluded under the agreed policy, with withdrawal needs and remaining shopping quantities.

**Blocked by:** S18: Combine queued crafts without double counting; S12: Show dated bank holdings in Inventory.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Apply the S07-approved cached-bank eligibility rule to existing combined requirements, retaining separate bags, bank, age and unknown indicators.
- [ ] Show exactly which owned quantities were subtracted and what must be withdrawn before crafting; remaining AH shopping need cannot be negative.
- [ ] After observed withdrawal or movement, avoid counting the same material in both bag and bank and recalculate requirements using current evidence.
- [ ] Verify eligible, stale/unknown and excess-bank cases with actual-client observation evidence plus controlled examples; do not claim banking-alt holdings or automatic transfer.

## Scope and verification

Bank-aware material accounting only; ownership rules are prerequisites, not silently chosen implementation defaults.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
