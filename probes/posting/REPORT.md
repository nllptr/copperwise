# S08 posting evidence

Status: direct Copperwise posting blocked in actual client. Native manual
control posted successfully with the probe disabled. Revised preparation-only
handoff awaits actual-client verification; S08 is not complete.

## Repository evidence

- Standalone native tab and operator-selected preview; current button only
  prepares native Sell. Failed direct-dispatch experiments are recorded below.
- Lua 5.1 syntax compilation passed; Go validation recorded in ticket comments.
- No fake runtime/private-helper tests; acceptance uses the owner-approved client seam.

## Runtime record (fill from actual observation)

- Client/version/build/interface, OS/architecture:
- Realm/faction/region, AH addons enabled:
- Sample item, bag/slot and initial stack:
- Invalid/unavailable or cancelled preview; unchanged holdings/listings:
- Chosen quantity, price in copper, duration index/native hours, deposit:
- Post call/event lines (supporting evidence only):
- Native Auctions listing item/quantity/price/duration and visible auction ID:
- Bag quantity afterwards:
- Outcome: confirmed listing / failed / cancelled before send / unknown:
- Repeated-click lock and no automatic dispatch on lifecycle changes:
- Native and Auctionator coexistence, scale/readability:
- Confirmation dialog requirements or other limitations:

Do not mark acceptance complete without visible native listing evidence and
an invalid/unavailable or cancelled attempt. Partial/unexercised paths must be
identified explicitly. A posted listing is not a completed sale.

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
