debug_print = {};

local DO_NOTHING = function () end;
setmetatable(debug_print, {__call = DO_NOTHING});

function debug_print.enable()
    io.stdout:setvbuf("no");
    getmetatable(debug_print).__call = function (self, ...)
        for _,v in ipairs({...}) do
            io.stdout:write(v, "\n");
        end
    end;
end

function debug_print.disable()
    getmetatable(debug_print).__call = DO_NOTHING;
end