--[[
This file returns subclasses of the abstract base class `BaseSdkAssertion`.

A BaseSdkAssertion object `a = BaseSdkAssertion:new(check_func, fields)` is a table with:
    - a.body: the inner body of an Antithesis SDK assertion, stored as a table  
    - a.done: a table mapping booleans to booleans.
    - a:to_jsonl(): returns `a.body` turned into JSONL.
--]]


local json = require "src.utils.json";


--[[
The Antithesis SDK's assertion JSONs have this structure:
```json
{
    antithesis_assert: {
        hit,            (boolean)
        must_hit,       (const boolean)
        assert_type,    (const string)
        display_type,   (const string)
        message,        (const string)
        condition,      (boolean)*
        id,             (const string)
        location: {
            class,      (const string)
            function,   (const string)
            file,       (const string)
            begin_line, (const integer)
            begin_column (const integer)
        },
        details         (JSON or null)
    }
}
```
--]]


local function typed_index_or_nil(tbl, key, typing)
    local value = tbl[key];

    if type(typing) == "string" then
        local valtype --[[<const>]] = type(value);
        if typing == valtype
            then return value;
            else return nil;
        end
    -- if typing is a table, assume it's list-like;
    -- interpret it as the union type of its keys as literals
    elseif type(typing) == "table" then
        for _,literal in ipairs(typing) do
            if literal == value
                then return value;
            end
        end
        return nil;
    end
    -- this line should never be reached
    error("typed_index_or_nil() received bad typing " .. tostring(typing), 2);
end

local function typed_index_or_err(tbl, key, typing)
    local result = typed_index_or_nil(tbl, key, typing);
    if result == nil then
        error(
            string.format(
                "Value for key `%s` is `%s` (doesn't match `%s`)",
                key,
                tostring(tbl[key]),
                tostring(typing)
            )
        );
    end
    return result;
end


local ASSERTION_FIELDS_TYPING --[[<const>]] = {
    must_hit = "boolean",
    assert_type = {"always", "sometimes", "reachability"},
    display_type = "string",
    message = "string",
    --condition = "boolean",
    id = "string",
    -- `location` is a table (with specific structure to check elsewhere)
    -- `details` is basically anything, so we'll ignore it here
}

local ASSERTION_LOC_FIELDS_TYPING --[[<const>]] = {
    class = "string",
    ["function"] = "string",
    file = "string",
    begin_line = "number",
    begin_column = "number",
}

local function validate_assertion_fields(fields)
    local filled = {};
    -- since every field is mandatory, check from the template
    for k,t in pairs(ASSERTION_FIELDS_TYPING) do
        filled[k] = typed_index_or_err(fields, k, t);
    end

    -- similarly, check `location`
    filled.location = {};
    for k,t in pairs(ASSERTION_LOC_FIELDS_TYPING) do
        filled.location[k] = typed_index_or_err(fields.location, k, t);
    end

    -- CHECKME: everything below this, especially for catalogging
    filled.condition = false;
    filled.details = fields.details;  -- `details` can be anything jsonifiable

    return filled;
end


--[[
"Base class" for stateful assertion tracking/emitting.
--]]
local BaseSdkAssertion = {};


--[[
Since the shape is always `{"antithesis_assert": innerValue}`,
we don't need to recreate the outer thing each time.
--]]
local SDK_ASSERT_TEMPLATE --[[<const>]] = '{"antithesis_assert":%s}';

function BaseSdkAssertion:to_jsonl()
    local inner_jsonl --[[<const>]] = json.from(self.body);
    return string.format(SDK_ASSERT_TEMPLATE, inner_jsonl);
end


function BaseSdkAssertion:new(check_func, fields, get_details)
    local new_a = {};
    setmetatable(new_a, self);
    self.__index = self;

    new_a.done = {};

    new_a.check_func = check_func;
    new_a.get_details = get_details;

    new_a.body = validate_assertion_fields(fields);
    new_a.body.hit = false;
    new_a.body.details = new_a.body.details or json.null;

    return new_a;
end


--[[
It'll be convenient to unregister assertions after they're no longer needed.
From the docs:
> There is no benefit to sending more than one true evaluation or more than
> one false evaluation.

Since Reachable/Unreachable assertions only ever evaluate true/false
respectively, we can make them easy to unregister:
--]]

local OneValuedSdkAssertion = {};
setmetatable(OneValuedSdkAssertion, BaseSdkAssertion)

function OneValuedSdkAssertion:new(hit_func, fields, get_details)
    local new_a = BaseSdkAssertion:new(hit_func, fields, get_details);
    setmetatable(new_a, self);
    self.__index = self;

    local hit_val = hit_func();
    new_a.done[hit_val] = false;
    return new_a;
end


--[[
Similarly, we can declare TwoValuedSdkAssertion:
--]]
local TwoValuedSdkAssertion = {};
setmetatable(TwoValuedSdkAssertion, BaseSdkAssertion);

function TwoValuedSdkAssertion:new(check_func, fields, get_details)
    local new_a = BaseSdkAssertion:new(check_func, fields, get_details);
    setmetatable(new_a, self);
    self.__index = self;

    new_a.done[true] = false;
    new_a.done[false] = false;
    return new_a;
end



return {OneValued = OneValuedSdkAssertion, TwoValued = TwoValuedSdkAssertion};