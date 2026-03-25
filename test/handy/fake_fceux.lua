--[[
Globally-available stubs that pretend to be FCEUX's exported libraries.
--]]

MEM_HANDLERS = {}

memory = {}


local REGISTEREXEC_LOG_TEMPLATE =
[[[fake_fceux] Called memory.registerexecute!
  [addr]   0x%04x
  [onhit]  %s
]]


function memory.registerexecute(addr, onhit)
    io.write(string.format(
        REGISTEREXEC_LOG_TEMPLATE,
        addr,
        tostring(onhit)
    ));
    MEM_HANDLERS[addr] = onhit;
end


function memory.debug__trip(addr)
  MEM_HANDLERS[addr]();
end
