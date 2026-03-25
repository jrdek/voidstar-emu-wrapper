--[[
This file defines `Array()`.
An object "is an Array" iff it's a table whose metatable has `__is_array = true`.
--]]

function Array(obj)
    setmetatable(obj, {__is_array = true});
    return obj;
end