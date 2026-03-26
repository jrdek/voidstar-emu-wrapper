debug_print = {};

local DO_NOTHING = function () end;
setmetatable(debug_print, {__call = DO_NOTHING});

function debug_print.enable()
    getmetatable(debug_print).__call = function (self, ...) print(...) end;
end

function debug_print.disable()
    getmetatable(debug_print).__call = DO_NOTHING;
end