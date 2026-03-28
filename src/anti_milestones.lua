--[[
This file returns a table implementing the Antithesis SDK's "Lifecycle" functionality.
--]]
local module = {};



local json = require "src.utils.json";

-- {"antithesis_setup": { "status": "complete", "details": null }}
function module.build_setup_complete_msg(details_val)
    local details = json.null
    if details_val ~= nil then details = details_val end;
    return json.from({
        antithesis_setup = {
            status = "complete",
            details = details
        }
    });
end



return module;