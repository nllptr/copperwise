# 01: Prove dataset imports at login and reload

**What to build:** A runnable minimal backend, companion, and addon probe demonstrates dataset imports at login and user-initiated `/reload` on macOS 26 Intel, with the loaded dataset unchanged between imports.

**Blocked by:** None (can start immediately).

**Status:** completed — login/reload import capability verified in the target client

- [x] Record the actual running client and platform builds, ordinary addon-loading/export setup, and reproducible probe steps.
- [x] Verify an initial login import, then multiple distinct companion exports becoming visible after user-initiated `/reload` cycles. Confirm newer exports do not replace the loaded dataset before login or `/reload`; exports alone do not pass.
- [x] Record source, download/export, and import times separately where observable. The addon reports loaded data and source age without claiming a live companion connection or knowledge of unseen exports.
- [x] If the gate fails, report evidence and viable alternatives, and stop dependent full implementation until the owner explicitly decides. (Not triggered: gate passed.)

## Comments

2026-11-14: The owner replaced continuous in-session imports with login and user-initiated `/reload` imports. The earlier repeated-load experiment is historical work and has not passed the revised gate. Adapt the existing backend/companion probe and replace repeated load-on-demand polling with ordinary addon loading; do not automatically trigger reloads or bypass client protections. Record actual in-client observations before completing this ticket. Dependent full implementation remains gated by the revised acceptance criteria.

2026-11-14: Adapted the probe to ordinary dependency loading and a read-only `/cwprobe` status command. Separate source, download, export, and import timestamps are reported without connectivity or unseen-export claims. Updated reproducible login/unchanged/reload/unchanged/reload instructions and evidence report under the delivery probe. The runtime gate remains pending; no acceptance criteria are marked complete based solely on file exports or repository checks.

2026-11-14: Completed the actual-client capability run after replacing outdated
installed probe files. Owner-provided chat shows initial A=15, then B=34 and C=44
after two explicit reloads on client 1.60.1 (70938), interface 16001, macOS 26.6.2
(25G83), x86_64. Directly inspected newer exports 37 and 47, followed by fresh
owner `/cwprobe` observations, establish loaded B and C staying unchanged with
fixed import times. Source/download/export/import fields are recorded separately;
the addon keeps connection/newer-export state UNKNOWN. The initial A interval
lacks an ordered newer-export/status pair; this limitation is explicit in the
[evidence report](../../../probes/delivery/REPORT.md), and the capability was
verified on both subsequent loaded revisions instead. Optional companion-stop
behavior was not exercised. Other Phase 0 gates remain in force.

