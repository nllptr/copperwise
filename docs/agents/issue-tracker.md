# Issue tracker: Local Markdown

Issues and specs live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`.
- Spec: `.scratch/<feature-slug>/spec.md`.
- One file per implementation ticket:
  `.scratch/<feature-slug>/issues/<NN>-<slug>.md`,
  numbered from `01`.
- Record state in a `Status:` line near the top.
- Append conversation under `## Comments`.

## Publishing and fetching

When a skill says "publish to the issue tracker", create the
appropriate spec or issue file using the conventions above.
Create directories as needed.

When a skill says "fetch the relevant ticket", read the file
at the referenced path.

## Wayfinding operations

Used by `/wayfinder`.

- Map: `.scratch/<effort>/map.md`, containing Notes,
  Decisions-so-far, and Fog.
- Child ticket: `.scratch/<effort>/issues/NN-<slug>.md`.
  Include the question and a `Type:` line:
  research, prototype, grilling, or task.
- Status: open, claimed, or resolved.
- Blocking: `Blocked by: NN, NN` near the top.
  A ticket is unblocked when all listed tickets are resolved.
- Frontier: select the first open, unblocked, unclaimed ticket
  by number.
- Claim: set `Status: claimed` and save before work.
- Resolve: append the answer under `## Answer`, set
  `Status: resolved`, and append a summary and link to
  Decisions-so-far in the map.
