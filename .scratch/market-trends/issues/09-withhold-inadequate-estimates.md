# 09: Withhold misleading price summaries

**What to build:** The addon applies the validated evidence rules to sparse or otherwise inadequate observations and explains withheld price estimates.

**Blocked by:** 07: Accumulate and browse seven-day history.

**Status:** ready-for-agent

- [ ] Apply Phase 0 evidence thresholds consistently to graph reference estimates and available summaries.
- [ ] Preserve useful stock, coverage, and observation context when a price estimate is withheld.
- [ ] Explain insufficient evidence and distinguish price spread from confidence or predictions.
- [ ] Controlled sparse, extreme, and adequate distributions verify visible estimates and explanations through the real pipeline.

## Comments

2026-11-14: Ticket 17's [synthetic UI study](../../../probes/ui-history/README.md)
withholds the median and band in a manually selected sparse fixture while keeping
stock and provenance visible. This proposes the presentation only; no evidence
threshold, quantile algorithm or production acceptance is established.

