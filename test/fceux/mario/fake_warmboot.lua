
-- emu.pause();

local addr_of = {
    routine = {
        RESET = 0x8000,
        NMI = 0x8082,
    },
    var = {
        TopScoreDisplay = 0x07d7,
        WarmBootValidation = 0x07ff,
        ContinueWorld = 0x07fd,
    },
    resource = {
    }
};


local function set_warm_boot()
    -- the five score bytes must be below 0x0a
    local score_offset = 5;
    while score_offset >= 0 do
        local score_byte_addr = addr_of.var.TopScoreDisplay + score_offset;
        memory.writebyte(score_byte_addr, 0);
        score_offset = score_offset - 1;
    end
    -- and WarmBootValidation must be 0xa5
    memory.writebyte(addr_of.var.WarmBootValidation, 0xa5);
end

local function set_continue_world(world_number)
    -- adjust (e.g., world 1 is stored as 0)
    local world_value = world_number - 1;
    memory.writebyte(addr_of.var.ContinueWorld, world_value);
end


emu.pause();

set_warm_boot();

set_continue_world(9);--0xf + 8);-- <= "world N"

emu.unpause();
