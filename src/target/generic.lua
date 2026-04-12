--[[ Helpers for multiple emulators/systems. ]]--

-- TODO: probably make a TargetModule class...

local target_helpers = {}


function target_helpers.build_metahandler(handlers)
    if handlers == nil then
        return nil;
    end
    local metahandler = function ()
        for _,named_handler in ipairs(handlers) do
            named_handler.onhit();
        end
    end;
    return metahandler;
end


return target_helpers;