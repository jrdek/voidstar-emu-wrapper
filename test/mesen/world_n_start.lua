


local breakOnPlayerInjury = emu.addMemoryCallback(
	function ()
		print("Took damage!!!!!")
		print("Input number: " .. tostring(inputline))
	end,
	emu.callbackType.exec,
	0xd92c
)

local function get_emu_metadata()
    return {
        frame = Snouty.target.get_frame_count(),
        cycle = Snouty.target.get_cpu_cycle_count()
    }
end

require "src.libsnouty";
debug_print.enable();

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



local jsav = require "test.jsav.jsav_header";

-- set up a save dump
-- TODO: move this
local function save_at_line(target_inputline, writefile)
	local savefile_path = REPO_ROOT .. "/output/" .. writefile;
	local this_callback_id <const> =
		("dump_savestate_at_inputline_%d"):format(target_inputline);
	local this_callback_loc <const> = {begin_line = 0x8082};  -- nmi handler
	Snouty.target.register_exec(
		this_callback_id,
		this_callback_loc,
		function ()
			if inputline == target_inputline then
				Snouty.target.deregister_exec(this_callback_id, this_callback_loc)

				local savefile_handle = io.open(savefile_path, "wb");
				assert(savefile_handle, "couldn't open savefile_path: " .. savefile_path);
				local savestate = emu.createSavestate();  -- NOTE: mesen-only for now
				assert(savestate);

				savefile_handle:write(jsav.build())
				savefile_handle:write(savestate);

				savefile_handle:flush();
				savefile_handle:close();
			end
		end
	);
end


-- start the TAS from a given input line
-- TODO: move this
local function load_from(readfile)
	local loadfile_path = REPO_ROOT .. "/output/" .. readfile;
	local loadfile_handle = io.open(loadfile_path, "rb");
	assert(loadfile_handle, "couldn't open loadfile_path: " .. loadfile_path);	
	local jsav_data = jsav.parse(loadfile_handle);
	local last_executed_input = jsav_data.lastInput - 1;
	Snouty.input_getter:skip_to_line(last_executed_input);
	local state = loadfile_handle:read("a");
	-- CHECKME: is this inputline off by one?
	inputline = last_executed_input;
	emu.loadSavestate(state);
end

-- local SAVE_AT_INPUTLINE = 4200;
-- local SAVE_FILENAME = "world_n_ending.jsav"
-- save_at_line(SAVE_AT_INPUTLINE, SAVE_FILENAME);

-- now GOOOOO
local movie_name =
	"world_n_ace__jrdek.fmi"

local MOVIES_DIR = REPO_ROOT .. "/reference/movies/";
local getter_args = {movie = {path = MOVIES_DIR .. movie_name, format = "fm2"}};

Snouty.setup_input_getter(getter_args);

local LOAD_FILENAME = "world_n_ending.jsav"

WorldNCallback = emu.addMemoryCallback(
	function ()
		emu.removeMemoryCallback(
			WorldNCallback,
			emu.callbackType.exec,
			0x8000
		);
		for sao = 0, 5 do
			emu.write(
				0x07d7 + sao,
				0x04,
				emu.memType.nesDebug
			);
		end;
		emu.write(
			0x07ff,
			0xa5,
			emu.memType.nesDebug
		);
		emu.write(
			0x07fd,
			0x16,
			emu.memType.nesDebug
		);
		--load_from(LOAD_FILENAME);
	end,
	emu.callbackType.exec,
	0x8000
);



print( ("[snouty] Starting (%d assertions)"):format(Snouty.target._assertion_count) );


-- Snouty.configure({
-- 	slow_down = {
-- 		at_frame = 4410;
-- 		delay_secs = "0.15";
-- 	}
-- })



-- Snouty.go()  -- if with FCEUX
Snouty.target.init_emulator();  -- if with Mesen



