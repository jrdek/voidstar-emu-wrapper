emu.pause();  -- CHECKME
require "src.libsnouty";
debug_print.enable();


local addr_LevelNumber = 0x075c;
local addr_OperMode = 0x0770;
local value_GameMode = 1;


-- turns out, this isn't THAT slow!
local inst_addr = 0x0000;
while inst_addr <= 0xFFFF do
    Snouty.assert.reachable({
        description = ("Reachable: address 0x%04x"):format(inst_addr),
        location = {
            address = inst_addr,
            bank = 0
        },
        get_details = function ()
            local lvl_num = memory.readbyte(addr_LevelNumber);
            local oper_mode = memory.readbyte(addr_OperMode);
            if (oper_mode == value_GameMode) and (lvl_num ~= 0) then
                --debug_print(("Level number is 0x%04x! Exiting."):format(lvl_num));
                emu.exit();
            end
        end
    });
    inst_addr = inst_addr + 1;
end



local movie_name = "happylee-supermariobros,warped.fm2";

local HERE = (require "src.utils.paths").path_to_repo_root();
local MOVIES_DIR = HERE .. "/reference/movies/";
local getter_args = {movie = {path = MOVIES_DIR .. movie_name, format = "fm2"}};

Snouty.setup_input_getter(getter_args);

Snouty.go()
