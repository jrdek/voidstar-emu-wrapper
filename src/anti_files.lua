--[[
This file returns SDK_PATHS, a table of useful paths (as strings) for the Antithesis SDK.
--]]
local SDK_PATHS = {};



SDK_PATHS.INPUT_DEVICE = "/dev/urandom";

local _ANTITHESIS_OUTPUT_DIR <const> = os.getenv("ANTITHESIS_OUTPUT_DIR");
SDK_PATHS.SDK_JSONL = _ANTITHESIS_OUTPUT_DIR .. "/sdk.jsonl";



return SDK_PATHS;