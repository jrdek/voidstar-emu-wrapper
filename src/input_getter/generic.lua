


local InputGetter = {}

function InputGetter:new(args)
    if (args or {}).movie then
        return (require "src.input_getter.scripted"):new(args);
    end
    local new_instance = {};
    setmetatable(new_instance, self);
    self.__index = self;
end

-- TODO: flesh this out for non-movie execution


return InputGetter