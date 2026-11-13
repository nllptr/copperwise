# 14: Browse cached history through outages and recovery

**What to build:** Existing item search and graphs remain useful during backend or companion outages, with honest status and automatic recovery.

**Blocked by:** 08: Represent empty markets and collection gaps honestly; 10: Search and browse supported trade goods; 13: Configure the companion and inspect update diagnostics.

**Status:** ready-for-agent

- [ ] Retain cached search and graph browsing during backend outages and retain usable loaded addon history when the companion is unavailable.
- [ ] Show green for normal data operation, yellow for problems preventing normal updates or use, and red when no usable dataset is loaded.
- [ ] Explain specific observable problems and source age without claiming a live companion connection the addon cannot prove.
- [ ] Controlled failures and recovery verify stale, unusable, and retained data behavior without fabricated samples or manual reload.

