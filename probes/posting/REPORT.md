# S08 posting evidence

Status: complete — one commodity posting verified through Copperwise
preparation and Blizzard's native Sell button. Direct custom posting remains
a recorded integration failure. This is a bounded capability investigation.

## Capability conclusion

On client 1.60.1/build 70938/interface 16001, Copperwise can prepare a selected
bag commodity and hand its quantity, unit price and duration to visible native
Sell. The owner screenshot shows Rough Stone ×1, unit/total buyout 15 copper,
8 Hours and a 1-silver calculated deposit. After the native Create Auction
click, the owner confirms a new owned listing and one fewer Rough Stone in bags,
with no errors. This is posting evidence, not evidence of a completed sale.

The earlier cancelled Copperwise preview disabled the action and left the
item in bags. Away-from-AH refusal, native tab opening and matching native
deposit were also observed. Duration indices are 2/8/24 hours in this client.
Deposits continue to use native calculation, not a fixed fee formula.

The successful handoff screenshot shows native and Auctionator tabs present.
No Auctionator API is used. This establishes one idle-coexistence sample only.
The owner did not explicitly change a previous native duration before this
handoff; visible 8 Hours is verified, transition-specific refresh is not.

## Limits and unexercised paths

- Direct PostCommodity calls were repeatedly blocked; root cause is unresolved.
  Final execution therefore remains on native Sell, outside Copperwise's tab.
- The revised probe submits no transaction itself and does not infer completion
  from events. The operator must inspect native fields and the owned listing.
- Native search can change price after handoff; immediate readback is not a
  promise that terms remain fixed. Final visible review is required.
- Noncommodity handoff refuses. Cross-stack quantities, multisell, batch posting,
  concurrent-addon transactions, extra confirmation dialogs and server failures
  are unverified. No fallback dependency or restriction bypass is established.
- Repeated-handoff guard and lifecycle automation checks were source-reviewed;
  a full runtime matrix was not exercised. Empty-slot and moved-item paths were
  not independently observed. Cancellation supplies the ticket's negative case.
- No auction ID, final stack total or new local OS/architecture output was
  supplied for the successful handoff. Evidence is owner confirmation plus
  the native Sell screenshot, not an automated transaction ledger.

## Repository evidence

- Standalone native tab and operator-selected preview; current button only
  prepares native Sell. Failed direct-dispatch experiments are recorded below.
- Lua 5.1 syntax compilation passed; Go validation recorded in ticket comments.
- No fake runtime/private-helper tests; acceptance uses the owner-approved client seam.

## Owner runtime observations

- Client 1.60.1/build 70938/interface 16001; Alliance, region 3.
- Away from AH, `/cwpost` refused; status showed open=false, attempted=false.
- At AH, owner confirms the posting tab opened; status at 1794695563
  showed open=true, attempted=false. Status repeated the prior refusal text;
  that text was stale, not a new failure. Button states remain unconfirmed.
- Native Sell duration choices, in order: 2, 8, 24 hours. Corrected the
  probe's provisional 12/24/48 labels. Owner selected Rough Stone ×1,
  buyout 15 copper and duration 8 hours (index 2). No dispatch evidence yet.

- Preview screenshot: Rough Stone 2835, bag 0 slot 1, stack/quantity 1,
  commodity unit/total buyout 15 copper, duration index 2, deposit 100 copper.
- Owner confirms Cancel preview disabled Post once and retained the bag item.
- Native Sell independently reports the same 1-silver deposit. Future deposit
  changes are owner-reported expectations, not measured rules; calculation
  continues to use the client API without a hardcoded formula.
- Dispatch at 1794696217 (quantity 1, price 15, duration 2) produced
  “Interface action failed because of an AddOn”; post-return=nil. Owner
  reports no native listing. Status at 1794696225: open=true, attempted=true.
  This is a blocked attempt, not successful posting evidence.
- Follow-up removes protected-call wrappers from the hardware Post button
  and calls PostCommodity/PostItem directly, matching native selling call
  shape. Adds blocked/forbidden event diagnostics. Root cause and corrected
  behavior remain unverified; this change is not evidence of a successful post.

- Revised direct dispatch at 1794696364 still blocked: UNKNOWN(), nil return,
  no listing reported. The external-post message was a diagnostic bug: the
  synchronous blocked handler reset the own-call flag before its post-hook.
  Removed transaction-function hooks entirely; public events and native Auctions
  remain the evidence seam. This isolates another possible restriction source;
  no root cause or successful correction is claimed yet.

- Hook-free direct dispatch at 1794696876 still blocked, now explicitly naming
  PostCommodity(). Screenshot shows disabled Post once and blocked feedback;
  no success is claimed. Taint logging enabled by owner; local taint.log exists
  but was still empty when inspected immediately after this attempt. Awaiting
  client log flush before diagnosing further. Removing wrappers/hooks has not
  established the cause or resolved the restriction.

- After logout, taint.log flushed the blocked PostCommodity stack for the
  1794696876 attempt. It also shows synchronous blocked-event diagnostics
  entering record/print and native chat SecureTypes/CircularBuffer code during
  that call. This does not establish which operation first caused the block.
  Follow-up queues all probe chat messages for the next OnUpdate, outside
  transaction and synchronous event stacks. Runtime retest remains pending.

- Deferred-chat variant also failed. Flushed log at 23:57:44.939 shows the
  blocked PostCommodity call at Probe.lua:118. Its chat stack is now Blizzard's
  own DisplayInterfaceActionBlockedMessage, not probe record/print. This rules
  out probe synchronous chat reporting as the sufficient explanation for the
  repeated block; no root cause established. Stop repeating this custom-call
  path until a distinct supported transaction route or isolation evidence exists.

- Control: with Copperwise Posting Probe disabled, owner confirms native Sell
  successfully posted Rough Stone ×1 at 15 copper for 8 hours. This establishes
  native manual posting for those terms, not a successful Copperwise post.
- Revised investigation uses a preparation-only native Sell handoff for commodity
  samples. The Copperwise button revalidates, opens native Sell, populates
  quantity/price/duration and reads them back. It never calls a transaction API
  or clicks a native button. The operator must review and click native Post.
  Handoff behavior remains unverified. Native search may update price after
  handoff; final visible review is required. Custom-tab direct posting remains
  a recorded integration failure, with no bypass or Auctionator dependency.

- 2026-11-15 integrated success: owner screenshot after Copperwise Review native
  Sell shows Rough Stone, quantity 1, unit/total price 15 copper, duration
  8 Hours and deposit 1 silver. Owner then clicked native Create Auction and
  explicitly confirmed a new owned listing and one fewer bag item, no errors.
  This supersedes handoff-pending notes above for this commodity sample.
