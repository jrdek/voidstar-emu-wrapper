require "src.libsnouty";
debug_print.enable();


--[[ Important addresses ]]--
local addr_of = (require "test.games.smb1.addrs");

--[[ Helper functions ]]--
local helpers = (require "test.games.smb1.helpers");

--[[ `details` generators ]]--
local function get_emu_metadata()
    return {
        frame = Snouty.target.get_frame_count(),
        -- cycle = Snouty.target.get_cycle_count()
    }
end

local function get_game_metadata()
    return {
        level = Snouty.target.get_byte_at_cpu_addr(addr_of.var.LevelNumber),
        world = Snouty.target.get_byte_at_cpu_addr(addr_of.var.WorldNumber),
        level_time_left = helpers.get.time_left(),
    }
end

local function get_metadata()
    return {
        emu = get_emu_metadata(),
        game = get_game_metadata()
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
        get_details = function() return {ppuframe = Snouty.target.get_frame_count()}; end
    });
end

-- now GOOOOO
local movie_name = "happylee-supermariobros,warped.fm2";

local MOVIES_DIR = REPO_ROOT .. "/reference/movies/";
local getter_args = {movie = {path = MOVIES_DIR .. movie_name, format = "fm2"}};

Snouty.setup_input_getter(getter_args);


-- Snouty.go()  -- if with FCEUX
Snouty.target.init_emulator();  -- if with Mesen