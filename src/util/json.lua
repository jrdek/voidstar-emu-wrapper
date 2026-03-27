--[[
This file returns, as a table, a library for JSONifying simple Lua objects.
It does enough that you should be able to reasonably generate JSONL to the Antithesis SDK's spec.
In line with that, there are some limitations to note:
    1. If you try to JSONify a userdata, a thread, or a function, you'll get an error.
    2. To JSONify arrays, you need to use `Array({'a', 'b', 'c'})` and not just `{'a', 'b', 'c'}`.
--]]

local IS_UNIMPLEMENTED_TYPE <const> = {
    ["userdata"] = true,
    ["thread"] = true,
    ["function"] = true,
}

local NULL = {};

local function sanitize(s)
    return s:gsub([["]], [[\"]])
end

local function jsonify_primitive(val, valtype)
    if (valtype == "number") then 
        -- TODO: this doesn't handle floats!
        return string.format("%d", val)
    elseif (valtype == "boolean") then
        return tostring(val);
    elseif valtype == "string" then
        return '"' .. sanitize(val) .. '"';
    end
end

-- hooray forward declaration
local jsonify;

local function jsonify_array(val)
    local item_jsons = {};
    for _, v in ipairs(val) do
        local item_json <const> = jsonify(v);
        table.insert(item_jsons, item_json);
    end
    return string.format("[%s]", table.concat(item_jsons, ','));
end

local function jsonify_obj_entry(k, v)
    return string.format([["%s":%s]], tostring(k), jsonify(v));
end

local function jsonify_object(val)
    local entry_jsons = {};
    for k, v in pairs(val) do
        local entry_json <const> = jsonify_obj_entry(k, v);
        table.insert(entry_jsons, entry_json);
    end
    return string.format("{%s}", table.concat(entry_jsons, ','));
end


function jsonify(val)
    local valtype <const> = type(val);
    if IS_UNIMPLEMENTED_TYPE[valtype] then
        error("jsonify() unimplemented for type " .. valtype, 2);
    elseif valtype == "table" then
        if val == NULL then
            return "null";
        -- NOTE: this is not foolproof! don't use int arrays in objects.
        elseif (getmetatable(val) or {}).__is_array then
            return jsonify_array(val);
        else
            return jsonify_object(val);
        end
    else  -- primitive type
        return jsonify_primitive(val, valtype);
    end
end


local module = {
    from = jsonify,
    null = NULL
};

return module;