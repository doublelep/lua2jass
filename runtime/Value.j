// scope Value
// REQUIRES Table Types List Call

globals

    integer array _Int
    real array    _Real
    string array  _String
    boolean array _Bool
    integer array _Table
    integer array _Type

    integer array _Int2
    integer array _Int3

    // List
    integer array _val
    integer array _key


    // constant
    integer _Nil


    //

    boolean _error


    integer _recycler	 // created via _alloc
    integer _all_objects // created via _alloc
    //#include "alloc-globals.j"
    #include "deque-alloc-globals.j"
endglobals

#include "deque-alloc.j"
//#include "alloc.j"

function _B2S takes boolean b returns string
    if b then
	return "|cffabcd00true|r"
    else
	return "|cffabcd00false|r"
    endif
endfunction

function _new takes nothing returns integer
    return _fresh( _all_objects, _recycler )
    //local integer this = Deque#_fresh( _all_objects, _recycler )
    //return this
endfunction

// @noalloc
function _litnil takes nothing returns integer
    return _Nil
endfunction


// @alloc
function _neg takes integer v returns integer
    local integer new = _new()
    local integer ty = _Type[v]
    if ty == Jass#_integer then
	set _Type[new] = Jass#_integer
	set _Int[new] = - _Int[v]
    elseif ty == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = - _Real[v]
    else
	call Print#_error("_neg: should not happen")
    endif
    return new
endfunction

// @alloc
function _complement takes integer v returns integer
    local integer new = _new()
    set _Type[new] = Jass#_integer
    set _Int[new] = - _Int[v] -1
    return new
endfunction

// @alloc
function _add takes integer a, integer b returns integer
    local integer new = _new()
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]

    if ty_a == Jass#_integer and ty_b == Jass#_integer then
	set _Type[new] = Jass#_integer
	set _Int[new] = _Int[a] + _Int[b]
    elseif ty_a == Jass#_integer  and ty_b == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Int[a] + _Real[b]
    elseif ty_b == Jass#_integer  and ty_a == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Real[a] + _Int[b]
    elseif ty_a == Jass#_real and ty_b == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Real[a] + _Real[b]
    else
	call Print#_error("_add: Error. Should not happen")
    endif
    return new
endfunction

// @alloc
function _sub takes integer a, integer b returns integer
    local integer new = _new()
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]

    if ty_a == Jass#_integer and ty_b == Jass#_integer then
	set _Type[new] = Jass#_integer
	set _Int[new] = _Int[a] - _Int[b]
    elseif ty_a == Jass#_integer  and ty_b == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Int[a] - _Real[b]
    elseif ty_b == Jass#_integer  and ty_a == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Real[a] - _Int[b]
    elseif ty_a == Jass#_real and ty_b == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Real[a] - _Real[b]
    else
	call Print#_error("_sub: Error. Should not happen")
    endif
    return new
endfunction

// @alloc
function _mul takes integer a, integer b returns integer
    local integer new = _new()
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]

    if ty_a == Jass#_integer and ty_b == Jass#_integer then
	set _Type[new] = Jass#_integer
	set _Int[new] = _Int[a] * _Int[b]
    elseif ty_a == Jass#_integer  and ty_b == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Int[a] * _Real[b]
    elseif ty_b == Jass#_integer  and ty_a == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Real[a] * _Int[b]
    elseif ty_a == Jass#_real and ty_b == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Real[a] * _Real[b]
    else
	call Print#_error("_mul: Error. Should not happen")
    endif
    return new
endfunction

// @alloc
function _div takes integer a, integer b returns integer
    // always real division
    local integer new = _new()
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]

    if ty_a == Jass#_integer and ty_b == Jass#_integer then
	set _Type[new] = Jass#_real
	set _Real[new] = I2R(_Int[a]) / _Int[b]
    elseif ty_a == Jass#_integer  and ty_b == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Int[a] / _Real[b]
    elseif ty_b == Jass#_integer  and ty_a == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Real[a] / _Int[b]
    elseif ty_a == Jass#_real and ty_b == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _Real[a] / _Real[b]
    else
	call Print#_error("_div: Error. Should not happen")
    endif
    return new
endfunction

