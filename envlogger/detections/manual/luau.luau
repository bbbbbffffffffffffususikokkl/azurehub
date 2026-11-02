-- Luau language + standard library semantics, as executed by the Roblox client's Luau VM.
-- Every expectation here is VM-level behaviour: the suite is validated by running it in plain
-- Lune (same Luau VM, no logger) -- see tools/validate_luau_oracle.py.  Wrappers that a logger
-- installs over builtins (pcall, type, tostring, select, string.format, ...) must reproduce it.
local function errmsg(f, ...)
    local ok, e = pcall(f, ...)
    if ok then return nil end
    return tostring(e)
end
local function stripPos(e) return (tostring(e):gsub("^[^\n]-:%d+: ", "")) end

-- type()/typeof() on Lua values
local typecases = {
    {nil, "nil"}, {true, "boolean"}, {false, "boolean"}, {0, "number"}, {-1.5, "number"}, {math.huge, "number"},
    {"", "string"}, {"x", "string"}, {{}, "table"}, {print, "function"}, {function() end, "function"},
    {coroutine.create(function() end), "thread"}, {buffer.create(1), "buffer"},
}
for i, c in ipairs(typecases) do
    T("luau.type." .. i .. "." .. c[2], function() return EQ(type(c[1]), c[2]) end)
    T("luau.typeof." .. i .. "." .. c[2], function() return EQ(typeof(c[1]), c[2]) end)
end
T("luau.type.userdata", function() return EQ(type(newproxy()), "userdata") end)
T("luau.typeof.userdata", function() return EQ(typeof(newproxy()), "userdata") end)
T("luau.type.missing_arg", function() return EQ(errmsg(type), "missing argument #1") end)
T("luau.typeof.missing_arg", function() return EQ(errmsg(typeof), "missing argument #1") end)
T("luau.typeof.metatable_type_ignored", function() return EQ(typeof(setmetatable({}, {__type = "Fake"})), "table") end)
T("luau.version", function() return EQ(_VERSION, "Luau") end)

-- tostring / tonumber
local numfmt = {
    {0, "0"}, {1, "1"}, {-1, "-1"}, {0.1, "0.1"}, {1 / 3, "0.3333333333333333"}, {100, "100"}, {1e100, "1e+100"},
    {-0.0, "-0"}, {2 ^ 53, "9007199254740992"}, {1e15, "1000000000000000"}, {0.5, "0.5"}, {-2.25, "-2.25"},
    {123456789, "123456789"}, {math.huge, "inf"}, {-math.huge, "-inf"}, {1e-5, "0.00001"}, {3.14159, "3.14159"},
    {1e300, "1e+300"}, {255, "255"}, {2 ^ 31, "2147483648"},
}
for i, c in ipairs(numfmt) do
    T("luau.tostring.number." .. i, function() return EQ(tostring(c[1]), c[2]) end)
    T("luau.concat.number." .. i, function() return EQ("" .. c[1], c[2]) end)
end
T("luau.tostring.nil", function() return EQ(tostring(nil), "nil") end)
T("luau.tostring.bool", function() return EQ(tostring(true) .. tostring(false), "truefalse") end)
T("luau.tostring.missing", function() return EQ(errmsg(tostring), "missing argument #1") end)
T("luau.tostring.__tostring", function() return EQ(tostring(setmetatable({}, {__tostring = function() return "X!" end})), "X!") end)
T("luau.tostring.__tostring_number_ok", function()
    return OK(function() return tostring(setmetatable({}, {__tostring = function() return 5 end})) end)
end)
T("luau.tostring.__tostring_table_errors", function()
    return ERR(function() return tostring(setmetatable({}, {__tostring = function() return {} end})) end, "'__tostring' must return a string")
end)
T("luau.tostring.table_addr", function() return EQ(tostring({}):match("^table: 0x%x+$") ~= nil, true) end)
T("luau.tostring.function_addr", function() return EQ(tostring(function() end):match("^function: 0x%x+$") ~= nil, true) end)
T("luau.tostring.builtin_addr", function() return EQ(tostring(print):match("^function: 0x%x+$") ~= nil, true) end)
T("luau.tostring.thread_addr", function() return EQ(tostring(coroutine.create(print)):match("^thread: 0x%x+$") ~= nil, true) end)
T("luau.tostring.buffer_addr", function() return EQ(tostring(buffer.create(1)):match("^buffer: 0x%x+$") ~= nil, true) end)
local tonum = {
    {"10", nil, 10}, {"0x10", nil, 16}, {"0X1f", nil, 31}, {"10", 2, 2}, {"z", 36, 35}, {"Z", 36, 35}, {"  5  ", nil, 5},
    {"5x", nil, nil}, {"1e2", nil, 100}, {"", nil, nil}, {"  ", nil, nil}, {".5", nil, 0.5}, {"5.", nil, 5},
    {"-7", nil, -7}, {"ff", 16, 255}, {"777", 8, 511}, {"9", 8, nil}, {"inf", nil, math.huge}, {"-inf", nil, -math.huge},
    {"0b101", nil, nil}, {"1_000", nil, nil}, {"1e", nil, nil}, {"0x", nil, nil}, {"- 1", nil, nil},
}
for i, c in ipairs(tonum) do
    T("luau.tonumber." .. i, function()
        if c[2] then return EQ(tonumber(c[1], c[2]), c[3]) end
        return EQ(tonumber(c[1]), c[3])
    end)
end
T("luau.tonumber.number", function() return EQ(tonumber(42), 42) end)
T("luau.tonumber.nonstring", function() return EQ(tonumber({}), nil) end)
T("luau.tonumber.bad_base", function() return ERR(function() return tonumber("1", 99) end) end)
T("luau.tonumber.missing", function() return EQ(errmsg(tonumber), "missing argument #1") end)

