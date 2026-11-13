# 01: Prove dataset imports at login and reload

**What to build:** A runnable minimal backend, companion, and addon probe demonstrates dataset imports at login and user-initiated `/reload` on macOS 26 Intel, with the loaded dataset unchanged between imports.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Record the actual running client and platform builds, ordinary addon-loading/export setup, and reproducible probe steps.
- [ ] Verify an initial login import, then multiple distinct companion exports becoming visible after user-initiated `/reload` cycles. Confirm newer exports do not replace the loaded dataset before login or `/reload`; exports alone do not pass.
- [ ] Record source, download/export, and import times separately where observable. The addon reports loaded data and source age without claiming a live companion connection or knowledge of unseen exports.
- [ ] If the gate fails, report evidence and viable alternatives, and stop dependent full implementation until the owner explicitly decides.

## Comments

2026-11-14: The owner replaced continuous in-session imports with login and user-initiated `/reload` imports. The earlier repeated-load experiment is historical work and has not passed the revised gate. Adapt the existing backend/companion probe and replace repeated load-on-demand polling with ordinary addon loading; do not automatically trigger reloads or bypass client protections. Record actual in-client observations before completing this ticket. Dependent full implementation remains gated by the revised acceptance criteria.

