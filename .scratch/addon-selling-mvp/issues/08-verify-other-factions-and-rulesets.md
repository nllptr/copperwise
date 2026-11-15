# 08: Verify other factions, markets and rulesets

**What to verify:** Dedicated client acceptance for factions, markets and rulesets beyond the owner's currently verified Forever Alliance environment.

**Blocked by:** Suitable client/character access for each tested environment; complete posting checks after ticket 06.

**Status:** deferred

**Labels:** acceptance, deferred

- [ ] Record each tested client build, ruleset, region, realm, faction and AH type; explicitly list environments not tested.
- [ ] Verify a character in an incompatible faction/realm/region cannot read another market's retained prices, supply or source time; its own scan remains separately scoped and returning to the original character preserves its observations.
- [ ] Verify compatible characters share observations through ordinary reload/logout without sharing holdings or sale intent.
- [ ] For each additional supported faction/ruleset, verify installation, native APIs/UI, full scan, retained observations, ranking/commission, stale warnings and configuration persistence.
- [ ] Repeat sale-intent, posting-review, deliberate-post and reconciliation acceptance in each additional supported environment once those slices exist.
- [ ] Record outcomes and limitations; fix compatibility defects before claiming support for that environment.

## Scope and verification

All additional-faction/ruleset acceptance for this MVP is tracked here, including
related incompatible-market client tests previously left in ticket 03 and the
release checklist. Current-environment acceptance remains in its originating
tickets. Existing automated isolation checks stay in the test suite.

This ticket defers testing; it does not establish compatibility or expand the
supported product scope. Neutral/cross-faction AH support and its commission
remain a separate later-release feature decision. Other rulesets require an
explicit support decision before implementation changes.

## Comments

Owner requested on 2026-11-15: “let's defer all tests for other factions/rulesets
to a dedicated ticket”. A suitable alternate character is currently unavailable.
This ticket does not block ticket 03 or current-environment MVP acceptance.
