# Ticket 01 evidence

## Current outcome

**Pass: login and user-initiated `/reload` imports verified in the target client.**
The owner observed initial revision A=15, then B=34 and C=44 after two explicit
reloads. Independently inspected newer exports did not replace loaded B or C
before a reload. Source, download, export and import times remain separate, and
the addon reports companion connection/newer-export state as unknown.

Ticket 01 is complete. This is a synthetic capability probe, not a production
transport contract, market-data verification or approval of all Phase 0 work.
Other Phase 0 gates still apply.

## Environment and setup, 2026-11-14

- Actual running client chat: version 1.60.1, build 70938, interface 16001.
- Local host: macOS 26.6.2, build 25G83, x86_64 (Intel).
- Installed `.build.info`: active EU `wowf`, version 1.60.1.70938.
- Installed Auctionator version 346; it is not a dependency of this probe.
- Go toolchain: go1.26.5 darwin/amd64.

The owner ran the real backend and companion following the
[repeatable procedure](README.md), with exports into the installed Forever
AddOns directory. CopperwiseDeliveryProbe depends on CopperwiseDeliveryData;
both use ordinary addon loading. The old installed repeated-load experiment
initially lacked `/cwprobe` and marked the data addon LoadOnDemand. Installed
Probe.lua and both manifests were updated from the repository, preserving the
companion's Data.lua. The owner then supplied initialization output following
full-restart/login instructions and later explicitly identified each reload.

The probe captures loaded data at PLAYER_LOGIN; `/cwprobe` only reports that
snapshot. No automatic reloads, load-on-demand polling, client modifications,
input automation or protections bypasses were used. File export alone was never
accepted as proof of in-client import.

## Runtime evidence

The chat lines below were supplied directly by the owner. Only relevant probe
output is retained; unrelated game/chat content is omitted. Export evidence was
read directly from the installed Data.lua (and cache.json for revision 31).

| Observation | Actual result |
| --- | --- |
| Initial login import A | revision 15; source=1794649133, download/export=1794649140, import=1794649145 |
| A stays loaded | Subsequent status retained 15 and import 1794649145, source age rising from 12 to 185 seconds |
| First explicit reload imports B | revision 34; source=1794649418, download/export=1794649430, import=1794649432 |
| Newer export while B remains loaded | Inspected export 37 (source=1794649463, download/export=1794649464), then fresh owner status still showed B=34 and import=1794649432 |
| Second explicit reload imports C | revision 44; source=1794649568, download/export=1794649570, import=1794649573 |
| Newer export while C remains loaded | Inspected export 47 (source=1794649613, download/export=1794649624), then fresh owner status still showed C=44 and import=1794649573 |
| Optional companion-stop behavior | Not exercised; not required for this gate |
| Errors | Old installed probe corrected before acceptance; no runtime error reported in the revised import sequence |

Relevant owner-provided chat:

```text
t=124624.131 client=1.60.1 build=70938 interface=16001 evidenceSession=4
t=124624.131 LOADED revision=15 observedAt=1794649133 downloadedAt=1794649140 exportedAt=1794649140 importedAt=1794649145 sourceAgeSeconds=12
t=124635.529 LOADED revision=15 observedAt=1794649133 downloadedAt=1794649140 exportedAt=1794649140 importedAt=1794649145 sourceAgeSeconds=23
t=124797.522 LOADED revision=15 observedAt=1794649133 downloadedAt=1794649140 exportedAt=1794649140 importedAt=1794649145 sourceAgeSeconds=185
t=124910.169 client=1.60.1 build=70938 interface=16001 evidenceSession=5
t=124910.169 LOADED revision=34 observedAt=1794649418 downloadedAt=1794649430 exportedAt=1794649430 importedAt=1794649432 sourceAgeSeconds=14
t=125008.71 LOADED revision=34 observedAt=1794649418 downloadedAt=1794649430 exportedAt=1794649430 importedAt=1794649432 sourceAgeSeconds=111
t=125051.428 client=1.60.1 build=70938 interface=16001 evidenceSession=5
t=125051.428 LOADED revision=44 observedAt=1794649568 downloadedAt=1794649570 exportedAt=1794649570 importedAt=1794649573 sourceAgeSeconds=5
t=125056.649 LOADED revision=44 observedAt=1794649568 downloadedAt=1794649570 exportedAt=1794649570 importedAt=1794649573 sourceAgeSeconds=9
t=125208.082 LOADED revision=44 observedAt=1794649568 downloadedAt=1794649570 exportedAt=1794649570 importedAt=1794649573 sourceAgeSeconds=160
```

The addon also reported companion connection UNKNOWN, newer exports UNKNOWN,
and refresh only at login or user /reload. It did not claim to know the separately
inspected exports.

## Interpretation and limits

The imports 15 -> 34 -> 44 establish initial loading and two newer revisions at
explicit reload boundaries. Ordered export/status observations establish that
loaded B and C stay unchanged despite newer exports. Source age increases while
import time remains fixed. Download/export timestamps can coincide at one-second
resolution; they remain distinct fields. Synthetic source timestamps and payload
metadata are probe claims, not independently verified upstream observations.

The initial A status was sampled before the independent inspection of export 31
(source=1794649373, download/export=1794649384). The owner's later before-reload
paste repeated those old status lines; it did not establish an ordered
export-then-status check for A. That limitation is retained rather than claiming
it passed. The same unchanged-loaded-data capability was subsequently established
with ordered observations for both B (after export 37) and C (after export 47).

Evidence is supplied chat and direct file observations, not a recording of all
client activity. Companion-stop behavior, outages, large payloads and rendering
performance are not established here. SavedVariables can additionally preserve
probe observations when the owner logs out; closure does not depend on another
log export. The earlier repeated-load experiment is not used as gate evidence.

## Repository verification

Existing CLI integration tests cover backend publication, companion caching,
export contents and separate timestamps. Targeted/full Go tests, build, vet,
LuaJIT syntax compilation and diff checks passed during probe implementation.
Those checks establish no in-client import behavior; the runtime observations
above provide that evidence. No implementation change was needed for this run;
only installed files were brought up to date and evidence was recorded.
