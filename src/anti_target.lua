--[[
This file returns a table of tables corresponding to emulator-specific functionality.
--]]
local module = {
    FCEUX = {
        _handlers = {
            execute = {}
        }
    }
};



-------------------------
--[[ STUFF FOR FCEUX ]]--
-------------------------

--[[
When a Lua script is passed to FCEUX, it runs with several extra libraries in scope.
Three functions included thereby -- which are very useful for us! -- are of the form
`memory.register${OP}`, where $OP is "read", "write", or execute":

    Given the arguments:
        watch_addr: integer
        watch_size: integer
        handler: (nil -> nil)
    Do:
        1. Define a "target range". In pseudocode:
            ```
            local rangemax = watch_addr + watch_size - 1;
            target_range = [watch_addr, watch_addr + 1, ..., rangemax];
            ```
        2. Rig FCEUX such that whenever the emulated system does $OP targeting an 
           address in the target range in its memory, FCEUX's Lua engine will
           immediately run `handler(trigger_addr, trigger_size, value)`, where
            - `trigger_addr` (integer) is the address of the current instruction.
            - `trigger_size` (integer) is the size of the current instruction.
                - On the NES, `trigger_size` is always 1. (CHECKME)
            - `value` (integer) is the value being $OP'd.
                - When `memory.registerexecute` calls `handler`, `value` is always 0.
        Then return nil.

These functions can all also be called with only `watch_addr` and `handler`, in which
case the "target range" is only `watch_addr`.

---

All three `memory.register${OP}` functions have two very important quirks:
    1. `watch_addr` is an address in the NES CPU's address space. Since games may have 
        multiple ROM banks, `watch_addr` should be considered a *virtual* address, not
        a *physical* address. To only trigger behavior at a specific *physical* address,
        `handler` must check which bank is currently mapped.
    2. (TODO: Check and clarify this.) Doing `memory.register${OP}(addr, nil)` will clear
       all of the trigger-on-$OP handlers at `addr`. This also means that only one $OP
       handler can be active on an address at once.

`module.FCEUX._register_exec` wraps `memory.registerexecute` to work around these quirks.
For now, it won't support `size`.
--]]

local function build_metahandler(handlers)
    if handlers == nil then
        return nil;
    end
    local metahandler = function ()
        for _,named_handler in ipairs(handlers) do
            named_handler.onhit();
        end
    end;
    return metahandler;
end

function module.FCEUX._register_exec(id, loc, onhit)
    assert(onhit, "Can't register nil; use deregister_exec() to deregister")
    --local locval = (0x10000 * loc.bank) + loc.address;
    -- ^ FIXME: banking needs extra logic...
    local locval = loc.begin_line;
    local current_onhits = module.FCEUX._handlers.execute[locval];
    if current_onhits == nil then
        module.FCEUX._handlers.execute[locval] = {};
        current_onhits = module.FCEUX._handlers.execute[locval]
    end
    table.insert(
        current_onhits,
        {id = id, onhit = onhit}
    );
    local metahandler = build_metahandler(current_onhits);
    memory.registerexecute(loc.begin_line, metahandler);
end

function module.FCEUX.deregister_exec(id, loc)  -- CHECKME needs testing
    -- TODO: as in register_exec, account for bank in locval
    local locval = loc.begin_line;
    local current_onhits = module.FCEUX._handlers.execute[locval];
    assert(current_onhits, string.format("Can't deregister_exec: no handlers at %d", locval));
    if current_onhits[id] ~= nil then
        current_onhits[id] = nil;
        local metahandler = build_metahandler(current_onhits);
        memory.registerexecute(loc.begin_line, metahandler);
    end
end

-- n.b.: this is actually bound to the *system*, not the *emulator*
function module.FCEUX._build_sdk_location(nes_loc)
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



return module;