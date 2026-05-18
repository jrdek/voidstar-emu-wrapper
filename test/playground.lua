--[[
When opened or `require`d in an interactive Lua shell, imports
a bunch of stuff that's probably very useful for debugging.
--]]

require "src._debug.fake_fceux";

print = require "test.utils.src._debug.detailed_print".detailed.print;