// round towards negative inf
function _floor takes real r returns integer
    local integer i = R2I(r)
    if i == r then
	return i
    elseif r < 0 then
	return R2I(r - 1)
    else
	return i
    endif
endfunction


// @noalloc
function _mod_real takes real dividend, real divisor returns real
    return dividend - divisor * _floor(dividend / divisor )
endfunction

// @noalloc
function _mod_int takes integer dividend, integer divisor returns integer
    return dividend - divisor * _floor(I2R(dividend)/divisor)
endfunction

// @alloc
function _idiv takes integer a, integer b returns integer
    // always returning an integer
    local integer new = _new()
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]

    if ty_a == Jass#_integer and ty_b == Jass#_integer then
	set _Type[new] = Jass#_integer
	set _Int[new] = _floor( I2R(_Int[a]) / _Int[b] )
    elseif ty_a == Jass#_integer  and ty_b == Jass#_real then
	set _Type[new] = Jass#_integer
	set _Int[new] = _floor( _Int[a] / _Real[b] )
    elseif ty_b == Jass#_integer  and ty_a == Jass#_real then
	set _Type[new] = Jass#_integer
	set _Int[new] = _floor( _Real[a] / _Int[b] )
    elseif ty_a == Jass#_real and ty_b == Jass#_real then
	set _Type[new] = Jass#_integer
	set _Int[new] = _floor( _Real[a] / _Real[b] )
    else
	call Print#_error("_idiv: Error. Should not happen")
    endif
    return new
endfunction

// @alloc
function _gt takes integer a, integer b returns integer
    local integer new = _new()
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]
    set _Type[new] = Jass#_boolean

    if ty_a == Jass#_integer and ty_b == Jass#_integer then
	set _Bool[new] = _Int[a] > _Int[b]
    elseif ty_a == Jass#_integer and ty_b == Jass#_real then
	set _Bool[new] = _Int[a] > _Real[b]
    elseif ty_b == Jass#_integer and ty_a == Jass#_real then
	set _Bool[new] = _Real[a] > _Int[b]
    elseif ty_a == Jass#_real and ty_b == Jass#_real then
	set _Bool[new] = _Real[a] > _Real[b]
    else
	call Print#_error("_gt: Error. Should not happen")
    endif
    return new
endfunction

// @alloc
function _gte takes integer a, integer b returns integer
    local integer new = _new()
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]
    set _Type[new] = Jass#_boolean

    if ty_a == Jass#_integer and ty_b == Jass#_integer then
	set _Bool[new] = _Int[a] >= _Int[b]
    elseif ty_a == Jass#_integer and ty_b == Jass#_real then
	set _Bool[new] = _Int[a] >= _Real[b]
    elseif ty_b == Jass#_integer and ty_a == Jass#_real then
	set _Bool[new] = _Real[a] >= _Int[b]
    elseif ty_a == Jass#_real and ty_b == Jass#_real then
	set _Bool[new] = _Real[a] >= _Real[b]
    else
	call Print#_error("_gte: Error. Should not happen")
    endif
    return new
endfunction

// @alloc
function _lt takes integer a, integer b returns integer
    local integer new = _new()
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]
    set _Type[new] = Jass#_boolean

    if ty_a == Jass#_integer and ty_b == Jass#_integer then
	set _Bool[new] = _Int[a] < _Int[b]
    elseif ty_a == Jass#_integer and ty_b == Jass#_real then
	set _Bool[new] = _Int[a] < _Real[b]
    elseif ty_b == Jass#_integer and ty_a == Jass#_real then
	set _Bool[new] = _Real[a] < _Int[b]
    elseif ty_a == Jass#_real and ty_b == Jass#_real then
	set _Bool[new] = _Real[a] < _Real[b]
    else
	call Print#_error("_lt: Error. Should not happen")
    endif
    return new
endfunction

// @alloc
function _lte takes integer a, integer b returns integer
    local integer new = _new()
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]
    set _Type[new] = Jass#_boolean

    if ty_a == Jass#_integer and ty_b == Jass#_integer then
	set _Bool[new] = _Int[a] <= _Int[b]
    elseif ty_a == Jass#_integer and ty_b == Jass#_real then
	set _Bool[new] = _Int[a] <= _Real[b]
    elseif ty_b == Jass#_integer and ty_a == Jass#_real then
	set _Bool[new] = _Real[a] <= _Int[b]
    elseif ty_a == Jass#_real and ty_b == Jass#_real then
	set _Bool[new] = _Real[a] <= _Real[b]
    else
	call Print#_error("_lte: Error. Should not happen")
    endif
    return new
