--[[
This file returns a table of builder functions for typical kinds of Antithesis-SDK assertions.
--]]
local build = {};

local SdkAssertion = require "src.anti_assert_body";


local LAMBDA_TRUE <const> = function () return true end;


function build.reachable(description, location, details)
    local fields = {
        must_hit = true,
        assert_type = "reachability",
        display_type = "Reachable",
        condition = true,
        message = description,
        id = description,
        location = location,
        details = details
    };
    return SdkAssertion:new(LAMBDA_TRUE, fields);
end

-- TODO: other types of assertion!



return build;