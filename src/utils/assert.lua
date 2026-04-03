--[[
Lua provides `assert()`, a convenience function for error-throwing:

    assert(v [, message])
        - If `v` is `false` or `nil`, calls `error(message or "assertion failed!")`.
        - Otherwise, returns all of its arguments (in order).

`assert()`, notably, is a completely ordinary function. In particular, since Lua is
an eagerly-evaluated language, this means that `assert(cond_expr, msg_expr)` will 
evaluate `cond_expr` and `msg_expr` before calling `assert()`. That can be undesirable:
    - `msg_expr` may be unneeded, but its evaluation cost is always incurred.
        - This matters for things like string generators in assertions inside recursive
          functions.
    - Without caution, `msg_expr` may only be well-typed if `_cond_val` is false.

So this file exports a neat little helper, `lazily_assert()`, which takes unpacked
arguments in order to allow slightly more lazy assertions. It also asserts riffs on that
which I find handy.
--]]

local function lazily_assert_at_level(level, v, first_arg, ...)
    -- NOTE #1: Unlike `assert()`, calling this with no args will assume `v` is `nil`.
    if (not v) then
        local msg_gen = nil;
        if (first_arg == nil) then
            error("assertion failed!", level)
        else
            if type(first_arg) == "function" then
                msg_gen = first_arg;
            else
                local arg_meta = getmetatable(first_arg);
                if arg_meta then
                    msg_gen = arg_meta.__call;
                end
            end
            if msg_gen then
                local evaluated_err_body --[[<const>]] = msg_gen(...);
                error(evaluated_err_body, level);
            else
                error(first_arg, level);
            end
        end
    end
    -- NOTE #2: Unlike `assert()`, we only return `v` on success.
    return v;
end


local function lazily_assert_with_format(v, fmt_str, ...)
    -- lazily_assert_at_level(1, ...): err in lazily_assert_at_level
    -- lazily_assert_at_level(2, ...): err in this function
    -- lazily_assert_at_level(3, ...): err in whatever called this function
    --   (the last one is what's useful)
    return lazily_assert_at_level(3, v, string.format, fmt_str, ...);
end


local module = {
    with_fmt = lazily_assert_with_format
};

local module_metatable = {
    __call =
        function (_, ...)
            -- `_` is `module`, so we discard it.
            -- See lazily_assert_with_format() for why `level` is 3.
            return lazily_assert_at_level(3, ...);
        end,
};

setmetatable(module, module_metatable);

return module;