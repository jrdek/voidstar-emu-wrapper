--[[
This file returns a table of tables corresponding to emulator-specific functionality.
--]]
local module = {
    FCEUX = {}
};



-------------------------
--[[ STUFF FOR FCEUX ]]--
-------------------------
module.FCEUX._register_exec = memory.registerexecute;  -- exported by the emulator

-- n.b.: this is actually bound to the *system*, not the *emulator*
function module.FCEUX._build_location(address, bank)
    bank = bank or 0;
    local nes_location = {
        class = "",         -- no obvious analog, so leave it blank
        ["function"] = "",  -- TODO: maybe we could track jumps in a ROM...
        file = "ROM Bank " .. tostring(bank),
        begin_line = address,
        begin_column = 0    -- no obvious analog, so leave it blank
    };
    return nes_location;
end



return module;