endfunction


// @alloc
function _litint takes integer a returns integer
    local integer new = _new()
    set _Type[new] = Jass#_integer
    set _Int[new] = a
    return new
endfunction

// @alloc
function _litfloat takes real a returns integer
    local integer new = _new()
    set _Type[new] = Jass#_real
    set _Real[new] = a
    return new
endfunction

// @alloc
function _litbool takes boolean a returns integer
    local integer new = _new()
    set _Type[new] = Jass#_boolean
    set _Bool[new] = a
    return new
endfunction

// @alloc
function _litstring takes string a returns integer
    local integer new = _new()
    set _Type[new] = Jass#_string
    set _String[new] = a
    return new
endfunction

// @alloc
function _table takes nothing returns integer
    local integer new = _new()
    set _Type[new] = Types#_Table
    set _Int[new] = Table#_alloc()  // int keys
    set _Int2[new] = Table#_alloc() // non-int keys
    set _Int3[new] = 0
    return new
endfunction


// @alloc
function _lambda takes integer a, string name returns integer
    local integer new = _new()
    set _Type[new] = Types#_Lambda
    set _Int[new] = a
    set _String[new] = name
    return new
endfunction

// @alloc
function _builtin takes string f returns integer
    local integer new = _new()
    set _Type[new] = Types#_BuiltInFunction
    set _String[new] = f
    return new
endfunction

// @noalloc
function _truthy takes integer a returns boolean
    local integer ty = _Type[a]
    if ty == Jass#_boolean then
	return _Bool[a]
    elseif ty == Types#_Nil then
	return false
    else
	return true
    endif
endfunction


// @noalloc
function _rawequal_noalloc takes integer a, integer b returns boolean
    local integer type_a = _Type[a]
    local integer type_b = _Type[b]
    if type_a == Jass#_integer and type_b == Jass#_integer then
	return _Int[a] == _Int[b]
    elseif type_a == Jass#_real and type_b == Jass#_real then
	// TODO: see if wc3 lua has the same quirky behavior for
	// real comparison
	return not (_Real[a] != _Real[b]) 
    elseif type_a == Jass#_integer and type_b == Jass#_real then
	return I2R(_Int[a]) == _Real[b]
    elseif type_b == Jass#_integer and type_a == Jass#_real then
	return I2R(_Int[b]) == _Real[a]
    elseif type_a == Jass#_boolean and type_b == Jass#_boolean then
	return _Bool[a] == _Bool[b]
    elseif type_a == Jass#_string and type_b == Jass#_string then
	return _String[a] == _String[b]
    elseif type_a == Types#_Table and type_b == Types#_Table then
	return _Int[a] == _Int[b]
    elseif type_a == Types#_Lambda and type_b == Types#_Lambda then
	return _Int[a] == _Int[b]
    elseif type_a == Types#_BuiltInFunction and type_b == Types#_BuiltInFunction then
	return _String[a] == _String[b]
    else
	return false
    endif
endfunction

// @noalloc
function _hash takes integer v returns integer
    // TODO: use some random seed
    local integer ty = _Type[v]
    if ty == Jass#_string then
	return StringHash(_String[v])
    elseif ty == Types#_Table then
	return _Int[v] * 23 + 1337
    elseif ty == Jass#_real then
	return R2I( _Real[v] * 16180.33 )
    elseif ty == Types#_Lambda then
	return _Int[v]
    elseif ty == Types#_BuiltInFunction then // TODO: we want to use IDs anyway i think
	return StringHash(_String[v])
    elseif ty == Jass#_boolean then
	if _Bool[v] then
	    return 0x11111111
	else
	    return 0xffffffff
	endif
    else
	return 0
    endif
endfunction

// @noalloc
function _settable takes integer t, integer k, integer v returns nothing
    local integer ty = _Type[k]
    local integer tbl
    local integer ls
    local integer prev

    //call Print#_print("_settable("+I2S(t)+","+I2S(k)+","+I2S(v)+")")

    if _Type[t] != Types#_Table then
	call Print#_error("Expected table but got "+I2S(_Type[t]))
    endif

    if _Type[k] == Types#_Nil then
	call Print#_error("table index is nil")
    endif

    if ty == Jass#_integer then
