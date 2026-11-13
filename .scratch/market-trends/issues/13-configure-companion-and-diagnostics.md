# 13: Configure the companion and inspect update diagnostics

**What to build:** The owner uses the desktop companion to configure its backend and inspect download, cache, and dataset-export outcomes.

**Blocked by:** 06: Collect and display one live item observation.

**Status:** ready-for-agent

- [ ] Provide a usable companion interface on macOS 26 Intel with backend configuration persisted across restarts.
- [ ] Support a local backend during development while preserving remote backend configuration as an option.
- [ ] Expose actionable download, cache, and dataset-export outcomes with distinct source, download/export, and import timing where observable. Explain that exported updates require login or `/reload`; successful export does not prove addon receipt.
- [ ] Verify valid and failed configuration changes and resulting visible export diagnostics through public behavior, without claiming a live addon connection or an unobserved import.

## Comments

2026-11-14: Reconciled with the owner-approved login and user-initiated `/reload` import model; ticket number and blocking edges retained.
