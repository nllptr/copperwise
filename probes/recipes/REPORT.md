# S05 runtime evidence

Status: pending — probe implemented; no target-client recipe observations yet.

## Repository verification (2026-11-14)

- LuaJIT `loadfile` syntax compilation: passed.
- `go vet ./...`: passed.
- Full `env CGO_ENABLED=0 go test ./...`: passed outside the sandbox; the
  sandboxed run could not bind local HTTP test ports.
- `git diff --check`: passed.
- Separate code-review axes against pre-work commit `2a83cf7`: Standards 0
  findings; Spec 0 actionable defects. Runtime acceptance remains pending.
- Installed `CopperwiseRecipeProbe` into the local Forever AddOns directory.

## Environment

- Client/build/interface: pending login output.
- OS/build/architecture: pending this run; earlier probes are not fresh evidence.
- Open owned professions and context API results: pending.

## Learned recipe

Pending: native UI comparison of recipe ID/name, learned state, each required
ingredient identity/quantity, output identity and yield range. Record optional,
alternative, currency and ambiguous output behavior separately if encountered.

## Unlearned discovery

Pending: `GetAllRecipeIDs` totals and example unlearned recipe, native UI learned
state comparison, filter changes and second profession where available. Catalog
coverage remains unverified. Record unsupported APIs and evidenced scope
alternatives rather than claiming a complete unlearned catalog.

## Ingredient sources and merchant prices

Pending: ingredient ID matched to a merchant offer, bundle price/count,
normalized copper/unit, stock, extended costs and native UI comparison.
Vendor sell metadata does not establish purchase cost. Unmatched ingredients
have unknown sources and purchase prices; dual-source selection is unresolved.

## Failures and limitations

- No runtime acceptance criteria passed by source inspection or syntax checks.
- Numeric item identity does not settle variant/quality handling.
- No crafting, purchasing, AH source classification or costing policy selected.
- Bounded saved evidence can evict old rows; preserve relevant samples promptly.
- Context loading, cache misses, unsupported APIs/events, variable yields,
  merchant discounts/currencies and non-item outputs need observed outcomes.
