

local mapper_0_utils = {};


local BOUNDS --[[<const>]] = {lo = 0x8000, hi = 0xffff};  -- (this is true for NROM)

-- TODO: these should be moved to an NES-utils file once i've made that
local function peek_nth_on_stack(n)  -- n.b.: one-indexed! (in a pop, SP increments first)
    local sp = Snouty.target.get_reg("SP");  -- 1-byte...
    local sp_plus_n = sp + n;
    -- this is how it becomes 2-byte; note that overflow is weird
    local addr_of_sp_plus_n = 0x100 + (sp_plus_n % 0x100);
    return Snouty.target.get_byte_at_cpu_addr(addr_of_sp_plus_n);
end

local function get_rti_targaddr_lohi()
    -- pops: flags, targaddr_lo, targaddr_hi
    local lo = peek_nth_on_stack(2);
    local hi = peek_nth_on_stack(3);
    return lo, hi
end

local function get_rts_targaddr_lohi()
    -- pops: targaddr_lo, targaddr_hi
    local lo = peek_nth_on_stack(1);
    local hi = peek_nth_on_stack(2);
    -- rts then increments the PC by 1, unlike other jumps
    lo = lo + 1;
    if lo == 0x100 then
        lo = 0x00;
        hi = (hi + 1) % 0x100;
    end
    return lo, hi
end

local function get_indjmp_targaddr_lohi(oper_lo, oper_hi)
    local oper_hi_as_upper = 0x100 * oper_hi;
    local addr_of_lo = oper_lo + oper_hi_as_upper;
    local lo = Snouty.target.get_byte_at_cpu_addr(addr_of_lo);
    -- the following looks wrong but is faithful to the NES!
    -- see https://www.nesdev.org/wiki/Instruction_reference#JMP
    local addr_of_hi = ((oper_lo + 1) % 0x100) + oper_hi_as_upper;
    local hi = Snouty.target.get_byte_at_cpu_addr(addr_of_hi);
    return lo, hi
end
mapper_0_utils.get_indjmp_targaddr_lohi = get_indjmp_targaddr_lohi;

local function build_targaddr_json(lo, hi)
    local addr_string = ("$%02x%02x"):format(hi, lo);
    return {
        jump_target = addr_string,
        frame = Snouty.target.get_frame_count(),
        cycle = Snouty.target.get_cpu_cycle_count(),
    };
end

-- TODO: Reorganize this.
-- "Mapper 0 utils" aren't dependent on the ROM. I'm just doing it 
-- this way to skip reiterating through all the chunks.
-- A better approach would be to make the disassembly-parser label 
-- indirect jumps along the way.
mapper_0_utils.code_chunks = nil;

local function points_to_code(targaddr_lo, targaddr_hi)
    assert(mapper_0_utils.code_chunks, "points_to_code() needs a map of code chunks!")
    local targaddr = targaddr_lo + (0x100 * targaddr_hi);
    return mapper_0_utils.code_chunks[targaddr] ~= nil;
end
mapper_0_utils.points_to_code = points_to_code;

function mapper_0_utils.assert_jumps_are_safe(disas_path)
    local all_chunks =
        (require "src.disas.6502_sourcegen")
        .get_region_starts(disas_path);
    local code_chunks = {};

    local addr = BOUNDS.lo;
    while addr < BOUNDS.hi do
        local chunk = all_chunks[addr];
        if chunk.is_instruction then
            code_chunks[addr] = chunk;
            local opcode = chunk.bytes[1];
            if opcode == 0x40 then      -- rti
                Snouty.assert.always_or_unreachable({
                    location = {address = addr},
                    description = ("rti @ $%04x jumps to code"):format(addr),
                    condition = function ()
                        return points_to_code(get_rti_targaddr_lohi());
                    end,
                    get_details = function () return build_targaddr_json(get_rti_targaddr_lohi()) end
                });
            elseif opcode == 0x60 then  -- rts
                Snouty.assert.always_or_unreachable({
                    location = {address = addr},
                    description = ("rts @ $%04x jumps to code"):format(addr),
                    condition = function ()
                        return points_to_code(get_rts_targaddr_lohi());
                    end,
                    get_details = function () return build_targaddr_json(get_rts_targaddr_lohi()) end
                });
            elseif opcode == 0x6c then  -- jmp ($hilo): 6c lo hi
                assert(#chunk.bytes == 3, ("indirect jmp at $%04x somehow has %d operands?!"):format(addr, #chunk.bytes))
                local operand_lo = chunk.bytes[2];
                local operand_hi = chunk.bytes[3];
                Snouty.assert.always_or_unreachable({
                    location = {address = addr},
                    description = ("jmp ($%02x%02x) @ $%04x jumps to code"):format(operand_hi, operand_lo, addr),
                    condition = function ()
                        return points_to_code(get_indjmp_targaddr_lohi(operand_lo, operand_hi));
                    end,
                    get_details = function () return build_targaddr_json(get_indjmp_targaddr_lohi(operand_lo, operand_hi)) end
                });
            end
        end
        addr = addr + chunk.num_bytes;
    end
    -- TODO: Reorganize this. (see the TODO near where this field is defined)
    if mapper_0_utils.code_chunks == nil then
        mapper_0_utils.code_chunks = code_chunks;
    end
end



return mapper_0_utils;