# Target-client capability evidence

Ticket 03 is **pending in-client verification**, not passed. This report records
what exists in the repository and what remains to be observed. No running client
build, graph screenshot, working keybinding, tooltip appearance or preserved
interaction has been observed for this probe yet.

## Implemented probe

- Standalone interface-16001 addon, no credentials or delivery dependencies.
- Synthetic Peacebloom (2447) and Copper Ore (2770) samples: five hourly points
  spanning four hours, aligned price and stock plots, local labels and timezone.
  Price plots include a median and middle-50% spread bounds, explicitly not
  confidence or sales. These fixtures establish no production calculation rules.
- Sample-name/ID lookup, movable window, two actions exposed to the game's
  configurable Key Bindings interface, and visible-GameTooltip item access.
- Synthetic tooltip additions for the two sample IDs, duplicate suppression and
  tooltip-clear handling. Prefer item post-call processing, otherwise use a
  supported legacy item-tooltip hook. Errors are diagnostic outcomes, not passes.
- Secure post-hook observation of supported sample items through Alt-modified
  item clicks. It does not claim a new click shortcut, replace the existing
  handler or change its return value. Preservation of normal actions still
  requires testing.
- Bounded SavedVariables evidence: five sessions, 120 events per session, 320
  characters per event. Build information and operator notes are recorded; no
  character/account names or real auction snapshots are collected automatically.

## Research basis (2026-11-14)

Locally installed Forever addons declare interface 16001. OneForAll's Map.lua
uses CreateLine, SetStartPoint and SetEndPoint. Its QoL.lua and Auctionator's
tooltip hooks demonstrate capability-selected modern/legacy hook patterns.
Auctionator's selling hooks use a secure post-hook on HandleModifiedItemClick.
Their presence informs the experiment; it proves none of this probe's behavior
in the target client. No dependency on either addon is introduced.

The following Blizzard-generated source mirrored on the `forever` branch was
read as API-shape research, not runtime evidence:

- [SimpleLineAPI documentation](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleLineAPIDocumentation.lua)
  describes line endpoint methods and their frame-relative coordinates.
- [Tooltip data handler](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipDataHandler.lua)
  exposes AddTooltipPostCall and distinguishes secure/insecure callbacks.

## Repository validation

LuaJIT's Lua-5.1-compatible `loadfile` parser accepted Graphs.lua and Probe.lua
without executing them. Python's XML parser accepted Bindings.xml. `go vet ./...`
and the full `go test ./...` suite passed. These checks validate syntax and the
existing Go packages only.

The spec's pre-agreed prerequisite testing seam is the actual in-client
capability probe. The [manual acceptance procedure](README.md#in-client-acceptance)
provides expected outcomes at that seam; no fake frame API harness or private
helper test seam was introduced. Automated red/green runtime checks are not
available here. All visual and behavioral expectations remain unexecuted.

## Acceptance record — fill from an actual run

| Capability | Result | Evidence needed |
| --- | --- | --- |
| Client/platform | Pending | GetBuildInfo output; actual macOS version and Intel architecture |
| Graph rendering | Pending | Both items; alignment, labels, timezone, readable scale/resolution |
| Access away from AH | Pending | Location context and successful window opening |
| Configurable binding | Pending | Assigned unused key; toggle; saved binding after manual reload |
| Name lookup | Pending | Both aliases, cached localized names, no-match and ambiguous queries |
| Tooltip additions | Pending | GameTooltip/ItemRefTooltip, legibility, repeated builds, no duplicates |
| Hovered-item access | Pending | Supported tooltip/key opens matching sample; absent/unsupported feedback |
| Modified-item observation | Pending | Hook path actually invoked; no claimed Alt-click shortcut |
| Original interactions | Pending | Normal clicks, Shift-link, Ctrl-preview, existing addon/AH shortcuts, combat |

Use `/cwclient note <outcome>` and preserve relevant SavedVariables lines after
logging out. Record errors, unavailable APIs and protected-action/taint failures.
Do not mark a capability passed just because construction or registration logged
success. A failed capability must retain its limitation in the Phase 0 report;
do not bypass client protections to force a pass.

## Verdict

The runnable probe and repeatable steps are ready. All ticket acceptance criteria
remain pending actual target-client evidence. Ticket 05 and dependent full
implementation remain gated by the Phase 0 feasibility requirements.
