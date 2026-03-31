--[[
This file returns a table containing the Emitter class.
An Emitter is a convenience-wrapper for a "w"-mode file handle.
--]]
local module = {};



module.Emitter = {};

function module.Emitter:new(path)
    local new_instance = {};
    setmetatable(new_instance, self);
    self.__index = self;
    
    new_instance.path = path;

    local handle = assert(io.open(path, "w"));
    handle:setvbuf("no");
    new_instance.handle = handle;

    return new_instance;
end

function module.Emitter:emit(line)
    self.handle:write(line);
    self.handle:write("\n");
end



return module;