

local DISAS_FOLDER_PATH --[[<const>]] = (require "src.utils.paths").path_to_repo_root() .. "/reference/mario_disas/";
local NROM_BOUNDS --[[<const>]] = {lo = 0x8000, hi = 0xffff};

local sourcegen_parser = require "src.disas.6502_sourcegen";
local addrs = sourcegen_parser.get_region_starts(DISAS_FOLDER_PATH .. "main_program.txt");

local addr = NROM_BOUNDS.lo;
local total_bytes = 0;
while addr <= NROM_BOUNDS.hi do
    local chunk = addrs[addr]
    if chunk.is_instruction then
        local opcode = chunk.bytes[1];
        local msg = nil;
        if opcode == 0x40 then
            msg = "rti";
        elseif opcode == 0x60 then
            msg = "rts";  --"[rom@0x%04x] rts\n"):format(addr) );
        elseif opcode == 0x6c then
            msg = ("jmp ($%02x%02x)"):format(chunk.bytes[3], chunk.bytes[2]);
        end  -- `brk` is not an indirect jump, because the IRQ handler is at a fixed address
        if msg then
            io.stdout:write("[disas] ");
            io.stdout:write( ("@$%04x: "):format(addr) );
            io.stdout:write(msg);
            io.stdout:write("\n");
        end
    end
    total_bytes = total_bytes + chunk.num_bytes;
    addr = addr + chunk.num_bytes;
end

io.stdout:write(("[test_sourcegen] Total bytes: %d\n"):format(total_bytes));