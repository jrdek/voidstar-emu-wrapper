require "src.libsnouty";
-- debug_print.enable();

-- local function get_emu_metadata()
--     return {
--         frame = Snouty.target.get_frame_count(),
--         cycle = Snouty.target.get_cpu_cycle_count()
--     }
-- end

local REPO_ROOT --[[<const>]] = (require "src.utils.paths").path_to_repo_root();
local DISAS_PATH --[[<const>]] = REPO_ROOT .. "/reference/mario_disas/main_program.txt";

local mapper0_utils = require "mappers.mapper_0";
mapper0_utils.assert_jumps_are_safe(DISAS_PATH);
-- it's bad ergonomics, but the above populates code_chunks too.

local nes_coverage = require "src.instrumentation.nes";
nes_coverage.init_coverage(mapper0_utils.code_chunks, "og_mario");
-- TODO: make this live in Snouty.target! this will only work on Mesen as-is
for addr, _ in pairs(mapper0_utils.code_chunks) do
    emu.addMemoryCallback(
        function ()
            nes_coverage.notify(addr);
        end,
        emu.callbackType.exec,
        addr
    );  -- not sure if these can ever be unregistered...
end


Snouty.setup_input_getter({random = true});

print( ("[snouty] Starting (%d assertions)"):format(Snouty.target._assertion_count) );

Snouty.emit_setup_complete()
Snouty.target.init_emulator();  -- if with Mesen