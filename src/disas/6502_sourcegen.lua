--[[
Parser for SourceGen files... or, at least, for files in the 
format of the 6502disassembly version of mario.nes.
--]]

local module = {};


--[[
Incredibly hacky, probably-buggy, probably-inefficient line parser.
But it does what I want for now.

Accepts a line from the SMB1 disassembly and returns `parsed_data`. 
- If the line has no address, returns `nil`.
- Otherwise, returns an object which has
    - addr: number
    - is_instruction: boolean
    - label: optional string
    - mnemonic: optional string
--]]
local function parse_line(line)
    line = line:gsub("^%s(.*)$", "%1");  -- trim initial whitespace
    local m_start, m_end;
    local parsed_data = {};

    -- any line we care about starts with an address ("NNNN: ")
    local addr_string = nil;
    m_start, m_end, addr_string = line:find("^(%x%x%x%x):");
    if (not m_start) or (m_start > m_end) then return nil; end;
    parsed_data.addr = tonumber(addr_string, 16);

    -- there must be one byte; there may be more
    local bytes_start, last_m_end;
    repeat
        last_m_end = m_end;
        m_start, m_end = line:find("^%s%x%x", m_end+1);
        if bytes_start == nil then bytes_start = m_start+1 end;
    until (not m_start) or (m_start > m_end);
    m_end = last_m_end;
    -- parse out the bytes from the bytes-string
    -- n.b. this is probably suboptimal, but it's short so it's fine
    local bytes_str = line:sub(bytes_start, m_end);
    parsed_data.bytes = {};
    for byte in bytes_str:gmatch("%x%x") do
        table.insert(parsed_data.bytes, tonumber(byte, 16));
    end

    m_start, m_end = line:find("^+?%s+", m_end+1); if (not m_start) or (m_start > m_end) then return nil; end;

    -- there may be a label
    last_m_end = m_end;
    m_start, m_end, parsed_data.label = line:find("^(%u%g*)%s+", m_end+1);
    if not m_end then m_end = last_m_end; end;
    
    -- now there's an instruction mnemonic.
    local mnemonic = nil;
    m_start, m_end, mnemonic = line:find("^(%.?%w*)", m_end+1);
    if (not m_start) or (m_start > m_end) then
        -- there really is always one!
        mnemonic = parsed_data.label;
        parsed_data.label = nil;
    end
    parsed_data.is_instruction = (mnemonic:find("^%.") == nil)

    -- we don't care about the rest
    return parsed_data;
end


function module.get_region_starts(path)
    local insts_file = assert(io.open(path, "r"), "file not found");
    local regions = {};
    local cnt = 0;
    local line = insts_file:read("*l");
    local last_addr = 0x8000;
    while line do
        local data = parse_line(line);
        if data then
            local addr = data.addr;
            assert(addr);
            data.addr = nil;
            assert(data.is_instruction ~= nil);
            regions[addr] = data;
            regions[last_addr].num_bytes = addr - last_addr;
            last_addr = addr;
            cnt = cnt + 1;
        end
        line = insts_file:read("*l");
    end;
    regions[last_addr].num_bytes = 0x10000 - last_addr;
    debug_print(("[6502_sourcegen] Found %d regions."):format(cnt));
    return regions;
end



return module;
