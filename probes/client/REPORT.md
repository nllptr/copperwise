# Target-client capability evidence

Ticket 03's **capability gate passed for the tested sample paths**. This report
separates direct owner-reported runtime observations, recorded build/platform
evidence, and untested edge cases. It does not establish production rendering,
every interaction path or complete Phase 0 feasibility.

## Implemented probe

- Standalone interface-16001 addon, no credentials or delivery dependencies.
- Synthetic Peacebloom (2447), Copper Ore (2770) and Sharp Arrow (2515) samples: five hourly points
  spanning four hours, aligned price and stock plots, local labels and timezone.
  Price plots include a median and middle-50% spread bounds, explicitly not
  confidence or sales. These fixtures establish no production calculation rules.
- Sample-name/ID lookup, movable window, two actions exposed to the game's
  configurable Key Bindings interface, and visible-GameTooltip item access.
- Synthetic tooltip additions for the three sample IDs, duplicate suppression and
  tooltip-clear handling. Prefer item post-call processing, otherwise use a
  supported legacy item-tooltip hook. Errors are diagnostic outcomes, not passes.
- Secure post-hook observation of supported sample items through Alt-modified
  item clicks. It does not claim a new click shortcut, replace the existing
  handler or change its return value. Normal Shift-link, stack movement/splitting
  and Ctrl-preview actions were owner-confirmed; modifier observation itself
  remains unverified.
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

## Acceptance record

| Capability | Result | Evidence and limits |
| --- | --- | --- |
| Client/platform | Recorded | Saved probe evidence: client 1.60.1, build 70938, interface 16001. Local host `sw_vers`: macOS 26.6.2 (25G83); `uname -m`: x86_64 (Intel). |
| Graph rendering | Pass — owner observed | Both graphs visible; selecting Copper Ore changes both; time positions align and labels/timezone match the computer. Scale/resolution not recorded. |
| Access away from AH | Pass — owner confirmed | Owner confirmed the window opens with its binding away from the auction house. Exact location not recorded. |
| Configurable binding | Pass — owner confirmed after fix | Both window-toggle and hovered-item bindings work after `/reload` without reassignment. Exact chosen keys not recorded. |
| Name lookup | Pass — sample lookup | Copper Ore selection updates both graphs; an unknown query hides both with a no-match message. Localized names and ambiguous queries remain unchecked. |
| Tooltip additions | Pass — Sharp Arrow sample | Owner confirmed the Sharp Arrow addition after reloading the updated probe. Repeated hovers/rebuilds, duplicate suppression and ItemRefTooltip were not separately confirmed. |
| Hovered-item access | Pass — Sharp Arrow sample | Hovered-item binding opens the sample successfully. Absent/unsupported-tooltip feedback remains unchecked. |
| Modified-item observation | Not validated; no shortcut promised | Hook observation is optional research. The ticket's hovered-item-or-modifier criterion is satisfied by hovered-item access. |
| Original interactions | Pass — tested normal actions | Owner confirmed Shift-click linking, stack movement/splitting and Ctrl-click equipment preview work with the probe enabled. Existing addon/AH shortcuts and combat remain unchecked. |

### Owner observations, 2026-11-14

The owner initially saw only delivery-probe logs because the client probe was not
installed. The client probe was subsequently installed into the Forever AddOns
directory. The owner then reported seeing the graphs and confirmed:

- Searching Copper Ore and pressing Enter changes both graphs.
- An unknown search hides both graphs and displays the no-match message.
- Time positions align across the graphs; labels and timezone match the computer.

These are direct owner reports, not screenshots or automatically captured logs.
Opening away from the auction house was confirmed later in the same session.

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
error. The owner subsequently confirmed "now it works", establishing successful
window-binding use after the fix. Later confirmations of persistence and
hovered-item access are recorded below; the assigned keys were not reported.

At the owner's request, Sharp Arrow was added as a third synthetic sample so
tooltip and hovered-item checks can use ammunition already in their bags.
Search, graphs and item interactions share the same sample catalog. Its tooltip
behavior was subsequently confirmed working by the owner. The owner also
explicitly confirmed that the tooltip and hover-open both work. Repeated-tooltip
duplicate suppression was not separately confirmed; absent/unsupported-tooltip
binding behavior remains unchecked.

The owner further confirmed that Shift-click linking Sharp Arrow into chat,
normal stack movement/splitting and Ctrl-click equipment dressing-room preview
work with the probe enabled. No errors or blocked actions were reported for
these checks. This does not establish combat behavior or every other addon's
shortcuts.

Finally, the owner answered "yes" to both remaining checks: opening with the
window binding away from the auction house, and both bindings working after
`/reload` without reassignment. These confirmations complete the ticket's core
capability checks. They do not imply exhaustive testing of the remaining cases
listed in the table.

Use `/cwclient note <outcome>` and preserve relevant SavedVariables lines after
logging out. Record errors, unavailable APIs and protected-action/taint failures.
Do not mark a capability passed just because construction or registration logged
success. A failed capability must retain its limitation in the Phase 0 report;
do not bypass client protections to force a pass.

## Verdict

**Pass for ticket 03's tested capability scope:** aligned sample rendering with
local time, sample-name lookup and no-match feedback, configurable window access
away from the auction house, binding persistence across reload, readable sample
tooltip additions and hovered-item opening, with the tested normal game actions
preserved. Client/platform builds are recorded above. Evidence consists of direct
owner confirmations, saved probe build output and local platform commands.

Untested limits remain explicit: combat, modifier-click shortcuts, exhaustive
tooltip rebuilding/comparison paths, localized/ambiguous searches, unsupported
hover feedback, and interactions with other addons/AH shortcuts. No modifier-click
shortcut or universal compatibility is promised. Ticket 03 is complete; ticket 05
and full implementation still require the other Phase 0 feasibility gates.
