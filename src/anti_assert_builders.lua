--[[
This file returns a table of builder functions for typical kinds of Antithesis-SDK assertions.
--]]
local build = {};


local SdkAssertion = require "src.anti_assert_body";


local LAMBDA_TRUE <const> = function () return true end;
local LAMBDA_FALSE <const> = function () return false end;


function build.reachable(description, location, get_details)
    local fields = {
        must_hit = true,
        assert_type = "reachability",
        display_type = "Reachable",
        message = description,
        id = description,
        location = location,
    };
    return SdkAssertion:new(LAMBDA_TRUE, fields, get_details);
end

function build.unreachable(description, location, get_details)
    local fields = {
        must_hit = false,
        assert_type = "reachability",
        display_type = "Unreachable",
        message = description,
        id = description,
        location = location,
    };
    return SdkAssertion:new(LAMBDA_FALSE, fields, get_details);
end

function build.always(description, check_func, location, get_details)
    local fields = {
        must_hit = true,
        assert_type = "always",
        display_type = "Always",
        message = description,
        id = description,
        location = location,
    };
    return SdkAssertion:new(check_func, fields, get_details);
end

function build.always_or_unreachable(description, check_func, location, get_details)
    local fields = {
        must_hit = false,
        assert_type = "always",
        display_type = "AlwaysOrUnreachable",
        message = description,
        id = description,
        location = location,
    };
    return SdkAssertion:new(check_func, fields, get_details);
end

function build.sometimes(description, check_func, location, get_details)
    local fields = {
        must_hit = true,
        assert_type = "sometimes",
        display_type = "Sometimes",
        message = description,
        id = description,
        location = location,
    };
    return SdkAssertion:new(check_func, fields, get_details);
end



return build;