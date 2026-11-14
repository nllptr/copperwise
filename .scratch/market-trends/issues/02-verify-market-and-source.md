# 02: Verify market identity and upstream observations

**What to build:** A runnable upstream probe establishes that collected observations describe the intended Forever EU RP Alliance market and comparable ordinary trade goods.

**Blocked by:** None (can start immediately).

**Status:** in-progress — runnable probe implemented; awaiting credentials and authenticated observations

- [ ] Record verified API market identifiers, upstream authentication requirements, and actual source responses without distributing secrets to clients.
- [ ] Verify comparable item identity, partial-stack quantity semantics, per-unit buyout normalization, bid-only listings, and successful empty versus failed responses.
- [ ] Establish source observation timestamps, unchanged-snapshot detection, actual update cadence, and upstream limits.
- [ ] Record applicable retention requirements and unresolved constraints; do not assume aggregates permit indefinite retention.

## Comments

2026-11-14: Implemented the backend-only [upstream probe](../../../probes/upstream/README.md)
and [evidence report](../../../probes/upstream/REPORT.md). The owner approved CLI
integration tests against a controlled HTTP source and confirmed credentials are
not yet available; registration is a future owner step. The probe captures
discovery responses, exact candidate per-unit prices, full item identities,
stock including bid-only units, HTTP/cache metadata, and unchanged-content
comparisons. Controlled fixtures are not live market evidence. All acceptance
checkboxes remain pending authenticated mapping, semantics and cadence checks;
ticket 04 and the Phase 0 gate remain blocked. Current official terms research
supports a maximum 30-day TTL and 36,000 calls/hour, subject to rechecking full
current terms and any stricter constraints before deployment.

