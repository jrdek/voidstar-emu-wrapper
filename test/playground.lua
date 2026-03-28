--[[
When opened or `require`d in an interactive Lua shell, imports
a bunch of stuff that's probably very useful for debugging.
--]]

require "test.utils.fake_fceux";

print = require "test.utils.detailed_print".detailed.print;