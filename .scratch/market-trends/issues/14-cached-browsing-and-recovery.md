# 14: Browse cached history through outages and recovery

**What to build:** Existing item search and graphs remain useful during backend or companion outages, with honest loaded-data status, automatic companion recovery, and refreshed addon data at login or user-initiated `/reload`.

**Blocked by:** 08: Represent empty markets and collection gaps honestly; 10: Search and browse supported trade goods; 13: Configure the companion and inspect update diagnostics.

**Status:** ready-for-agent

- [ ] Retain cached search and graph browsing during backend outages and retain usable loaded addon history when the companion is unavailable.
- [ ] Show green for normal data operation under the login/reload model, yellow for observable problems including loaded source data exceeding the agreed age threshold, and red when no usable dataset is loaded. Waiting for the next import boundary alone is not a fault.
- [ ] Explain observable problems, source age, import time, and the login/reload refresh model without claiming a live companion connection, current download failures, or newer exports the addon cannot observe.
- [ ] Controlled failures and recovery preserve the last usable cache/export and loaded addon data without fabricated samples. Companion downloads and exports recover automatically; the addon retains its loaded revision until the next login or user-initiated `/reload`, then imports the recovered dataset.

## Comments

2026-11-14: Reconciled with the owner-approved login and user-initiated `/reload` import model; ticket number and blocking edges retained.
