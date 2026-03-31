--[[
This file returns a table of builder functions for typical kinds of Antithesis-SDK assertions.
--]]
local build = {};


local SdkAssertion = require "src.anti_assert_body";


local LAMBDA_TRUE --[[<const>]] = function () return true end;
local LAMBDA_FALSE --[[<const>]] = function () return false end;


function build.reachable(defn)
    local fields = {
        must_hit = true,
        assert_type = "reachability",
        display_type = "Reachable",
        message = defn.description,
        id = defn.description,
        location = defn.location,
    };
    return SdkAssertion.OneValued:new(LAMBDA_TRUE, fields, defn.get_details);
end

function build.unreachable(defn)
    local fields = {
        must_hit = false,
        assert_type = "reachability",
        display_type = "Unreachable",
        message = defn.description,
        id = defn.description,
        location = defn.location,
    };
    return SdkAssertion.OneValued:new(LAMBDA_FALSE, fields, defn.get_details);
end

function build.always(defn)
    local fields = {
        must_hit = true,
        assert_type = "always",
        display_type = "Always",
        message = defn.description,
        id = defn.description,
        location = defn.location,
    };
    return SdkAssertion.TwoValued:new(defn.condition, fields, defn.get_details);
end

function build.always_or_unreachable(defn)
    local fields = {
        must_hit = false,
        assert_type = "always",
        display_type = "AlwaysOrUnreachable",
        message = defn.description,
        id = defn.description,
        location = defn.location,
    };
    return SdkAssertion.TwoValued:new(defn.condition, fields, defn.get_details);
end

function build.sometimes(defn)
    local fields = {
        must_hit = true,
        assert_type = "sometimes",
        display_type = "Sometimes",
        message = defn.description,
        id = defn.description,
        location = defn.location,
    };
    return SdkAssertion.TwoValued:new(defn.condition, fields, defn.get_details);
end



return build;