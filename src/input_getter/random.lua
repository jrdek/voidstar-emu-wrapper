--[[
An InputGetter that reads from /dev/urandom.
--]]


local RandomInputGetter = {};


function RandomInputGetter:new(args)
    local new_getter = {};
    setmetatable(new_getter, self);
    self.__index = self;

    new_getter.entropy = io.open("/dev/urandom");
    -- TODO: handle for non-*nix systems

    return new_getter;
end

local BUTTON_ORDER --[[<const>]] =
    {"right", "left", "down", "up", "start", "select", "B", "A"};


function RandomInputGetter:get_next()
    local inputs_char = self.entropy:read(1);
    -- TODO: maybe move this logic to a new file?
    -- and maybe add more bytes...
    local pressed = {};
    local inputs_num = string.unpack('B', inputs_char);
    local inputs_num_bkp = inputs_num;
    local ibval = 128;
    for i = 1,8 do
        local masked = ((inputs_num >= ibval) and ibval) or 0;
        local is_pressed = (masked ~= 0);
        -- print(BUTTON_ORDER[i], is_pressed);
        pressed[BUTTON_ORDER[i]] = is_pressed;
        inputs_num = inputs_num - ibval;
        ibval = ibval // 2;
    end

    -- hmmm...
    --pressed["start"] = (inputs_num_bkp % 5 == 0);

    return {[1] = pressed};
end


return RandomInputGetter;
