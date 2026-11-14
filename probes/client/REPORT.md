# Target-client capability evidence

Ticket 03 is **partially verified in-client**, not passed. This report separates
owner-reported runtime observations from remaining checks. Exact running client
build, platform details, bindings, tooltips and preserved interactions still need
evidence.

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
available here. Owner-reported runtime results are recorded separately below.

## Acceptance record — fill from an actual run

| Capability | Result | Evidence needed |
| --- | --- | --- |
| Client/platform | Partial — saved probe evidence | client 1.60.1, build 70938, interface 16001, macOS reported by the addon. Actual macOS version and Intel architecture remain to be recorded. |
| Graph rendering | Partial — owner observed | Both graphs visible; selecting Copper Ore changes both; time positions align and labels/timezone match the computer. Scale/resolution not recorded. |
| Access away from AH | Pending | Location context and successful window opening |
| Configurable binding | Failed — owner reported; diagnosis pending | Owner reports binding does not work. Need to distinguish missing settings entry from failed key dispatch and record assigned key. Persistence not verified. |
| Name lookup | Partial — owner observed | Copper Ore selection updates both graphs; an unknown query hides both with a no-match message. Localized names and ambiguous queries remain unchecked. |
| Tooltip additions | Pending | GameTooltip/ItemRefTooltip, legibility, repeated builds, no duplicates |
| Hovered-item access | Pending | Supported tooltip/key opens matching sample; absent/unsupported feedback |
| Modified-item observation | Pending | Hook path actually invoked; no claimed Alt-click shortcut |
| Original interactions | Pending | Normal clicks, Shift-link, Ctrl-preview, existing addon/AH shortcuts, combat |

### Owner observations, 2026-11-14

The owner initially saw only delivery-probe logs because the client probe was not
installed. The client probe was subsequently installed into the Forever AddOns
directory. The owner then reported seeing the graphs and confirmed:

- Searching Copper Ore and pressing Enter changes both graphs.
- An unknown search hides both graphs and displays the no-match message.
- Time positions align across the graphs; labels and timezone match the computer.

These are direct owner reports, not screenshots or automatically captured logs.
Opening away from the auction house has not yet been explicitly confirmed.

The owner subsequently reported that the keybinding does not work. The installed
Bindings.xml matches the repository version. No saved Copperwise key assignments
were found in the on-disk bindings cache during diagnosis; unsaved/current
in-memory bindings cannot be inferred from that. Saved probe evidence contains
`client=1.60.1 build=70938 interface=16001 platform=macOS (version/architecture unknown)`.
The client FrameXML.log subsequently provided concrete load errors:
`CopperwiseClientProbe/Bindings.xml:2 Unrecognized XML: Binding` and corresponding
attribute errors at both binding entries. Bindings.xml had incorrectly been
listed in the TOC and was parsed as ordinary UI XML. Removed the TOC entry so
the dedicated binding loader can handle it; added explicit settings categories
matching the installed OneForAll binding pattern. This fixes an observed loading
error; actual binding visibility, dispatch and persistence still require retest.

Use `/cwclient note <outcome>` and preserve relevant SavedVariables lines after
logging out. Record errors, unavailable APIs and protected-action/taint failures.
Do not mark a capability passed just because construction or registration logged
success. A failed capability must retain its limitation in the Phase 0 report;
do not bypass client protections to force a pass.

## Verdict

The owner has confirmed basic graph rendering, time alignment and sample/no-match
lookup behavior. Remaining client/platform and interaction checks keep ticket 03
open. Ticket 05 and dependent full implementation remain gated by the Phase 0
feasibility requirements.
