

local sourcegen_parser = require "src.disas.6502_sourcegen";

local DISAS_FOLDER_PATH --[[<const>]] = (require "src.utils.paths").path_to_repo_root() .. "/reference/mario_disas/";

addrs = sourcegen_parser.get_region_starts(DISAS_FOLDER_PATH .. "main_program.txt");

local addr = 0x8000;
local total_bytes = 0;
while addr < 0x10000 do
    local these_bytes = addrs[addr].num_bytes
    total_bytes = total_bytes + these_bytes;
    addr = addr + these_bytes;
end

io.stdout:write(("[test_sourcegen] Total bytes: %d\n"):format(total_bytes));