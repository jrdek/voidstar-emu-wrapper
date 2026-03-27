

require "src.libsnouty";


Snouty.assert.reachable(
    "RESET vector addr is reachable",
    0x8000,
    0,  -- bank
    {}
)

Snouty.assert.reachable(
    "Flagpole-hit routine is reachable",
    0xb2a4,
    0,
    {}
)

