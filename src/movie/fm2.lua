--[[
Utils for reading fm2-format NES TAS movies.
(These are the kind used by FCEUX's "TAS Editor".)
--]]


local fm2_lib = {};

function fm2_lib.initialize_handle(handle)
    -- move the cursor past the prelude
    local start_of_line = handle:seek("set", 0);  -- (start_of_line = 0)
    local line = "";
    repeat
        start_of_line = handle:seek("cur");
        line = handle:read("*l");
    until (line == nil) or (line:find("^|.*|$") ~= nil);

    -- set the cursor back to the start of the first line of inputs
    handle:seek("set", start_of_line);

    return (line ~= nil), start_of_line;
end


local FM2_BUTTON_ORDER --[[<const>]] = {"right", "left", "down", "up", "start", "select", "B", "A"}

-- from the spec: any character other than ' ' or '.' means that the button was pressed
local function indicates_pressed(c)
    return (c ~= ' ') and (c ~= '.');
end


function fm2_lib.parse_line(inputs_line)
    local line_components = {};
    for segment in inputs_line:gmatch("|([^|]*)") do
        -- a `segment` is the stuff after a pipe, but before the next pipe
        -- note that this includes anything after the last pipe
        table.insert(line_components, segment)
    end;

    if line_components[1] == "1" then
        -- this is a slight lie but whatever
        return "softreset";
    end

    -- TODO: account for more than just p1
    -- (and otherwise make this more resilient)
    local P1_IDX --[[<const>]] = 2;
    local p1_component --[[<const>]] = line_components[P1_IDX];
    local pressed = {};
    for i, btn in ipairs(FM2_BUTTON_ORDER) do
        pressed[btn] = indicates_pressed(p1_component:sub(i, i));
    end
    return {[1] = pressed};
end


return fm2_lib;