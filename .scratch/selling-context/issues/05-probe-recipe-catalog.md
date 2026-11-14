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
