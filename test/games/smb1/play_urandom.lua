require "src.libsnouty";
--debug_print.enable();


local function get_emu_metadata()
    return {
        frame = Snouty.target.get_frame_count(),
        cycle = Snouty.target.get_cpu_cycle_count()
    }
end


local REPO_ROOT --[[<const>]] = (require "src.utils.paths").path_to_repo_root();
local DISAS_PATH --[[<const>]] = REPO_ROOT .. "/reference/mario_disas/main_program.txt";

local mapper0_utils = require "test.mappers.mapper_0"
mapper0_utils.assert_jumps_are_safe(DISAS_PATH);
for addr,_ in pairs(mapper0_utils.code_chunks) do
    Snouty.assert.reachable({
        location = {address = addr},
        description = ("inst @ $%04x is reachable"):format(addr),
        get_details = get_emu_metadata
    });
end

Snouty.setup_input_getter({random = true});

print( ("[snouty] Starting (%d assertions)"):format(Snouty.target._assertion_count) );
Snouty.target.init_emulator();  -- if with Mesen


