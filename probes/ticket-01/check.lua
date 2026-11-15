-- Supporting checks only; also run /cwdiag in the target client.
local path = "probes/ticket-01/addons/CopperwiseDiagnostics/"
dofile(path .. "Sources.lua")
dofile(path .. "Runner.lua")
local results, failures = CopperwiseRunDiagnostics("all")
for _, result in ipairs(results) do
    print((result.ok and "PASS: " or "FAIL: ") .. result.name .. " — " .. result.title)
    if result.error then print(result.error) end
end
assert(failures == 0, failures .. " controlled diagnostic cases failed")
