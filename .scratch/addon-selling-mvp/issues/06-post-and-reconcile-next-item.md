# 06: Post and reconcile the next queued item

**What to build:** The player deliberately posts one reviewed AH-marked item through Copperwise, with confirmed completion reducing pending intent and unfinished quantities retained.

**Blocked by:** 05: Review AH-marked items in the native AH tab.

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] Use the verified supported direct native posting approach from Copperwise's AH tab, requiring a deliberate user action and final validation of reviewed item, quantity and terms.
- [ ] Preserve required native confirmations; timers, events, marking, opening windows, restoring queues and reload never initiate posts or automatic retries.
- [ ] Attribute completion using native owned-listing evidence and reconciled current holdings; a click, API return, shared event or bag delta alone is insufficient.
- [ ] Reduce intent only by confirmed posted units, remove zero-remainder entries and retain partial quantities for subsequent deliberate posts across stacks.
- [ ] Preserve intent on cancellation or failure; uncertain outcomes retain unresolved intent and block blind retries until reconciled, with explicit operator reconciliation when reliable attribution is unavailable.
- [ ] Verify a deliberate successful post, partial completion, changed availability/terms and unsuccessful/cancelled/uncertain handling in the target client; record chosen terms, native evidence and remaining limitations.
- [ ] Confirm normal AH navigation and other-addon activity cannot accidentally complete, duplicate or consume Copperwise's pending intent.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.
