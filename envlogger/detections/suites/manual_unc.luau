-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "manual_unc"
local __total, __pass, __fail = 0, 0, 0
local __pcall, __tostring, __typeof, __print, __type = pcall, tostring, typeof, print, type
local __find, __abs, __max = string.find, math.abs, math.max
local function S(v)
    local okT, t = __pcall(__typeof, v)
    local okS, s = __pcall(__tostring, v)
    return (okT and t or "?") .. ":" .. (okS and s or "<tostring error>")
end
local function T(id, f)
    __total = __total + 1
    local ok, r, why = __pcall(f)
    if ok and r == true then
        __pass = __pass + 1
        return
    end
    __fail = __fail + 1
    local detail
    if not ok then
        detail = "error: " .. __tostring(r)
    elseif why ~= nil then
        detail = __tostring(why)
    else
        detail = "returned " .. S(r)
    end
    __print("@@F|" .. id .. "|" .. detail)
end
-- exact equality
local function EQ(a, b)
    if a == b then return true end
    return false, "expected " .. S(b) .. " got " .. S(a)
end
-- numeric equality within a relative tolerance (default 1e-6)
local function NEAR(a, b, eps)
    if a == b then return true end
    if __type(a) == "number" and __type(b) == "number" and __abs(a - b) <= (eps or 1e-6) * __max(1, __abs(b)) then
        return true
    end
    return false, "expected ~" .. S(b) .. " got " .. S(a)
end
-- component-wise tolerance for a list of numbers
local function NEARV(got, exp, eps)
    for i = 1, #exp do
        local g, e = got[i], exp[i]
        if not (g == e or (__type(g) == "number" and __abs(g - e) <= (eps or 1e-6) * __max(1, __abs(e)))) then
            return false, "component " .. i .. " expected ~" .. __tostring(e) .. " got " .. __tostring(g)
        end
    end
    return true
end
local function TY(v, t)
    local got = __typeof(v)
    if got == t then return true end
    return false, "expected typeof " .. t .. " got " .. got .. " (" .. S(v) .. ")"
end
-- the call must raise; when `needle` is given the message must contain it (plain find)
local function ERR(f, needle)
    local ok, e = __pcall(f)
    if ok then return false, "expected an error, call succeeded" end
    if needle ~= nil and not __find(__tostring(e), needle, 1, true) then
        return false, "error message mismatch: " .. __tostring(e)
    end
    return true
end
-- the call must not raise
local function OK(f)
    local ok, e = __pcall(f)
    if ok then return true end
    return false, "unexpected error: " .. __tostring(e)
end
-- assert one sub-check inside a multi-step check: A(EQ(x, 1)); A(TY(y, "Vector3")); return true
local function A(r, why)
    if r ~= true then error(why or "sub-check failed", 0) end
end
__print("@@B|" .. __suite)

-- Executor environment (UNC). Assertions mirror the public UNC environment check: the logger
-- presents itself as an executor, so a script probing these functions must see UNC behaviour.
-- Network-dependent APIs (request, WebSocket.connect) are only checked for presence.
local function exists(name)
    local cur = getfenv(0)
    for part in name:gmatch("[^%.]+") do
        if type(cur) ~= "table" then return nil end
        cur = cur[part]
    end
    return cur
end
local uncFunctions = {
    "cache.invalidate", "cache.iscached", "cache.replace", "cloneref", "compareinstances", "checkcaller",
    "clonefunction", "getcallingscript", "getscriptclosure", "hookfunction", "iscclosure", "islclosure",
    "isexecutorclosure", "loadstring", "newcclosure", "crypt.base64encode", "crypt.base64decode", "crypt.encrypt",
    "crypt.decrypt", "crypt.generatebytes", "crypt.generatekey", "crypt.hash", "debug.getconstant",
    "debug.getconstants", "debug.getinfo", "debug.getproto", "debug.getprotos", "debug.getstack", "debug.getupvalue",
    "debug.getupvalues", "debug.setconstant", "debug.setstack", "debug.setupvalue", "readfile", "listfiles",
    "writefile", "makefolder", "appendfile", "isfile", "isfolder", "delfolder", "delfile", "loadfile", "dofile",
    "isrbxactive", "mouse1click", "mouse1press", "mouse1release", "mouse2click", "mouse2press", "mouse2release",
    "mousemoveabs", "mousemoverel", "mousescroll", "fireclickdetector", "getcallbackvalue", "getconnections",
    "getcustomasset", "gethiddenproperty", "sethiddenproperty", "gethui", "getinstances", "getnilinstances",
    "isscriptable", "setscriptable", "setrbxclipboard", "getrawmetatable", "hookmetamethod", "getnamecallmethod",
    "isreadonly", "setrawmetatable", "setreadonly", "identifyexecutor", "lz4compress", "lz4decompress",
    "messagebox", "queue_on_teleport", "request", "setclipboard", "setfpscap", "getgc", "getgenv",
    "getloadedmodules", "getrenv", "getrunningscripts", "getscriptbytecode", "getscripthash", "getscripts",
    "getsenv", "getthreadidentity", "setthreadidentity", "Drawing.new", "isrenderobj", "getrenderproperty",
    "setrenderproperty", "cleardrawcache", "WebSocket.connect", "firesignal", "fireproximityprompt",
    "firetouchinterest", "getfpscap", "restorefunction",
}
for _, name in ipairs(uncFunctions) do
    T("unc.exists." .. name, function() return TY(exists(name), "function") end)
