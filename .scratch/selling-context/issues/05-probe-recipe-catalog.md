# 05: Verify recipe metadata and discovery

**What to build:** A target-client probe displays a known recipe and determines whether unlearned recipes for the character's professions can be discovered.

**Blocked by:** None (can start immediately).

**Status:** in-progress — read-only probe implemented; target-client evidence pending

**Labels:** ready-for-agent

**Type:** prototype

- [ ] For one learned recipe, show ingredient identities and quantities, output identity and output yield, with actual-client evidence.
- [ ] Determine whether supported client data provides unlearned recipes; show their learned state or explicitly record unavailable/incomplete catalog coverage.
- [ ] Investigate metadata needed to distinguish vendor-sourced inputs from AH-sourced inputs; identify unavailable purchase prices, dual-source cases and recipe/yield ambiguity.
- [ ] Record builds, public API behavior and failures; do not invent recipe catalogs, source rules or variable yields when metadata is missing.

## Scope and verification

Metadata capability probe only. A failed capability returns evidenced alternatives rather than silently promising a complete unlearned catalog.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Owner runtime output at t=1794679416 confirms unlearned schematic
access for recipe 3817 (Cured Medium Hide): output 4233, yield 1–1, required
one item 4232 (name/sell metadata unavailable) and one Salt (4289). Salt matches
the earlier vendor offer at 45 copper/unit, distinct from its sell value of
12 copper/unit. `learned=false` coexists with `craftable=true`, so craftable
must not establish ownership/executability. Native UI comparisons remain
pending; full catalog coverage and dual-source rules remain unestablished.

2026-11-14: Owner supplied open-merchant runtime output at t=1794679330:
15 offers with purchase prices, bundle count 1, no extended costs, available=-1
and purchasable=true. Examples: Salt (4289) 45 copper/unit and Coarse Thread
(2320) 9 copper/unit. Full sample recorded in the report. This verifies the
merchant query path, not universal prices, ingredient-source exclusivity or
dual-source policy. Recipe matching, native UI comparison and unlearned
schematic evidence remain pending.

2026-11-14: Owner runtime output confirms client 1.60.1/70938/interface 16001
on macOS, own Leatherworking context (skill 65), and GetAllRecipeIDs returning
592 recipes (13 learned, 579 unlearned, 0 unknown). Learned recipe 2881 exposes
three Ruined Leather Scraps (2934) to one Light Leather (2318), with fixed
1–1 yield. Recorded in the runtime report. Native UI comparison, unlearned
schematic inspection and vendor purchase/source investigation remain pending;
no complete catalog or ingredient acquisition policy is established.

2026-11-14: Added the standalone [recipe probe](../../../probes/recipes/README.md)
with paged profession discovery, learned-state and schematic inspection, raw
yield/ingredient alternatives, context diagnostics and separate open-merchant
purchase quotes. No catalog completeness or ingredient-source policy is assumed.
The [runtime report](../../../probes/recipes/REPORT.md) and native UI comparison
checklist are ready. All acceptance items await actual-client observations;
repository checks do not pass this capability gate.

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
