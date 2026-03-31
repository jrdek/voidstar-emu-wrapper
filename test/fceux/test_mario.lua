

require "src.libsnouty";


--[[ Important addresses ]]--
local addr = {
    routine = {
        RESET = 0x8000,
        NMI = 0x8082,  -- called every frame
        FlagpoleSlide = 0xb2a4,
    },
    var = {
        WorldNumber = 0x075f,
        LevelNumber = 0x075c,
        GameTimerDisplay = 0x07f8,
    },
    resource = {
        -- TODO
    }
}


--[[ Helper functions ]]--

local function getTimeLeft()
    -- timer is stored as 3 bytes of BCD
    local time = 100 * memory.readbyte(addr.var.GameTimerDisplay)
    time = time + 10 * memory.readbyte(addr.var.GameTimerDisplay + 1)
    time = time + memory.readbyte(addr.var.GameTimerDisplay + 2)
    return time
end


--[[ check-function generators ]]--

local function time_left_is(n)
    return (function () return getTimeLeft() == n end);
end


--[[ `details` generators ]]--
local function get_emu_metadata()
    return {
        frame = emu.framecount(),
        cycle = debugger.getcyclescount(),
    }
end

local function get_game_metadata()
    return {
        level = memory.readbyte(addr.var.LevelNumber),
        world = memory.readbyte(addr.var.WorldNumber),
        level_time_left = getTimeLeft(),
    }
end

local function get_metadata()
    return {
        emu = get_emu_metadata(),
        game = get_game_metadata()
    }
end


--[[ Assertions ]]--

Snouty.assert.reachable({
    description = "RESET vector addr is reachable",
    location = {
        address = addr.routine.RESET,
        bank = 0
    },
})

Snouty.assert.reachable({
    description = "Flagpole-hit routine is reachable",
    location = {
        address = 0xb2a4,
        bank = 0
    },
    get_details = get_metadata
})

Snouty.assert.sometimes({
    description = "Current game-time is 395",
    condition = time_left_is(395),
    location = {
        address = addr.routine.NMI,
        bank = 0,
    },
    get_details = get_metadata
})

