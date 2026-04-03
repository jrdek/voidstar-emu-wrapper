--[[
An InputGetter that reads from a movie file.
--]]


local assert_meets_type = require "src.utils.typecheck";

local ScriptedInputGetter = {};


function ScriptedInputGetter:new(args)
    args = assert_meets_type(
        args,
        {movie = {path = "string", format = "string"}},
        "ScriptedInputGetter:new(args)",
        "args"
    );

    local load_success, movie_lib = pcall(require, "src.movie." .. args.movie.format);
    assert(load_success, string.format("Unimplemented movie type: %s", args.movie.format));

    local new_getter = {};
    setmetatable(new_getter, self);
    self.__index = self;

    local movie_handle = assert(io.open(args.movie.path, "r"), string.format("Couldn't open file %s", args.movie.path));
    
    new_getter.movie_lib = movie_lib;
    new_getter.movie_handle = movie_handle;

    assert(new_getter:init_movie(), string.format("Couldn't get inputs from file %s", args.movie.path));

    return new_getter;
end

function ScriptedInputGetter:init_movie()
    if self.initial_cursor_pos then
        self.movie_handle:seek("set", self.initial_cursor_pos);
        return true;
    else
        local success, start_pos = self.movie_lib.initialize_handle(self.movie_handle);
        self.initial_cursor_pos = start_pos;
        return success;
    end
end

function ScriptedInputGetter:get_next()
    local inputs_line = self.movie_handle:read("*l");
    -- debug_print(string.format("[snouty][movie] Got line: %s", inputs_line));
    if inputs_line == nil then return nil end;
    return self.movie_lib.parse_line(inputs_line);
end


return ScriptedInputGetter;