

local lazily_assert = require "src.utils.assert";  -- n.b.: normal assert would actually do just fine

local TYPECHECK_TEMPLATE --[[<const>]] =
    [[%s <-- `%s` must have type "%s", not "%s"]];

local function assert_meets_type(val, constraint, line_prefix, valname, valname_prefixes)
    -- make sure the constraint is legal
    local constraint_kind --[[<const>]] = type(constraint);
    lazily_assert.with_fmt(
        (constraint_kind == "string") or (constraint_kind == "table"),
        "assert_meets_type(): constraint must be string or table, not %s",
        constraint_kind
    );
    valname = valname or "(arg)";
    line_prefix = line_prefix or "(somewhere)";
    valname_prefixes = valname_prefixes or {};

    -- ensure that val shallowly meets constraint
    local valtype --[[<const>]] = type(val);
    local shallow_constraint --[[<const>]] =
        (constraint_kind == "string" and constraint) or constraint_kind;
    
    if (valtype ~= shallow_constraint) then
        local joined_prefix --[[<const>]] = table.concat(valname_prefixes, '.');
        local full_valname --[[<const>]] =
            joined_prefix ..
            (((joined_prefix ~= "") and '.') or "") ..
            valname;
        assert(
            valtype == shallow_constraint,
            string.format(
                TYPECHECK_TEMPLATE,
                line_prefix,
                full_valname,
                shallow_constraint,
                valtype
            )
        );
    end

    -- finally, if the constraint was a table, recurse
    table.insert(valname_prefixes, valname);
    if constraint_kind == "table" then
        for f_name, f_constraint in pairs(constraint) do
            assert_meets_type(val[f_name], f_constraint, line_prefix, f_name, valname_prefixes);
        end
    end
    table.remove(valname_prefixes);

    -- if we get here, we're good!
    return val;
end



return assert_meets_type;