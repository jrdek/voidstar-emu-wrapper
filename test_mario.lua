

require "src.libsnouty";


local RESET_VEC = 0x8000;
local NMI_VEC = 0x8082;  -- called every frame
local TIMER_ADDR = 0x07f8;
local WORLDNUMBER_ADDR = 0x075f;
local LEVELNUMBER_ADDR = 0x075c;

local function getTimeLeft()
    -- timer is stored as 3 bytes of BCD
    local time = 100 * memory.readbyte(TIMER_ADDR)
    time = time + 10 * memory.readbyte(TIMER_ADDR + 1)
    time = time + memory.readbyte(TIMER_ADDR + 2)
    return time
end

local function time_left_is(n)
    return (function () return getTimeLeft() == n end);
end

local function get_emu_metadata()
    return {
        frame = emu.framecount(),
        cycle = debugger.getcyclescount(),
    }
end

local function get_game_metadata()
    return {
        level = memory.readbyte(LEVELNUMBER_ADDR),
        world = memory.readbyte(WORLDNUMBER_ADDR),
        level_time_left = getTimeLeft(),
    }
end

local function get_metadata()
    return {
        emu = get_emu_metadata(),
        game = get_game_metadata()
    }
end


--[[ ASSERTIONS ]]--

Snouty.assert.reachable(
    "RESET vector addr is reachable",
    RESET_VEC,
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
    NMI_VEC,
    0,
    get_metadata
)