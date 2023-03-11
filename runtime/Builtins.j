// scope Builtins
// REQUIRES Print Value Table Context Jass

//function _wrap_jass_handle takes handle h 

globals
    player array _value2player

    // Table
    integer _trigger2value
    // List
    integer array _trigger_actions
    // List
    integer array _trigger_conditions

    trigger array _value2trigger

    timer array _value2timer
    // Table
    integer _timer2value

    // Indexed by _trigger_actions
    integer array _trigger_action
endglobals

// TODO: autogenerate this stuff
function _Player takes integer tbl, integer ctx, integer interpreter returns nothing
    local integer integer_value = Table#_get( tbl, 1 )
    local integer return_table = Table#_get( tbl, 0 )
    local integer player_value = Value#_table()

    set _value2player[player_value] = Player(Value#_Int[integer_value])
    call Table#_set( Value#_Int[player_value], 'type', Jass#_Player )
    call Table#_set( Value#_Int[return_table], 1, player_value )
endfunction

// TODO: conditions
// TODO: bunch of checks
// TODO: reverse actions
function _trigger_execute_all_actions takes nothing returns nothing
    local integer trigger_value = Table#_get( _trigger2value, GetHandleId(GetTriggeringTrigger()) )
    local integer ls = _trigger_actions[trigger_value]
    local integer interpreter = Table#_get( Value#_Int[trigger_value], 'intp' )
    local integer ret = Value#_table() // not used
    local integer fn_value

    //call Print#_print("_trigger_execute_all_actions()")
    //call Print#_print("  - trigger lua obj: "+I2S(trigger_value))
    //call Print#_print("  - interpreter: "+I2S(interpreter))


    loop
    exitwhen ls == 0
	set fn_value = Table#_get( Value#_Int[_trigger_action[ls]], 'func' )
	call Call#_call0( fn_value, ret, interpreter )
	set ls = List#_next[ls]
    endloop

endfunction

// TODO: autogenerate this stuff
function _CreateTimer takes integer tbl, integer ctx, integer interpreter returns nothing
    local integer v = Value#_table()
    local timer t = CreateTimer()

    local integer return_table = Table#_get( tbl, 0 )

    //call Print#_print("_CreateTimer")
    //call Print#_print("  - timer obj: "+I2S(v))

    call Table#_set( Value#_Int[v], 'type', Jass#_Timer )
    call Table#_set( Value#_Int[v], 'intp', interpreter )

    set _value2timer[v] = t
    call Table#_set( _timer2value, GetHandleId(t), v )

    call Table#_set( Value#_Int[return_table], 1, v )
endfunction

function _execute_timer_action takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer timer_value = Table#_get( _timer2value, GetHandleId(t) )
    local integer ret_value = Value#_table() // not used
    local integer fn_value = Table#_get( Value#_Int[timer_value], 'func' )
    local integer interpreter = Table#_get( Value#_Int[timer_value], 'intp' )

    //call Print#_print("_execute_timer_action")

    call Call#_call0( fn_value, ret_value, interpreter )
endfunction

function _TimerStart takes integer tbl, integer ctx, integer interpreter returns nothing
    local integer timer_value = Table#_get(tbl, 1)
    local integer real_value = Table#_get(tbl, 2)
    local integer bool_value = Table#_get(tbl, 3)
    local integer fn_value = Table#_get(tbl, 4)

    local real timeout
    // TODO: generic
    if Value#_Type[real_value] == Types#_Int then
	set timeout = Value#_Int[real_value]
    elseif Value#_Type[real_value] == Types#_Real then
	set timeout = Value#_Real[real_value]
    elseif Value#_Type[real_value] == Types#_String then
	set timeout = Value#_parse_number(Value#_String[real_value])
    else
	call Print#_error("Cannot convert to number")
    endif

    //call Print#_print("_TimerStart")
    //call Print#_print("  - timer obj: "+I2S(timer_value))
    //call Print#_print("  - timeout: "+R2S(timeout))

    call Table#_set( Value#_Int[timer_value], 'func', fn_value )

    call TimerStart( _value2timer[timer_value], timeout, Value#_Bool[bool_value], function _execute_timer_action )

endfunction

function _CreateTrigger takes integer tbl, integer ctx, integer interpreter returns nothing
    local integer v = Value#_table()
    local trigger t = CreateTrigger()

    local integer return_table = Table#_get( tbl, 0 )

    //call Print#_print("_CreateTrigger()")
    //call Print#_print("  - trigger lua obj: "+I2S(v))
    //call Print#_print("  - interpreter: "+I2S(interpreter))

    call Table#_set( Value#_Int[v], 'type', Jass#_Trigger )
    call Table#_set( Value#_Int[v], 'intp', interpreter )

    set _value2trigger[v] = t
    call Table#_set( _trigger2value, GetHandleId(t), v )

    //call TriggerAddCondition( t, Condition( function _ // TODO: not sure if this is not better handled totally custom
    call TriggerAddAction( t, function _trigger_execute_all_actions )


    call Table#_set( Value#_Int[return_table], 1, v )
    //call Print#_print("  - done")


    set t = null
endfunction

function _GetEventPlayerChatString takes integer tbl, integer ctx, integer interpreter returns nothing
    local integer returntable_value = Table#_get(tbl, 0)
    local string s = GetEventPlayerChatString()
    local integer string_value = Value#_litstring( s )
    call Table#_set( Value#_Int[returntable_value], 1, string_value )
endfunction

function _TriggerAddAction takes integer tbl, integer ctx, integer interpreter returns nothing
    local integer trigger_value = Table#_get(tbl, 1)
    local integer fn_value = Table#_get(tbl, 2)
    local integer returntable_value = Table#_get(tbl, 0)

    local integer triggeraction_value = Value#_table()

    local integer ls = _trigger_actions[trigger_value]

    set ls = List#_cons(ls)
    set _trigger_action[ls] = triggeraction_value
    set _trigger_actions[trigger_value] = ls

    call Table#_set( Value#_Int[triggeraction_value], 'type', Jass#_TriggerAction )
    call Table#_set( Value#_Int[triggeraction_value], 'func', fn_value )

    call Table#_set( Value#_Int[returntable_value], 1, triggeraction_value )

endfunction

// these kind of natives should be auto-generated in the future
function _TriggerRegisterPlayerChatEvent takes integer tbl, integer ctx, integer interpreter returns nothing
    local integer trigger_value = Table#_get(tbl, 1)
    local integer player_value = Table#_get(tbl, 2)
    local integer string_value = Table#_get(tbl, 3)
    local integer bool_value = Table#_get(tbl, 4)

    call TriggerRegisterPlayerChatEvent( _value2trigger[trigger_value], _value2player[player_value], Value#_String[string_value], Value#_Bool[bool_value] )

    // TODO: technically this returns an event handle
endfunction

function _print takes integer tbl, integer ctx, integer interpreter returns nothing
    local string r = ""
    local integer k = 1
    local integer v
    //call Print#_print("_print("+I2S(tbl)+")")


    //if ctx == 0 then
    //    set k = 0
    //endif

    //call Print#_print("  - starting at k = "+I2S(k))

    loop
        if Table#_has( tbl, k ) then
            set v = Table#_get(tbl, k)

	    //if interpreter == 0 then
	    //    if Value#_Type[v] == Types#_Int then
	    //        set r = r + I2S(Value#_Int[v])+".   "
	    //    elseif Value#_Type[v] == Types#_Real then
	    //        set r = r + R2S(Value#_Real[v])+".   "
	    //    elseif Value#_Type[v] == Types#_String then
	    //        set r = r + (Value#_String[v])+".   "
	    //    else
	    //        set r = r + "(type "+I2S(Value#_Type[v])+") .  "
	    //    endif
	    //else
		set r = r + Value#_tostring(v, interpreter) + "   "
	    //endif
            set k = k +1
        else
            exitwhen true
        endif
    endloop
    call Print#_print("|c00aaaaff"+r+"|r")
endfunction

// function setmetatable(table, metatable)
function _setmetatable takes integer params_tbl, integer ctx, integer interpreter returns nothing
    local integer table = Table#_get( params_tbl, 1 )
    local integer metatable = Table#_get( params_tbl, 2 )
    local integer return_table = Table#_get( params_tbl, 0 )
    //call Print#_print("_setmetatable")
    //call Print#_print("  - setting metable of table "+I2S(Value#_Int[table])+" to "+I2S(Value#_Int[metatable]))

    // TODO: check if _Int3 is allready set
    if metatable == Value#_Nil then
	//call Print#_print("  - metatable is nil")
	set Value#_Int3[table] = 0
    else
	//call Print#_print("  - metatable is not nil")
	set Value#_Int3[table] = metatable
    endif

    call Table#_set( Value#_Int[return_table], 1, table )
endfunction

function _dispatch_builtin takes integer value, integer params, integer ctx, integer interpreter returns nothing
    local string name = Value#_String[value]
    local integer tbl = Value#_Int[params]
    //call Print#_print("_dispatch_builtin("+I2S(value)+","+I2S(params)+","+I2S(ctx)+","+I2S(reg_res)+")")
    //call Print#_print("  - tbl = "+I2S(tbl))
    //call Print#_print("  - name = "+name)
    if name == "print" then
        call _print(tbl, ctx, interpreter)
    elseif name == "setmetatable" then
	call _setmetatable(tbl, ctx, interpreter)
    elseif name == "Player" then
	call _Player(tbl, ctx, interpreter)
    elseif name == "CreateTrigger" then
	call _CreateTrigger(tbl, ctx, interpreter)
    elseif name == "TriggerAddAction" then
	call _TriggerAddAction(tbl, ctx, interpreter)
    elseif name == "TriggerRegisterPlayerChatEvent" then
	call _TriggerRegisterPlayerChatEvent(tbl, ctx, interpreter)
    elseif name == "GetEventPlayerChatString" then
	call _GetEventPlayerChatString(tbl, ctx, interpreter)
    elseif name == "TimerStart" then
	call _TimerStart(tbl, ctx, interpreter)
    elseif name == "CreateTimer" then
	call _CreateTimer(tbl, ctx, interpreter)
    else
        call Print#_print("Unknown builtin function "+name)
    endif
endfunction


function _register_builtin takes integer ctx, string name, integer id returns nothing
    call Context#_set( ctx, name, Value#_builtin(name) )
endfunction

function _init takes nothing returns nothing
    set _trigger2value = Table#_alloc()
    set _timer2value = Table#_alloc()
endfunction

