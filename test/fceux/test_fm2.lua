

local ScriptedInputGetter = require "src.input_getter.scripted";

local fm2_path = "reference/happylee-supermariobros,warped.fm2";

smb_getter = ScriptedInputGetter:new({movie = {path = fm2_path, format = "fm2"}})

local FM2_BUTTON_ORDER --[[<const>]] = {"right", "left", "down", "up", "start", "select", "A", "B"}

function again()
    local all_inps_tbl = smb_getter:get_next();
    if type(all_inps_tbl) == "string" then print(all_inps_tbl) return end;
    local p1_inps_tbl = all_inps_tbl[1];
    local p1_states_arr = {}
    for _,btn in ipairs(FM2_BUTTON_ORDER) do
        table.insert(p1_states_arr, (p1_inps_tbl[btn] and "#") or ".");
    end
    print(table.concat(p1_states_arr));
end
