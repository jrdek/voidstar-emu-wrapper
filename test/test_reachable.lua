
--print = require "test.utils.src._debug.detailed_print".detailed.print;


require "src._debug.fake_fceux";

require "src.libsnouty";

Snouty.assert.reachable(
    "RESET vector addr is reachable",
    -- 0x8000,  -- address
    -- 0,       -- ROM bank
    -- function() return {example = "this is an example"} end
)

-- now let's pretend we trip the watchpoint that ^ sets:
memory.debug__trip(0x8000)
