--[[
This file defines the class `AssertionManager`.
--]]


local build_assertion = require "src.anti_assert_builders";
local all_targets = require "src.anti_target";



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

    new_instance._inventory = {};
    new_instance._emitter = emitter;

    new_instance.target_utils = all_targets[target];

    return new_instance;
end


function AssertionManager:_catalog(assert_obj)
    -- No duplicate assertion IDs are allowed.
    local assertion_id <const> = assert_obj.body.id;
    if self._inventory[assertion_id] ~= nil
        then error(string.format(
            "Assertions must have unique IDs!\n"
            .. "ID: %s\n"
            .. "New assertion: %s (%s, address 0x%x)\n"
            .. "Already catalogged: %s (%s, address 0x%x)\n",
            assertion_id,
            assert_obj.body.assert_type,
            assert_obj.body.location.file,
            assert_obj.body.location.begin_line,
            self._inventory[assertion_id].body.assert_type,
            self._inventory[assertion_id].body.file,
            self._inventory[assertion_id].body.location.begin_line
        ));
    end
    -- If it's not a duplicate, add the assertion to our "inventory"...
    self._inventory[assertion_id] = assert_obj;
    -- ...then emit the catalog message.
    local catalog_json <const> = assert_obj:to_jsonl();
    self._emitter:emit(catalog_json);
    -- We don't need to track whether assertions have been catalogged:
    -- by construction, all inventoried assertions have.

    -- In the future, anytime the assertion emits, its `hit` is true.
    assert_obj.body.hit = true;

    -- Return the assertion ID as a handle.
    return assertion_id;
end

function AssertionManager:_check_and_emit(assert_id)
    local assert_obj <const> = self._inventory[assert_id]
    local result <const> = assert_obj.check_func();
    if (assert_obj.has_hit_with_condition[result] == false) then
        assert_obj.has_hit_with_condition[result] = true;
        self._emitter:emit(assert_obj:to_jsonl())
    end
end

function AssertionManager:assert_reachable(description, address, bank, details)
    local loc <const> = self.target_utils._build_location(address, bank);
    local new_assert = build_assertion.reachable(description, loc, details);
    local id <const> = self:_catalog(new_assert);

    local onhit <const> = (function () self:_check_and_emit(id); end);
    self.target_utils._register_exec(address, onhit);
end