-- select / unpack / pack
T("luau.select.count", function() return EQ(select("#", 1, nil, 3, nil), 4) end)
T("luau.select.count_empty", function() return EQ(select("#"), 0) end)
T("luau.select.index", function() local a, b = select(2, "a", "b", "c"); return EQ(a .. b, "bc") end)
T("luau.select.negative", function() return EQ(select(-1, "a", "b", "c"), "c") end)
T("luau.select.zero", function() return EQ(errmsg(select, 0, 1), "invalid argument #1 to 'select' (index out of range)") end)
T("luau.select.toobig", function() return EQ(select("#", select(5, 1, 2)), 0) end)
T("luau.unpack.range", function() local a, b = table.unpack({1, 2, 3}, 2); return EQ(a * 10 + b, 23) end)
T("luau.unpack.global", function() local a, b = unpack({7, 8}); return EQ(a * 10 + b, 78) end)
T("luau.tonumber.nan", function() local n = tonumber("nan"); return EQ(n ~= n, true) end)
T("luau.pack.n", function() local t = table.pack(1, nil, 3); return EQ(t.n, 3) end)

-- raw access
T("luau.rawget.bypass", function() local t = setmetatable({}, {__index = function() return 1 end}); return EQ(rawget(t, "x"), nil) end)
T("luau.rawset.bypass", function()
    local log = {}
    local t = setmetatable({}, {__newindex = function(_, k) log[#log + 1] = k end})
    rawset(t, "a", 1)
    return EQ(#log == 0 and t.a == 1, true)
end)
T("luau.rawset.returns_table", function() local t = {}; return EQ(rawset(t, 1, 2), t) end)
T("luau.rawequal", function() local t = {}; return EQ(rawequal(t, t) and not rawequal(t, {}), true) end)
T("luau.rawequal.bypass_eq", function()
    local mt = {__eq = function() return true end}
    local a, b = setmetatable({}, mt), setmetatable({}, mt)
    return EQ((a == b) and not rawequal(a, b), true)
end)
T("luau.rawlen", function() return EQ(rawlen(setmetatable({1, 2, 3}, {__len = function() return 99 end})), 3) end)
T("luau.rawget.missing", function() return EQ(errmsg(rawget), "missing argument #1 to 'rawget' (table expected)") end)
T("luau.rawget.badtype", function() return EQ(errmsg(rawget, "s", 1), "invalid argument #1 to 'rawget' (table expected, got string)") end)
T("luau.rawset.frozen", function() return ERR(function() rawset(table.freeze({}), "a", 1) end) end)

-- metatables
T("luau.mt.protected_get", function() return EQ(getmetatable(setmetatable({}, {__metatable = "locked!"})), "locked!") end)
T("luau.mt.protected_set", function()
    local t = setmetatable({}, {__metatable = false})
    return EQ(stripPos(errmsg(setmetatable, t, {})), "cannot change a protected metatable")
end)
T("luau.mt.string_metatable", function() return EQ(getmetatable("").__index, string) end)
T("luau.mt.string_method", function() return EQ(("abc"):upper(), "ABC") end)
T("luau.mt.number_none", function() return EQ(getmetatable(1), nil) end)
T("luau.mt.setmetatable_returns", function() local t = {}; return EQ(setmetatable(t, {}), t) end)
T("luau.mt.setmetatable_nil", function() local t = setmetatable({}, {}); setmetatable(t, nil); return EQ(getmetatable(t), nil) end)
T("luau.mt.setmetatable_bad", function() return EQ(errmsg(setmetatable, 1, {}), "invalid argument #1 to 'setmetatable' (table expected, got number)") end)
T("luau.mt.index_chain", function() local b = {x = 1}; local a = setmetatable({}, {__index = b}); return EQ(a.x, 1) end)
T("luau.mt.call", function() local t = setmetatable({}, {__call = function(self, a) return a * 2 end}); return EQ(t(21), 42) end)
T("luau.mt.concat", function() local t = setmetatable({}, {__concat = function(a, b) return "C" end}); return EQ(t .. "x", "C") end)
T("luau.mt.unm", function() local t = setmetatable({}, {__unm = function() return "neg" end}); return EQ(-t, "neg") end)
T("luau.mt.len", function() local t = setmetatable({}, {__len = function() return 7 end}); return EQ(#t, 7) end)
T("luau.mt.lt", function() local mt = {__lt = function() return true end}; return EQ(setmetatable({}, mt) < setmetatable({}, mt), true) end)
T("luau.mt.le", function() local mt = {__le = function() return false end}; return EQ(setmetatable({}, mt) <= setmetatable({}, mt), false) end)
T("luau.mt.arith", function()
    local mt = {__add = function() return 1 end, __sub = function() return 2 end, __mul = function() return 3 end,
        __div = function() return 4 end, __mod = function() return 5 end, __pow = function() return 6 end, __idiv = function() return 7 end}
    local t = setmetatable({}, mt)
    return EQ((t + 1) .. (t - 1) .. (t * 1) .. (t / 1) .. (t % 1) .. (t ^ 1) .. (t // 1), "1234567")
end)
T("luau.mt.iter", function()
    local t = setmetatable({}, {__iter = function() return next, {a = 1} end})
    local n = 0
    for k, v in t do n += v end
    return EQ(n, 1)
end)
T("luau.mt.weak_keys", function()
    local t = setmetatable({}, {__mode = "k"})
    return EQ(getmetatable(t).__mode, "k")
end)
T("luau.mt.newindex", function()
    local store = {}
    local t = setmetatable({}, {__newindex = store})
    t.a = 5
    return EQ(rawget(t, "a") == nil and store.a == 5, true)
end)

-- errors and protected calls
T("luau.pcall.missing", function() return EQ(errmsg(pcall), "missing argument #1") end)
T("luau.pcall.results", function() local ok, a, b = pcall(function() return 1, 2 end); return EQ(ok and a + b == 3, true) end)
T("luau.pcall.error_string_level1", function()
    local ok, e = pcall(function() error("boom") end)
    return EQ(ok == false and e:match(":%d+: boom$") ~= nil, true)
end)
T("luau.pcall.error_level0", function() local _, e = pcall(function() error("boom", 0) end); return EQ(e, "boom") end)
T("luau.pcall.error_direct", function() local _, e = pcall(error, "direct"); return EQ(e, "direct") end)
T("luau.pcall.error_table", function() local t = {}; local _, e = pcall(error, t); return EQ(e, t) end)
T("luau.pcall.error_nil", function() local ok, e = pcall(error); return EQ(ok == false and e == nil, true) end)
T("luau.pcall.error_number", function() local _, e = pcall(function() error(42) end); return EQ(tostring(e):match(":%d+: 42$") ~= nil, true) end)
T("luau.pcall.error_number_level0", function() local _, e = pcall(function() error(42, 0) end); return EQ(e, 42) end)
T("luau.pcall.nested", function() local ok, ok2, e = pcall(pcall, error, "x"); return EQ(ok and not ok2 and e == "x", true) end)
T("luau.pcall.call_nonfunction", function() local ok, e = pcall(42); return EQ(ok == false and stripPos(e) == "attempt to call a number value", true) end)
T("luau.pcall.level2", function()
    local function thrower() error("lvl2", 2) end
    local ok, e = pcall(function() thrower() end)
    return EQ(e:match(":%d+: lvl2$") ~= nil, true)
end)
T("luau.xpcall.handler", function()
    local ok, r = xpcall(function() error("e", 0) end, function(m) return "H:" .. m end)
    return EQ(not ok and r == "H:e", true)
end)
T("luau.xpcall.args", function() local ok, r = xpcall(function(a, b) return a + b end, print, 2, 3); return EQ(ok and r == 5, true) end)
T("luau.xpcall.traceback_handler", function()
    local ok, r = xpcall(function() error("tb") end, debug.traceback)
    return EQ(not ok and type(r) == "string" and r:find("tb", 1, true) ~= nil, true)
end)
T("luau.xpcall.missing", function() return ERR(function() return xpcall() end) end)
T("luau.assert.passthrough", function() local a, b = assert(1, 2); return EQ(a + b, 3) end)
T("luau.assert.default_msg", function() return EQ(stripPos(errmsg(assert, false)), "assertion failed!") end)
T("luau.assert.custom_msg", function() return EQ(errmsg(assert, nil, "custom"), "custom") end)
T("luau.error.vm_index_nil", function() return EQ(stripPos(errmsg(function() local a = nil; return a.b end)), "attempt to index nil with 'b'") end)
T("luau.error.vm_call_nil", function() return EQ(stripPos(errmsg(function() local a = nil; a() end)), "attempt to call a nil value") end)
T("luau.error.vm_arith", function() return EQ(stripPos(errmsg(function() local a = nil; return a + 1 end)), "attempt to perform arithmetic (add) on nil and number") end)
T("luau.error.vm_compare", function() return EQ(stripPos(errmsg(function() return {} < {} end)), "attempt to compare table < table") end)
T("luau.error.vm_len", function() return EQ(stripPos(errmsg(function() local a = nil; return #a end)), "attempt to get length of a nil value") end)
T("luau.error.vm_concat", function() return EQ(stripPos(errmsg(function() return "a" .. {} end)), "attempt to concatenate string with table") end)
T("luau.error.vm_index_number", function() return EQ(stripPos(errmsg(function() local a = 5; return a.x end)), "attempt to index number with 'x'") end)
T("luau.error.vm_newindex_nil", function() return EQ(stripPos(errmsg(function() local a = nil; a.x = 1 end)), "attempt to index nil with 'x'") end)
T("luau.error.vm_frozen", function() return EQ(stripPos(errmsg(function() local t = table.freeze({}); t.x = 1 end)), "attempt to modify a readonly table") end)
T("luau.error.position_line", function()
    local ok, e = pcall(function() error("here") end) local line = debug.info(1, "l")
    return EQ(tonumber(e:match(":(%d+): here$")), line)
end)

-- source instrumentation must not shift line numbers or change loop semantics
T("luau.lines.after_loops", function()
    local l0 = debug.info(1, "l")
    for i = 1, 3 do local _ = i end
    while false do end
    repeat until true
    for _, v in ipairs({1}) do local _ = v end
    local l1 = debug.info(1, "l")
    return EQ(l1 - l0, 5)
end)
T("luau.lines.in_loop_body", function()
    local first, lines = debug.info(1, "l"), {}
    for i = 1, 2 do
        lines[i] = debug.info(1, "l")
    end
    return EQ(lines[1] == first + 2 and lines[2] == first + 2, true)
end)
T("luau.loop.continue", function()
    local s = 0
    for i = 1, 10 do
        if i % 2 == 0 then continue end
        s += i
    end
    return EQ(s, 25)
end)
T("luau.loop.repeat_scope", function()
    local n = 0
    repeat
        local done = n >= 3
        n += 1
    until done
    return EQ(n, 4)
end)
T("luau.loop.nested_break", function()
    local hits = 0
    for i = 1, 5 do
        for j = 1, 5 do
            if j > i then break end
            hits += 1
        end
    end
    return EQ(hits, 15)
end)
T("luau.loop.while_counter", function() local i = 0; while i < 1000 do i += 1 end; return EQ(i, 1000) end)
T("luau.loop.numeric_float_step", function() local n = 0; for _ = 0, 1, 0.25 do n += 1 end; return EQ(n, 5) end)
T("luau.loop.reverse", function() local s = ""; for i = 3, 1, -1 do s ..= i end; return EQ(s, "321") end)
T("luau.loop.generalized", function() local s = 0; for _, v in {1, 2, 3} do s += v end; return EQ(s, 6) end)
T("luau.loop.closure_capture", function()
    local fns = {}
    for i = 1, 3 do fns[i] = function() return i end end
    return EQ(fns[1]() + fns[2]() * 10 + fns[3]() * 100, 321)
end)
T("luau.loop.strings_untouched", function()
    local s = "for i = 1, 10 do while true do end end -- repeat until"
    return EQ(#s, 54)
end)
T("luau.loop.long_string_untouched", function()
    local s = [[
while true do end
for i=1,2 do end]]
    return EQ(s, "while true do end\nfor i=1,2 do end")
end)
T("luau.syntax.if_expression", function() local x = 5; return EQ(if x > 3 then "big" else "small", "big") end)
T("luau.syntax.interpolation", function() local n = 3; return EQ(`n={n} sq={n * n} {"for"}`, "n=3 sq=9 for") end)
T("luau.syntax.compound", function() local x = 10; x -= 3; x *= 2; x //= 3; x ^= 2; x %= 7; return EQ(x, 2) end)
T("luau.syntax.floor_div", function() return EQ(7 // 2 + (-7) // 2, -1) end)
T("luau.syntax.type_annotations", function() local function f(a: number, b: string?): number return a end; return EQ(f(4, nil), 4) end)
T("luau.syntax.typecast", function() local x = (5 :: any) :: number; return EQ(x, 5) end)
T("luau.syntax.varargs", function() local function f(...) return select("#", ...), ... end; local n, a = f(9, 8); return EQ(n * 10 + a, 29) end)
T("luau.syntax.method_call", function() local o = {v = 2}; function o:get(m) return self.v * m end; return EQ(o:get(3), 6) end)
T("luau.syntax.multiple_assignment", function() local a, b, c = 1, 2; a, b = b, a; return EQ(a == 2 and b == 1 and c == nil, true) end)
T("luau.syntax.integer_literals", function() return EQ(0x10 + 0b101 + 1_000, 1021) end)

-- string library
local fmt = {
    {"%d", 42, "42"}, {"%5d", 42, "   42"}, {"%-5d|", 42, "42   |"}, {"%05d", 42, "00042"}, {"%x", 255, "ff"},
    {"%X", 255, "FF"}, {"%o", 8, "10"}, {"%5.2f", 3.14159, " 3.14"}, {"%.3f", 2 / 3, "0.667"}, {"%e", 12345.678, "1.234568e+04"},
    {"%g", 0.0001, "0.0001"}, {"%g", 1e20, "1e+20"}, {"%c", 65, "A"}, {"%s", "str", "str"}, {"%10s", "r", "         r"},
    {"%-4s|", "l", "l   |"}, {"%%", nil, "%"}, {"%i", 7, "7"}, {"%d", 1.9, "1"}, {"%d", -1.9, "-1"}, {"%s", 12, "12"},
    {"%.2s", "abcdef", "ab"}, {"%+d", 5, "+5"}, {"% d", 5, " 5"}, {"%#x", 255, "0xff"},
}
for i, c in ipairs(fmt) do
    T("luau.string.format." .. i, function()
        if c[2] == nil then return EQ(string.format(c[1]), c[3]) end
        return EQ(string.format(c[1], c[2]), c[3])
    end)
end
T("luau.string.format.q", function() return EQ(string.format("%q", 'a\nb"c\0'), '"a\\\nb\\"c\\000"') end)
T("luau.string.format.missing_arg", function() return ERR(function() return string.format("%d") end) end)
T("luau.string.format.bad_spec", function() return ERR(function() return string.format("%y", 1) end) end)
T("luau.string.format.bad_type", function() return ERR(function() return string.format("%d", "x") end) end)
T("luau.string.format.s_bool_errors", function() return ERR(function() return string.format("%s", true) end, "invalid argument #2 to 'format' (string expected, got boolean)") end)
T("luau.string.format.s_table_errors", function() return ERR(function() return string.format("%s", {}) end, "(string expected, got table)") end)
T("luau.string.format.empty", function() return EQ(errmsg(string.format), "missing argument #1 to 'format' (string expected)") end)
T("luau.string.rep", function() return EQ(string.rep("ab", 3), "ababab") end)
T("luau.string.rep_no_separator", function() return EQ(string.rep("ab", 3, ","), "ababab") end)
T("luau.string.rep_zero", function() return EQ(string.rep("x", 0), "") end)
T("luau.string.sub", function() return EQ(("hello"):sub(2, 4) .. ("hello"):sub(-3) .. ("hello"):sub(4, 100), "ellllolo") end)
T("luau.string.sub_empty", function() return EQ(("hello"):sub(4, 2), "") end)
T("luau.string.byte", function() local a, b = string.byte("AB", 1, 2); return EQ(a * 1000 + b, 65066) end)
T("luau.string.byte_default", function() return EQ(string.byte("A"), 65) end)
T("luau.string.char", function() return EQ(string.char(72, 105, 0, 255), "Hi\0\255") end)
T("luau.string.char_bad", function() return ERR(function() return string.char(256) end) end)
T("luau.string.upper_lower", function() return EQ(("MiXeD"):upper() .. ("MiXeD"):lower(), "MIXEDmixed") end)
T("luau.string.reverse", function() return EQ(("abc"):reverse(), "cba") end)
T("luau.string.len", function() return EQ(("a\0b"):len(), 3) end)
T("luau.string.find_plain", function() local a, b = ("a.b.c"):find(".", 1, true); return EQ(a * 10 + b, 22) end)
T("luau.string.find_pattern", function() local a, b = ("hello world"):find("o w"); return EQ(a * 10 + b, 57) end)
T("luau.string.find_captures", function() local _, _, k, v = ("key=val"):find("(%w+)=(%w+)"); return EQ(k .. v, "keyval") end)
T("luau.string.find_none", function() return EQ(("abc"):find("z"), nil) end)
T("luau.string.find_init", function() return EQ(("abcabc"):find("a", 2), 4) end)
T("luau.string.match", function() return EQ(("x=10, y=20"):match("y=(%d+)"), "20") end)
T("luau.string.match_anchor", function() return EQ(("abc"):match("^b"), nil) end)
T("luau.string.match_position", function() return EQ(("abc"):match("()b()"), 2) end)
T("luau.string.gmatch", function() local t = {}; for w in ("one two  three"):gmatch("%a+") do t[#t + 1] = w end; return EQ(table.concat(t, "|"), "one|two|three") end)
T("luau.string.gmatch_pairs", function() local s = 0; for k, v in ("a=1,b=2"):gmatch("(%w)=(%d)") do s += tonumber(v) end; return EQ(s, 3) end)
T("luau.string.gsub_count", function() local s, n = ("hello world"):gsub("o", "0"); return EQ(s .. n, "hell0 w0rld2") end)
T("luau.string.gsub_limit", function() return EQ((("aaa"):gsub("a", "b", 2)), "bba") end)
T("luau.string.gsub_func", function() return EQ((("abc"):gsub("%w", function(c) return c:upper() end)), "ABC") end)
T("luau.string.gsub_table", function() return EQ((("$x $y"):gsub("%$(%w)", {x = "1", y = "2"})), "1 2") end)
T("luau.string.gsub_capture_ref", function() return EQ((("ab"):gsub("(a)(b)", "%2%1")), "ba") end)
T("luau.string.gsub_bad_ref", function() return ERR(function() return ("ab"):gsub("a", "%9") end) end)
T("luau.string.split", function() local p = ("a,b,,c"):split(","); return EQ(#p == 4 and p[3] == "" and p[4] == "c", true) end)
T("luau.string.split_default", function() return EQ(#("a,b"):split(), 2) end)
T("luau.string.pack", function() return EQ(string.pack("<i4", 1), "\1\0\0\0") end)
T("luau.string.unpack", function() local v = string.unpack("<i4", "\1\0\0\0"); return EQ(v, 1) end)
T("luau.string.packsize", function() return EQ(string.packsize("i4i8"), 12) end)
T("luau.string.balanced", function() return EQ(("f(a(b)c)d"):match("%b()"), "(a(b)c)") end)
T("luau.string.frontier", function() return EQ(("THE (quick) fox"):gsub("%f[%a]%a+", "W"), "W (W) W") end)
T("luau.string.class_escapes", function() return EQ(("a1 _B"):gsub("[%w_]", "x"), "xx xx") end)
T("luau.string.no_dump", function() return EQ(string.dump, nil) end)

-- table library
T("luau.table.insert_remove", function()
    local t = {1, 2, 3}
    table.insert(t, 4); table.insert(t, 1, 0)
    local r = table.remove(t, 1); local last = table.remove(t)
    return EQ(table.concat(t, ",") .. "|" .. r .. last, "1,2,3|04")
end)
T("luau.table.concat_range", function() return EQ(table.concat({1, 2, 3, 4}, "-", 2, 3), "2-3") end)
T("luau.table.concat_invalid", function() return ERR(function() return table.concat({1, {}, 3}) end) end)
T("luau.table.sort", function() local t = {3, 1, 2}; table.sort(t); return EQ(table.concat(t), "123") end)
T("luau.table.sort_cmp", function() local t = {3, 1, 2}; table.sort(t, function(a, b) return a > b end); return EQ(table.concat(t), "321") end)
T("luau.table.sort_invalid_cmp", function() return ERR(function() table.sort({3, 2, 1, 5, 4}, function() return true end) end) end)
T("luau.table.find", function() return EQ(table.find({5, 6, 7}, 7), 3) end)
T("luau.table.find_init", function() return EQ(table.find({5, 6, 5}, 5, 2), 3) end)
T("luau.table.find_none", function() return EQ(table.find({1}, 9), nil) end)
T("luau.table.clear", function() local t = {1, 2, x = 3}; table.clear(t); return EQ(next(t), nil) end)
T("luau.table.clone", function()
    local mt = {}
    local t = setmetatable({1, {2}}, mt)
    local c = table.clone(t)
    return EQ(c ~= t and c[2] == t[2] and getmetatable(c) == mt, true)
end)
T("luau.table.freeze", function() local t = table.freeze({}); return EQ(table.isfrozen(t), true) end)
T("luau.table.isfrozen_false", function() return EQ(table.isfrozen({}), false) end)
T("luau.table.freeze_twice", function() return ERR(function() table.freeze(table.freeze({})) end) end)
T("luau.table.create", function() local t = table.create(3, "x"); return EQ(#t == 3 and t[3] == "x", true) end)
T("luau.table.move", function() local t = table.move({1, 2, 3}, 1, 3, 2, {}); return EQ(t[1] == nil and t[2] == 1 and t[4] == 3, true) end)
T("luau.table.maxn", function() return EQ(table.maxn({1, 2, [10] = 1}), 10) end)
T("luau.table.getn", function() return EQ(table.getn({1, 2, 3}), 3) end)
T("luau.table.foreach", function() local n = 0; table.foreach({a = 1, b = 2}, function(_, v) n += v end); return EQ(n, 3) end)
T("luau.table.foreachi", function() local n = 0; table.foreachi({4, 5}, function(i, v) n += i * v end); return EQ(n, 14) end)
T("luau.table.length_border", function() local t = {1, 2, 3}; t[5] = 5; return EQ(#t == 3 or #t == 5, true) end)
T("luau.next.order", function() local t = {10, 20}; local k, v = next(t); return EQ(k == 1 and v == 10, true) end)
T("luau.next.invalid_key", function() return EQ(errmsg(next, {}, "nokey"), "invalid key to 'next'") end)
T("luau.ipairs.stops_at_nil", function() local n = 0; for _ in ipairs({1, 2, nil, 4}) do n += 1 end; return EQ(n, 2) end)
T("luau.ipairs.missing", function() return EQ(errmsg(ipairs), "missing argument #1 to 'ipairs' (table expected)") end)
T("luau.pairs.count", function() local n = 0; for _ in pairs({1, 2, a = 3, b = 4}) do n += 1 end; return EQ(n, 4) end)

-- math library
local mathcases = {
    {"floor", {-0.5}, -1}, {"floor", {2.7}, 2}, {"ceil", {-0.5}, -0}, {"ceil", {2.1}, 3}, {"round", {2.5}, 3},
    {"round", {-2.5}, -3}, {"round", {0.49999999999999994}, 0}, {"sign", {-3}, -1}, {"sign", {0}, 0}, {"sign", {7}, 1},
    {"clamp", {5, 1, 3}, 3}, {"clamp", {-5, 1, 3}, 1}, {"clamp", {2, 1, 3}, 2}, {"abs", {-4}, 4}, {"max", {1, 5, 3}, 5},
    {"min", {1, 5, -3}, -3}, {"fmod", {7, 3}, 1}, {"fmod", {-7, 3}, -1}, {"sqrt", {16}, 4}, {"exp", {0}, 1},
    {"log", {8, 2}, 3}, {"log10", {1000}, 3}, {"pow", {2, 10}, 1024}, {"rad", {180}, math.pi}, {"deg", {math.pi}, 180},
    {"noise", {1, 2, 3}, 0}, {"noise", {0, 0, 0}, 0}, {"noise", {5}, 0}, {"map", {5, 0, 10, 0, 100}, 50},
    {"lerp", {0, 10, 0.25}, 2.5}, {"atan2", {1, 1}, math.pi / 4}, {"ldexp", {1, 4}, 16}, {"cosh", {0}, 1}, {"tanh", {0}, 0},
}
for i, c in ipairs(mathcases) do
    T("luau.math." .. c[1] .. "." .. i, function() return NEAR(math[c[1]](table.unpack(c[2])), c[3], 1e-12) end)
end
T("luau.math.huge", function() return EQ(math.huge, 1 / 0) end)
T("luau.math.pi", function() return EQ(math.pi, 3.141592653589793) end)
T("luau.math.modf", function() local a, b = math.modf(3.75); return EQ(a == 3 and b == 0.75, true) end)
T("luau.math.frexp", function() local m, e = math.frexp(8); return EQ(m == 0.5 and e == 4, true) end)
T("luau.math.clamp_bad", function() return EQ(errmsg(math.clamp, 1, 3, 2), "invalid argument #3 to 'clamp' (max must be greater than or equal to min)") end)
T("luau.math.random_range", function()
    for _ = 1, 200 do local r = math.random(); if r < 0 or r >= 1 then return false, tostring(r) end end
    return true
end)
T("luau.math.random_int", function()
    for _ = 1, 200 do local r = math.random(3, 5); if r < 3 or r > 5 or r % 1 ~= 0 then return false, tostring(r) end end
    return true
end)
T("luau.math.random_one", function() for _ = 1, 50 do if math.random(1) ~= 1 then return false end end return true end)
T("luau.math.random_empty", function() return ERR(function() return math.random(5, 1) end) end)
T("luau.math.randomseed_deterministic", function()
    math.randomseed(1234); local a = math.random(); math.randomseed(1234); return EQ(math.random(), a)
end)
T("luau.math.noise_range", function()
    for i = 1, 50 do local n = math.noise(i * 0.37, i * 0.11, i * 0.73); if n < -1 or n > 1 then return false, tostring(n) end end
    return true
end)
T("luau.math.noise_nonzero", function() return EQ(math.noise(0.5, 0.5, 0.5) ~= 0 or math.noise(1.3, 2.7) ~= 0, true) end)

-- bit32
local bitcases = {
    {"band", {5, 3}, 1}, {"bor", {5, 3}, 7}, {"bxor", {5, 3}, 6}, {"bnot", {0}, 4294967295}, {"lshift", {1, 4}, 16},
    {"rshift", {256, 4}, 16}, {"arshift", {0x80000000, 4}, 0xF8000000}, {"btest", {5, 4}, true}, {"btest", {5, 2}, false},
    {"extract", {0xF0, 4, 4}, 15}, {"replace", {0, 7, 4, 3}, 112}, {"lrotate", {0x80000001, 1}, 3}, {"rrotate", {3, 1}, 0x80000001},
    {"countlz", {1}, 31}, {"countlz", {0}, 32}, {"countrz", {8}, 3}, {"countrz", {0}, 32}, {"byteswap", {0x01020304}, 0x04030201},
    {"band", {-1, 0xFF}, 255}, {"lshift", {1, 32}, 0}, {"rshift", {-1, 31}, 1}, {"bxor", {}, 0}, {"band", {}, 4294967295},
}
for i, c in ipairs(bitcases) do
    T("luau.bit32." .. c[1] .. "." .. i, function() return EQ(bit32[c[1]](table.unpack(c[2])), c[3]) end)
end
T("luau.bit32.bad_arg", function() return ERR(function() return bit32.band("x") end) end)
T("luau.bit32.frozen", function() return EQ(table.isfrozen(bit32), true) end)

-- buffer
T("luau.buffer.create_len", function() return EQ(buffer.len(buffer.create(16)), 16) end)
T("luau.buffer.zeroed", function() return EQ(buffer.readu32(buffer.create(8), 4), 0) end)
T("luau.buffer.rw_ints", function()
    local b = buffer.create(16)
    buffer.writei8(b, 0, -1); buffer.writeu16(b, 1, 65535); buffer.writei32(b, 4, -2); buffer.writeu32(b, 8, 4294967295)
    return EQ(buffer.readi8(b, 0) == -1 and buffer.readu8(b, 0) == 255 and buffer.readu16(b, 1) == 65535
        and buffer.readi32(b, 4) == -2 and buffer.readu32(b, 8) == 4294967295, true)
end)
T("luau.buffer.rw_floats", function()
    local b = buffer.create(12)
    buffer.writef32(b, 0, 0.1); buffer.writef64(b, 4, 0.1)
    return EQ(buffer.readf32(b, 0) == 0.10000000149011612 and buffer.readf64(b, 4) == 0.1, true)
end)
T("luau.buffer.strings", function()
    local b = buffer.fromstring("hello")
    buffer.writestring(b, 1, "ip")
    return EQ(buffer.tostring(b) .. buffer.readstring(b, 1, 2), "hiploip")
end)
T("luau.buffer.copy_fill", function()
    local a, b = buffer.fromstring("abcdef"), buffer.create(6)
    buffer.fill(b, 0, 120); buffer.copy(b, 1, a, 2, 3)
    return EQ(buffer.tostring(b), "xcdexx")
end)
T("luau.buffer.oob", function() return EQ(stripPos(errmsg(buffer.readu8, buffer.create(1), 5)), "buffer access out of bounds") end)
T("luau.buffer.oob_write", function() return ERR(function() buffer.writeu32(buffer.create(2), 0, 1) end) end)
T("luau.buffer.negative_size", function() return ERR(function() return buffer.create(-1) end) end)
T("luau.buffer.typeof", function() return EQ(typeof(buffer.create(0)), "buffer") end)
T("luau.buffer.bits", function()
    local b = buffer.create(4)
    buffer.writebits(b, 3, 5, 21)
    return EQ(buffer.readbits(b, 3, 5), 21)
end)
T("luau.buffer.frozen_lib", function() return EQ(table.isfrozen(buffer), true) end)

-- utf8
T("luau.utf8.char", function() return EQ(utf8.char(72, 228, 8364, 128512), "H\195\164\226\130\172\240\159\152\128") end)
T("luau.utf8.charpattern", function() return EQ(utf8.charpattern, "[\0-\x7F\xC2-\xF4][\x80-\xBF]*") end)
T("luau.utf8.len", function() return EQ(utf8.len("h\195\164h"), 3) end)
T("luau.utf8.len_invalid", function() local n, pos = utf8.len("h\255i"); return EQ(n == nil and pos == 2, true) end)
T("luau.utf8.codepoint", function() local a, b = utf8.codepoint("\195\164\226\130\172", 1, -1); return EQ(a * 100000 + b, 22808364) end)
T("luau.utf8.offset", function() return EQ(utf8.offset("a\195\164b", 3), 4) end)
T("luau.utf8.codes", function() local s = 0; for _, c in utf8.codes("ab") do s += c end; return EQ(s, 195) end)
T("luau.utf8.codes_invalid", function() return ERR(function() for _ in utf8.codes("\255") do end end) end)

-- coroutines (Luau semantics)
T("luau.co.status", function()
    local co
    co = coroutine.create(function() return coroutine.status(co) end)
    local s1 = coroutine.status(co)
    local _, inner = coroutine.resume(co)
    return EQ(s1 .. inner .. coroutine.status(co), "suspendedrunningdead")
end)
T("luau.co.yield_values", function()
    local co = coroutine.create(function(a) local b = coroutine.yield(a + 1); return b * 2 end)
    local _, x = coroutine.resume(co, 1)
    local _, y = coroutine.resume(co, 10)
    return EQ(x * 100 + y, 220)
end)
T("luau.co.wrap", function() local f = coroutine.wrap(function() coroutine.yield(1); return 2 end); return EQ(f() + f(), 3) end)
T("luau.co.wrap_error", function() local f = coroutine.wrap(function() error("werr", 0) end); return EQ(errmsg(f), "werr") end)
T("luau.co.resume_error", function()
    local ok, e = coroutine.resume(coroutine.create(function() error("cerr", 0) end))
    return EQ(not ok and e == "cerr", true)
end)
T("luau.co.isyieldable_main", function()
    local inside
    local co = coroutine.create(function() inside = coroutine.isyieldable() end)
    coroutine.resume(co)
    return EQ(inside, true)
end)
T("luau.co.running", function()
    local co, same
    co = coroutine.create(function() same = coroutine.running() == co end)
    coroutine.resume(co)
    return EQ(same, true)
end)
T("luau.co.close", function()
    local co = coroutine.create(function() coroutine.yield() end)
    coroutine.resume(co)
    local ok = coroutine.close(co)
    return EQ(ok == true and coroutine.status(co) == "dead", true)
end)
T("luau.co.normal_status", function()
    local outer, st
    outer = coroutine.create(function()
        local inner = coroutine.create(function() st = coroutine.status(outer) end)
        coroutine.resume(inner)
    end)
    coroutine.resume(outer)
    return EQ(st, "normal")
end)
T("luau.co.create_bad", function() return ERR(function() return coroutine.create(5) end) end)

-- os
T("luau.os.time_integer", function() local t = os.time(); return EQ(type(t) == "number" and t % 1 == 0 and t > 1.6e9, true) end)
T("luau.os.time_table", function() return EQ(os.time({year = 2000, month = 1, day = 1, hour = 0, min = 0, sec = 0}) ~= nil, true) end)
T("luau.os.clock_monotonic", function() local a = os.clock(); local b = os.clock(); return EQ(b >= a, true) end)
T("luau.os.date_utc", function() return EQ(os.date("!%Y-%m-%d %H:%M:%S", 0), "1970-01-01 00:00:00") end)
T("luau.os.date_table", function() local t = os.date("!*t", 86400 * 365); return EQ(t.year * 100 + t.month, 197101) end)
T("luau.os.difftime", function() return EQ(os.difftime(10, 4), 6) end)
for _, name in ipairs({"exit", "execute", "getenv", "remove", "rename", "tmpname", "setlocale"}) do
    T("luau.os.absent." .. name, function() return EQ(os[name], nil) end)
end
T("luau.os.frozen", function() return EQ(table.isfrozen(os), true) end)
T("luau.libs.frozen_string", function() return EQ(table.isfrozen(string), true) end)
T("luau.libs.frozen_math", function() return EQ(table.isfrozen(math), true) end)
T("luau.libs.frozen_table", function() return EQ(table.isfrozen(table), true) end)
T("luau.libs.frozen_coroutine", function() return EQ(table.isfrozen(coroutine), true) end)
T("luau.libs.frozen_utf8", function() return EQ(table.isfrozen(utf8), true) end)

-- absent Lua 5.x globals
for _, name in ipairs({"load", "dofile", "loadfile", "io", "package", "module", "setglobal", "getglobal"}) do
    T("luau.absent." .. name, function() return EQ(getfenv(0)[name], nil) end)
end

-- debug.info on builtins: C functions report source "[C]", line -1, arity 0 + vararg
local builtins = {
    {print, "print"}, {tostring, "tostring"}, {tonumber, "tonumber"}, {type, "type"}, {typeof, "typeof"},
    {pcall, "pcall"}, {xpcall, "xpcall"}, {error, "error"}, {assert, "assert"}, {select, "select"},
    {rawget, "rawget"}, {rawset, "rawset"}, {rawequal, "rawequal"}, {rawlen, "rawlen"}, {setmetatable, "setmetatable"},
    {getmetatable, "getmetatable"}, {next, "next"}, {ipairs, "ipairs"}, {pairs, "pairs"}, {unpack, "unpack"},
    {math.floor, "floor"}, {math.abs, "abs"}, {math.random, "random"}, {string.format, "format"}, {string.sub, "sub"},
    {string.gsub, "gsub"}, {table.insert, "insert"}, {table.concat, "concat"}, {coroutine.wrap, "wrap"},
    {coroutine.resume, "resume"}, {os.clock, "clock"}, {bit32.band, "band"}, {buffer.create, "create"},
    {utf8.char, "char"}, {string.char, "char"}, {table.unpack, "unpack"}, {newproxy, "newproxy"}, {gcinfo, "gcinfo"},
}
for _, b in ipairs(builtins) do
    T("luau.debuginfo.source." .. b[2], function() return EQ(debug.info(b[1], "s"), "[C]") end)
    T("luau.debuginfo.line." .. b[2], function() return EQ(debug.info(b[1], "l"), -1) end)
    T("luau.debuginfo.name." .. b[2], function() return EQ(debug.info(b[1], "n"), b[2]) end)
    T("luau.debuginfo.arity." .. b[2], function() local n, va = debug.info(b[1], "a"); return EQ(n == 0 and va == true, true) end)
    T("luau.debuginfo.what." .. b[2], function() return EQ(select("#", debug.info(b[1], "slna")), 5) end)
end
T("luau.debuginfo.lua_arity", function() local n, va = debug.info(function(a, b, ...) end, "a"); return EQ(n == 2 and va == true, true) end)
T("luau.debuginfo.lua_line", function()
    local f = function() end local l = debug.info(1, "l")
    return EQ(debug.info(f, "l"), l)
end)
T("luau.debuginfo.level_function", function()
    local me
    local function probe() me = debug.info(1, "f") end
    probe()
    return EQ(me, probe)
end)
T("luau.debuginfo.caller", function()
    local caller
    local function inner() caller = debug.info(2, "f") end
    local function outer() inner() end
    outer()
    return EQ(caller, outer)
end)
T("luau.debuginfo.bad_level", function() return EQ(debug.info(200, "f"), nil) end)
T("luau.debuginfo.bad_options", function() return ERR(function() return debug.info(1, "zz") end) end)
T("luau.debuginfo.named_local", function()
    local function namedThing() return debug.info(1, "n") end
    return EQ(namedThing(), "namedThing")
end)
T("luau.debug.traceback_string", function()
    local tb = debug.traceback("msg")
    return EQ(type(tb) == "string" and tb:sub(1, 4) == "msg\n", true)
end)
T("luau.debug.traceback_nonstring", function() return ERR(function() return debug.traceback({}) end, "invalid argument #1 to 'traceback' (string expected, got table)") end)

-- environment functions
T("luau.fenv.setfenv_lua", function()
    local function f() return injected_global_zq end
    setfenv(f, {injected_global_zq = 5})
    return EQ(f(), 5)
end)
T("luau.fenv.getfenv_function", function()
    local env = {}
    local function f() end
    setfenv(f, env)
    return EQ(getfenv(f), env)
end)
T("luau.fenv.setfenv_c_errors", function() return ERR(function() setfenv(print, {}) end) end)
T("luau.fenv.getfenv_table", function() return EQ(type(getfenv(0)), "table") end)
T("luau.fenv.global_lookup", function() return EQ(getfenv(1).print, print) end)

-- misc builtins
T("luau.newproxy.metatable", function() local p = newproxy(true); getmetatable(p).__index = function() return 9 end; return EQ(p.anything, 9) end)
T("luau.newproxy.plain", function() return EQ(getmetatable(newproxy(false)), nil) end)
T("luau.gcinfo", function() return EQ(type(gcinfo()) == "number" and gcinfo() > 0, true) end)
T("luau.collectgarbage.count", function() return EQ(type(collectgarbage("count")), "number") end)
T("luau.collectgarbage.collect_rejected", function() return ERR(function() return collectgarbage("collect") end) end)
T("luau.collectgarbage.step_rejected", function() return ERR(function() return collectgarbage("step") end) end)
T("luau.string_coercion.arith", function() return EQ("10" + 5, 15) end)
T("luau.string_coercion.concat_num", function() return EQ(1 .. 2, "12") end)
T("luau.integer_division_zero", function() return EQ(1 // 0, math.huge) end)
T("luau.modulo_negative", function() return EQ(-7 % 3, 2) end)
T("luau.nan_ne", function() local n = 0 / 0; return EQ(n ~= n, true) end)
T("luau.vector_lib", function() local v = vector.create(1, 2, 3); return EQ(v.x + v.y + v.z, 6) end)
T("luau.vector_lib_magnitude", function() return EQ(vector.magnitude(vector.create(3, 4, 0)), 5) end)
