--[[ Interface for working with the Mesen multi-emulator. ]]--
local targMesen = {
    assertion_handlers = {
        execute = {}
    },
    event_callbacks = {}
};

function targMesen.get_reg(regname)
    return emu.getNesData(regname)
end

function targMesen.get_byte_at_cpu_addr(addr)
    return emu.read(
        addr,
        emu.memType.nesDebug,
        false  -- (not signed)
    )
end

targMesen._assertion_count = 0;

function targMesen.register_exec(id, loc, onhit)
    local onhit_t = type(onhit);
    assert(
        onhit_t == "function",
        ("handler must be a function, not a %s")
            :format(onhit_t)
    );
    local locval = loc.begin_line;  -- TODO: banks
    -- Mesen composes handlers for us! :D
    local callback_id = emu.addMemoryCallback(
        onhit  -- handler (CHECKME: arg types?)
      , emu.callbackType.exec  -- (this is register_exec)
      , locval  -- start addr
    -- , locval  -- end addr
    -- , emu.cpuType.nes  -- cpuType (probably doesn't matter?)
    -- , emu.memType.nesDebug  -- memoryType: we'll use nesDebug to avoid accidental clobbers
    );
    targMesen.assertion_handlers.execute[id] = callback_id;
    targMesen._assertion_count = targMesen._assertion_count + 1;
end

function targMesen.deregister_exec(id, loc)
    -- CHECKME: do we need loc?
    local locval = loc.begin_line;
    local callback_id = targMesen.assertion_handlers.execute[id];
    assert(
        callback_id,
        ("Can't deregister_exec: no such handler \"%s\"")
            :format(id)
    );
    emu.removeMemoryCallback(
        callback_id
      , emu.callbackType.exec
      , locval
    -- , locval
    -- , emu.cpuType.nes
    -- , emu.memType.nesDebug
    );
    targMesen._assertion_count = targMesen._assertion_count - 1;
end

-- n.b.: this is actually bound to the *system*, not the *emulator*
function targMesen.build_sdk_location(nes_loc)
    assert(nes_loc.address, "Any assertion must have an address");
    local bank = nes_loc.bank or 0;
    local sdk_location = {
        class = "",         -- no obvious analog, so leave it blank
        ["function"] = "",  -- TODO: maybe we could track jumps in a ROM...
        file = string.format("ROM Bank %d", bank),
        begin_line = nes_loc.address,
        begin_column = 0    -- no obvious analog, so leave it blank
    };
    return sdk_location;
end

function targMesen.set_joypad_for_player(player, buttons)
    buttons.a = buttons.A;  -- have to adjust format slightly
    buttons.b = buttons.B;
    emu.setInput(buttons or {}, player - 1, 0);
end

-- this is a hot mess. hopefully fixable. TODO
function targMesen.init_emulator()
    targMesen._can_resume = true;
    emu.addEventCallback(
        function ()
            Snouty.do_frame();
            if targMesen._can_resume then
                emu.resume();
            end
        end,
        emu.eventType.codeBreak
    );

    -- We're using a memoryCallback instead of emu.eventType.Nmi 
    -- because I'm not positive whether the event happens *before*
    -- the PC jumps to the NMI handler.
    -- FIXME: this address shouldn't need to be hardcoded :(
    local NMI_addr = 0x8082;

    targMesen.event_callbacks.breakBuilder = emu.addMemoryCallback(
        function ()
            emu.removeMemoryCallback(
                targMesen.event_callbacks.breakBuilder,
                emu.callbackType.exec,
                NMI_addr
            );

            targMesen.event_callbacks.breaker = emu.addEventCallback(
                function ()
                    emu.breakExecution();
                end,
                emu.eventType.inputPolled
            )
        end,
        emu.callbackType.exec,
        NMI_addr
    );
end

function targMesen.advance_frame()
    -- since Mesen doesn't let Lua *push* control of the emulation,
    -- this can probably be a nop... CHECKME
end

function targMesen.soft_reset()
    emu.reset();
end

function targMesen.get_frame_count()
    if emu.getNesData then
        return emu.getNesData("ppuFrame");
    else
        return emu.getState()["ppuFrame"];  -- <-- incredibly slow!
    end
end

function targMesen.get_cpu_cycle_count()
    if emu.getNesData then
        return emu.getNesData("cpuCycle");
    else
        return emu.getState()["cpuCycle"];  -- <-- incredibly slow!
end

local DO_NOTHING = function () end;

-- TODO: it's unclear if there's even an analogue for these,
-- since Mesen doesn't let Lua push commands
targMesen.pause = DO_NOTHING;
targMesen.unpause = DO_NOTHING;



return targMesen;