end

-- cache / references
T("unc.cache.invalidate", function()
    local container = Instance.new("Folder")
    local part = Instance.new("Part", container)
    cache.invalidate(container:FindFirstChild("Part"))
    return EQ(part ~= container:FindFirstChild("Part"), true)
end)
T("unc.cache.iscached", function()
    local part = Instance.new("Part")
    A(EQ(cache.iscached(part), true)); cache.invalidate(part); return EQ(cache.iscached(part), false)
end)
T("unc.cache.replace", function()
    local part, fire = Instance.new("Part"), Instance.new("Fire")
    cache.replace(part, fire)
    return EQ(part ~= fire, true)
end)
T("unc.cloneref.distinct", function() local p = Instance.new("Part"); return EQ(cloneref(p) ~= p, true) end)
T("unc.cloneref.shared_state", function()
    local p = Instance.new("Part"); local c = cloneref(p); c.Name = "Test"
    return EQ(p.Name, "Test")
end)
T("unc.cloneref.typeof", function() return TY(cloneref(workspace), "Instance") end)
T("unc.compareinstances", function()
    local p = Instance.new("Part"); local c = cloneref(p)
    A(EQ(p ~= c, true)); return EQ(compareinstances(p, c), true)
end)
T("unc.compareinstances_false", function() return EQ(compareinstances(Instance.new("Part"), Instance.new("Part")), false) end)
T("unc.checkcaller", function() return EQ(checkcaller(), true) end)

-- closures
T("unc.clonefunction", function()
    local function f() return "success" end
    local copy = clonefunction(f)
    A(EQ(f(), copy())); return EQ(f ~= copy, true)
end)
T("unc.hookfunction", function()
    local function f() return true end
    local ref = hookfunction(f, function() return false end)
    A(EQ(f(), false)); A(EQ(ref(), true)); return EQ(f ~= ref, true)
end)
T("unc.hookfunction_c", function()
    local fn = coroutine.isyieldable
    local saw = false
    local old = hookfunction(fn, function(...) saw = true; return false end)
    fn()
    hookfunction(fn, old)
    return EQ(saw, true)
end)
T("unc.iscclosure", function() A(EQ(iscclosure(print), true)); return EQ(iscclosure(function() end), false) end)
T("unc.islclosure", function() A(EQ(islclosure(print), false)); return EQ(islclosure(function() end), true) end)
T("unc.isexecutorclosure", function()
    A(EQ(isexecutorclosure(isexecutorclosure), true)); A(EQ(isexecutorclosure(newcclosure(function() end)), true))
    A(EQ(isexecutorclosure(function() end), true)); return EQ(isexecutorclosure(print), false)
end)
T("unc.newcclosure", function()
    local function f() return true end
    local c = newcclosure(f)
    A(EQ(f(), c())); A(EQ(f ~= c, true)); return EQ(iscclosure(c), true)
end)
T("unc.newcclosure_args", function() local c = newcclosure(function(a, b) return a * b, a + b end); local x, y = c(3, 4); return EQ(x * 100 + y, 1207) end)
T("unc.newcclosure_debuginfo", function() return EQ(debug.info(newcclosure(function() end), "s"), "[C]") end)
T("unc.loadstring_math", function() return EQ(assert(loadstring("return ... + 1"))(1), 2) end)
T("unc.loadstring_error", function() local f, e = loadstring("f"); return EQ(f == nil and type(e) == "string", true) end)
T("unc.loadstring_env", function() local f = loadstring("return game"); return EQ(f(), game) end)

