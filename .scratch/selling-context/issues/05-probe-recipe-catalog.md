# 05: Verify recipe metadata and discovery

**What to build:** A target-client probe displays a known recipe and determines whether unlearned recipes for the character's professions can be discovered.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

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

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
