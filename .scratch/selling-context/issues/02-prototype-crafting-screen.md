# 02: Explore the Crafting screen

**What to build:** The owner can select synthetic recipes, inspect output economics and explore queue intent using the same market-detail experience.

**Blocked by:** S01: Explore the Inventory screen.

**Status:** awaiting-owner-review

**Labels:** ready-for-agent

**Type:** prototype

- [x] Show known recipes and an Include unlearned recipes option, with unlearned clearly distinguished from currently craftable.
- [x] For one sample recipe, show output buyout, vendor sell value, separate per-output crafting cost and estimated margin; include an incomplete-input state.
- [x] Demonstrate entering craft intent and seeing required materials, bag/bank locations and shopping needs without executing purchases or crafts.
- [ ] Record feedback on the recipe-to-shopping journey and quantity terminology; do not silently finalize sorting units, persistence or bank-subtraction rules.

## Scope and verification

Synthetic journey only; no claim of recipe-catalog coverage, client data access or completed queue implementation.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.

2026-11-14: Implemented the [shared Inventory/Crafting browser study](../../../probes/ui-inventory/README.md#crafting-journey-s02).
Synthetic learned/unlearned recipes, per-output economics, incomplete inputs,
craft/output counts and combined shopping requirements are available for review.
Bank subtraction is an explicit optional comparison; ranking and production queue
policies remain undecided. Browser-only checks cover visible behavior; no client
catalog, transaction or production queue capability is claimed. Owner feedback on
the recipe-to-shopping journey and quantity terminology is pending; the final
acceptance item remains open. See README review prompts and verification evidence.
