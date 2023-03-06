function print_hello takes nothing returns nothing
    local integer i = 2342
    call BJDebugMsg("Hallo von JHCR " + I2S(i))
endfunction

function reload_script takes nothing returns nothing
    call BJDebugMsg("|c00ff0000Reloading script...|r")
    call ExecuteFunc("JHCR_Init_parse")
endfunction


function start_interpreter takes nothing returns nothing
    if GetEventPlayerChatString() == "a" then
        call BJDebugMsg("|c0000ff00Starting interpreter...|r")
        call lua_Interpreter_debug_start_main()
    else
        call lua_Print_print( R2S( lua_Value_parse_number(GetEventPlayerChatString())) )
    endif
endfunction

// our entry point to the map
function InitCustomTriggers takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
    call TriggerAddAction(t, function reload_script)

    set t = CreateTrigger()
    //call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_CHAT)
    call TriggerRegisterPlayerChatEvent(t, Player(0), "", true)
    call TriggerAddAction(t, function start_interpreter)

    call lua_Auto_init()
    call lua_Ins_init()
    call lua_Value_init()
    call lua_Wrap_init()
    call lua_Interpreter_init()

    //call TimerStart(CreateTimer(), 1.0, true, function print_hello)
    call CreateUnit(Player(0), 'Hpal', 0, 0, 0)

endfunction