-- crypt
T("unc.crypt.base64encode", function() return EQ(crypt.base64encode("test"), "dGVzdA==") end)
T("unc.crypt.base64decode", function() return EQ(crypt.base64decode("dGVzdA=="), "test") end)
T("unc.crypt.base64_binary", function()
    local s = ""; for i = 0, 255 do s ..= string.char(i) end
    return EQ(crypt.base64decode(crypt.base64encode(s)), s)
end)
T("unc.crypt.base64_padding", function() return EQ(crypt.base64encode("a") .. crypt.base64encode("ab"), "YQ==YWI=") end)
T("unc.crypt.encrypt", function()
    local key = crypt.generatekey()
    local enc, iv = crypt.encrypt("test", key, nil, "CBC")
    A(EQ(iv ~= nil, true))
    return EQ(crypt.decrypt(enc, key, iv, "CBC"), "test")
end)
T("unc.crypt.decrypt", function()
    local key, iv = crypt.generatekey(), crypt.generatekey()
    local enc = crypt.encrypt("test", key, iv, "CBC")
    return EQ(crypt.decrypt(enc, key, iv, "CBC"), "test")
end)
T("unc.crypt.generatebytes", function()
    for _, size in ipairs({10, 16, 33, 100}) do
        local b = crypt.generatebytes(size)
        if #crypt.base64decode(b) ~= size then return false, "size " .. size end
    end
    return true
end)
T("unc.crypt.generatekey", function() return EQ(#crypt.base64decode(crypt.generatekey()), 32) end)
local hashes = {
    md5 = "098f6bcd4621d373cade4e832627b4f6",
    sha1 = "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3",
    sha256 = "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
    sha384 = "768412320f7b0aa5812fce428dc4706b3cae50e02a64caa16a782249bfe8efc4b7ef1ccb126255d196047dfedf17a0a9",
    sha512 = "ee26b0dd4af7e749aa1a8ee3c10ae9923f618980772e473f8819a5d4940e0db27ac185f8a0e1d5f84f88bc887fd67b143732c304cc5fa9ad8e6f57f50028a8ff",
    ["sha3-256"] = "36f028580bb02cc8272a9a020f4200e346e276ae664e45ee80745574e2f5ab80",
}
for algo, expected in pairs(hashes) do
    T("unc.crypt.hash." .. algo, function() return EQ(string.lower(crypt.hash("test", algo)), expected) end)
end

-- debug library extensions
T("unc.debug.getconstant", function()
    local function f() print("Hello, world!") end
    A(EQ(debug.getconstant(f, 1), "print")); A(EQ(debug.getconstant(f, 2), nil)); return EQ(debug.getconstant(f, 3), "Hello, world!")
end)
T("unc.debug.getconstants", function()
    local function f() local num = 5000 .. 50000; print("Hello, world!", num, warn) end
    local c = debug.getconstants(f)
    A(EQ(c[1], 50000)); A(EQ(c[2], "print")); A(EQ(c[3], nil)); A(EQ(c[4], "Hello, world!")); return EQ(c[5], "warn")
end)
T("unc.debug.getinfo", function()
    local types = {source = "string", short_src = "string", func = "function", what = "string", currentline = "number",
        name = "string", nups = "number", numparams = "number", is_vararg = "number"}
    local function f(...) print(...) end
    local info = debug.getinfo(f)
    for k, v in pairs(types) do
        if type(info[k]) ~= v then return false, k .. " is " .. type(info[k]) end
    end
    return true
end)
T("unc.debug.getproto", function()
    local function f() local function proto() return true end end
    local p = debug.getproto(f, 1, true)[1]
    return EQ(p(), true)
end)
T("unc.debug.getprotos", function()
    local function f()
        local function _1() return true end
        local function _2() return true end
        local function _3() return true end
    end
    local n = 0
    for i in ipairs(debug.getprotos(f)) do
        local p = debug.getproto(f, i, true)[1]
        if not p() then return false, "proto " .. i end
        n += 1
    end
    return EQ(n, 3)
end)
T("unc.debug.getstack", function()
    local _ = "a" .. "b"
    A(EQ(debug.getstack(1, 1), "ab")); return EQ(debug.getstack(1)[1], "ab")
end)
T("unc.debug.getupvalue", function()
    local up = function() end
    local function f() print(up) end
    return EQ(debug.getupvalue(f, 1), up)
end)
T("unc.debug.getupvalues", function()
    local up = function() end
    local function f() print(up) end
    return EQ(debug.getupvalues(f)[1], up)
end)
T("unc.debug.setconstant", function()
    local function f() return "fail" end
    debug.setconstant(f, 1, "success")
    return EQ(f(), "success")
end)
T("unc.debug.setstack", function()
    local function f() return "fail", debug.setstack(1, 1, "success") end
    return EQ(f(), "success")
end)
T("unc.debug.setupvalue", function()
    local function up() return "fail" end
    local function f() return up() end
    debug.setupvalue(f, 1, function() return "success" end)
    return EQ(f(), "success")
end)

-- filesystem (sandboxed workspace)
if isfolder(".tests") then delfolder(".tests") end
makefolder(".tests")
T("unc.fs.readfile", function() writefile(".tests/readfile.txt", "success"); return EQ(readfile(".tests/readfile.txt"), "success") end)
T("unc.fs.listfiles", function()
    makefolder(".tests/listfiles")
    writefile(".tests/listfiles/test_1.txt", "success"); writefile(".tests/listfiles/test_2.txt", "success")
    local files = listfiles(".tests/listfiles")
    A(EQ(#files, 2)); A(EQ(isfile(files[1]), true)); return EQ(readfile(files[1]), "success")
end)
T("unc.fs.listfiles_folders", function()
    makefolder(".tests/listfiles_2"); makefolder(".tests/listfiles_2/test_1"); makefolder(".tests/listfiles_2/test_2")
    local folders = listfiles(".tests/listfiles_2")
    A(EQ(#folders, 2)); return EQ(isfolder(folders[1]), true)
end)
T("unc.fs.writefile", function() writefile(".tests/writefile.txt", "success"); return EQ(readfile(".tests/writefile.txt"), "success") end)
T("unc.fs.writefile_overwrite", function() writefile(".tests/ow.txt", "one"); writefile(".tests/ow.txt", "two"); return EQ(readfile(".tests/ow.txt"), "two") end)
T("unc.fs.makefolder", function() makefolder(".tests/makefolder"); return EQ(isfolder(".tests/makefolder"), true) end)
T("unc.fs.appendfile", function()
    writefile(".tests/appendfile.txt", "su"); appendfile(".tests/appendfile.txt", "cce"); appendfile(".tests/appendfile.txt", "ss")
    return EQ(readfile(".tests/appendfile.txt"), "success")
end)
T("unc.fs.isfile", function()
    writefile(".tests/isfile.txt", "success")
    A(EQ(isfile(".tests/isfile.txt"), true)); A(EQ(isfile(".tests"), false)); return EQ(isfile(".tests/doesnotexist.exe"), false)
end)
T("unc.fs.isfolder", function() A(EQ(isfolder(".tests"), true)); return EQ(isfolder(".tests/doesnotexist.exe"), false) end)
T("unc.fs.delfolder", function() makefolder(".tests/delfolder"); delfolder(".tests/delfolder"); return EQ(isfolder(".tests/delfolder"), false) end)
T("unc.fs.delfile", function() writefile(".tests/delfile.txt", "x"); delfile(".tests/delfile.txt"); return EQ(isfile(".tests/delfile.txt"), false) end)
T("unc.fs.loadfile", function()
    writefile(".tests/loadfile.txt", "return ... + 1")
    A(EQ(assert(loadfile(".tests/loadfile.txt"))(1), 2))
    writefile(".tests/loadfile.txt", "f")
    local cb, err = loadfile(".tests/loadfile.txt")
    return EQ(cb == nil and err ~= nil, true)
end)
T("unc.fs.readfile_missing", function() return ERR(function() return readfile(".tests/missing_zq.txt") end) end)
T("unc.fs.binary", function()
    local s = "\0\1\2\255\254"
    writefile(".tests/bin.dat", s)
    return EQ(readfile(".tests/bin.dat"), s)
end)

-- instances
T("unc.fireclickdetector", function() return OK(function() fireclickdetector(Instance.new("ClickDetector"), 50, "MouseHoverEnter") end) end)
T("unc.getcallbackvalue", function()
    local b = Instance.new("BindableFunction")
    local function f() end
    b.OnInvoke = f
    return EQ(getcallbackvalue(b, "OnInvoke"), f)
end)
T("unc.getconnections", function()
    local types = {Enabled = "boolean", ForeignState = "boolean", LuaConnection = "boolean", Function = "function",
        Thread = "thread", Fire = "function", Defer = "function", Disconnect = "function", Disable = "function", Enable = "function"}
    local b = Instance.new("BindableEvent")
    b.Event:Connect(function() end)
    local c = getconnections(b.Event)[1]
    for k, v in pairs(types) do
        if type(c[k]) ~= v then return false, k .. " is " .. type(c[k]) end
    end
    return true
end)
T("unc.getconnections_function", function()
    local b = Instance.new("BindableEvent")
    local function handler() end
    b.Event:Connect(handler)
    return EQ(getconnections(b.Event)[1].Function, handler)
end)
T("unc.getconnections_disable", function()
    local b, n = Instance.new("BindableEvent"), 0
    b.Event:Connect(function() n += 1 end)
    getconnections(b.Event)[1]:Disable()
    b:Fire(); task.wait()
    return EQ(n, 0)
end)
T("unc.firesignal", function()
    local b, got = Instance.new("BindableEvent"), nil
    b.Event:Connect(function(x) got = x end)
    firesignal(b.Event, 7); task.wait()
    return EQ(got, 7)
end)
T("unc.getcustomasset", function()
    writefile(".tests/getcustomasset.txt", "success")
    local id = getcustomasset(".tests/getcustomasset.txt")
    A(TY(id, "string")); return EQ(id:match("rbxasset://") == "rbxasset://", true)
end)
T("unc.gethiddenproperty", function()
    local value, hidden = gethiddenproperty(Instance.new("Fire"), "size_xml")
    A(EQ(value, 5)); return EQ(hidden, true)
end)
T("unc.sethiddenproperty", function()
    local fire = Instance.new("Fire")
    A(EQ(sethiddenproperty(fire, "size_xml", 10), true))
    return EQ(gethiddenproperty(fire, "size_xml"), 10)
end)
T("unc.gethui", function() return TY(gethui(), "Instance") end)
T("unc.getinstances", function() return EQ(getinstances()[1]:IsA("Instance"), true) end)
T("unc.getnilinstances", function()
    local first = getnilinstances()[1]
    A(EQ(first:IsA("Instance"), true)); return EQ(first.Parent, nil)
end)
T("unc.getnilinstances_contains", function()
    local p = Instance.new("Part"); p.Name = "NilProbe_zq"
    for _, x in ipairs(getnilinstances()) do if x == p then return true end end
    return false, "fresh unparented part missing"
end)
T("unc.isscriptable", function()
    local fire = Instance.new("Fire")
    A(EQ(isscriptable(fire, "size_xml"), false)); return EQ(isscriptable(fire, "Size"), true)
end)
T("unc.setscriptable", function()
    local fire = Instance.new("Fire")
    A(EQ(setscriptable(fire, "size_xml", true), false)); A(EQ(isscriptable(fire, "size_xml"), true))
    return EQ(isscriptable(Instance.new("Fire"), "size_xml"), false)
end)

-- metatables
T("unc.getrawmetatable", function()
    local mt = {__metatable = "Locked!"}
    return EQ(getrawmetatable(setmetatable({}, mt)), mt)
end)
T("unc.getrawmetatable_game", function()
    local mt = getrawmetatable(game)
    A(TY(mt, "table")); A(TY(mt.__index, "function")); A(TY(mt.__namecall, "function")); return TY(mt.__newindex, "function")
end)
T("unc.getrawmetatable_game_locked", function() return EQ(getrawmetatable(game).__metatable, "The metatable is locked") end)
T("unc.hookmetamethod", function()
    local obj = setmetatable({}, {__index = newcclosure(function() return false end), __metatable = "Locked!"})
    local ref = hookmetamethod(obj, "__index", function() return true end)
    A(EQ(obj.test, true)); return EQ(ref(), false)
end)
T("unc.getnamecallmethod", function()
    local method, ref
    ref = hookmetamethod(game, "__namecall", function(...)
        if not method then method = getnamecallmethod() end
        return ref(...)
    end)
    game:GetService("Lighting")
    hookmetamethod(game, "__namecall", ref)
    return EQ(method, "GetService")
end)
T("unc.isreadonly", function() return EQ(isreadonly(table.freeze({})), true) end)
T("unc.isreadonly_false", function() return EQ(isreadonly({}), false) end)
T("unc.setrawmetatable", function()
    local obj = setmetatable({}, {__index = function() return false end, __metatable = "Locked!"})
    setrawmetatable(obj, {__index = function() return true end})
    return EQ(obj.test, true)
end)
T("unc.setreadonly", function()
    local obj = table.freeze({success = false})
    setreadonly(obj, false)
    obj.success = true
    return EQ(obj.success, true)
end)

-- misc
T("unc.identifyexecutor", function() local n, v = identifyexecutor(); A(TY(n, "string")); return TY(v, "string") end)
T("unc.lz4", function()
    local raw = "Hello, world!"
    local c = lz4compress(raw)
    A(TY(c, "string")); return EQ(lz4decompress(c, #raw), raw)
end)
T("unc.lz4_repetitive", function()
    local raw = string.rep("abc", 500)
    local c = lz4compress(raw)
    A(EQ(#c < #raw, true)); return EQ(lz4decompress(c, #raw), raw)
end)
T("unc.getgc", function() local gc = getgc(); A(TY(gc, "table")); return EQ(#gc > 0, true) end)
T("unc.getgc_tables", function()
    local marker = {zq_marker = true}
    for _, v in ipairs(getgc(true)) do if v == marker then return true end end
    return false, "getgc(true) did not include a live table"
end)
T("unc.getgenv", function()
    getgenv().__TEST_GLOBAL = true
    local ok = __TEST_GLOBAL == true
    getgenv().__TEST_GLOBAL = nil
    return EQ(ok, true)
end)
T("unc.getgenv_table", function() return TY(getgenv(), "table") end)
T("unc.getrenv", function() return EQ(_G ~= getrenv()._G, true) end)
T("unc.getrenv_game", function() return EQ(getrenv().game, game) end)
T("unc.getloadedmodules", function() return TY(getloadedmodules(), "table") end)
T("unc.getrunningscripts", function() return TY(getrunningscripts(), "table") end)
T("unc.getscripts", function() return TY(getscripts(), "table") end)
T("unc.getthreadidentity", function() return TY(getthreadidentity(), "number") end)
T("unc.setthreadidentity", function()
    local old = getthreadidentity()
    setthreadidentity(3)
    local now = getthreadidentity()
    setthreadidentity(old)
    return EQ(now, 3)
end)
T("unc.isrbxactive", function() return TY(isrbxactive(), "boolean") end)
T("unc.fpscap", function() setfpscap(60); return EQ(getfpscap(), 60) end)

-- Drawing
T("unc.drawing.new", function()
    local d = Drawing.new("Square")
    d.Visible = false
    return OK(function() d:Destroy() end)
end)
T("unc.drawing.fonts", function()
    A(EQ(Drawing.Fonts.UI, 0)); A(EQ(Drawing.Fonts.System, 1)); A(EQ(Drawing.Fonts.Plex, 2)); return EQ(Drawing.Fonts.Monospace, 3)
end)
T("unc.drawing.isrenderobj", function()
    local d = Drawing.new("Image"); d.Visible = true
    A(EQ(isrenderobj(d), true)); return EQ(isrenderobj(newproxy()), false)
end)
T("unc.drawing.getrenderproperty", function()
    local d = Drawing.new("Image"); d.Visible = true
    return TY(getrenderproperty(d, "Visible"), "boolean")
end)
T("unc.drawing.setrenderproperty", function()
    local d = Drawing.new("Square"); d.Visible = true
    setrenderproperty(d, "Visible", false)
    return EQ(d.Visible, false)
end)
T("unc.drawing.cleardrawcache", function() return OK(function() cleardrawcache() end) end)
for _, kind in ipairs({"Line", "Text", "Image", "Circle", "Square", "Quad", "Triangle"}) do
    T("unc.drawing.kind." .. kind, function()
        local d = Drawing.new(kind)
        A(EQ(d.Visible, false)); A(TY(d.ZIndex, "number")); A(TY(d.Transparency, "number")); return TY(d.Color, "Color3")
    end)
end
T("unc.drawing.bad_kind", function() return ERR(function() return Drawing.new("NotAShape") end) end)
T("unc.drawing.line_props", function()
    local d = Drawing.new("Line")
    d.From = Vector2.new(1, 2); d.To = Vector2.new(3, 4); d.Thickness = 2
    A(EQ(d.From, Vector2.new(1, 2))); A(EQ(d.To, Vector2.new(3, 4))); return EQ(d.Thickness, 2)
end)
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
