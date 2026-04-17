--[[
This file defines and instantiates `Snouty`, which is basically the entire "SDK wrapper".
--]]

require "src.utils.debug_print";
require "src.utils.array";
require "src.anti_assert_manager";

Snouty = {};

--[[
Underscore-prefixed `_keys` in Snouty are "internal" things which 
shouldn't be needed by a script requiring libsnouty.

They're included anyways, for debugging and tidiness.
--]]

local SDK_JSONL_PATH --[[<const>]] = require "src.anti_files".SDK_JSONL;
Snouty._emitter = require "src.anti_emitter".Emitter:new(SDK_JSONL_PATH);

Snouty._utils = {}
Snouty._utils.build_setup_complete_msg = (require "src.anti_milestones").build_setup_complete_msg


Snouty.target_name =  -- TODO: make this specifiable elsewhere
    "Mesen";
    --"FCEUX";
Snouty.target = require( ("src.target.%s"):format(Snouty.target_name) );
Snouty._assertion_manager = AssertionManager:new(Snouty.target_name, Snouty._emitter);

Snouty.target.pause();


function Snouty.setup_input_getter(args)
    Snouty.input_getter = (require "src.input_getter.generic"):new(args);
    assert(Snouty.input_getter);
    debug_print("[snouty] Input getter set up!");
end

-- TODO: this should live elsewhere
local FM2_BUTTON_ORDER --[[<const>]] = {"right", "left", "down", "up", "start", "select", "A", "B"}

function Snouty.do_frame()
    -- get input for the next frame
    -- (TODO: also handle non-movie execution)
    -- debug_print(("Frame: %d"):format(Snouty.target.get_frame_count()))
    -- debug_print("[snouty][do_frame] Getting inputs...")
    local all_inputs = Snouty.input_getter:get_next();
    if all_inputs == nil then
        debug_print( ("No more inputs! Stopping.") )
        debug_print( ("\tCurrent frame: %d"):format(Snouty.target.get_frame_count()) )
        debug_print( ("\tCurrent CPU cycle: %d"):format(Snouty.target.get_cpu_cycle_count()) )
        -- print( ("[snouty] Stopping (%d assertions still unresolved)"):format(Snouty.target._assertion_count) );
        emu.stop();  -- FIXME Mesen-specific
        --while true do end;
    elseif all_inputs == "softreset" then
        -- debug_print("[snouty][do_frame] Soft resetting...")
        Snouty.target.soft_reset();
    else
        local p1_inputs = all_inputs[1];  -- TODO: not just p1...
        -- set them in the emulator
        --debug_print("[snouty][do_frame] Setting inputs...")
        Snouty.target.set_joypad_for_player(1, p1_inputs);
        -- advance.
        Snouty.target.advance_frame();
    end
    -- debug_print("[snouty][do_frame] Done.")
    -- debug_print("")
end


function Snouty.go(args)
    args = args or {};
    local cmd_limit --[[<const>]] = args.num_commands or math.huge;
    local cmd_step --[[<const>]] = args.step_commands_by or 1;
    local frame_limit --[[<const]] = args.frame_limit or math.huge;
    local debug_wait = function() end;
    if ((args.framewait_ms or 0) > 0) then
        local sleep_s --[[<const>]] = args.framewait_ms / 1000;
        local sleep_cmd --[[<const>]] = string.format("sleep %f", sleep_s);
        debug_wait = function() os.execute(sleep_cmd) end;
    end
    assert(
        (cmd_step > 0) and (cmd_step == cmd_step / 1),
        "[snouty][go] args.step_commands_by must be a positive integer"
    );
    local cmd_num = 0;

    -- fceux, at least, needs to advance the frame once upon a reset
    Snouty.target.init_emulator();

    while true do
        local frame_count = Snouty.target.get_frame_count();
        --[[
        debug_print(string.format(
            "[snouty][go] Currently at cmd %d :: frame %d (diff %d). Stepping by %s.",
            cmd_num,
            frame_count,
            cmd_num - frame_count,
            cmd_step
        ))  -- TODO: `debug_print()` should have flags...
        --]]
        for _ = 1, cmd_step do
            Snouty.do_frame();
            debug_wait();
        end
        -- debug_print("[snouty][go] Done.\n");
        cmd_num = cmd_num + cmd_step;

        if cmd_num >= cmd_limit then
            debug_print("[snouty][go] Stopping (command limit reached)");
            break;
        elseif frame_count > frame_limit then
            debug_print("[snouty][go] Stopping (frame limit reached)");
            break;
        end
    end
end


function Snouty.emit_setup_complete(details)
    local msg --[[<const>]] = Snouty._utils.build_setup_complete_msg(details);
    Snouty._emitter:emit(msg);
    -- NOTE: This should only be emitted *once* in a branch.
end


--[[ Assertions ]]--

Snouty.assert = {};

function Snouty.assert.reachable(defn)
    return Snouty._assertion_manager:assert_reachable(defn);
end

function Snouty.assert.unreachable(defn)
    return Snouty._assertion_manager:assert_unreachable(defn);
end

function Snouty.assert.always(defn)
    return Snouty._assertion_manager:assert_always(defn)
end

function Snouty.assert.always_or_unreachable(defn)
    return Snouty._assertion_manager:assert_always_or_unreachable(defn)
end

function Snouty.assert.sometimes(defn)
    return Snouty._assertion_manager:assert_sometimes(defn)
end

-- (TODO: more of these!)
