--[[
When opened or `require`d in an interactive Lua shell, imports
a bunch of stuff that's probably very useful for debugging.
--]]

require "test.handy.fake_fceux";

print = require "test.handy.detailed_print".detailed.print;