//	call Print#_print("  - int key: "+I2S(_Int[k]))
//	call Print#_print("  - _Int table id: "+I2S(_Int[t]))
	call Table#_set( _Int[t], _Int[k], v )
    elseif ty == Jass#_real and _Real[k] == R2I(_Real[k]) then
	//call Print#_print("  - real type but int key")
	call Table#_set( _Int[t], R2I(_Real[k]), v )
    else
	//call Print#_print("  - key of type "+I2S(ty))
	set tbl = _Int2[t]
	set ls = Table#_get( tbl, _hash(k) )
	set prev = ls
	loop
	exitwhen ls == 0
	    //call Print#_print("  - "+I2S(ls))
	    if _rawequal_noalloc(_key[ls], k) then
		set _val[ls] = v
		//return _val[ls]
		return
	    endif
	    set prev = ls
	    set ls = List#_next[ls]
	endloop
	set prev = List#_cons(prev)
	set _key[prev] = k
	set _val[prev] = v
	call Table#_set( tbl, _hash(k), prev )
    endif
endfunction


// @noalloc
function _gettable takes integer v, integer k returns integer
    local integer ty = _Type[k]
    local integer tbl
    local integer ls
    //call Print#_print("_gettable")
    if ty == Jass#_integer then
	//call Print#_print("  - int key")
	return Table#_get( _Int[v], _Int[k] )
    elseif ty == Jass#_real and _Real[k] == R2I(_Real[k]) then
	//call Print#_print("  - real type but int key")
	return Table#_get( _Int[v], R2I(_Real[k]) )
    else
	//call Print#_print("  - key of type "+I2S(ty))
	set tbl = _Int2[v]
	set ls = Table#_get( tbl, _hash(k) )
	loop
	exitwhen ls == 0
	    if _rawequal_noalloc(_key[ls], k) then
		return _val[ls]
	    endif
	    set ls = List#_next[ls]
	endloop
	return _Nil
    endif
endfunction

function _len takes integer v returns integer
    local integer ty = _Type[v]
    local integer k = 1
    local integer tbl
    //call Print#_print("_len")
    if ty == Jass#_string then
	return Value#_litint(StringLength(_String[v]))
    elseif ty == Types#_Table then
	set tbl = _Int[v]
	loop
	    //call Print#_print("  - checking key k = "+ I2S(k))
	    if Table#_has( tbl, k ) then
		//call Print#_print("  - v = "+_tostring(Table#_get(tbl, k)))
		set k = k +1
	    else
		//call Print#_print("  - table does not have key, returning k = "+I2S(k))
		return _litint(k)
	    endif
	endloop
    endif
    return Value#_litint(0) // TODO
endfunction

// @alloc
function _mod takes integer a, integer b returns integer
    local integer new = _new()
    local integer tya = _Type[a]
    local integer tyb = _Type[b]
    if tya == Jass#_integer and tyb == Jass#_integer then
	set _Type[new] = Jass#_integer
	set _Int[new] = _mod_int(_Int[a],  _Int[b])
    elseif tya == Jass#_real and tyb == Jass#_real then
	set _Type[new] = Jass#_real
	set _Real[new] = _mod_real( _Real[a], _Real[b] )
    elseif tya == Jass#_real and tyb == Jass#_integer then
	set _Type[new] = Jass#_real
	set _Real[new] = _mod_real( _Real[a], _Int[b] )
    elseif tyb == Jass#_real and tya == Jass#_integer then
	set _Type[new] = Jass#_real
	set _Real[new] = _mod_real( _Int[a], _Real[b] )
    endif

    return new
endfunction

// @alloc
function _exp takes integer a, integer b returns integer
    local integer new = _new()
    local integer tya = _Type[a]
    local integer tyb = _Type[b]
    set _Type[new] = Jass#_real
    if tya == Jass#_integer and tyb == Jass#_integer then
	set _Real[new] = Pow(_Int[a], _Int[b])
    elseif tya == Jass#_real and tyb == Jass#_real then
	set _Real[new] = Pow( _Real[a], _Real[b] )
    elseif tya == Jass#_real and tyb == Jass#_integer then
	set _Real[new] = Pow( _Real[a], _Int[b] )
    elseif tyb == Jass#_real and tya == Jass#_integer then
	set _Real[new] = Pow( _Int[a], _Real[b] )
    endif

    return new
