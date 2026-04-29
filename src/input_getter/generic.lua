


local InputGetter = {}

function InputGetter:new(args)
    args = args or {};
    if args.movie then
        return (require "src.input_getter.scripted"):new(args);
    elseif args.random then
        return (require "src.input_getter.random"):new(args);
    end
    local new_instance = {};
    setmetatable(new_instance, self);
    self.__index = self;
end

-- TODO: flesh this out for non-movie execution


return InputGetter