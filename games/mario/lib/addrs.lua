local Mario_addr_of = {
    routine = {
        RESET = 0x8000,
        NMI = 0x8082,  -- called every frame
        FlagpoleSlide = 0xb2a4,
        PlayerEndLevel = 0xb2ca,
    },
    var = {
        WorldNumber = 0x075f,
        LevelNumber = 0x075c,
        GameTimerDisplay = 0x07f8,
        TopScoreDisplay = 0x07d7,
        WarmBootValidation = 0x07ff,
        ContinueWorld = 0x07fd,
    },
    resource = {
        -- TODO
    }
}

return Mario_addr_of;