endfunction

// bit functions

// @alloc
function _shiftl takes integer a, integer b returns integer
    local integer new = _new()
    set _Type[new] = Jass#_integer
    if _Int[b] < 0 then
	set _Int[new] = _Int[a] / R2I(Pow(2, -_Int[b]))
    else
	set _Int[new] = _Int[a] * R2I(Pow(2, _Int[b]) )
    endif
    return new
endfunction

// @alloc
function _shiftr takes integer a, integer b returns integer
    local integer new = _new()
    set _Type[new] = Jass#_integer
    if _Int[b] < 0 then
	set _Int[new] = _Int[a] * R2I(Pow(2, -_Int[b]) )
    else
	set _Int[new] = _Int[a] / R2I(Pow(2, _Int[b]) )
    endif
    return new
endfunction

// @alloc
function _band takes integer a, integer b returns integer
    local integer new = _new()
    set _Type[new] = Jass#_integer
    set _Int[new] = BlzBitAnd( _Int[a], _Int[b] ) // TODO: pre 1.31 patches
    return new
endfunction

// @alloc
function _bor takes integer a, integer b returns integer
    local integer new = _new()
    set _Type[new] = Jass#_integer
    set _Int[new] = BlzBitOr( _Int[a], _Int[b] ) // TODO: pre 1.31 patches
    return new
endfunction

// @alloc
function _bxor takes integer a, integer b returns integer
    local integer new = _new()
    set _Type[new] = Jass#_integer
    set _Int[new] = BlzBitXor( _Int[a], _Int[b] ) // TODO: pre 1.31 patches
    return new
endfunction


// @alloc
function _eq takes integer a, integer b returns integer
    local integer new = _new()
    set _Type[new] = Jass#_boolean
    set _Bool[new] = _rawequal_noalloc(a, b)
    return new
endfunction

// @alloc
function _neq takes integer a, integer b returns integer
    local integer new = _new()
    set _Type[new] = Jass#_boolean
    set _Bool[new] = not _rawequal_noalloc(a, b)
    return new
endfunction

// @alloc
function _not takes integer v returns integer
    local integer new = _new()
    set _Type[new] = Jass#_boolean
    set _Bool[new] = not _truthy(v)
    return new
endfunction


function _parse_digit takes string c returns integer
    if c == "F" then
	return 15
    elseif c == "E" then
	return 14
    elseif c == "D" then
	return 13
    elseif c == "C" then
	return 12
    elseif c == "B" then
	return 11
    elseif c == "A" then
	return 10
    elseif c == "9" then
	return 9
    elseif c == "8" then
	return 8
    elseif c == "7" then
	return 7
    elseif c == "6" then
	return 6
    elseif c == "5" then
	return 5
    elseif c == "4" then
	return 4
    elseif c == "3" then
	return 3
    elseif c == "2" then
	return 2
    elseif c == "1" then
	return 1
    elseif c == "0" then
	return 0
    else
	return -1
    endif
endfunction

