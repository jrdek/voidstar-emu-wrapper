-- FIXME: this file needs cleanup...
-- ... and fceux is currently broken!

emu.pause();

require "src.libsnouty";
debug_print.enable();


local function get_emu_metadata()
    return {
        frame = Snouty.target.get_frame_count(),
        cycle = Snouty.target.get_cpu_cycle_count()
    }
end

local REPO_ROOT --[[<const>]] = (require "src.utils.paths").path_to_repo_root();
local DISAS_PATH --[[<const>]] = REPO_ROOT .. "/reference/mario_disas/main_program.txt";

local mapper0_utils = require "mappers.mapper_0"
mapper0_utils.assert_jumps_are_safe(DISAS_PATH);
for addr,_ in pairs(mapper0_utils.code_chunks) do
    Snouty.assert.reachable({
        location = {address = addr},
        description = ("inst @ $%04x is reachable"):format(addr),
        get_details = get_emu_metadata
    });
end


-- now GOOOOO
local movie_name =
	"world_n_ace__jrdek.fmi"

local MOVIES_DIR = REPO_ROOT .. "/reference/movies/";
local getter_args = {movie = {path = MOVIES_DIR .. movie_name, format = "fm2"}};

Snouty.setup_input_getter(getter_args);


-- for sao = 0, 5 do
--     memory.writebyte(0x7d7 + sao, 0x04);
-- end
-- memory.writebyte(0x7ff, 0xa5);
-- memory.writebyte(0x7fd, 0x16);


debug_print( ("[snouty] Starting (%d assertions)"):format(Snouty.target._assertion_count) );


-- Snouty.configure({
-- 	slow_down = {
-- 		at_frame = 4410;
-- 		delay_secs = "0.15";
-- 	}
-- })



Snouty.go()  -- if with FCEUX
-- Snouty.target.init_emulator();  -- if with Mesen



