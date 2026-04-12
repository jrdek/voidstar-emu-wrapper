require "src.libsnouty";
debug_print.enable();


--[[ Important addresses ]]--
local addr_of = {
    routine = {
        RESET = 0x8000,
        NMI = 0x8082,  -- called every frame
        FlagpoleSlide = 0xb2a4,
        PlayerEndLevel = 0xb2ca,
    },
    var = {
        WorldNumber = 0x075f,
        LevelNumber = 0x075c,
        GameTimerDisplay = 0x07f8,
        TopScoreDisplay = 0x07d7,
        WarmBootValidation = 0x07ff,
        ContinueWorld = 0x07fd,
    },
    resource = {
        -- TODO
    }
}


--[[ Helper functions ]]--

local function getTimeLeft()
    -- timer is stored as 3 bytes of BCD
    local time = 100 * Snouty.target.get_byte_at_cpu_addr(addr_of.var.GameTimerDisplay)
    time = time + 10 * Snouty.target.get_byte_at_cpu_addr(addr_of.var.GameTimerDisplay + 1)
    time = time + Snouty.target.get_byte_at_cpu_addr(addr_of.var.GameTimerDisplay + 2)
    return time
end

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


--[[ check-function generators ]]--

local function time_left_is(n)
    return (function () return getTimeLeft() == n end);
end


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
        level_time_left = getTimeLeft(),
    }
end

local function get_metadata()
    return {
        emu = get_emu_metadata(),
        game = get_game_metadata()
    }
end


-- every byte in RAM is unreachable (in mario).
-- it would be pretty sick to assert "we will never reach open bus", but it's not clear
-- how we would do this in FCEUX, in the general case.
for ram_addr = 0x0000, 0x1fff do
    Snouty.assert.unreachable({
        description = ("Unreachable: RAM (address 0x%04x)"):format(
            ram_addr
        ),
        location = {
            address = ram_addr,
            bank = 0,
        },
        get_details = get_metadata;
    })
end

-- ppu regs shouldn't be reachable
for ppu_addr = 0x2000, 0x3fff do
    Snouty.assert.unreachable({
        description = ("Unreachable: PPU regs (address 0x%04x)"):format(
            ppu_addr
        ),
        location = {
            address = ppu_addr,
            bank = 0,
        },
        get_details = get_metadata;
    })
end

-- apu/io regs shouldn't be reachable
for apuio_addr = 0x4000, 0x401F do
    Snouty.assert.unreachable({
        description = ("Unreachable: APU/IO regs (address 0x%04x)"):format(
            apuio_addr
        ),
        location = {
            address = apuio_addr,
            bank = 0,
        },
        get_details = get_metadata;
    })
end

-- unmapped addresses (!!!!!)
for unmapped_addr = 0x4020, 0x7fff do
    Snouty.assert.unreachable({
        description = ("Unreachable: unmapped memory (address 0x%04x)"):format(
            unmapped_addr
        ),
        location = {
            address = unmapped_addr,
            bank = 0,
        },
        get_details = get_metadata;
    })
end


local rom_regions =
    (require "src.disas.6502_sourcegen")
    .get_region_starts(
        "/Users/riley/Documents/pcloud/code/projects/big/voidstar-emu-wrapper/" ..
        "reference/mario_disas/main_program.txt"
    );

local region_addr = 0x8000;
while region_addr <= 0xffff do
    local info = rom_regions[region_addr];
    local declare = Snouty.assert[(info.is_instruction and "reachable") or "unreachable"];

    -- NOTE: in mesen, at least, the operand bytes of an inst never "get executed"...
    -- so there's LOADS of unneeded callbacks left in emulatorland forever! bad!
    
    -- I could imagine an "assertion array" being more efficient than whatever mesen is doing...

    --for byte_addr = region_addr, (region_addr + info.num_bytes - 1) do
    for byte_addr = region_addr, region_addr do
        declare({
            description = ("%s: ROM (address 0x%04x)"):format(
                (info.is_instruction and "Reachable") or "Unreachable",
                byte_addr
            ),
            location = {
                address = byte_addr,
                bank = 0,
            },
            get_details = get_metadata;
        })
    end
    region_addr = region_addr + info.num_bytes;
end


-- now GOOOOO
local movie_name = "happylee-supermariobros,warped.fm2";

local HERE = (require "src.utils.paths").path_to_repo_root();
local MOVIES_DIR = HERE .. "/reference/movies/";
local getter_args = {movie = {path = MOVIES_DIR .. movie_name, format = "fm2"}};

Snouty.setup_input_getter(getter_args);


-- Snouty.go()  -- if with FCEUX
Snouty.target.init_emulator();  -- if with Mesen