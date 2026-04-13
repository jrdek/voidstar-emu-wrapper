

local mario_helpers = {
    get = {},
    set = {},
}

local addr_of = require "test.games.smb1.addrs";


function mario_helpers.get.time_left()
    -- timer is stored as 3 bytes of BCD
    local time = 100 * Snouty.target.get_byte_at_cpu_addr(addr_of.var.GameTimerDisplay)
    time = time + 10 * Snouty.target.get_byte_at_cpu_addr(addr_of.var.GameTimerDisplay + 1)
    time = time + Snouty.target.get_byte_at_cpu_addr(addr_of.var.GameTimerDisplay + 2)
    return time
end

function mario_helpers.set.warm_boot()
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

function mario_helpers.set.continue_world(world_number)
    -- adjust (e.g., world 1 is stored as 0)
    local world_value = world_number - 1;
    memory.writebyte(addr_of.var.ContinueWorld, world_value);
end


return mario_helpers;