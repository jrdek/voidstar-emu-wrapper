--[[
A rough port of the Go SDK's `symbol_table.go`.
See https://github.com/antithesishq/antithesis-sdk-go/blob/main/tools/antithesis-go-instrumentor/scanners/coverage/symboltable/symbol_table.go

It's pretty handy that Go also has multiple returns. :)
--]]
local Emitter = require("src.anti_emitter").Emitter;


local SymbolTable = {};

function SymbolTable.new(args)
    local new_instance = {};
    setmetatable(new_instance, SymbolTable);
    SymbolTable.__index = SymbolTable;

    new_instance.language = assert(args.language);
    new_instance.path = assert(args.path);

    new_instance.emitter = Emitter:new(new_instance.path);

    return new_instance;
end

local --[[<const>]] SYMBOLTABLE_COLUMNS = table.concat(
    {
        "file",
        "function",
        "begin_line",
        "begin_column",
        "end_line",
        "end_column",
        "address"
    },
    "\t"
);
function SymbolTable:write_header(module_name)
    -- TODO: should probably pcall these
    self.emitter:emit("# language = " .. self.language);
    self.emitter:emit("# instrumentor = voidstar_emu_wrapper");
    self.emitter:emit("# module = " .. module_name);
    self.emitter:emit(SYMBOLTABLE_COLUMNS);
end

local --[[<const>]] SYMBOLTABLE_ROW_TEMPLATE = table.concat(
    {
        "%s",  -- file
        "%s",  -- function
        "%d",  -- begin_line
        "%d",  -- begin_column
        "%d",  -- end_line
        "%d",  -- end_column
        "%d",  -- address (edge)
    },
    "\t"
);
function SymbolTable:write_position(path, func, startline, startcol, endline, endcol, edge)
    return self.emitter:emit(SYMBOLTABLE_ROW_TEMPLATE:format(path, func, startline, startcol, endline, endcol, edge));
end

local function create(outpath, module_name, language_name)
    local symbol_table = SymbolTable.new({
        path = outpath,
        language = language_name,
    });

    local err = symbol_table:write_header(module_name);
    if err ~= nil then
        symbol_table = nil;
    end

    return symbol_table, err;
end


return {create = create};