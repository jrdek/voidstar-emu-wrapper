

--[[
This file defines and instantiates `Snouty`, which is basically the entire "SDK wrapper".
--]]

require "src.util.debug_print";
debug_print.enable();

require "src.util.array";
require "src.anti_assert_manager";

Snouty = {};

--[[
Underscore-prefixed `_keys` in Snouty are "internal" things which 
shouldn't be needed by a script requiring libsnouty.

They're included anyways, for debugging and tidiness.
--]]

local SDK_JSONL_PATH <const> = require "src.anti_files".SDK_JSONL;
Snouty._emitter = require "src.anti_emitter".Emitter:new(SDK_JSONL_PATH);

Snouty._utils = {}
Snouty._utils.build_setup_complete_msg = require "src.anti_milestones".build_setup_complete_msg


Snouty._assertion_manager = AssertionManager:new("FCEUX", Snouty._emitter);


-- Reads a byte from /dev/urandom, then returns it as a number.
function Snouty.get_byte()
    local byte <const> = assert(Snouty._files.INPUT_DEVICE.handle:read(1));
    local hex <const> = string.byte(byte);
    return hex;
end

function Snouty.emit_setup_complete(details)
    local msg <const> = Snouty._utils.build_setup_complete_msg(details);
    Snouty._emitter:emit(msg);
    -- NOTE: This should only be emitted *once* in a branch.
end


--[[ Assertions ]]--

Snouty.assert = {};

function Snouty.assert.reachable(description, address, bank, get_details)
    return Snouty._assertion_manager:assert_reachable(description, address, bank, get_details);
end

function Snouty.assert.unreachable(description, address, bank, get_details)
    return Snouty._assertion_manager:assert_unreachable(description, address, bank, get_details);
end

function Snouty.assert.always(description, check_func, address, bank, get_details)
    return Snouty._assertion_manager:assert_always(description, check_func, address, bank, get_details)
end

function Snouty.assert.always_or_unreachable(description, check_func, address, bank, get_details)
    return Snouty._assertion_manager:assert_always_or_unreachable(description, check_func, address, bank, get_details)
end

function Snouty.assert.sometimes(description, check_func, address, bank, get_details)
    return Snouty._assertion_manager:assert_sometimes(description, check_func, address, bank, get_details)
end

-- (TODO: more of these!)
