# Ticket 01 controlled diagnostics

Runs unchanged bundled production Inventory, Storage and Scan Lua in a fresh
environment for each case. API inputs, time, bags, UI widgets and storage are
synthetic; the separate native diagnostics window displays captured Inventory
text and assertions. No real auction queries, transactions, bag changes, saved
variables or production Copperwise globals are accessed by the sandbox.

This is controlled diagnostic evidence, not native-server acceptance. In
particular, injected metadata availability and query readiness do not demonstrate
actual cache timing or native server throttling. No ranking or recommendation
exists in ticket 01; these checks establish missing-price and retained-observation
behavior only. The source bundle is generated from production files, with hashes
in its header; regenerate whenever those files change.

## Install and run

1. Copy `addons/CopperwiseDiagnostics` from this directory into
   `/Applications/World of Warcraft/_forever_/Interface/AddOns/` beside Copperwise.
   It has no dependency and no saved variables. Do not replace production files.
2. Enable **Copperwise ticket 01 diagnostics**, then `/reload`.
3. Run `/cwdiag` anywhere, including away from the AH. Expected summary: **7/7
   passed; 0 failed**. Scroll for captured simulated Inventory outputs.
4. Inspect individually with `/cwdiag metadata`, `empty`, `buyout`, `failure`,
   `timeout`, `partial` or `throttle`. Individual reports include before/after
   text and intermediate loading/partial/throttled states where relevant.
5. Supply the summary screenshot and any failure text. Record the actual-client
   diagnostic outcome separately from native production observations in ticket 01.
6. Disable the diagnostics addon after verification; ordinary Copperwise stays
   installed. `/reload` clears diagnostic windows and all simulated state.

Cases cover unavailable-to-zero vendor metadata without scanning, complete-empty
coverage, zero native buyout treated as unavailable, thrown-request failure with
retained data, response timeout plus late responses, incomplete coverage followed
by total timeout, and readiness pause/resume of pagination. Both timeout clocks
are advanced synthetically, so the checks finish immediately. Request/row caps
and actual native throttling are not exercised by these cases.

## Supporting checks

From the repository root (LuaJIT supplies the Lua 5.1 environment used by the
target addon):

```sh
python3 probes/ticket-01/build.py
python3 probes/ticket-01/build.py --check
luajit probes/ticket-01/check.lua
luajit addons/Copperwise/tests/storage.lua
```

`Sources.lua` is committed so the diagnostic folder can be installed directly.
No runtime Lua compilation or filesystem access is used in the game.
