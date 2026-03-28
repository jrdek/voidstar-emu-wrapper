

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

Snouty.assert.reachable(
    "RESET vector addr is reachable",
    addr.routine.RESET,
    0,  -- bank
    {}
)

Snouty.assert.reachable(
    "Flagpole-hit routine is reachable",
    0xb2a4,
    0,
    get_metadata
)

Snouty.assert.sometimes(
    "Current game-time is 395",
    time_left_is(395),
    addr.routine.NMI,
    0,
    get_metadata
)

