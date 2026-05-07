--[[
todo: docstring
]]

-- local symbol_table = require "src.instrumentation.symbol_table";
local voidstar = require "libvoidstarlua";


local module = {};


local run_symtbl = nil;
local run_symtblpath = nil;
local run_moduleoffset = nil;
local run_addridxs = nil;
local run_guardcount = nil;


local function full_addr_from(bank, addr)
    return (bank * 0x10000) + addr;
end

function module.declare_guard(symtbl, game_name, addr, bank)
    bank = bank or 0;
    local full_addr = full_addr_from(bank, addr);
    run_guardcount = run_guardcount + 1;
    run_addridxs[full_addr] = run_guardcount;
    -- return symtbl:write_position(
    --     game_name,
    --     "",
    --     full_addr,  -- (start is inclusive)
    --     0,
    --     full_addr+1,  -- (end is exclusive)
    --     0,
    --     full_addr
    --     -- (checkme: or do these need to *not* be sparse?)
    -- )
end

local function init_symbols(code_chunks, game_name)
    game_name = game_name or "nes_rom";
    run_symtblpath = "/symbols/" .. game_name .. ".sym.tsv";
    -- run_symtbl = assert(symbol_table.create(run_symtblpath, game_name, "asm6502"));
    run_guardcount = 0;
    run_addridxs = {};
    for addr, _ in pairs(code_chunks) do
        module.declare_guard(nil, game_name, addr);
    end
    return run_guardcount;
end

function module.init_coverage(code_chunks, game_name)
    local num_guards = init_symbols(code_chunks, game_name);
    run_moduleoffset = voidstar.initCoverageModule(num_guards, run_symtblpath);
end

function module.notify(addr, bank)
    assert(run_addridxs);  -- this fails if notify() is called before init_symbols()!
    bank = bank or 0;
    local loc = run_moduleoffset + run_addridxs[full_addr_from(bank, addr)];
    return voidstar.notifyCoverage(loc);
end


return module;