function _parse_number takes string s returns real
    local integer i = 0
    local integer len = StringLength(s)
    local string c
    local real res = 0.0
    local real frac = 0.0
    local integer tmp
    local boolean dot = false
    local integer dotpos = -1
    local integer base = 3
    local integer exp = 0
    local real exp_sign = 1
    local real sign = 1

    //call Print#_print("_parse_number("+s+")")

    set _error = false


    // ltrim
    loop
	set c = SubString(s, i, i+1)
	exitwhen c != " " and c != "\t" and c != "\n" and c != "\r"
	set i = i +1
    endloop
    //set s = SubString(s, i, len)

    set c = SubString(s, i, i+1)
    if c == "+" then
	set i = i +1
    elseif c == "-" then
	set i = i +1
	set sign = -1
    endif

    // base detection
    if StringCase(SubString(s, i, i+2), true) == "0X" then
	set base = 16
	set i = i+2
    else
	set base = 10
    endif

    // parsing number
    loop
    exitwhen i >= len
	set c = StringCase(SubString(s, i, i+1), true)
	set tmp = _parse_digit(c)

	if c == "." and dot then
	    set _error = true
	    return 0.0
	elseif c == "." then
	    set dot = true
	    set dotpos = i
	elseif c == "E" and base == 10 then
	    // scientific notation
	    set i = i +1
	    set c = SubString(s, i, i+1)
	    if c == "+" then
		set i = i +1
	    elseif c == "-" then
		set i = i +1
		set exp_sign = -1
	    else
		set tmp = _parse_digit(c)
		if tmp < 0 or tmp > 9 then
		    set _error = true
		    return 0.0
		endif
	    endif

	    loop
	    exitwhen i >= len
		set c = SubString(s, i, i+1)
		set tmp = _parse_digit(c)
		if tmp < 0 or tmp >= 10 then
		    set _error = true
		    return 0.0
		endif
		set exp = exp * 10 + tmp
		set i = i +1
	    endloop
	    exitwhen true
	elseif tmp >= base then
	    set _error = true
	    return 0.0
	elseif tmp < 0 then
	    set i = i -1
	    exitwhen true
	elseif tmp >= 0 then
	    if dot then
		set frac = frac + tmp/Pow(base, i-dotpos)
	    else
		set res = res * base + tmp
	    endif
	else
	endif
	set i = i + 1
    endloop

    // error checking and rtrim
    loop
    exitwhen i >= len
	set c = SubString(s, i, i+1)
	if c != " " and c != "\t" and c != "\n" and c != "\r" then
	    set _error = true
	    return 0.0
	endif
	set i = i + 1
    endloop

    return sign * (res + frac) * Pow(10, exp*exp_sign)
endfunction



// @recursive
function _tostring takes integer v, integer interpreter returns string
    local integer ty = _Type[v]
    local integer metatable
    local integer metamethod
    local integer ret
    //call Print#_print("_tostring")
    //call Print#_print("  - type: "+I2S(ty))
    if ty == Jass#_integer then
	//call Print#_print("  - int")
	return I2S(_Int[v])
    elseif ty == Jass#_real then
	//call Print#_print("  - real")
	return R2S(_Real[v])
    elseif ty == Jass#_string then
	//call Print#_print("  - string")
	return _String[v]
    elseif ty == Types#_Lambda then
	//call Print#_print("  - lambda")
	return "Fun: "+ I2S(_Int[v])
    elseif ty == Types#_BuiltInFunction then
	//call Print#_print("  - native")
	return "Native: " + I2S(_Int[v])
    elseif ty == Types#_Table then
	//call Print#_print("  - table")
	set metatable = _Int3[v]
	if metatable != 0 then
	    set metamethod = _gettable( metatable, _litstring("__tostring"))
	    if metamethod != _Nil then
		set ret = _table()
		call Call#_call1( metamethod, v, ret, interpreter )
		return _tostring( Table#_get( _Int[ret], 1), interpreter )
	    endif
	endif
	return "Table: " + I2S(_Int[v])
    elseif ty == Jass#_boolean then
	if Value#_Bool[v] then
	    return "true"
	else
	    return "false"
	endif
    elseif ty == Types#_Nil then
	return "nil"
    else
	return "unknown: " + I2S(_Type[v])
    endif
endfunction

// @recursive
// TODO: concat actually doesn't call __tostring metamethod
function _concat takes integer a, integer b, integer interpreter returns integer
    local integer ty_a = _Type[a]
    local integer ty_b = _Type[b]
    local string sa
    local string sb
    if ty_a != Jass#_string then
	set sa = Value#_tostring(a, interpreter)
    else
	set sa = _String[a]
    endif
    if ty_b != Jass#_string then
	set sb = Value#_tostring(b, interpreter)
    else
	set sb = _String[b]
    endif
    call Print#_print("_concat")
    call Print#_print("  - sa: " + sa)
    call Print#_print("  - sb: " + sb)
    return Value#_litstring( sa + sb )

endfunction


function _init takes nothing returns nothing
    set _recycler = _alloc() // this is the deque alloc
    set _all_objects = _alloc() // this is the deque alloc
    //set _recycler = Deque#_alloc()
    //set _all_objects = Deque#_alloc()
    //set _Nil = _new()
    //set _Type[_Nil] = Types#_Nil
endfunction

