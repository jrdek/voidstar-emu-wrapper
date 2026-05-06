--[[
todo: docstring
]]

local symbol_table = require "src.instrumentation.symbol_table";
local voidstar = require "libvoidstarlua";


local module = {};


local run_symtbl = nil;
local run_symtblpath = nil;
local run_moduleoffset = nil;


function module.declare_guard(symtbl, game_name, addr, bank)
    bank = bank or 0;
    local full_addr = (bank * 0x10000) + addr;
    return symtbl:write_position(
        game_name,
        "",
        full_addr,  -- this is silly, but the
        0,
        full_addr,  -- start and end of each
        0,
        full_addr   -- tracked inst is its addr.
        -- (checkme: or do these need to *not* be sparse?)
    )
end

local function init_symbols(code_chunks, game_name)
    game_name = game_name or "nes_rom";
    run_symtblpath = "/opt/luasrc/" .. game_name .. ".tsv";
    --run_symtblpath = "/tmp/" .. game_name .. ".tsv";
    run_symtbl = assert(symbol_table.create(run_symtblpath, game_name, "asm6502"));
    local guard_count = 0;
    for addr, _ in pairs(code_chunks) do
        module.declare_guard(run_symtbl, game_name, addr);
        guard_count = guard_count + 1;
    end
    return guard_count;
end

function module.init_coverage(code_chunks, game_name)
    local num_guards = init_symbols(code_chunks, game_name);
    run_moduleoffset = voidstar.initCoverageModule(num_guards, run_symtblpath);
end

function module.notify(addr)
    local loc = run_moduleoffset + addr;
    return voidstar.notifyCoverage(loc);
end


return module;