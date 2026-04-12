while true do
    emu.pause();
    io.write( ("@ PC 0x%04x (inst count %d)\n"):format(memory.getregister("PC"), debugger.getinstructionscount()) )
    debugger.hitbreakpoint()
    emu.unpause();
end
