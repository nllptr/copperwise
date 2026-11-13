# Domain Docs

## Before exploring

Read the root `GLOSSARY.md` and relevant ADRs in `docs/adr/`.

If these files do not exist, proceed silently. Do not flag
their absence or suggest creating them upfront.
The `/domain-modeling` skill creates them lazily as terms
and decisions are resolved.

## Layout

This repo uses a single-context layout:

- `GLOSSARY.md`: domain vocabulary.
- `docs/adr/`: architecture decision records.

## Use the glossary's vocabulary

Use the glossary's defined terms when naming domain concepts
in issues, proposals, hypotheses, and tests.

If a concept is missing, reconsider whether it belongs or
note the gap for `/domain-modeling`.

## Flag ADR conflicts

Explicitly surface proposals that contradict an existing ADR,
identifying the ADR and explaining why it should be reopened.
