
--print = require "test.utils.detailed_print".detailed.print;


require "test.utils.fake_fceux";

require "src.libsnouty";

Snouty.assert.reachable(
    "RESET vector addr is reachable",
    0x8000,  -- address
    0,       -- ROM bank
    function() return {example = "this is an example"} end
)

-- now let's pretend we trip the watchpoint that ^ sets:
memory.debug__trip(0x8000)
