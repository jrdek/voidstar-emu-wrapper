require "src.libsnouty"


NesMario = {};


NesMario.subroutines = {bank = {}};
NesMario.subroutines.bank[0] = {
    Start = 0x8000,
    ColdBoot = 0x802b,
    -- EndlessLoop = 0x8057  -- when could this be reachable?
    NonMaskableInterrupt = 0x8082,

};