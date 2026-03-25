--[[
Override the default Lua `print()` with a somewhat nicer wrapper for it.
--]]

local module = {
    base = {
        tostring = tostring,
        print = print,
    },
    detailed = {

    }
};

function module.detailed.tostring(v)
    local vtype <const> = type(v);
    -- no need to do a fancy 8-way switch here;
    -- i actually just want to print table nicely!
    local base_string <const> = module.base.tostring(v);
    if vtype ~= "table"
        then return base_string;
    else
        local lines = {base_string};
        for k,r in pairs(v) do
            local line <const> = string.format(
                "    [ %s ] --> %s",
                module.base.tostring(k),
                module.base.tostring(r)
            );
            table.insert(lines, line);
        end
        return table.concat(lines, '\n');
    end
end

function module.detailed.print(...)
    local args <const> = {...};
    for _,v in ipairs(args) do
        module.base.print( module.detailed.tostring(v) );
    end
end


return module;