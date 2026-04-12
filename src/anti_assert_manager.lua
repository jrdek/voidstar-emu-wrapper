--[[
This file defines the class `AssertionManager`.
--]]


local build_assertion = require "src.anti_assert_builders";


--[[
Class responsible for emitting and mutating assertion data.
--]]
AssertionManager = {
    assert = {},
};

function AssertionManager:new(target, emitter)
    local new_instance = {};
    setmetatable(new_instance, self);
    self.__index = self;

    new_instance.inventory = {};
    new_instance.emitter = emitter;

    new_instance.target_utils = require( ("src.target.%s"):format(target) );

    return new_instance;
end


function AssertionManager:catalog(assert_obj)
    -- No duplicate assertion IDs are allowed.
    local assertion_id = assert_obj.body.id;
    if self.inventory[assertion_id] ~= nil
        then error(string.format(
            "Assertions must have unique IDs!\n"
            .. "ID: %s\n"
            .. "New assertion: %s (%s, address 0x%x)\n"
            .. "Already catalogged: %s (%s, address 0x%x)\n",
            assertion_id,
            assert_obj.body.assert_type,
            assert_obj.body.location.file,
            assert_obj.body.location.begin_line,
            self.inventory[assertion_id].body.assert_type,
            self.inventory[assertion_id].body.file or "undefined",
            self.inventory[assertion_id].body.location.begin_line or "undefined"
        ));
    end
    debug_print(string.format(
        "[snouty][assert][cat] Assertion @ 0x%04x (\"%s\")",
        assert_obj.body.location.begin_line,
        assertion_id
    ));
    -- If it's not a duplicate, add the assertion to our "inventory"...
    self.inventory[assertion_id] = assert_obj;
    -- ...then emit the catalog message.
    local catalog_json = assert_obj:to_jsonl();
    self.emitter:emit(catalog_json);
    -- We don't need to track whether assertions have been catalogged:
    -- by construction, all inventoried assertions have.

    -- In the future, anytime the assertion emits, its `hit` is true.
    assert_obj.body.hit = true;

    -- Return the assertion ID as a handle.
    return assertion_id;
end

function AssertionManager:check_and_emit(assert_id)
    local assert_obj = self.inventory[assert_id]
    local result = assert_obj.check_func();
    assert_obj.body.condition = result;
    -- If we haven't hit with this value before,
    if (assert_obj.done[result] == false) then
        -- Mark that we now have;
        assert_obj.done[result] = true;
        -- Fill in `details` if available (otherwise leave it as initialized);
        if type(assert_obj.get_details) == "function" then
            assert_obj.body.details = assert_obj.get_details()
        end
        -- Then emit the assertion.
        debug_print(string.format(
            "[snouty][assert][hit][%s] Assertion @ 0x%04x (\"%s\")",
            (result and "Y") or "N",
            assert_obj.body.location.begin_line,
            assert_id
        ));
        self.emitter:emit(assert_obj:to_jsonl())
        -- Check if we should deregister the handler.
        local can_deregister = true;
        for _, value_seen in pairs(assert_obj.done) do
            if not value_seen then can_deregister = false; break; end
        end
        -- If we should, do it.
        if can_deregister then
            debug_print(string.format(
                "[snouty][assert][del] Unregistering assertion @ 0x%04x (\"%s\")",
                assert_obj.body.location.begin_line,
                assert_id
            ))
            self.target_utils.deregister_exec(assert_obj.body.id, assert_obj.body.location);
        end
    end
end


-- TODO: a bunch of this code is dedupeable

function AssertionManager:assert_reachable(defn)
    -- this mutates `defn`, but it's fine i guess
    defn.location = self.target_utils.build_sdk_location(defn.location);
    local new_assert = build_assertion.reachable(defn);
    local id = self:catalog(new_assert);

    local onhit = (function () self:check_and_emit(id); end);
    self.target_utils.register_exec(id, defn.location, onhit);
end

function AssertionManager:assert_unreachable(defn)
    defn.location = self.target_utils.build_sdk_location(defn.location);
    local new_assert = build_assertion.unreachable(defn);
    local id = self:catalog(new_assert);

    local onhit = (function () self:check_and_emit(id); end);
    self.target_utils.register_exec(id, defn.location, onhit);
end

function AssertionManager:assert_always(defn)
    defn.location = self.target_utils.build_sdk_location(defn.location);
    local new_assert = build_assertion.always(defn);
    local id = self:catalog(new_assert);

    local onhit = (function () self:check_and_emit(id); end);
    self.target_utils.register_exec(id, defn.location, onhit);
end

function AssertionManager:assert_always_or_unreachable(defn)
    defn.location = self.target_utils.build_sdk_location(defn.location);
    local new_assert = build_assertion.always_or_unreachable(defn);
    local id = self:catalog(new_assert);

    local onhit = (function () self:check_and_emit(id); end);
    self.target_utils.register_exec(id, defn.location, onhit);
end

function AssertionManager:assert_sometimes(defn)
    defn.location = self.target_utils.build_sdk_location(defn.location);
    local new_assert = build_assertion.sometimes(defn);
    local id = self:catalog(new_assert);

    local onhit = (function () self:check_and_emit(id); end);
    self.target_utils.register_exec(id, defn.location, onhit);
end

