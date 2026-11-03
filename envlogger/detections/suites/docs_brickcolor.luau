-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "docs_brickcolor"
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

do
    T("brickcolor.number_to_name.1", function() return EQ(BrickColor.new(1).Name, "White") end)
    T("brickcolor.tostring.1", function() return EQ(tostring(BrickColor.new(1)), "White") end)
    T("brickcolor.rgb.1", function() local c = BrickColor.new(1).Color; return NEARV({c.R, c.G, c.B}, {242/255, 243/255, 243/255}, 1e-6) end)
    T("brickcolor.number_field.1", function() return EQ(BrickColor.new(1).Number, 1) end)
    T("brickcolor.name_to_number.1", function() return EQ(BrickColor.new("White").Number, 1) end)
    T("brickcolor.nearest_self.1", function() return EQ(BrickColor.new(Color3.fromRGB(242, 243, 243)).Number, 1) end)
    T("brickcolor.palette.87", function() return EQ(BrickColor.palette(87).Number, 1) end)
end
do
    T("brickcolor.number_to_name.2", function() return EQ(BrickColor.new(2).Name, "Grey") end)
    T("brickcolor.tostring.2", function() return EQ(tostring(BrickColor.new(2)), "Grey") end)
    T("brickcolor.rgb.2", function() local c = BrickColor.new(2).Color; return NEARV({c.R, c.G, c.B}, {161/255, 165/255, 162/255}, 1e-6) end)
    T("brickcolor.number_field.2", function() return EQ(BrickColor.new(2).Number, 2) end)
    T("brickcolor.name_to_number.2", function() return EQ(BrickColor.new("Grey").Number, 2) end)
end
do
    T("brickcolor.number_to_name.3", function() return EQ(BrickColor.new(3).Name, "Light yellow") end)
    T("brickcolor.tostring.3", function() return EQ(tostring(BrickColor.new(3)), "Light yellow") end)
    T("brickcolor.rgb.3", function() local c = BrickColor.new(3).Color; return NEARV({c.R, c.G, c.B}, {249/255, 233/255, 153/255}, 1e-6) end)
    T("brickcolor.number_field.3", function() return EQ(BrickColor.new(3).Number, 3) end)
    T("brickcolor.name_to_number.3", function() return EQ(BrickColor.new("Light yellow").Number, 3) end)
end
do
    T("brickcolor.number_to_name.5", function() return EQ(BrickColor.new(5).Name, "Brick yellow") end)
    T("brickcolor.tostring.5", function() return EQ(tostring(BrickColor.new(5)), "Brick yellow") end)
    T("brickcolor.rgb.5", function() local c = BrickColor.new(5).Color; return NEARV({c.R, c.G, c.B}, {215/255, 197/255, 154/255}, 1e-6) end)
    T("brickcolor.number_field.5", function() return EQ(BrickColor.new(5).Number, 5) end)
    T("brickcolor.name_to_number.5", function() return EQ(BrickColor.new("Brick yellow").Number, 5) end)
    T("brickcolor.nearest_self.5", function() return EQ(BrickColor.new(Color3.fromRGB(215, 197, 154)).Number, 5) end)
    T("brickcolor.palette.109", function() return EQ(BrickColor.palette(109).Number, 5) end)
end
do
    T("brickcolor.number_to_name.6", function() return EQ(BrickColor.new(6).Name, "Light green (Mint)") end)
    T("brickcolor.tostring.6", function() return EQ(tostring(BrickColor.new(6)), "Light green (Mint)") end)
    T("brickcolor.rgb.6", function() local c = BrickColor.new(6).Color; return NEARV({c.R, c.G, c.B}, {194/255, 218/255, 184/255}, 1e-6) end)
    T("brickcolor.number_field.6", function() return EQ(BrickColor.new(6).Number, 6) end)
    T("brickcolor.name_to_number.6", function() return EQ(BrickColor.new("Light green (Mint)").Number, 6) end)
end
do
    T("brickcolor.number_to_name.9", function() return EQ(BrickColor.new(9).Name, "Light reddish violet") end)
    T("brickcolor.tostring.9", function() return EQ(tostring(BrickColor.new(9)), "Light reddish violet") end)
    T("brickcolor.rgb.9", function() local c = BrickColor.new(9).Color; return NEARV({c.R, c.G, c.B}, {232/255, 186/255, 200/255}, 1e-6) end)
    T("brickcolor.number_field.9", function() return EQ(BrickColor.new(9).Number, 9) end)
    T("brickcolor.name_to_number.9", function() return EQ(BrickColor.new("Light reddish violet").Number, 9) end)
    T("brickcolor.nearest_self.9", function() return EQ(BrickColor.new(Color3.fromRGB(232, 186, 200)).Number, 9) end)
    T("brickcolor.palette.88", function() return EQ(BrickColor.palette(88).Number, 9) end)
end
do
    T("brickcolor.number_to_name.11", function() return EQ(BrickColor.new(11).Name, "Pastel Blue") end)
    T("brickcolor.tostring.11", function() return EQ(tostring(BrickColor.new(11)), "Pastel Blue") end)
    T("brickcolor.rgb.11", function() local c = BrickColor.new(11).Color; return NEARV({c.R, c.G, c.B}, {128/255, 187/255, 219/255}, 1e-6) end)
    T("brickcolor.number_field.11", function() return EQ(BrickColor.new(11).Number, 11) end)
    T("brickcolor.name_to_number.11", function() return EQ(BrickColor.new("Pastel Blue").Number, 11) end)
    T("brickcolor.nearest_self.11", function() return EQ(BrickColor.new(Color3.fromRGB(128, 187, 219)).Number, 11) end)
    T("brickcolor.palette.51", function() return EQ(BrickColor.palette(51).Number, 11) end)
end
do
    T("brickcolor.number_to_name.12", function() return EQ(BrickColor.new(12).Name, "Light orange brown") end)
    T("brickcolor.tostring.12", function() return EQ(tostring(BrickColor.new(12)), "Light orange brown") end)
    T("brickcolor.rgb.12", function() local c = BrickColor.new(12).Color; return NEARV({c.R, c.G, c.B}, {203/255, 132/255, 66/255}, 1e-6) end)
    T("brickcolor.number_field.12", function() return EQ(BrickColor.new(12).Number, 12) end)
    T("brickcolor.name_to_number.12", function() return EQ(BrickColor.new("Light orange brown").Number, 12) end)
end
do
    T("brickcolor.number_to_name.18", function() return EQ(BrickColor.new(18).Name, "Nougat") end)
    T("brickcolor.tostring.18", function() return EQ(tostring(BrickColor.new(18)), "Nougat") end)
    T("brickcolor.rgb.18", function() local c = BrickColor.new(18).Color; return NEARV({c.R, c.G, c.B}, {204/255, 142/255, 105/255}, 1e-6) end)
    T("brickcolor.number_field.18", function() return EQ(BrickColor.new(18).Number, 18) end)
    T("brickcolor.name_to_number.18", function() return EQ(BrickColor.new("Nougat").Number, 18) end)
    T("brickcolor.nearest_self.18", function() return EQ(BrickColor.new(Color3.fromRGB(204, 142, 105)).Number, 18) end)
    T("brickcolor.palette.110", function() return EQ(BrickColor.palette(110).Number, 18) end)
end
do
    T("brickcolor.number_to_name.21", function() return EQ(BrickColor.new(21).Name, "Bright red") end)
    T("brickcolor.tostring.21", function() return EQ(tostring(BrickColor.new(21)), "Bright red") end)
    T("brickcolor.rgb.21", function() local c = BrickColor.new(21).Color; return NEARV({c.R, c.G, c.B}, {196/255, 40/255, 28/255}, 1e-6) end)
    T("brickcolor.number_field.21", function() return EQ(BrickColor.new(21).Number, 21) end)
    T("brickcolor.name_to_number.21", function() return EQ(BrickColor.new("Bright red").Number, 21) end)
    T("brickcolor.nearest_self.21", function() return EQ(BrickColor.new(Color3.fromRGB(196, 40, 28)).Number, 21) end)
    T("brickcolor.palette.68", function() return EQ(BrickColor.palette(68).Number, 21) end)
end
do
    T("brickcolor.number_to_name.22", function() return EQ(BrickColor.new(22).Name, "Med. reddish violet") end)
    T("brickcolor.tostring.22", function() return EQ(tostring(BrickColor.new(22)), "Med. reddish violet") end)
    T("brickcolor.rgb.22", function() local c = BrickColor.new(22).Color; return NEARV({c.R, c.G, c.B}, {196/255, 112/255, 160/255}, 1e-6) end)
    T("brickcolor.number_field.22", function() return EQ(BrickColor.new(22).Number, 22) end)
    T("brickcolor.name_to_number.22", function() return EQ(BrickColor.new("Med. reddish violet").Number, 22) end)
end
do
    T("brickcolor.number_to_name.23", function() return EQ(BrickColor.new(23).Name, "Bright blue") end)
    T("brickcolor.tostring.23", function() return EQ(tostring(BrickColor.new(23)), "Bright blue") end)
    T("brickcolor.rgb.23", function() local c = BrickColor.new(23).Color; return NEARV({c.R, c.G, c.B}, {13/255, 105/255, 172/255}, 1e-6) end)
    T("brickcolor.number_field.23", function() return EQ(BrickColor.new(23).Number, 23) end)
    T("brickcolor.name_to_number.23", function() return EQ(BrickColor.new("Bright blue").Number, 23) end)
    T("brickcolor.nearest_self.23", function() return EQ(BrickColor.new(Color3.fromRGB(13, 105, 172)).Number, 23) end)
    T("brickcolor.palette.21", function() return EQ(BrickColor.palette(21).Number, 23) end)
end
do
    T("brickcolor.number_to_name.24", function() return EQ(BrickColor.new(24).Name, "Bright yellow") end)
    T("brickcolor.tostring.24", function() return EQ(tostring(BrickColor.new(24)), "Bright yellow") end)
    T("brickcolor.rgb.24", function() local c = BrickColor.new(24).Color; return NEARV({c.R, c.G, c.B}, {245/255, 205/255, 48/255}, 1e-6) end)
    T("brickcolor.number_field.24", function() return EQ(BrickColor.new(24).Number, 24) end)
    T("brickcolor.name_to_number.24", function() return EQ(BrickColor.new("Bright yellow").Number, 24) end)
    T("brickcolor.nearest_self.24", function() return EQ(BrickColor.new(Color3.fromRGB(245, 205, 48)).Number, 24) end)
    T("brickcolor.palette.71", function() return EQ(BrickColor.palette(71).Number, 24) end)
end
do
    T("brickcolor.number_to_name.25", function() return EQ(BrickColor.new(25).Name, "Earth orange") end)
    T("brickcolor.tostring.25", function() return EQ(tostring(BrickColor.new(25)), "Earth orange") end)
    T("brickcolor.rgb.25", function() local c = BrickColor.new(25).Color; return NEARV({c.R, c.G, c.B}, {98/255, 71/255, 50/255}, 1e-6) end)
    T("brickcolor.number_field.25", function() return EQ(BrickColor.new(25).Number, 25) end)
    T("brickcolor.name_to_number.25", function() return EQ(BrickColor.new("Earth orange").Number, 25) end)
end
do
    T("brickcolor.number_to_name.26", function() return EQ(BrickColor.new(26).Name, "Black") end)
    T("brickcolor.tostring.26", function() return EQ(tostring(BrickColor.new(26)), "Black") end)
    T("brickcolor.rgb.26", function() local c = BrickColor.new(26).Color; return NEARV({c.R, c.G, c.B}, {27/255, 42/255, 53/255}, 1e-6) end)
    T("brickcolor.number_field.26", function() return EQ(BrickColor.new(26).Number, 26) end)
    T("brickcolor.name_to_number.26", function() return EQ(BrickColor.new("Black").Number, 26) end)
    T("brickcolor.nearest_self.26", function() return EQ(BrickColor.new(Color3.fromRGB(27, 42, 53)).Number, 26) end)
    T("brickcolor.palette.3", function() return EQ(BrickColor.palette(3).Number, 26) end)
end
do
    T("brickcolor.number_to_name.27", function() return EQ(BrickColor.new(27).Name, "Dark grey") end)
    T("brickcolor.tostring.27", function() return EQ(tostring(BrickColor.new(27)), "Dark grey") end)
    T("brickcolor.rgb.27", function() local c = BrickColor.new(27).Color; return NEARV({c.R, c.G, c.B}, {109/255, 110/255, 108/255}, 1e-6) end)
    T("brickcolor.number_field.27", function() return EQ(BrickColor.new(27).Number, 27) end)
    T("brickcolor.name_to_number.27", function() return EQ(BrickColor.new("Dark grey").Number, 27) end)
end
do
    T("brickcolor.number_to_name.28", function() return EQ(BrickColor.new(28).Name, "Dark green") end)
    T("brickcolor.tostring.28", function() return EQ(tostring(BrickColor.new(28)), "Dark green") end)
    T("brickcolor.rgb.28", function() local c = BrickColor.new(28).Color; return NEARV({c.R, c.G, c.B}, {40/255, 127/255, 71/255}, 1e-6) end)
    T("brickcolor.number_field.28", function() return EQ(BrickColor.new(28).Number, 28) end)
    T("brickcolor.name_to_number.28", function() return EQ(BrickColor.new("Dark green").Number, 28) end)
    T("brickcolor.nearest_self.28", function() return EQ(BrickColor.new(Color3.fromRGB(40, 127, 71)).Number, 28) end)
    T("brickcolor.palette.8", function() return EQ(BrickColor.palette(8).Number, 28) end)
end
do
    T("brickcolor.number_to_name.29", function() return EQ(BrickColor.new(29).Name, "Medium green") end)
    T("brickcolor.tostring.29", function() return EQ(tostring(BrickColor.new(29)), "Medium green") end)
    T("brickcolor.rgb.29", function() local c = BrickColor.new(29).Color; return NEARV({c.R, c.G, c.B}, {161/255, 196/255, 140/255}, 1e-6) end)
    T("brickcolor.number_field.29", function() return EQ(BrickColor.new(29).Number, 29) end)
    T("brickcolor.name_to_number.29", function() return EQ(BrickColor.new("Medium green").Number, 29) end)
    T("brickcolor.nearest_self.29", function() return EQ(BrickColor.new(Color3.fromRGB(161, 196, 140)).Number, 29) end)
    T("brickcolor.palette.59", function() return EQ(BrickColor.palette(59).Number, 29) end)
end
do
    T("brickcolor.number_to_name.36", function() return EQ(BrickColor.new(36).Name, "Lig. Yellowich orange") end)
    T("brickcolor.tostring.36", function() return EQ(tostring(BrickColor.new(36)), "Lig. Yellowich orange") end)
    T("brickcolor.rgb.36", function() local c = BrickColor.new(36).Color; return NEARV({c.R, c.G, c.B}, {243/255, 207/255, 155/255}, 1e-6) end)
    T("brickcolor.number_field.36", function() return EQ(BrickColor.new(36).Number, 36) end)
    T("brickcolor.name_to_number.36", function() return EQ(BrickColor.new("Lig. Yellowich orange").Number, 36) end)
end
do
    T("brickcolor.number_to_name.37", function() return EQ(BrickColor.new(37).Name, "Bright green") end)
    T("brickcolor.tostring.37", function() return EQ(tostring(BrickColor.new(37)), "Bright green") end)
    T("brickcolor.rgb.37", function() local c = BrickColor.new(37).Color; return NEARV({c.R, c.G, c.B}, {75/255, 151/255, 75/255}, 1e-6) end)
    T("brickcolor.number_field.37", function() return EQ(BrickColor.new(37).Number, 37) end)
    T("brickcolor.name_to_number.37", function() return EQ(BrickColor.new("Bright green").Number, 37) end)
    T("brickcolor.nearest_self.37", function() return EQ(BrickColor.new(Color3.fromRGB(75, 151, 75)).Number, 37) end)
    T("brickcolor.palette.25", function() return EQ(BrickColor.palette(25).Number, 37) end)
end
do
    T("brickcolor.number_to_name.38", function() return EQ(BrickColor.new(38).Name, "Dark orange") end)
    T("brickcolor.tostring.38", function() return EQ(tostring(BrickColor.new(38)), "Dark orange") end)
    T("brickcolor.rgb.38", function() local c = BrickColor.new(38).Color; return NEARV({c.R, c.G, c.B}, {160/255, 95/255, 53/255}, 1e-6) end)
    T("brickcolor.number_field.38", function() return EQ(BrickColor.new(38).Number, 38) end)
    T("brickcolor.name_to_number.38", function() return EQ(BrickColor.new("Dark orange").Number, 38) end)
    T("brickcolor.nearest_self.38", function() return EQ(BrickColor.new(Color3.fromRGB(160, 95, 53)).Number, 38) end)
    T("brickcolor.palette.119", function() return EQ(BrickColor.palette(119).Number, 38) end)
end
do
    T("brickcolor.number_to_name.39", function() return EQ(BrickColor.new(39).Name, "Light bluish violet") end)
    T("brickcolor.tostring.39", function() return EQ(tostring(BrickColor.new(39)), "Light bluish violet") end)
    T("brickcolor.rgb.39", function() local c = BrickColor.new(39).Color; return NEARV({c.R, c.G, c.B}, {193/255, 202/255, 222/255}, 1e-6) end)
    T("brickcolor.number_field.39", function() return EQ(BrickColor.new(39).Number, 39) end)
    T("brickcolor.name_to_number.39", function() return EQ(BrickColor.new("Light bluish violet").Number, 39) end)
end
do
    T("brickcolor.number_to_name.40", function() return EQ(BrickColor.new(40).Name, "Transparent") end)
    T("brickcolor.tostring.40", function() return EQ(tostring(BrickColor.new(40)), "Transparent") end)
    T("brickcolor.rgb.40", function() local c = BrickColor.new(40).Color; return NEARV({c.R, c.G, c.B}, {236/255, 236/255, 236/255}, 1e-6) end)
    T("brickcolor.number_field.40", function() return EQ(BrickColor.new(40).Number, 40) end)
    T("brickcolor.name_to_number.40", function() return EQ(BrickColor.new("Transparent").Number, 40) end)
end
do
    T("brickcolor.number_to_name.41", function() return EQ(BrickColor.new(41).Name, "Tr. Red") end)
    T("brickcolor.tostring.41", function() return EQ(tostring(BrickColor.new(41)), "Tr. Red") end)
    T("brickcolor.rgb.41", function() local c = BrickColor.new(41).Color; return NEARV({c.R, c.G, c.B}, {205/255, 84/255, 75/255}, 1e-6) end)
    T("brickcolor.number_field.41", function() return EQ(BrickColor.new(41).Number, 41) end)
    T("brickcolor.name_to_number.41", function() return EQ(BrickColor.new("Tr. Red").Number, 41) end)
end
do
    T("brickcolor.number_to_name.42", function() return EQ(BrickColor.new(42).Name, "Tr. Lg blue") end)
    T("brickcolor.tostring.42", function() return EQ(tostring(BrickColor.new(42)), "Tr. Lg blue") end)
    T("brickcolor.rgb.42", function() local c = BrickColor.new(42).Color; return NEARV({c.R, c.G, c.B}, {193/255, 223/255, 240/255}, 1e-6) end)
    T("brickcolor.number_field.42", function() return EQ(BrickColor.new(42).Number, 42) end)
    T("brickcolor.name_to_number.42", function() return EQ(BrickColor.new("Tr. Lg blue").Number, 42) end)
end
do
    T("brickcolor.number_to_name.43", function() return EQ(BrickColor.new(43).Name, "Tr. Blue") end)
    T("brickcolor.tostring.43", function() return EQ(tostring(BrickColor.new(43)), "Tr. Blue") end)
    T("brickcolor.rgb.43", function() local c = BrickColor.new(43).Color; return NEARV({c.R, c.G, c.B}, {123/255, 182/255, 232/255}, 1e-6) end)
    T("brickcolor.number_field.43", function() return EQ(BrickColor.new(43).Number, 43) end)
    T("brickcolor.name_to_number.43", function() return EQ(BrickColor.new("Tr. Blue").Number, 43) end)
end
do
    T("brickcolor.number_to_name.44", function() return EQ(BrickColor.new(44).Name, "Tr. Yellow") end)
    T("brickcolor.tostring.44", function() return EQ(tostring(BrickColor.new(44)), "Tr. Yellow") end)
    T("brickcolor.rgb.44", function() local c = BrickColor.new(44).Color; return NEARV({c.R, c.G, c.B}, {247/255, 241/255, 141/255}, 1e-6) end)
    T("brickcolor.number_field.44", function() return EQ(BrickColor.new(44).Number, 44) end)
    T("brickcolor.name_to_number.44", function() return EQ(BrickColor.new("Tr. Yellow").Number, 44) end)
end
do
    T("brickcolor.number_to_name.45", function() return EQ(BrickColor.new(45).Name, "Light blue") end)
    T("brickcolor.tostring.45", function() return EQ(tostring(BrickColor.new(45)), "Light blue") end)
    T("brickcolor.rgb.45", function() local c = BrickColor.new(45).Color; return NEARV({c.R, c.G, c.B}, {180/255, 210/255, 228/255}, 1e-6) end)
    T("brickcolor.number_field.45", function() return EQ(BrickColor.new(45).Number, 45) end)
    T("brickcolor.name_to_number.45", function() return EQ(BrickColor.new("Light blue").Number, 45) end)
    T("brickcolor.nearest_self.45", function() return EQ(BrickColor.new(Color3.fromRGB(180, 210, 228)).Number, 45) end)
    T("brickcolor.palette.63", function() return EQ(BrickColor.palette(63).Number, 45) end)
end
do
    T("brickcolor.number_to_name.47", function() return EQ(BrickColor.new(47).Name, "Tr. Flu. Reddish orange") end)
    T("brickcolor.tostring.47", function() return EQ(tostring(BrickColor.new(47)), "Tr. Flu. Reddish orange") end)
    T("brickcolor.rgb.47", function() local c = BrickColor.new(47).Color; return NEARV({c.R, c.G, c.B}, {217/255, 133/255, 108/255}, 1e-6) end)
    T("brickcolor.number_field.47", function() return EQ(BrickColor.new(47).Number, 47) end)
    T("brickcolor.name_to_number.47", function() return EQ(BrickColor.new("Tr. Flu. Reddish orange").Number, 47) end)
end
do
    T("brickcolor.number_to_name.48", function() return EQ(BrickColor.new(48).Name, "Tr. Green") end)
    T("brickcolor.tostring.48", function() return EQ(tostring(BrickColor.new(48)), "Tr. Green") end)
    T("brickcolor.rgb.48", function() local c = BrickColor.new(48).Color; return NEARV({c.R, c.G, c.B}, {132/255, 182/255, 141/255}, 1e-6) end)
    T("brickcolor.number_field.48", function() return EQ(BrickColor.new(48).Number, 48) end)
    T("brickcolor.name_to_number.48", function() return EQ(BrickColor.new("Tr. Green").Number, 48) end)
end
do
    T("brickcolor.number_to_name.49", function() return EQ(BrickColor.new(49).Name, "Tr. Flu. Green") end)
    T("brickcolor.tostring.49", function() return EQ(tostring(BrickColor.new(49)), "Tr. Flu. Green") end)
    T("brickcolor.rgb.49", function() local c = BrickColor.new(49).Color; return NEARV({c.R, c.G, c.B}, {248/255, 241/255, 132/255}, 1e-6) end)
    T("brickcolor.number_field.49", function() return EQ(BrickColor.new(49).Number, 49) end)
    T("brickcolor.name_to_number.49", function() return EQ(BrickColor.new("Tr. Flu. Green").Number, 49) end)
end
do
    T("brickcolor.number_to_name.50", function() return EQ(BrickColor.new(50).Name, "Phosph. White") end)
    T("brickcolor.tostring.50", function() return EQ(tostring(BrickColor.new(50)), "Phosph. White") end)
    T("brickcolor.rgb.50", function() local c = BrickColor.new(50).Color; return NEARV({c.R, c.G, c.B}, {236/255, 232/255, 222/255}, 1e-6) end)
    T("brickcolor.number_field.50", function() return EQ(BrickColor.new(50).Number, 50) end)
    T("brickcolor.name_to_number.50", function() return EQ(BrickColor.new("Phosph. White").Number, 50) end)
end
do
    T("brickcolor.number_to_name.100", function() return EQ(BrickColor.new(100).Name, "Light red") end)
    T("brickcolor.tostring.100", function() return EQ(tostring(BrickColor.new(100)), "Light red") end)
    T("brickcolor.rgb.100", function() local c = BrickColor.new(100).Color; return NEARV({c.R, c.G, c.B}, {238/255, 196/255, 182/255}, 1e-6) end)
    T("brickcolor.number_field.100", function() return EQ(BrickColor.new(100).Number, 100) end)
    T("brickcolor.name_to_number.100", function() return EQ(BrickColor.new("Light red").Number, 100) end)
end
do
    T("brickcolor.number_to_name.101", function() return EQ(BrickColor.new(101).Name, "Medium red") end)
    T("brickcolor.tostring.101", function() return EQ(tostring(BrickColor.new(101)), "Medium red") end)
    T("brickcolor.rgb.101", function() local c = BrickColor.new(101).Color; return NEARV({c.R, c.G, c.B}, {218/255, 134/255, 122/255}, 1e-6) end)
    T("brickcolor.number_field.101", function() return EQ(BrickColor.new(101).Number, 101) end)
    T("brickcolor.name_to_number.101", function() return EQ(BrickColor.new("Medium red").Number, 101) end)
    T("brickcolor.nearest_self.101", function() return EQ(BrickColor.new(Color3.fromRGB(218, 134, 122)).Number, 101) end)
    T("brickcolor.palette.101", function() return EQ(BrickColor.palette(101).Number, 101) end)
end
do
    T("brickcolor.number_to_name.102", function() return EQ(BrickColor.new(102).Name, "Medium blue") end)
    T("brickcolor.tostring.102", function() return EQ(tostring(BrickColor.new(102)), "Medium blue") end)
    T("brickcolor.rgb.102", function() local c = BrickColor.new(102).Color; return NEARV({c.R, c.G, c.B}, {110/255, 153/255, 202/255}, 1e-6) end)
    T("brickcolor.number_field.102", function() return EQ(BrickColor.new(102).Number, 102) end)
    T("brickcolor.name_to_number.102", function() return EQ(BrickColor.new("Medium blue").Number, 102) end)
    T("brickcolor.nearest_self.102", function() return EQ(BrickColor.new(Color3.fromRGB(110, 153, 202)).Number, 102) end)
    T("brickcolor.palette.20", function() return EQ(BrickColor.palette(20).Number, 102) end)
end
do
    T("brickcolor.number_to_name.103", function() return EQ(BrickColor.new(103).Name, "Light grey") end)
    T("brickcolor.tostring.103", function() return EQ(tostring(BrickColor.new(103)), "Light grey") end)
    T("brickcolor.rgb.103", function() local c = BrickColor.new(103).Color; return NEARV({c.R, c.G, c.B}, {199/255, 193/255, 183/255}, 1e-6) end)
    T("brickcolor.number_field.103", function() return EQ(BrickColor.new(103).Number, 103) end)
    T("brickcolor.name_to_number.103", function() return EQ(BrickColor.new("Light grey").Number, 103) end)
end
do
    T("brickcolor.number_to_name.104", function() return EQ(BrickColor.new(104).Name, "Bright violet") end)
    T("brickcolor.tostring.104", function() return EQ(tostring(BrickColor.new(104)), "Bright violet") end)
    T("brickcolor.rgb.104", function() local c = BrickColor.new(104).Color; return NEARV({c.R, c.G, c.B}, {107/255, 50/255, 124/255}, 1e-6) end)
    T("brickcolor.number_field.104", function() return EQ(BrickColor.new(104).Number, 104) end)
    T("brickcolor.name_to_number.104", function() return EQ(BrickColor.new("Bright violet").Number, 104) end)
    T("brickcolor.nearest_self.104", function() return EQ(BrickColor.new(Color3.fromRGB(107, 50, 124)).Number, 104) end)
    T("brickcolor.palette.44", function() return EQ(BrickColor.palette(44).Number, 104) end)
end
do
    T("brickcolor.number_to_name.105", function() return EQ(BrickColor.new(105).Name, "Br. yellowish orange") end)
    T("brickcolor.tostring.105", function() return EQ(tostring(BrickColor.new(105)), "Br. yellowish orange") end)
    T("brickcolor.rgb.105", function() local c = BrickColor.new(105).Color; return NEARV({c.R, c.G, c.B}, {226/255, 155/255, 64/255}, 1e-6) end)
    T("brickcolor.number_field.105", function() return EQ(BrickColor.new(105).Number, 105) end)
    T("brickcolor.name_to_number.105", function() return EQ(BrickColor.new("Br. yellowish orange").Number, 105) end)
    T("brickcolor.nearest_self.105", function() return EQ(BrickColor.new(Color3.fromRGB(226, 155, 64)).Number, 105) end)
    T("brickcolor.palette.94", function() return EQ(BrickColor.palette(94).Number, 105) end)
end
do
    T("brickcolor.number_to_name.106", function() return EQ(BrickColor.new(106).Name, "Bright orange") end)
    T("brickcolor.tostring.106", function() return EQ(tostring(BrickColor.new(106)), "Bright orange") end)
    T("brickcolor.rgb.106", function() local c = BrickColor.new(106).Color; return NEARV({c.R, c.G, c.B}, {218/255, 133/255, 65/255}, 1e-6) end)
    T("brickcolor.number_field.106", function() return EQ(BrickColor.new(106).Number, 106) end)
    T("brickcolor.name_to_number.106", function() return EQ(BrickColor.new("Bright orange").Number, 106) end)
    T("brickcolor.nearest_self.106", function() return EQ(BrickColor.new(Color3.fromRGB(218, 133, 65)).Number, 106) end)
    T("brickcolor.palette.83", function() return EQ(BrickColor.palette(83).Number, 106) end)
end
do
    T("brickcolor.number_to_name.107", function() return EQ(BrickColor.new(107).Name, "Bright bluish green") end)
    T("brickcolor.tostring.107", function() return EQ(tostring(BrickColor.new(107)), "Bright bluish green") end)
    T("brickcolor.rgb.107", function() local c = BrickColor.new(107).Color; return NEARV({c.R, c.G, c.B}, {0/255, 143/255, 156/255}, 1e-6) end)
    T("brickcolor.number_field.107", function() return EQ(BrickColor.new(107).Number, 107) end)
    T("brickcolor.name_to_number.107", function() return EQ(BrickColor.new("Bright bluish green").Number, 107) end)
    T("brickcolor.nearest_self.107", function() return EQ(BrickColor.new(Color3.fromRGB(0, 143, 156)).Number, 107) end)
    T("brickcolor.palette.2", function() return EQ(BrickColor.palette(2).Number, 107) end)
end
do
    T("brickcolor.number_to_name.108", function() return EQ(BrickColor.new(108).Name, "Earth yellow") end)
    T("brickcolor.tostring.108", function() return EQ(tostring(BrickColor.new(108)), "Earth yellow") end)
    T("brickcolor.rgb.108", function() local c = BrickColor.new(108).Color; return NEARV({c.R, c.G, c.B}, {104/255, 92/255, 67/255}, 1e-6) end)
    T("brickcolor.number_field.108", function() return EQ(BrickColor.new(108).Number, 108) end)
    T("brickcolor.name_to_number.108", function() return EQ(BrickColor.new("Earth yellow").Number, 108) end)
end
do
    T("brickcolor.number_to_name.110", function() return EQ(BrickColor.new(110).Name, "Bright bluish violet") end)
    T("brickcolor.tostring.110", function() return EQ(tostring(BrickColor.new(110)), "Bright bluish violet") end)
    T("brickcolor.rgb.110", function() local c = BrickColor.new(110).Color; return NEARV({c.R, c.G, c.B}, {67/255, 84/255, 147/255}, 1e-6) end)
    T("brickcolor.number_field.110", function() return EQ(BrickColor.new(110).Number, 110) end)
    T("brickcolor.name_to_number.110", function() return EQ(BrickColor.new("Bright bluish violet").Number, 110) end)
end
do
    T("brickcolor.number_to_name.111", function() return EQ(BrickColor.new(111).Name, "Tr. Brown") end)
    T("brickcolor.tostring.111", function() return EQ(tostring(BrickColor.new(111)), "Tr. Brown") end)
    T("brickcolor.rgb.111", function() local c = BrickColor.new(111).Color; return NEARV({c.R, c.G, c.B}, {191/255, 183/255, 177/255}, 1e-6) end)
    T("brickcolor.number_field.111", function() return EQ(BrickColor.new(111).Number, 111) end)
    T("brickcolor.name_to_number.111", function() return EQ(BrickColor.new("Tr. Brown").Number, 111) end)
end
do
    T("brickcolor.number_to_name.112", function() return EQ(BrickColor.new(112).Name, "Medium bluish violet") end)
    T("brickcolor.tostring.112", function() return EQ(tostring(BrickColor.new(112)), "Medium bluish violet") end)
    T("brickcolor.rgb.112", function() local c = BrickColor.new(112).Color; return NEARV({c.R, c.G, c.B}, {104/255, 116/255, 172/255}, 1e-6) end)
    T("brickcolor.number_field.112", function() return EQ(BrickColor.new(112).Number, 112) end)
    T("brickcolor.name_to_number.112", function() return EQ(BrickColor.new("Medium bluish violet").Number, 112) end)
end
do
    T("brickcolor.number_to_name.113", function() return EQ(BrickColor.new(113).Name, "Tr. Medi. reddish violet") end)
    T("brickcolor.tostring.113", function() return EQ(tostring(BrickColor.new(113)), "Tr. Medi. reddish violet") end)
    T("brickcolor.rgb.113", function() local c = BrickColor.new(113).Color; return NEARV({c.R, c.G, c.B}, {229/255, 173/255, 200/255}, 1e-6) end)
    T("brickcolor.number_field.113", function() return EQ(BrickColor.new(113).Number, 113) end)
    T("brickcolor.name_to_number.113", function() return EQ(BrickColor.new("Tr. Medi. reddish violet").Number, 113) end)
end
do
    T("brickcolor.number_to_name.115", function() return EQ(BrickColor.new(115).Name, "Med. yellowish green") end)
    T("brickcolor.tostring.115", function() return EQ(tostring(BrickColor.new(115)), "Med. yellowish green") end)
    T("brickcolor.rgb.115", function() local c = BrickColor.new(115).Color; return NEARV({c.R, c.G, c.B}, {199/255, 210/255, 60/255}, 1e-6) end)
    T("brickcolor.number_field.115", function() return EQ(BrickColor.new(115).Number, 115) end)
    T("brickcolor.name_to_number.115", function() return EQ(BrickColor.new("Med. yellowish green").Number, 115) end)
end
do
    T("brickcolor.number_to_name.116", function() return EQ(BrickColor.new(116).Name, "Med. bluish green") end)
    T("brickcolor.tostring.116", function() return EQ(tostring(BrickColor.new(116)), "Med. bluish green") end)
    T("brickcolor.rgb.116", function() local c = BrickColor.new(116).Color; return NEARV({c.R, c.G, c.B}, {85/255, 165/255, 175/255}, 1e-6) end)
    T("brickcolor.number_field.116", function() return EQ(BrickColor.new(116).Number, 116) end)
    T("brickcolor.name_to_number.116", function() return EQ(BrickColor.new("Med. bluish green").Number, 116) end)
end
do
    T("brickcolor.number_to_name.118", function() return EQ(BrickColor.new(118).Name, "Light bluish green") end)
    T("brickcolor.tostring.118", function() return EQ(tostring(BrickColor.new(118)), "Light bluish green") end)
    T("brickcolor.rgb.118", function() local c = BrickColor.new(118).Color; return NEARV({c.R, c.G, c.B}, {183/255, 215/255, 213/255}, 1e-6) end)
    T("brickcolor.number_field.118", function() return EQ(BrickColor.new(118).Number, 118) end)
    T("brickcolor.name_to_number.118", function() return EQ(BrickColor.new("Light bluish green").Number, 118) end)
end
do
    T("brickcolor.number_to_name.119", function() return EQ(BrickColor.new(119).Name, "Br. yellowish green") end)
    T("brickcolor.tostring.119", function() return EQ(tostring(BrickColor.new(119)), "Br. yellowish green") end)
    T("brickcolor.rgb.119", function() local c = BrickColor.new(119).Color; return NEARV({c.R, c.G, c.B}, {164/255, 189/255, 71/255}, 1e-6) end)
    T("brickcolor.number_field.119", function() return EQ(BrickColor.new(119).Number, 119) end)
    T("brickcolor.name_to_number.119", function() return EQ(BrickColor.new("Br. yellowish green").Number, 119) end)
    T("brickcolor.nearest_self.119", function() return EQ(BrickColor.new(Color3.fromRGB(164, 189, 71)).Number, 119) end)
    T("brickcolor.palette.46", function() return EQ(BrickColor.palette(46).Number, 119) end)
end
do
    T("brickcolor.number_to_name.120", function() return EQ(BrickColor.new(120).Name, "Lig. yellowish green") end)
    T("brickcolor.tostring.120", function() return EQ(tostring(BrickColor.new(120)), "Lig. yellowish green") end)
    T("brickcolor.rgb.120", function() local c = BrickColor.new(120).Color; return NEARV({c.R, c.G, c.B}, {217/255, 228/255, 167/255}, 1e-6) end)
    T("brickcolor.number_field.120", function() return EQ(BrickColor.new(120).Number, 120) end)
    T("brickcolor.name_to_number.120", function() return EQ(BrickColor.new("Lig. yellowish green").Number, 120) end)
end
do
    T("brickcolor.number_to_name.121", function() return EQ(BrickColor.new(121).Name, "Med. yellowish orange") end)
    T("brickcolor.tostring.121", function() return EQ(tostring(BrickColor.new(121)), "Med. yellowish orange") end)
    T("brickcolor.rgb.121", function() local c = BrickColor.new(121).Color; return NEARV({c.R, c.G, c.B}, {231/255, 172/255, 88/255}, 1e-6) end)
    T("brickcolor.number_field.121", function() return EQ(BrickColor.new(121).Number, 121) end)
    T("brickcolor.name_to_number.121", function() return EQ(BrickColor.new("Med. yellowish orange").Number, 121) end)
end
do
    T("brickcolor.number_to_name.123", function() return EQ(BrickColor.new(123).Name, "Br. reddish orange") end)
    T("brickcolor.tostring.123", function() return EQ(tostring(BrickColor.new(123)), "Br. reddish orange") end)
    T("brickcolor.rgb.123", function() local c = BrickColor.new(123).Color; return NEARV({c.R, c.G, c.B}, {211/255, 111/255, 76/255}, 1e-6) end)
    T("brickcolor.number_field.123", function() return EQ(BrickColor.new(123).Number, 123) end)
    T("brickcolor.name_to_number.123", function() return EQ(BrickColor.new("Br. reddish orange").Number, 123) end)
end
do
    T("brickcolor.number_to_name.124", function() return EQ(BrickColor.new(124).Name, "Bright reddish violet") end)
    T("brickcolor.tostring.124", function() return EQ(tostring(BrickColor.new(124)), "Bright reddish violet") end)
    T("brickcolor.rgb.124", function() local c = BrickColor.new(124).Color; return NEARV({c.R, c.G, c.B}, {146/255, 57/255, 120/255}, 1e-6) end)
    T("brickcolor.number_field.124", function() return EQ(BrickColor.new(124).Number, 124) end)
    T("brickcolor.name_to_number.124", function() return EQ(BrickColor.new("Bright reddish violet").Number, 124) end)
end
do
    T("brickcolor.number_to_name.125", function() return EQ(BrickColor.new(125).Name, "Light orange") end)
    T("brickcolor.tostring.125", function() return EQ(tostring(BrickColor.new(125)), "Light orange") end)
    T("brickcolor.rgb.125", function() local c = BrickColor.new(125).Color; return NEARV({c.R, c.G, c.B}, {234/255, 184/255, 146/255}, 1e-6) end)
    T("brickcolor.number_field.125", function() return EQ(BrickColor.new(125).Number, 125) end)
    T("brickcolor.name_to_number.125", function() return EQ(BrickColor.new("Light orange").Number, 125) end)
    T("brickcolor.nearest_self.125", function() return EQ(BrickColor.new(Color3.fromRGB(234, 184, 146)).Number, 125) end)
    T("brickcolor.palette.100", function() return EQ(BrickColor.palette(100).Number, 125) end)
end
do
    T("brickcolor.number_to_name.126", function() return EQ(BrickColor.new(126).Name, "Tr. Bright bluish violet") end)
    T("brickcolor.tostring.126", function() return EQ(tostring(BrickColor.new(126)), "Tr. Bright bluish violet") end)
    T("brickcolor.rgb.126", function() local c = BrickColor.new(126).Color; return NEARV({c.R, c.G, c.B}, {165/255, 165/255, 203/255}, 1e-6) end)
    T("brickcolor.number_field.126", function() return EQ(BrickColor.new(126).Number, 126) end)
    T("brickcolor.name_to_number.126", function() return EQ(BrickColor.new("Tr. Bright bluish violet").Number, 126) end)
end
do
    T("brickcolor.number_to_name.127", function() return EQ(BrickColor.new(127).Name, "Gold") end)
    T("brickcolor.tostring.127", function() return EQ(tostring(BrickColor.new(127)), "Gold") end)
    T("brickcolor.rgb.127", function() local c = BrickColor.new(127).Color; return NEARV({c.R, c.G, c.B}, {220/255, 188/255, 129/255}, 1e-6) end)
    T("brickcolor.number_field.127", function() return EQ(BrickColor.new(127).Number, 127) end)
end
do
    T("brickcolor.number_to_name.128", function() return EQ(BrickColor.new(128).Name, "Dark nougat") end)
    T("brickcolor.tostring.128", function() return EQ(tostring(BrickColor.new(128)), "Dark nougat") end)
    T("brickcolor.rgb.128", function() local c = BrickColor.new(128).Color; return NEARV({c.R, c.G, c.B}, {174/255, 122/255, 89/255}, 1e-6) end)
    T("brickcolor.number_field.128", function() return EQ(BrickColor.new(128).Number, 128) end)
    T("brickcolor.name_to_number.128", function() return EQ(BrickColor.new("Dark nougat").Number, 128) end)
end
do
    T("brickcolor.number_to_name.131", function() return EQ(BrickColor.new(131).Name, "Silver") end)
    T("brickcolor.tostring.131", function() return EQ(tostring(BrickColor.new(131)), "Silver") end)
    T("brickcolor.rgb.131", function() local c = BrickColor.new(131).Color; return NEARV({c.R, c.G, c.B}, {156/255, 163/255, 168/255}, 1e-6) end)
    T("brickcolor.number_field.131", function() return EQ(BrickColor.new(131).Number, 131) end)
    T("brickcolor.name_to_number.131", function() return EQ(BrickColor.new("Silver").Number, 131) end)
end
do
    T("brickcolor.number_to_name.133", function() return EQ(BrickColor.new(133).Name, "Neon orange") end)
    T("brickcolor.tostring.133", function() return EQ(tostring(BrickColor.new(133)), "Neon orange") end)
    T("brickcolor.rgb.133", function() local c = BrickColor.new(133).Color; return NEARV({c.R, c.G, c.B}, {213/255, 115/255, 61/255}, 1e-6) end)
    T("brickcolor.number_field.133", function() return EQ(BrickColor.new(133).Number, 133) end)
    T("brickcolor.name_to_number.133", function() return EQ(BrickColor.new("Neon orange").Number, 133) end)
    T("brickcolor.nearest_self.133", function() return EQ(BrickColor.new(Color3.fromRGB(213, 115, 61)).Number, 133) end)
    T("brickcolor.palette.82", function() return EQ(BrickColor.palette(82).Number, 133) end)
end
do
    T("brickcolor.number_to_name.134", function() return EQ(BrickColor.new(134).Name, "Neon green") end)
    T("brickcolor.tostring.134", function() return EQ(tostring(BrickColor.new(134)), "Neon green") end)
    T("brickcolor.rgb.134", function() local c = BrickColor.new(134).Color; return NEARV({c.R, c.G, c.B}, {216/255, 221/255, 86/255}, 1e-6) end)
    T("brickcolor.number_field.134", function() return EQ(BrickColor.new(134).Number, 134) end)
    T("brickcolor.name_to_number.134", function() return EQ(BrickColor.new("Neon green").Number, 134) end)
end
do
    T("brickcolor.number_to_name.135", function() return EQ(BrickColor.new(135).Name, "Sand blue") end)
    T("brickcolor.tostring.135", function() return EQ(tostring(BrickColor.new(135)), "Sand blue") end)
    T("brickcolor.rgb.135", function() local c = BrickColor.new(135).Color; return NEARV({c.R, c.G, c.B}, {116/255, 134/255, 157/255}, 1e-6) end)
    T("brickcolor.number_field.135", function() return EQ(BrickColor.new(135).Number, 135) end)
    T("brickcolor.name_to_number.135", function() return EQ(BrickColor.new("Sand blue").Number, 135) end)
    T("brickcolor.nearest_self.135", function() return EQ(BrickColor.new(Color3.fromRGB(116, 134, 157)).Number, 135) end)
    T("brickcolor.palette.19", function() return EQ(BrickColor.palette(19).Number, 135) end)
end
do
    T("brickcolor.number_to_name.136", function() return EQ(BrickColor.new(136).Name, "Sand violet") end)
    T("brickcolor.tostring.136", function() return EQ(tostring(BrickColor.new(136)), "Sand violet") end)
    T("brickcolor.rgb.136", function() local c = BrickColor.new(136).Color; return NEARV({c.R, c.G, c.B}, {135/255, 124/255, 144/255}, 1e-6) end)
    T("brickcolor.number_field.136", function() return EQ(BrickColor.new(136).Number, 136) end)
    T("brickcolor.name_to_number.136", function() return EQ(BrickColor.new("Sand violet").Number, 136) end)
end
do
    T("brickcolor.number_to_name.137", function() return EQ(BrickColor.new(137).Name, "Medium orange") end)
    T("brickcolor.tostring.137", function() return EQ(tostring(BrickColor.new(137)), "Medium orange") end)
    T("brickcolor.rgb.137", function() local c = BrickColor.new(137).Color; return NEARV({c.R, c.G, c.B}, {224/255, 152/255, 100/255}, 1e-6) end)
    T("brickcolor.number_field.137", function() return EQ(BrickColor.new(137).Number, 137) end)
    T("brickcolor.name_to_number.137", function() return EQ(BrickColor.new("Medium orange").Number, 137) end)
end
do
    T("brickcolor.number_to_name.138", function() return EQ(BrickColor.new(138).Name, "Sand yellow") end)
    T("brickcolor.tostring.138", function() return EQ(tostring(BrickColor.new(138)), "Sand yellow") end)
    T("brickcolor.rgb.138", function() local c = BrickColor.new(138).Color; return NEARV({c.R, c.G, c.B}, {149/255, 138/255, 115/255}, 1e-6) end)
    T("brickcolor.number_field.138", function() return EQ(BrickColor.new(138).Number, 138) end)
    T("brickcolor.name_to_number.138", function() return EQ(BrickColor.new("Sand yellow").Number, 138) end)
end
do
    T("brickcolor.number_to_name.140", function() return EQ(BrickColor.new(140).Name, "Earth blue") end)
    T("brickcolor.tostring.140", function() return EQ(tostring(BrickColor.new(140)), "Earth blue") end)
    T("brickcolor.rgb.140", function() local c = BrickColor.new(140).Color; return NEARV({c.R, c.G, c.B}, {32/255, 58/255, 86/255}, 1e-6) end)
    T("brickcolor.number_field.140", function() return EQ(BrickColor.new(140).Number, 140) end)
    T("brickcolor.name_to_number.140", function() return EQ(BrickColor.new("Earth blue").Number, 140) end)
end
do
    T("brickcolor.number_to_name.141", function() return EQ(BrickColor.new(141).Name, "Earth green") end)
    T("brickcolor.tostring.141", function() return EQ(tostring(BrickColor.new(141)), "Earth green") end)
    T("brickcolor.rgb.141", function() local c = BrickColor.new(141).Color; return NEARV({c.R, c.G, c.B}, {39/255, 70/255, 45/255}, 1e-6) end)
    T("brickcolor.number_field.141", function() return EQ(BrickColor.new(141).Number, 141) end)
    T("brickcolor.name_to_number.141", function() return EQ(BrickColor.new("Earth green").Number, 141) end)
    T("brickcolor.nearest_self.141", function() return EQ(BrickColor.new(Color3.fromRGB(39, 70, 45)).Number, 141) end)
    T("brickcolor.palette.0", function() return EQ(BrickColor.palette(0).Number, 141) end)
end
do
    T("brickcolor.number_to_name.143", function() return EQ(BrickColor.new(143).Name, "Tr. Flu. Blue") end)
    T("brickcolor.tostring.143", function() return EQ(tostring(BrickColor.new(143)), "Tr. Flu. Blue") end)
    T("brickcolor.rgb.143", function() local c = BrickColor.new(143).Color; return NEARV({c.R, c.G, c.B}, {207/255, 226/255, 247/255}, 1e-6) end)
    T("brickcolor.number_field.143", function() return EQ(BrickColor.new(143).Number, 143) end)
    T("brickcolor.name_to_number.143", function() return EQ(BrickColor.new("Tr. Flu. Blue").Number, 143) end)
end
do
    T("brickcolor.number_to_name.145", function() return EQ(BrickColor.new(145).Name, "Sand blue metallic") end)
    T("brickcolor.tostring.145", function() return EQ(tostring(BrickColor.new(145)), "Sand blue metallic") end)
    T("brickcolor.rgb.145", function() local c = BrickColor.new(145).Color; return NEARV({c.R, c.G, c.B}, {121/255, 136/255, 161/255}, 1e-6) end)
    T("brickcolor.number_field.145", function() return EQ(BrickColor.new(145).Number, 145) end)
    T("brickcolor.name_to_number.145", function() return EQ(BrickColor.new("Sand blue metallic").Number, 145) end)
end
do
    T("brickcolor.number_to_name.146", function() return EQ(BrickColor.new(146).Name, "Sand violet metallic") end)
    T("brickcolor.tostring.146", function() return EQ(tostring(BrickColor.new(146)), "Sand violet metallic") end)
    T("brickcolor.rgb.146", function() local c = BrickColor.new(146).Color; return NEARV({c.R, c.G, c.B}, {149/255, 142/255, 163/255}, 1e-6) end)
    T("brickcolor.number_field.146", function() return EQ(BrickColor.new(146).Number, 146) end)
    T("brickcolor.name_to_number.146", function() return EQ(BrickColor.new("Sand violet metallic").Number, 146) end)
end
do
    T("brickcolor.number_to_name.147", function() return EQ(BrickColor.new(147).Name, "Sand yellow metallic") end)
    T("brickcolor.tostring.147", function() return EQ(tostring(BrickColor.new(147)), "Sand yellow metallic") end)
    T("brickcolor.rgb.147", function() local c = BrickColor.new(147).Color; return NEARV({c.R, c.G, c.B}, {147/255, 135/255, 103/255}, 1e-6) end)
    T("brickcolor.number_field.147", function() return EQ(BrickColor.new(147).Number, 147) end)
    T("brickcolor.name_to_number.147", function() return EQ(BrickColor.new("Sand yellow metallic").Number, 147) end)
end
do
    T("brickcolor.number_to_name.148", function() return EQ(BrickColor.new(148).Name, "Dark grey metallic") end)
    T("brickcolor.tostring.148", function() return EQ(tostring(BrickColor.new(148)), "Dark grey metallic") end)
    T("brickcolor.rgb.148", function() local c = BrickColor.new(148).Color; return NEARV({c.R, c.G, c.B}, {87/255, 88/255, 87/255}, 1e-6) end)
    T("brickcolor.number_field.148", function() return EQ(BrickColor.new(148).Number, 148) end)
    T("brickcolor.name_to_number.148", function() return EQ(BrickColor.new("Dark grey metallic").Number, 148) end)
end
do
    T("brickcolor.number_to_name.149", function() return EQ(BrickColor.new(149).Name, "Black metallic") end)
    T("brickcolor.tostring.149", function() return EQ(tostring(BrickColor.new(149)), "Black metallic") end)
    T("brickcolor.rgb.149", function() local c = BrickColor.new(149).Color; return NEARV({c.R, c.G, c.B}, {22/255, 29/255, 50/255}, 1e-6) end)
    T("brickcolor.number_field.149", function() return EQ(BrickColor.new(149).Number, 149) end)
    T("brickcolor.name_to_number.149", function() return EQ(BrickColor.new("Black metallic").Number, 149) end)
end
do
    T("brickcolor.number_to_name.150", function() return EQ(BrickColor.new(150).Name, "Light grey metallic") end)
    T("brickcolor.tostring.150", function() return EQ(tostring(BrickColor.new(150)), "Light grey metallic") end)
    T("brickcolor.rgb.150", function() local c = BrickColor.new(150).Color; return NEARV({c.R, c.G, c.B}, {171/255, 173/255, 172/255}, 1e-6) end)
    T("brickcolor.number_field.150", function() return EQ(BrickColor.new(150).Number, 150) end)
    T("brickcolor.name_to_number.150", function() return EQ(BrickColor.new("Light grey metallic").Number, 150) end)
end
do
    T("brickcolor.number_to_name.151", function() return EQ(BrickColor.new(151).Name, "Sand green") end)
    T("brickcolor.tostring.151", function() return EQ(tostring(BrickColor.new(151)), "Sand green") end)
    T("brickcolor.rgb.151", function() local c = BrickColor.new(151).Color; return NEARV({c.R, c.G, c.B}, {120/255, 144/255, 130/255}, 1e-6) end)
    T("brickcolor.number_field.151", function() return EQ(BrickColor.new(151).Number, 151) end)
    T("brickcolor.name_to_number.151", function() return EQ(BrickColor.new("Sand green").Number, 151) end)
    T("brickcolor.nearest_self.151", function() return EQ(BrickColor.new(Color3.fromRGB(120, 144, 130)).Number, 151) end)
    T("brickcolor.palette.34", function() return EQ(BrickColor.palette(34).Number, 151) end)
end
do
    T("brickcolor.number_to_name.153", function() return EQ(BrickColor.new(153).Name, "Sand red") end)
    T("brickcolor.tostring.153", function() return EQ(tostring(BrickColor.new(153)), "Sand red") end)
    T("brickcolor.rgb.153", function() local c = BrickColor.new(153).Color; return NEARV({c.R, c.G, c.B}, {149/255, 121/255, 119/255}, 1e-6) end)
    T("brickcolor.number_field.153", function() return EQ(BrickColor.new(153).Number, 153) end)
    T("brickcolor.name_to_number.153", function() return EQ(BrickColor.new("Sand red").Number, 153) end)
    T("brickcolor.nearest_self.153", function() return EQ(BrickColor.new(Color3.fromRGB(149, 121, 119)).Number, 153) end)
    T("brickcolor.palette.114", function() return EQ(BrickColor.palette(114).Number, 153) end)
end
do
    T("brickcolor.number_to_name.154", function() return EQ(BrickColor.new(154).Name, "Dark red") end)
    T("brickcolor.tostring.154", function() return EQ(tostring(BrickColor.new(154)), "Dark red") end)
    T("brickcolor.rgb.154", function() local c = BrickColor.new(154).Color; return NEARV({c.R, c.G, c.B}, {123/255, 46/255, 47/255}, 1e-6) end)
    T("brickcolor.number_field.154", function() return EQ(BrickColor.new(154).Number, 154) end)
    T("brickcolor.name_to_number.154", function() return EQ(BrickColor.new("Dark red").Number, 154) end)
end
do
    T("brickcolor.number_to_name.157", function() return EQ(BrickColor.new(157).Name, "Tr. Flu. Yellow") end)
    T("brickcolor.tostring.157", function() return EQ(tostring(BrickColor.new(157)), "Tr. Flu. Yellow") end)
    T("brickcolor.rgb.157", function() local c = BrickColor.new(157).Color; return NEARV({c.R, c.G, c.B}, {255/255, 246/255, 123/255}, 1e-6) end)
    T("brickcolor.number_field.157", function() return EQ(BrickColor.new(157).Number, 157) end)
    T("brickcolor.name_to_number.157", function() return EQ(BrickColor.new("Tr. Flu. Yellow").Number, 157) end)
end
do
    T("brickcolor.number_to_name.158", function() return EQ(BrickColor.new(158).Name, "Tr. Flu. Red") end)
    T("brickcolor.tostring.158", function() return EQ(tostring(BrickColor.new(158)), "Tr. Flu. Red") end)
    T("brickcolor.rgb.158", function() local c = BrickColor.new(158).Color; return NEARV({c.R, c.G, c.B}, {225/255, 164/255, 194/255}, 1e-6) end)
    T("brickcolor.number_field.158", function() return EQ(BrickColor.new(158).Number, 158) end)
    T("brickcolor.name_to_number.158", function() return EQ(BrickColor.new("Tr. Flu. Red").Number, 158) end)
end
do
    T("brickcolor.number_to_name.168", function() return EQ(BrickColor.new(168).Name, "Gun metallic") end)
    T("brickcolor.tostring.168", function() return EQ(tostring(BrickColor.new(168)), "Gun metallic") end)
    T("brickcolor.rgb.168", function() local c = BrickColor.new(168).Color; return NEARV({c.R, c.G, c.B}, {117/255, 108/255, 98/255}, 1e-6) end)
    T("brickcolor.number_field.168", function() return EQ(BrickColor.new(168).Number, 168) end)
    T("brickcolor.name_to_number.168", function() return EQ(BrickColor.new("Gun metallic").Number, 168) end)
end
do
    T("brickcolor.number_to_name.176", function() return EQ(BrickColor.new(176).Name, "Red flip/flop") end)
    T("brickcolor.tostring.176", function() return EQ(tostring(BrickColor.new(176)), "Red flip/flop") end)
    T("brickcolor.rgb.176", function() local c = BrickColor.new(176).Color; return NEARV({c.R, c.G, c.B}, {151/255, 105/255, 91/255}, 1e-6) end)
    T("brickcolor.number_field.176", function() return EQ(BrickColor.new(176).Number, 176) end)
    T("brickcolor.name_to_number.176", function() return EQ(BrickColor.new("Red flip/flop").Number, 176) end)
end
do
    T("brickcolor.number_to_name.178", function() return EQ(BrickColor.new(178).Name, "Yellow flip/flop") end)
    T("brickcolor.tostring.178", function() return EQ(tostring(BrickColor.new(178)), "Yellow flip/flop") end)
    T("brickcolor.rgb.178", function() local c = BrickColor.new(178).Color; return NEARV({c.R, c.G, c.B}, {180/255, 132/255, 85/255}, 1e-6) end)
    T("brickcolor.number_field.178", function() return EQ(BrickColor.new(178).Number, 178) end)
    T("brickcolor.name_to_number.178", function() return EQ(BrickColor.new("Yellow flip/flop").Number, 178) end)
end
do
    T("brickcolor.number_to_name.179", function() return EQ(BrickColor.new(179).Name, "Silver flip/flop") end)
    T("brickcolor.tostring.179", function() return EQ(tostring(BrickColor.new(179)), "Silver flip/flop") end)
    T("brickcolor.rgb.179", function() local c = BrickColor.new(179).Color; return NEARV({c.R, c.G, c.B}, {137/255, 135/255, 136/255}, 1e-6) end)
    T("brickcolor.number_field.179", function() return EQ(BrickColor.new(179).Number, 179) end)
    T("brickcolor.name_to_number.179", function() return EQ(BrickColor.new("Silver flip/flop").Number, 179) end)
end
do
    T("brickcolor.number_to_name.180", function() return EQ(BrickColor.new(180).Name, "Curry") end)
    T("brickcolor.tostring.180", function() return EQ(tostring(BrickColor.new(180)), "Curry") end)
    T("brickcolor.rgb.180", function() local c = BrickColor.new(180).Color; return NEARV({c.R, c.G, c.B}, {215/255, 169/255, 75/255}, 1e-6) end)
    T("brickcolor.number_field.180", function() return EQ(BrickColor.new(180).Number, 180) end)
    T("brickcolor.name_to_number.180", function() return EQ(BrickColor.new("Curry").Number, 180) end)
end
do
    T("brickcolor.number_to_name.190", function() return EQ(BrickColor.new(190).Name, "Fire Yellow") end)
    T("brickcolor.tostring.190", function() return EQ(tostring(BrickColor.new(190)), "Fire Yellow") end)
    T("brickcolor.rgb.190", function() local c = BrickColor.new(190).Color; return NEARV({c.R, c.G, c.B}, {249/255, 214/255, 46/255}, 1e-6) end)
    T("brickcolor.number_field.190", function() return EQ(BrickColor.new(190).Number, 190) end)
    T("brickcolor.name_to_number.190", function() return EQ(BrickColor.new("Fire Yellow").Number, 190) end)
end
do
    T("brickcolor.number_to_name.191", function() return EQ(BrickColor.new(191).Name, "Flame yellowish orange") end)
    T("brickcolor.tostring.191", function() return EQ(tostring(BrickColor.new(191)), "Flame yellowish orange") end)
    T("brickcolor.rgb.191", function() local c = BrickColor.new(191).Color; return NEARV({c.R, c.G, c.B}, {232/255, 171/255, 45/255}, 1e-6) end)
    T("brickcolor.number_field.191", function() return EQ(BrickColor.new(191).Number, 191) end)
    T("brickcolor.name_to_number.191", function() return EQ(BrickColor.new("Flame yellowish orange").Number, 191) end)
end
do
    T("brickcolor.number_to_name.192", function() return EQ(BrickColor.new(192).Name, "Reddish brown") end)
    T("brickcolor.tostring.192", function() return EQ(tostring(BrickColor.new(192)), "Reddish brown") end)
    T("brickcolor.rgb.192", function() local c = BrickColor.new(192).Color; return NEARV({c.R, c.G, c.B}, {105/255, 64/255, 40/255}, 1e-6) end)
    T("brickcolor.number_field.192", function() return EQ(BrickColor.new(192).Number, 192) end)
    T("brickcolor.name_to_number.192", function() return EQ(BrickColor.new("Reddish brown").Number, 192) end)
    T("brickcolor.nearest_self.192", function() return EQ(BrickColor.new(Color3.fromRGB(105, 64, 40)).Number, 192) end)
    T("brickcolor.palette.103", function() return EQ(BrickColor.palette(103).Number, 192) end)
end
do
    T("brickcolor.number_to_name.193", function() return EQ(BrickColor.new(193).Name, "Flame reddish orange") end)
    T("brickcolor.tostring.193", function() return EQ(tostring(BrickColor.new(193)), "Flame reddish orange") end)
    T("brickcolor.rgb.193", function() local c = BrickColor.new(193).Color; return NEARV({c.R, c.G, c.B}, {207/255, 96/255, 36/255}, 1e-6) end)
    T("brickcolor.number_field.193", function() return EQ(BrickColor.new(193).Number, 193) end)
    T("brickcolor.name_to_number.193", function() return EQ(BrickColor.new("Flame reddish orange").Number, 193) end)
end
do
    T("brickcolor.number_to_name.194", function() return EQ(BrickColor.new(194).Name, "Medium stone grey") end)
    T("brickcolor.tostring.194", function() return EQ(tostring(BrickColor.new(194)), "Medium stone grey") end)
    T("brickcolor.rgb.194", function() local c = BrickColor.new(194).Color; return NEARV({c.R, c.G, c.B}, {163/255, 162/255, 165/255}, 1e-6) end)
    T("brickcolor.number_field.194", function() return EQ(BrickColor.new(194).Number, 194) end)
    T("brickcolor.name_to_number.194", function() return EQ(BrickColor.new("Medium stone grey").Number, 194) end)
    T("brickcolor.nearest_self.194", function() return EQ(BrickColor.new(Color3.fromRGB(163, 162, 165)).Number, 194) end)
    T("brickcolor.palette.123", function() return EQ(BrickColor.palette(123).Number, 194) end)
end
do
    T("brickcolor.number_to_name.195", function() return EQ(BrickColor.new(195).Name, "Royal blue") end)
    T("brickcolor.tostring.195", function() return EQ(tostring(BrickColor.new(195)), "Royal blue") end)
    T("brickcolor.rgb.195", function() local c = BrickColor.new(195).Color; return NEARV({c.R, c.G, c.B}, {70/255, 103/255, 164/255}, 1e-6) end)
    T("brickcolor.number_field.195", function() return EQ(BrickColor.new(195).Number, 195) end)
    T("brickcolor.name_to_number.195", function() return EQ(BrickColor.new("Royal blue").Number, 195) end)
end
do
    T("brickcolor.number_to_name.196", function() return EQ(BrickColor.new(196).Name, "Dark Royal blue") end)
    T("brickcolor.tostring.196", function() return EQ(tostring(BrickColor.new(196)), "Dark Royal blue") end)
    T("brickcolor.rgb.196", function() local c = BrickColor.new(196).Color; return NEARV({c.R, c.G, c.B}, {35/255, 71/255, 139/255}, 1e-6) end)
    T("brickcolor.number_field.196", function() return EQ(BrickColor.new(196).Number, 196) end)
    T("brickcolor.name_to_number.196", function() return EQ(BrickColor.new("Dark Royal blue").Number, 196) end)
end
do
    T("brickcolor.number_to_name.198", function() return EQ(BrickColor.new(198).Name, "Bright reddish lilac") end)
    T("brickcolor.tostring.198", function() return EQ(tostring(BrickColor.new(198)), "Bright reddish lilac") end)
    T("brickcolor.rgb.198", function() local c = BrickColor.new(198).Color; return NEARV({c.R, c.G, c.B}, {142/255, 66/255, 133/255}, 1e-6) end)
    T("brickcolor.number_field.198", function() return EQ(BrickColor.new(198).Number, 198) end)
    T("brickcolor.name_to_number.198", function() return EQ(BrickColor.new("Bright reddish lilac").Number, 198) end)
end
do
    T("brickcolor.number_to_name.199", function() return EQ(BrickColor.new(199).Name, "Dark stone grey") end)
    T("brickcolor.tostring.199", function() return EQ(tostring(BrickColor.new(199)), "Dark stone grey") end)
    T("brickcolor.rgb.199", function() local c = BrickColor.new(199).Color; return NEARV({c.R, c.G, c.B}, {99/255, 95/255, 98/255}, 1e-6) end)
    T("brickcolor.number_field.199", function() return EQ(BrickColor.new(199).Number, 199) end)
    T("brickcolor.name_to_number.199", function() return EQ(BrickColor.new("Dark stone grey").Number, 199) end)
    T("brickcolor.nearest_self.199", function() return EQ(BrickColor.new(Color3.fromRGB(99, 95, 98)).Number, 199) end)
    T("brickcolor.palette.122", function() return EQ(BrickColor.palette(122).Number, 199) end)
end
do
    T("brickcolor.number_to_name.200", function() return EQ(BrickColor.new(200).Name, "Lemon metalic") end)
    T("brickcolor.tostring.200", function() return EQ(tostring(BrickColor.new(200)), "Lemon metalic") end)
    T("brickcolor.rgb.200", function() local c = BrickColor.new(200).Color; return NEARV({c.R, c.G, c.B}, {130/255, 138/255, 93/255}, 1e-6) end)
    T("brickcolor.number_field.200", function() return EQ(BrickColor.new(200).Number, 200) end)
    T("brickcolor.name_to_number.200", function() return EQ(BrickColor.new("Lemon metalic").Number, 200) end)
end
do
    T("brickcolor.number_to_name.208", function() return EQ(BrickColor.new(208).Name, "Light stone grey") end)
    T("brickcolor.tostring.208", function() return EQ(tostring(BrickColor.new(208)), "Light stone grey") end)
    T("brickcolor.rgb.208", function() local c = BrickColor.new(208).Color; return NEARV({c.R, c.G, c.B}, {229/255, 228/255, 223/255}, 1e-6) end)
    T("brickcolor.number_field.208", function() return EQ(BrickColor.new(208).Number, 208) end)
    T("brickcolor.name_to_number.208", function() return EQ(BrickColor.new("Light stone grey").Number, 208) end)
    T("brickcolor.nearest_self.208", function() return EQ(BrickColor.new(Color3.fromRGB(229, 228, 223)).Number, 208) end)
    T("brickcolor.palette.62", function() return EQ(BrickColor.palette(62).Number, 208) end)
end
do
    T("brickcolor.number_to_name.209", function() return EQ(BrickColor.new(209).Name, "Dark Curry") end)
    T("brickcolor.tostring.209", function() return EQ(tostring(BrickColor.new(209)), "Dark Curry") end)
    T("brickcolor.rgb.209", function() local c = BrickColor.new(209).Color; return NEARV({c.R, c.G, c.B}, {176/255, 142/255, 68/255}, 1e-6) end)
    T("brickcolor.number_field.209", function() return EQ(BrickColor.new(209).Number, 209) end)
    T("brickcolor.name_to_number.209", function() return EQ(BrickColor.new("Dark Curry").Number, 209) end)
end
do
    T("brickcolor.number_to_name.210", function() return EQ(BrickColor.new(210).Name, "Faded green") end)
    T("brickcolor.tostring.210", function() return EQ(tostring(BrickColor.new(210)), "Faded green") end)
    T("brickcolor.rgb.210", function() local c = BrickColor.new(210).Color; return NEARV({c.R, c.G, c.B}, {112/255, 149/255, 120/255}, 1e-6) end)
    T("brickcolor.number_field.210", function() return EQ(BrickColor.new(210).Number, 210) end)
    T("brickcolor.name_to_number.210", function() return EQ(BrickColor.new("Faded green").Number, 210) end)
end
do
    T("brickcolor.number_to_name.211", function() return EQ(BrickColor.new(211).Name, "Turquoise") end)
    T("brickcolor.tostring.211", function() return EQ(tostring(BrickColor.new(211)), "Turquoise") end)
    T("brickcolor.rgb.211", function() local c = BrickColor.new(211).Color; return NEARV({c.R, c.G, c.B}, {121/255, 181/255, 181/255}, 1e-6) end)
    T("brickcolor.number_field.211", function() return EQ(BrickColor.new(211).Number, 211) end)
    T("brickcolor.name_to_number.211", function() return EQ(BrickColor.new("Turquoise").Number, 211) end)
end
do
    T("brickcolor.number_to_name.212", function() return EQ(BrickColor.new(212).Name, "Light Royal blue") end)
    T("brickcolor.tostring.212", function() return EQ(tostring(BrickColor.new(212)), "Light Royal blue") end)
    T("brickcolor.rgb.212", function() local c = BrickColor.new(212).Color; return NEARV({c.R, c.G, c.B}, {159/255, 195/255, 233/255}, 1e-6) end)
    T("brickcolor.number_field.212", function() return EQ(BrickColor.new(212).Number, 212) end)
    T("brickcolor.name_to_number.212", function() return EQ(BrickColor.new("Light Royal blue").Number, 212) end)
end
do
    T("brickcolor.number_to_name.213", function() return EQ(BrickColor.new(213).Name, "Medium Royal blue") end)
    T("brickcolor.tostring.213", function() return EQ(tostring(BrickColor.new(213)), "Medium Royal blue") end)
    T("brickcolor.rgb.213", function() local c = BrickColor.new(213).Color; return NEARV({c.R, c.G, c.B}, {108/255, 129/255, 183/255}, 1e-6) end)
    T("brickcolor.number_field.213", function() return EQ(BrickColor.new(213).Number, 213) end)
    T("brickcolor.name_to_number.213", function() return EQ(BrickColor.new("Medium Royal blue").Number, 213) end)
end
do
    T("brickcolor.number_to_name.216", function() return EQ(BrickColor.new(216).Name, "Rust") end)
    T("brickcolor.tostring.216", function() return EQ(tostring(BrickColor.new(216)), "Rust") end)
    T("brickcolor.rgb.216", function() local c = BrickColor.new(216).Color; return NEARV({c.R, c.G, c.B}, {144/255, 76/255, 42/255}, 1e-6) end)
    T("brickcolor.number_field.216", function() return EQ(BrickColor.new(216).Number, 216) end)
end
do
    T("brickcolor.number_to_name.217", function() return EQ(BrickColor.new(217).Name, "Brown") end)
    T("brickcolor.tostring.217", function() return EQ(tostring(BrickColor.new(217)), "Brown") end)
    T("brickcolor.rgb.217", function() local c = BrickColor.new(217).Color; return NEARV({c.R, c.G, c.B}, {124/255, 92/255, 70/255}, 1e-6) end)
    T("brickcolor.number_field.217", function() return EQ(BrickColor.new(217).Number, 217) end)
    T("brickcolor.name_to_number.217", function() return EQ(BrickColor.new("Brown").Number, 217) end)
    T("brickcolor.nearest_self.217", function() return EQ(BrickColor.new(Color3.fromRGB(124, 92, 70)).Number, 217) end)
    T("brickcolor.palette.111", function() return EQ(BrickColor.palette(111).Number, 217) end)
end
do
    T("brickcolor.number_to_name.218", function() return EQ(BrickColor.new(218).Name, "Reddish lilac") end)
    T("brickcolor.tostring.218", function() return EQ(tostring(BrickColor.new(218)), "Reddish lilac") end)
    T("brickcolor.rgb.218", function() local c = BrickColor.new(218).Color; return NEARV({c.R, c.G, c.B}, {150/255, 112/255, 159/255}, 1e-6) end)
    T("brickcolor.number_field.218", function() return EQ(BrickColor.new(218).Number, 218) end)
    T("brickcolor.name_to_number.218", function() return EQ(BrickColor.new("Reddish lilac").Number, 218) end)
end
do
    T("brickcolor.number_to_name.219", function() return EQ(BrickColor.new(219).Name, "Lilac") end)
    T("brickcolor.tostring.219", function() return EQ(tostring(BrickColor.new(219)), "Lilac") end)
    T("brickcolor.rgb.219", function() local c = BrickColor.new(219).Color; return NEARV({c.R, c.G, c.B}, {107/255, 98/255, 155/255}, 1e-6) end)
    T("brickcolor.number_field.219", function() return EQ(BrickColor.new(219).Number, 219) end)
end
do
    T("brickcolor.number_to_name.220", function() return EQ(BrickColor.new(220).Name, "Light lilac") end)
    T("brickcolor.tostring.220", function() return EQ(tostring(BrickColor.new(220)), "Light lilac") end)
    T("brickcolor.rgb.220", function() local c = BrickColor.new(220).Color; return NEARV({c.R, c.G, c.B}, {167/255, 169/255, 206/255}, 1e-6) end)
    T("brickcolor.number_field.220", function() return EQ(BrickColor.new(220).Number, 220) end)
    T("brickcolor.name_to_number.220", function() return EQ(BrickColor.new("Light lilac").Number, 220) end)
end
do
    T("brickcolor.number_to_name.221", function() return EQ(BrickColor.new(221).Name, "Bright purple") end)
    T("brickcolor.tostring.221", function() return EQ(tostring(BrickColor.new(221)), "Bright purple") end)
    T("brickcolor.rgb.221", function() local c = BrickColor.new(221).Color; return NEARV({c.R, c.G, c.B}, {205/255, 98/255, 152/255}, 1e-6) end)
    T("brickcolor.number_field.221", function() return EQ(BrickColor.new(221).Number, 221) end)
    T("brickcolor.name_to_number.221", function() return EQ(BrickColor.new("Bright purple").Number, 221) end)
end
do
    T("brickcolor.number_to_name.222", function() return EQ(BrickColor.new(222).Name, "Light purple") end)
    T("brickcolor.tostring.222", function() return EQ(tostring(BrickColor.new(222)), "Light purple") end)
    T("brickcolor.rgb.222", function() local c = BrickColor.new(222).Color; return NEARV({c.R, c.G, c.B}, {228/255, 173/255, 200/255}, 1e-6) end)
    T("brickcolor.number_field.222", function() return EQ(BrickColor.new(222).Number, 222) end)
    T("brickcolor.name_to_number.222", function() return EQ(BrickColor.new("Light purple").Number, 222) end)
end
do
    T("brickcolor.number_to_name.223", function() return EQ(BrickColor.new(223).Name, "Light pink") end)
    T("brickcolor.tostring.223", function() return EQ(tostring(BrickColor.new(223)), "Light pink") end)
    T("brickcolor.rgb.223", function() local c = BrickColor.new(223).Color; return NEARV({c.R, c.G, c.B}, {220/255, 144/255, 149/255}, 1e-6) end)
    T("brickcolor.number_field.223", function() return EQ(BrickColor.new(223).Number, 223) end)
    T("brickcolor.name_to_number.223", function() return EQ(BrickColor.new("Light pink").Number, 223) end)
end
do
    T("brickcolor.number_to_name.224", function() return EQ(BrickColor.new(224).Name, "Light brick yellow") end)
    T("brickcolor.tostring.224", function() return EQ(tostring(BrickColor.new(224)), "Light brick yellow") end)
    T("brickcolor.rgb.224", function() local c = BrickColor.new(224).Color; return NEARV({c.R, c.G, c.B}, {240/255, 213/255, 160/255}, 1e-6) end)
    T("brickcolor.number_field.224", function() return EQ(BrickColor.new(224).Number, 224) end)
    T("brickcolor.name_to_number.224", function() return EQ(BrickColor.new("Light brick yellow").Number, 224) end)
end
do
    T("brickcolor.number_to_name.225", function() return EQ(BrickColor.new(225).Name, "Warm yellowish orange") end)
    T("brickcolor.tostring.225", function() return EQ(tostring(BrickColor.new(225)), "Warm yellowish orange") end)
    T("brickcolor.rgb.225", function() local c = BrickColor.new(225).Color; return NEARV({c.R, c.G, c.B}, {235/255, 184/255, 127/255}, 1e-6) end)
    T("brickcolor.number_field.225", function() return EQ(BrickColor.new(225).Number, 225) end)
    T("brickcolor.name_to_number.225", function() return EQ(BrickColor.new("Warm yellowish orange").Number, 225) end)
end
do
    T("brickcolor.number_to_name.226", function() return EQ(BrickColor.new(226).Name, "Cool yellow") end)
    T("brickcolor.tostring.226", function() return EQ(tostring(BrickColor.new(226)), "Cool yellow") end)
    T("brickcolor.rgb.226", function() local c = BrickColor.new(226).Color; return NEARV({c.R, c.G, c.B}, {253/255, 234/255, 141/255}, 1e-6) end)
    T("brickcolor.number_field.226", function() return EQ(BrickColor.new(226).Number, 226) end)
    T("brickcolor.name_to_number.226", function() return EQ(BrickColor.new("Cool yellow").Number, 226) end)
    T("brickcolor.nearest_self.226", function() return EQ(BrickColor.new(Color3.fromRGB(253, 234, 141)).Number, 226) end)
    T("brickcolor.palette.73", function() return EQ(BrickColor.palette(73).Number, 226) end)
end
do
    T("brickcolor.number_to_name.232", function() return EQ(BrickColor.new(232).Name, "Dove blue") end)
    T("brickcolor.tostring.232", function() return EQ(tostring(BrickColor.new(232)), "Dove blue") end)
    T("brickcolor.rgb.232", function() local c = BrickColor.new(232).Color; return NEARV({c.R, c.G, c.B}, {125/255, 187/255, 221/255}, 1e-6) end)
    T("brickcolor.number_field.232", function() return EQ(BrickColor.new(232).Number, 232) end)
    T("brickcolor.name_to_number.232", function() return EQ(BrickColor.new("Dove blue").Number, 232) end)
end
do
    T("brickcolor.number_to_name.268", function() return EQ(BrickColor.new(268).Name, "Medium lilac") end)
    T("brickcolor.tostring.268", function() return EQ(tostring(BrickColor.new(268)), "Medium lilac") end)
    T("brickcolor.rgb.268", function() local c = BrickColor.new(268).Color; return NEARV({c.R, c.G, c.B}, {52/255, 43/255, 117/255}, 1e-6) end)
    T("brickcolor.number_field.268", function() return EQ(BrickColor.new(268).Number, 268) end)
    T("brickcolor.name_to_number.268", function() return EQ(BrickColor.new("Medium lilac").Number, 268) end)
end
do
    T("brickcolor.number_to_name.301", function() return EQ(BrickColor.new(301).Name, "Slime green") end)
    T("brickcolor.tostring.301", function() return EQ(tostring(BrickColor.new(301)), "Slime green") end)
    T("brickcolor.rgb.301", function() local c = BrickColor.new(301).Color; return NEARV({c.R, c.G, c.B}, {80/255, 109/255, 84/255}, 1e-6) end)
    T("brickcolor.number_field.301", function() return EQ(BrickColor.new(301).Number, 301) end)
    T("brickcolor.name_to_number.301", function() return EQ(BrickColor.new("Slime green").Number, 301) end)
    T("brickcolor.nearest_self.301", function() return EQ(BrickColor.new(Color3.fromRGB(80, 109, 84)).Number, 301) end)
    T("brickcolor.palette.1", function() return EQ(BrickColor.palette(1).Number, 301) end)
end
do
    T("brickcolor.number_to_name.302", function() return EQ(BrickColor.new(302).Name, "Smoky grey") end)
    T("brickcolor.tostring.302", function() return EQ(tostring(BrickColor.new(302)), "Smoky grey") end)
    T("brickcolor.rgb.302", function() local c = BrickColor.new(302).Color; return NEARV({c.R, c.G, c.B}, {91/255, 93/255, 105/255}, 1e-6) end)
    T("brickcolor.number_field.302", function() return EQ(BrickColor.new(302).Number, 302) end)
    T("brickcolor.name_to_number.302", function() return EQ(BrickColor.new("Smoky grey").Number, 302) end)
    T("brickcolor.nearest_self.302", function() return EQ(BrickColor.new(Color3.fromRGB(91, 93, 105)).Number, 302) end)
    T("brickcolor.palette.10", function() return EQ(BrickColor.palette(10).Number, 302) end)
end
do
    T("brickcolor.number_to_name.303", function() return EQ(BrickColor.new(303).Name, "Dark blue") end)
    T("brickcolor.tostring.303", function() return EQ(tostring(BrickColor.new(303)), "Dark blue") end)
    T("brickcolor.rgb.303", function() local c = BrickColor.new(303).Color; return NEARV({c.R, c.G, c.B}, {0/255, 16/255, 176/255}, 1e-6) end)
    T("brickcolor.number_field.303", function() return EQ(BrickColor.new(303).Number, 303) end)
    T("brickcolor.name_to_number.303", function() return EQ(BrickColor.new("Dark blue").Number, 303) end)
    T("brickcolor.nearest_self.303", function() return EQ(BrickColor.new(Color3.fromRGB(0, 16, 176)).Number, 303) end)
    T("brickcolor.palette.5", function() return EQ(BrickColor.palette(5).Number, 303) end)
end
do
    T("brickcolor.number_to_name.304", function() return EQ(BrickColor.new(304).Name, "Parsley green") end)
    T("brickcolor.tostring.304", function() return EQ(tostring(BrickColor.new(304)), "Parsley green") end)
    T("brickcolor.rgb.304", function() local c = BrickColor.new(304).Color; return NEARV({c.R, c.G, c.B}, {44/255, 101/255, 29/255}, 1e-6) end)
    T("brickcolor.number_field.304", function() return EQ(BrickColor.new(304).Number, 304) end)
    T("brickcolor.name_to_number.304", function() return EQ(BrickColor.new("Parsley green").Number, 304) end)
    T("brickcolor.nearest_self.304", function() return EQ(BrickColor.new(Color3.fromRGB(44, 101, 29)).Number, 304) end)
    T("brickcolor.palette.7", function() return EQ(BrickColor.palette(7).Number, 304) end)
end
do
    T("brickcolor.number_to_name.305", function() return EQ(BrickColor.new(305).Name, "Steel blue") end)
    T("brickcolor.tostring.305", function() return EQ(tostring(BrickColor.new(305)), "Steel blue") end)
    T("brickcolor.rgb.305", function() local c = BrickColor.new(305).Color; return NEARV({c.R, c.G, c.B}, {82/255, 124/255, 174/255}, 1e-6) end)
    T("brickcolor.number_field.305", function() return EQ(BrickColor.new(305).Number, 305) end)
    T("brickcolor.name_to_number.305", function() return EQ(BrickColor.new("Steel blue").Number, 305) end)
    T("brickcolor.nearest_self.305", function() return EQ(BrickColor.new(Color3.fromRGB(82, 124, 174)).Number, 305) end)
    T("brickcolor.palette.11", function() return EQ(BrickColor.palette(11).Number, 305) end)
end
do
    T("brickcolor.number_to_name.306", function() return EQ(BrickColor.new(306).Name, "Storm blue") end)
    T("brickcolor.tostring.306", function() return EQ(tostring(BrickColor.new(306)), "Storm blue") end)
    T("brickcolor.rgb.306", function() local c = BrickColor.new(306).Color; return NEARV({c.R, c.G, c.B}, {51/255, 88/255, 130/255}, 1e-6) end)
    T("brickcolor.number_field.306", function() return EQ(BrickColor.new(306).Number, 306) end)
    T("brickcolor.name_to_number.306", function() return EQ(BrickColor.new("Storm blue").Number, 306) end)
    T("brickcolor.nearest_self.306", function() return EQ(BrickColor.new(Color3.fromRGB(51, 88, 130)).Number, 306) end)
    T("brickcolor.palette.12", function() return EQ(BrickColor.palette(12).Number, 306) end)
end
do
    T("brickcolor.number_to_name.307", function() return EQ(BrickColor.new(307).Name, "Lapis") end)
    T("brickcolor.tostring.307", function() return EQ(tostring(BrickColor.new(307)), "Lapis") end)
    T("brickcolor.rgb.307", function() local c = BrickColor.new(307).Color; return NEARV({c.R, c.G, c.B}, {16/255, 42/255, 220/255}, 1e-6) end)
    T("brickcolor.number_field.307", function() return EQ(BrickColor.new(307).Number, 307) end)
    T("brickcolor.name_to_number.307", function() return EQ(BrickColor.new("Lapis").Number, 307) end)
    T("brickcolor.nearest_self.307", function() return EQ(BrickColor.new(Color3.fromRGB(16, 42, 220)).Number, 307) end)
    T("brickcolor.palette.13", function() return EQ(BrickColor.palette(13).Number, 307) end)
end
do
    T("brickcolor.number_to_name.308", function() return EQ(BrickColor.new(308).Name, "Dark indigo") end)
    T("brickcolor.tostring.308", function() return EQ(tostring(BrickColor.new(308)), "Dark indigo") end)
    T("brickcolor.rgb.308", function() local c = BrickColor.new(308).Color; return NEARV({c.R, c.G, c.B}, {61/255, 21/255, 133/255}, 1e-6) end)
    T("brickcolor.number_field.308", function() return EQ(BrickColor.new(308).Number, 308) end)
    T("brickcolor.name_to_number.308", function() return EQ(BrickColor.new("Dark indigo").Number, 308) end)
    T("brickcolor.nearest_self.308", function() return EQ(BrickColor.new(Color3.fromRGB(61, 21, 133)).Number, 308) end)
    T("brickcolor.palette.14", function() return EQ(BrickColor.palette(14).Number, 308) end)
end
do
    T("brickcolor.number_to_name.309", function() return EQ(BrickColor.new(309).Name, "Sea green") end)
    T("brickcolor.tostring.309", function() return EQ(tostring(BrickColor.new(309)), "Sea green") end)
    T("brickcolor.rgb.309", function() local c = BrickColor.new(309).Color; return NEARV({c.R, c.G, c.B}, {52/255, 142/255, 64/255}, 1e-6) end)
    T("brickcolor.number_field.309", function() return EQ(BrickColor.new(309).Number, 309) end)
    T("brickcolor.name_to_number.309", function() return EQ(BrickColor.new("Sea green").Number, 309) end)
    T("brickcolor.nearest_self.309", function() return EQ(BrickColor.new(Color3.fromRGB(52, 142, 64)).Number, 309) end)
    T("brickcolor.palette.16", function() return EQ(BrickColor.palette(16).Number, 309) end)
end
do
    T("brickcolor.number_to_name.310", function() return EQ(BrickColor.new(310).Name, "Shamrock") end)
    T("brickcolor.tostring.310", function() return EQ(tostring(BrickColor.new(310)), "Shamrock") end)
    T("brickcolor.rgb.310", function() local c = BrickColor.new(310).Color; return NEARV({c.R, c.G, c.B}, {91/255, 154/255, 76/255}, 1e-6) end)
    T("brickcolor.number_field.310", function() return EQ(BrickColor.new(310).Number, 310) end)
    T("brickcolor.name_to_number.310", function() return EQ(BrickColor.new("Shamrock").Number, 310) end)
    T("brickcolor.nearest_self.310", function() return EQ(BrickColor.new(Color3.fromRGB(91, 154, 76)).Number, 310) end)
    T("brickcolor.palette.17", function() return EQ(BrickColor.palette(17).Number, 310) end)
end
do
    T("brickcolor.number_to_name.311", function() return EQ(BrickColor.new(311).Name, "Fossil") end)
    T("brickcolor.tostring.311", function() return EQ(tostring(BrickColor.new(311)), "Fossil") end)
    T("brickcolor.rgb.311", function() local c = BrickColor.new(311).Color; return NEARV({c.R, c.G, c.B}, {159/255, 161/255, 172/255}, 1e-6) end)
    T("brickcolor.number_field.311", function() return EQ(BrickColor.new(311).Number, 311) end)
    T("brickcolor.name_to_number.311", function() return EQ(BrickColor.new("Fossil").Number, 311) end)
    T("brickcolor.nearest_self.311", function() return EQ(BrickColor.new(Color3.fromRGB(159, 161, 172)).Number, 311) end)
    T("brickcolor.palette.29", function() return EQ(BrickColor.palette(29).Number, 311) end)
end
do
    T("brickcolor.number_to_name.312", function() return EQ(BrickColor.new(312).Name, "Mulberry") end)
    T("brickcolor.tostring.312", function() return EQ(tostring(BrickColor.new(312)), "Mulberry") end)
    T("brickcolor.rgb.312", function() local c = BrickColor.new(312).Color; return NEARV({c.R, c.G, c.B}, {89/255, 34/255, 89/255}, 1e-6) end)
    T("brickcolor.number_field.312", function() return EQ(BrickColor.new(312).Number, 312) end)
    T("brickcolor.name_to_number.312", function() return EQ(BrickColor.new("Mulberry").Number, 312) end)
    T("brickcolor.nearest_self.312", function() return EQ(BrickColor.new(Color3.fromRGB(89, 34, 89)).Number, 312) end)
    T("brickcolor.palette.23", function() return EQ(BrickColor.palette(23).Number, 312) end)
end
do
    T("brickcolor.number_to_name.313", function() return EQ(BrickColor.new(313).Name, "Forest green") end)
    T("brickcolor.tostring.313", function() return EQ(tostring(BrickColor.new(313)), "Forest green") end)
    T("brickcolor.rgb.313", function() local c = BrickColor.new(313).Color; return NEARV({c.R, c.G, c.B}, {31/255, 128/255, 29/255}, 1e-6) end)
    T("brickcolor.number_field.313", function() return EQ(BrickColor.new(313).Number, 313) end)
    T("brickcolor.name_to_number.313", function() return EQ(BrickColor.new("Forest green").Number, 313) end)
    T("brickcolor.nearest_self.313", function() return EQ(BrickColor.new(Color3.fromRGB(31, 128, 29)).Number, 313) end)
    T("brickcolor.palette.24", function() return EQ(BrickColor.palette(24).Number, 313) end)
end
do
    T("brickcolor.number_to_name.314", function() return EQ(BrickColor.new(314).Name, "Cadet blue") end)
    T("brickcolor.tostring.314", function() return EQ(tostring(BrickColor.new(314)), "Cadet blue") end)
    T("brickcolor.rgb.314", function() local c = BrickColor.new(314).Color; return NEARV({c.R, c.G, c.B}, {159/255, 173/255, 192/255}, 1e-6) end)
    T("brickcolor.number_field.314", function() return EQ(BrickColor.new(314).Number, 314) end)
    T("brickcolor.name_to_number.314", function() return EQ(BrickColor.new("Cadet blue").Number, 314) end)
    T("brickcolor.nearest_self.314", function() return EQ(BrickColor.new(Color3.fromRGB(159, 173, 192)).Number, 314) end)
    T("brickcolor.palette.39", function() return EQ(BrickColor.palette(39).Number, 314) end)
end
do
    T("brickcolor.number_to_name.315", function() return EQ(BrickColor.new(315).Name, "Electric blue") end)
    T("brickcolor.tostring.315", function() return EQ(tostring(BrickColor.new(315)), "Electric blue") end)
    T("brickcolor.rgb.315", function() local c = BrickColor.new(315).Color; return NEARV({c.R, c.G, c.B}, {9/255, 137/255, 207/255}, 1e-6) end)
    T("brickcolor.number_field.315", function() return EQ(BrickColor.new(315).Number, 315) end)
    T("brickcolor.name_to_number.315", function() return EQ(BrickColor.new("Electric blue").Number, 315) end)
    T("brickcolor.nearest_self.315", function() return EQ(BrickColor.new(Color3.fromRGB(9, 137, 207)).Number, 315) end)
    T("brickcolor.palette.30", function() return EQ(BrickColor.palette(30).Number, 315) end)
end
do
    T("brickcolor.number_to_name.316", function() return EQ(BrickColor.new(316).Name, "Eggplant") end)
    T("brickcolor.tostring.316", function() return EQ(tostring(BrickColor.new(316)), "Eggplant") end)
    T("brickcolor.rgb.316", function() local c = BrickColor.new(316).Color; return NEARV({c.R, c.G, c.B}, {123/255, 0/255, 123/255}, 1e-6) end)
    T("brickcolor.number_field.316", function() return EQ(BrickColor.new(316).Number, 316) end)
    T("brickcolor.name_to_number.316", function() return EQ(BrickColor.new("Eggplant").Number, 316) end)
    T("brickcolor.nearest_self.316", function() return EQ(BrickColor.new(Color3.fromRGB(123, 0, 123)).Number, 316) end)
    T("brickcolor.palette.33", function() return EQ(BrickColor.palette(33).Number, 316) end)
end
do
    T("brickcolor.number_to_name.317", function() return EQ(BrickColor.new(317).Name, "Moss") end)
    T("brickcolor.tostring.317", function() return EQ(tostring(BrickColor.new(317)), "Moss") end)
    T("brickcolor.rgb.317", function() local c = BrickColor.new(317).Color; return NEARV({c.R, c.G, c.B}, {124/255, 156/255, 107/255}, 1e-6) end)
    T("brickcolor.number_field.317", function() return EQ(BrickColor.new(317).Number, 317) end)
    T("brickcolor.name_to_number.317", function() return EQ(BrickColor.new("Moss").Number, 317) end)
    T("brickcolor.nearest_self.317", function() return EQ(BrickColor.new(Color3.fromRGB(124, 156, 107)).Number, 317) end)
    T("brickcolor.palette.35", function() return EQ(BrickColor.palette(35).Number, 317) end)
end
do
    T("brickcolor.number_to_name.318", function() return EQ(BrickColor.new(318).Name, "Artichoke") end)
    T("brickcolor.tostring.318", function() return EQ(tostring(BrickColor.new(318)), "Artichoke") end)
    T("brickcolor.rgb.318", function() local c = BrickColor.new(318).Color; return NEARV({c.R, c.G, c.B}, {138/255, 171/255, 133/255}, 1e-6) end)
    T("brickcolor.number_field.318", function() return EQ(BrickColor.new(318).Number, 318) end)
    T("brickcolor.name_to_number.318", function() return EQ(BrickColor.new("Artichoke").Number, 318) end)
    T("brickcolor.nearest_self.318", function() return EQ(BrickColor.new(Color3.fromRGB(138, 171, 133)).Number, 318) end)
    T("brickcolor.palette.36", function() return EQ(BrickColor.palette(36).Number, 318) end)
end
do
    T("brickcolor.number_to_name.319", function() return EQ(BrickColor.new(319).Name, "Sage green") end)
    T("brickcolor.tostring.319", function() return EQ(tostring(BrickColor.new(319)), "Sage green") end)
    T("brickcolor.rgb.319", function() local c = BrickColor.new(319).Color; return NEARV({c.R, c.G, c.B}, {185/255, 196/255, 177/255}, 1e-6) end)
    T("brickcolor.number_field.319", function() return EQ(BrickColor.new(319).Number, 319) end)
    T("brickcolor.name_to_number.319", function() return EQ(BrickColor.new("Sage green").Number, 319) end)
    T("brickcolor.nearest_self.319", function() return EQ(BrickColor.new(Color3.fromRGB(185, 196, 177)).Number, 319) end)
    T("brickcolor.palette.37", function() return EQ(BrickColor.palette(37).Number, 319) end)
end
do
    T("brickcolor.number_to_name.320", function() return EQ(BrickColor.new(320).Name, "Ghost grey") end)
    T("brickcolor.tostring.320", function() return EQ(tostring(BrickColor.new(320)), "Ghost grey") end)
    T("brickcolor.rgb.320", function() local c = BrickColor.new(320).Color; return NEARV({c.R, c.G, c.B}, {202/255, 203/255, 209/255}, 1e-6) end)
    T("brickcolor.number_field.320", function() return EQ(BrickColor.new(320).Number, 320) end)
    T("brickcolor.name_to_number.320", function() return EQ(BrickColor.new("Ghost grey").Number, 320) end)
    T("brickcolor.nearest_self.320", function() return EQ(BrickColor.new(Color3.fromRGB(202, 203, 209)).Number, 320) end)
    T("brickcolor.palette.50", function() return EQ(BrickColor.palette(50).Number, 320) end)
end
do
    T("brickcolor.number_to_name.321", function() return EQ(BrickColor.new(321).Name, "Lilac") end)
    T("brickcolor.tostring.321", function() return EQ(tostring(BrickColor.new(321)), "Lilac") end)
    T("brickcolor.rgb.321", function() local c = BrickColor.new(321).Color; return NEARV({c.R, c.G, c.B}, {167/255, 94/255, 155/255}, 1e-6) end)
    T("brickcolor.number_field.321", function() return EQ(BrickColor.new(321).Number, 321) end)
    T("brickcolor.nearest_self.321", function() return EQ(BrickColor.new(Color3.fromRGB(167, 94, 155)).Number, 321) end)
    T("brickcolor.palette.42", function() return EQ(BrickColor.palette(42).Number, 321) end)
end
do
    T("brickcolor.number_to_name.322", function() return EQ(BrickColor.new(322).Name, "Plum") end)
    T("brickcolor.tostring.322", function() return EQ(tostring(BrickColor.new(322)), "Plum") end)
    T("brickcolor.rgb.322", function() local c = BrickColor.new(322).Color; return NEARV({c.R, c.G, c.B}, {123/255, 47/255, 123/255}, 1e-6) end)
    T("brickcolor.number_field.322", function() return EQ(BrickColor.new(322).Number, 322) end)
    T("brickcolor.name_to_number.322", function() return EQ(BrickColor.new("Plum").Number, 322) end)
    T("brickcolor.nearest_self.322", function() return EQ(BrickColor.new(Color3.fromRGB(123, 47, 123)).Number, 322) end)
    T("brickcolor.palette.43", function() return EQ(BrickColor.palette(43).Number, 322) end)
end
do
    T("brickcolor.number_to_name.323", function() return EQ(BrickColor.new(323).Name, "Olivine") end)
    T("brickcolor.tostring.323", function() return EQ(tostring(BrickColor.new(323)), "Olivine") end)
    T("brickcolor.rgb.323", function() local c = BrickColor.new(323).Color; return NEARV({c.R, c.G, c.B}, {148/255, 190/255, 129/255}, 1e-6) end)
    T("brickcolor.number_field.323", function() return EQ(BrickColor.new(323).Number, 323) end)
    T("brickcolor.name_to_number.323", function() return EQ(BrickColor.new("Olivine").Number, 323) end)
    T("brickcolor.nearest_self.323", function() return EQ(BrickColor.new(Color3.fromRGB(148, 190, 129)).Number, 323) end)
    T("brickcolor.palette.47", function() return EQ(BrickColor.palette(47).Number, 323) end)
end
do
    T("brickcolor.number_to_name.324", function() return EQ(BrickColor.new(324).Name, "Laurel green") end)
    T("brickcolor.tostring.324", function() return EQ(tostring(BrickColor.new(324)), "Laurel green") end)
    T("brickcolor.rgb.324", function() local c = BrickColor.new(324).Color; return NEARV({c.R, c.G, c.B}, {168/255, 189/255, 153/255}, 1e-6) end)
    T("brickcolor.number_field.324", function() return EQ(BrickColor.new(324).Number, 324) end)
    T("brickcolor.name_to_number.324", function() return EQ(BrickColor.new("Laurel green").Number, 324) end)
    T("brickcolor.nearest_self.324", function() return EQ(BrickColor.new(Color3.fromRGB(168, 189, 153)).Number, 324) end)
    T("brickcolor.palette.48", function() return EQ(BrickColor.palette(48).Number, 324) end)
end
do
    T("brickcolor.number_to_name.325", function() return EQ(BrickColor.new(325).Name, "Quill grey") end)
    T("brickcolor.tostring.325", function() return EQ(tostring(BrickColor.new(325)), "Quill grey") end)
    T("brickcolor.rgb.325", function() local c = BrickColor.new(325).Color; return NEARV({c.R, c.G, c.B}, {223/255, 223/255, 222/255}, 1e-6) end)
    T("brickcolor.number_field.325", function() return EQ(BrickColor.new(325).Number, 325) end)
    T("brickcolor.name_to_number.325", function() return EQ(BrickColor.new("Quill grey").Number, 325) end)
    T("brickcolor.nearest_self.325", function() return EQ(BrickColor.new(Color3.fromRGB(223, 223, 222)).Number, 325) end)
    T("brickcolor.palette.49", function() return EQ(BrickColor.palette(49).Number, 325) end)
end
do
    T("brickcolor.number_to_name.327", function() return EQ(BrickColor.new(327).Name, "Crimson") end)
    T("brickcolor.tostring.327", function() return EQ(tostring(BrickColor.new(327)), "Crimson") end)
    T("brickcolor.rgb.327", function() local c = BrickColor.new(327).Color; return NEARV({c.R, c.G, c.B}, {151/255, 0/255, 0/255}, 1e-6) end)
    T("brickcolor.number_field.327", function() return EQ(BrickColor.new(327).Number, 327) end)
    T("brickcolor.name_to_number.327", function() return EQ(BrickColor.new("Crimson").Number, 327) end)
    T("brickcolor.nearest_self.327", function() return EQ(BrickColor.new(Color3.fromRGB(151, 0, 0)).Number, 327) end)
    T("brickcolor.palette.56", function() return EQ(BrickColor.palette(56).Number, 327) end)
end
do
    T("brickcolor.number_to_name.328", function() return EQ(BrickColor.new(328).Name, "Mint") end)
    T("brickcolor.tostring.328", function() return EQ(tostring(BrickColor.new(328)), "Mint") end)
    T("brickcolor.rgb.328", function() local c = BrickColor.new(328).Color; return NEARV({c.R, c.G, c.B}, {177/255, 229/255, 166/255}, 1e-6) end)
    T("brickcolor.number_field.328", function() return EQ(BrickColor.new(328).Number, 328) end)
    T("brickcolor.name_to_number.328", function() return EQ(BrickColor.new("Mint").Number, 328) end)
    T("brickcolor.nearest_self.328", function() return EQ(BrickColor.new(Color3.fromRGB(177, 229, 166)).Number, 328) end)
    T("brickcolor.palette.60", function() return EQ(BrickColor.palette(60).Number, 328) end)
end
do
    T("brickcolor.number_to_name.329", function() return EQ(BrickColor.new(329).Name, "Baby blue") end)
    T("brickcolor.tostring.329", function() return EQ(tostring(BrickColor.new(329)), "Baby blue") end)
    T("brickcolor.rgb.329", function() local c = BrickColor.new(329).Color; return NEARV({c.R, c.G, c.B}, {152/255, 194/255, 219/255}, 1e-6) end)
    T("brickcolor.number_field.329", function() return EQ(BrickColor.new(329).Number, 329) end)
    T("brickcolor.name_to_number.329", function() return EQ(BrickColor.new("Baby blue").Number, 329) end)
    T("brickcolor.nearest_self.329", function() return EQ(BrickColor.new(Color3.fromRGB(152, 194, 219)).Number, 329) end)
    T("brickcolor.palette.64", function() return EQ(BrickColor.palette(64).Number, 329) end)
end
do
    T("brickcolor.number_to_name.330", function() return EQ(BrickColor.new(330).Name, "Carnation pink") end)
    T("brickcolor.tostring.330", function() return EQ(tostring(BrickColor.new(330)), "Carnation pink") end)
    T("brickcolor.rgb.330", function() local c = BrickColor.new(330).Color; return NEARV({c.R, c.G, c.B}, {255/255, 152/255, 220/255}, 1e-6) end)
    T("brickcolor.number_field.330", function() return EQ(BrickColor.new(330).Number, 330) end)
    T("brickcolor.name_to_number.330", function() return EQ(BrickColor.new("Carnation pink").Number, 330) end)
    T("brickcolor.nearest_self.330", function() return EQ(BrickColor.new(Color3.fromRGB(255, 152, 220)).Number, 330) end)
    T("brickcolor.palette.65", function() return EQ(BrickColor.palette(65).Number, 330) end)
end
do
    T("brickcolor.number_to_name.331", function() return EQ(BrickColor.new(331).Name, "Persimmon") end)
    T("brickcolor.tostring.331", function() return EQ(tostring(BrickColor.new(331)), "Persimmon") end)
    T("brickcolor.rgb.331", function() local c = BrickColor.new(331).Color; return NEARV({c.R, c.G, c.B}, {255/255, 89/255, 89/255}, 1e-6) end)
    T("brickcolor.number_field.331", function() return EQ(BrickColor.new(331).Number, 331) end)
    T("brickcolor.name_to_number.331", function() return EQ(BrickColor.new("Persimmon").Number, 331) end)
    T("brickcolor.nearest_self.331", function() return EQ(BrickColor.new(Color3.fromRGB(255, 89, 89)).Number, 331) end)
    T("brickcolor.palette.66", function() return EQ(BrickColor.palette(66).Number, 331) end)
end
do
    T("brickcolor.number_to_name.332", function() return EQ(BrickColor.new(332).Name, "Maroon") end)
    T("brickcolor.tostring.332", function() return EQ(tostring(BrickColor.new(332)), "Maroon") end)
    T("brickcolor.rgb.332", function() local c = BrickColor.new(332).Color; return NEARV({c.R, c.G, c.B}, {117/255, 0/255, 0/255}, 1e-6) end)
    T("brickcolor.number_field.332", function() return EQ(BrickColor.new(332).Number, 332) end)
    T("brickcolor.name_to_number.332", function() return EQ(BrickColor.new("Maroon").Number, 332) end)
    T("brickcolor.nearest_self.332", function() return EQ(BrickColor.new(Color3.fromRGB(117, 0, 0)).Number, 332) end)
    T("brickcolor.palette.69", function() return EQ(BrickColor.palette(69).Number, 332) end)
end
do
    T("brickcolor.number_to_name.333", function() return EQ(BrickColor.new(333).Name, "Gold") end)
    T("brickcolor.tostring.333", function() return EQ(tostring(BrickColor.new(333)), "Gold") end)
    T("brickcolor.rgb.333", function() local c = BrickColor.new(333).Color; return NEARV({c.R, c.G, c.B}, {239/255, 184/255, 56/255}, 1e-6) end)
    T("brickcolor.number_field.333", function() return EQ(BrickColor.new(333).Number, 333) end)
    T("brickcolor.nearest_self.333", function() return EQ(BrickColor.new(Color3.fromRGB(239, 184, 56)).Number, 333) end)
    T("brickcolor.palette.70", function() return EQ(BrickColor.palette(70).Number, 333) end)
end
do
    T("brickcolor.number_to_name.334", function() return EQ(BrickColor.new(334).Name, "Daisy orange") end)
    T("brickcolor.tostring.334", function() return EQ(tostring(BrickColor.new(334)), "Daisy orange") end)
    T("brickcolor.rgb.334", function() local c = BrickColor.new(334).Color; return NEARV({c.R, c.G, c.B}, {248/255, 217/255, 109/255}, 1e-6) end)
    T("brickcolor.number_field.334", function() return EQ(BrickColor.new(334).Number, 334) end)
    T("brickcolor.name_to_number.334", function() return EQ(BrickColor.new("Daisy orange").Number, 334) end)
    T("brickcolor.nearest_self.334", function() return EQ(BrickColor.new(Color3.fromRGB(248, 217, 109)).Number, 334) end)
    T("brickcolor.palette.72", function() return EQ(BrickColor.palette(72).Number, 334) end)
end
do
    T("brickcolor.number_to_name.335", function() return EQ(BrickColor.new(335).Name, "Pearl") end)
    T("brickcolor.tostring.335", function() return EQ(tostring(BrickColor.new(335)), "Pearl") end)
    T("brickcolor.rgb.335", function() local c = BrickColor.new(335).Color; return NEARV({c.R, c.G, c.B}, {231/255, 231/255, 236/255}, 1e-6) end)
    T("brickcolor.number_field.335", function() return EQ(BrickColor.new(335).Number, 335) end)
    T("brickcolor.name_to_number.335", function() return EQ(BrickColor.new("Pearl").Number, 335) end)
    T("brickcolor.nearest_self.335", function() return EQ(BrickColor.new(Color3.fromRGB(231, 231, 236)).Number, 335) end)
    T("brickcolor.palette.75", function() return EQ(BrickColor.palette(75).Number, 335) end)
end
do
    T("brickcolor.number_to_name.336", function() return EQ(BrickColor.new(336).Name, "Fog") end)
    T("brickcolor.tostring.336", function() return EQ(tostring(BrickColor.new(336)), "Fog") end)
    T("brickcolor.rgb.336", function() local c = BrickColor.new(336).Color; return NEARV({c.R, c.G, c.B}, {199/255, 212/255, 228/255}, 1e-6) end)
    T("brickcolor.number_field.336", function() return EQ(BrickColor.new(336).Number, 336) end)
    T("brickcolor.name_to_number.336", function() return EQ(BrickColor.new("Fog").Number, 336) end)
    T("brickcolor.nearest_self.336", function() return EQ(BrickColor.new(Color3.fromRGB(199, 212, 228)).Number, 336) end)
    T("brickcolor.palette.76", function() return EQ(BrickColor.palette(76).Number, 336) end)
end
do
    T("brickcolor.number_to_name.337", function() return EQ(BrickColor.new(337).Name, "Salmon") end)
    T("brickcolor.tostring.337", function() return EQ(tostring(BrickColor.new(337)), "Salmon") end)
    T("brickcolor.rgb.337", function() local c = BrickColor.new(337).Color; return NEARV({c.R, c.G, c.B}, {255/255, 148/255, 148/255}, 1e-6) end)
    T("brickcolor.number_field.337", function() return EQ(BrickColor.new(337).Number, 337) end)
    T("brickcolor.name_to_number.337", function() return EQ(BrickColor.new("Salmon").Number, 337) end)
    T("brickcolor.nearest_self.337", function() return EQ(BrickColor.new(Color3.fromRGB(255, 148, 148)).Number, 337) end)
    T("brickcolor.palette.90", function() return EQ(BrickColor.palette(90).Number, 337) end)
end
do
    T("brickcolor.number_to_name.338", function() return EQ(BrickColor.new(338).Name, "Terra Cotta") end)
    T("brickcolor.tostring.338", function() return EQ(tostring(BrickColor.new(338)), "Terra Cotta") end)
    T("brickcolor.rgb.338", function() local c = BrickColor.new(338).Color; return NEARV({c.R, c.G, c.B}, {190/255, 104/255, 98/255}, 1e-6) end)
    T("brickcolor.number_field.338", function() return EQ(BrickColor.new(338).Number, 338) end)
    T("brickcolor.name_to_number.338", function() return EQ(BrickColor.new("Terra Cotta").Number, 338) end)
    T("brickcolor.nearest_self.338", function() return EQ(BrickColor.new(Color3.fromRGB(190, 104, 98)).Number, 338) end)
    T("brickcolor.palette.79", function() return EQ(BrickColor.palette(79).Number, 338) end)
end
do
    T("brickcolor.number_to_name.339", function() return EQ(BrickColor.new(339).Name, "Cocoa") end)
    T("brickcolor.tostring.339", function() return EQ(tostring(BrickColor.new(339)), "Cocoa") end)
    T("brickcolor.rgb.339", function() local c = BrickColor.new(339).Color; return NEARV({c.R, c.G, c.B}, {86/255, 36/255, 36/255}, 1e-6) end)
    T("brickcolor.number_field.339", function() return EQ(BrickColor.new(339).Number, 339) end)
    T("brickcolor.name_to_number.339", function() return EQ(BrickColor.new("Cocoa").Number, 339) end)
    T("brickcolor.nearest_self.339", function() return EQ(BrickColor.new(Color3.fromRGB(86, 36, 36)).Number, 339) end)
    T("brickcolor.palette.81", function() return EQ(BrickColor.palette(81).Number, 339) end)
end
do
    T("brickcolor.number_to_name.340", function() return EQ(BrickColor.new(340).Name, "Wheat") end)
    T("brickcolor.tostring.340", function() return EQ(tostring(BrickColor.new(340)), "Wheat") end)
    T("brickcolor.rgb.340", function() local c = BrickColor.new(340).Color; return NEARV({c.R, c.G, c.B}, {241/255, 231/255, 199/255}, 1e-6) end)
    T("brickcolor.number_field.340", function() return EQ(BrickColor.new(340).Number, 340) end)
    T("brickcolor.name_to_number.340", function() return EQ(BrickColor.new("Wheat").Number, 340) end)
    T("brickcolor.nearest_self.340", function() return EQ(BrickColor.new(Color3.fromRGB(241, 231, 199)).Number, 340) end)
    T("brickcolor.palette.84", function() return EQ(BrickColor.palette(84).Number, 340) end)
end
do
    T("brickcolor.number_to_name.341", function() return EQ(BrickColor.new(341).Name, "Buttermilk") end)
    T("brickcolor.tostring.341", function() return EQ(tostring(BrickColor.new(341)), "Buttermilk") end)
    T("brickcolor.rgb.341", function() local c = BrickColor.new(341).Color; return NEARV({c.R, c.G, c.B}, {254/255, 243/255, 187/255}, 1e-6) end)
    T("brickcolor.number_field.341", function() return EQ(BrickColor.new(341).Number, 341) end)
    T("brickcolor.name_to_number.341", function() return EQ(BrickColor.new("Buttermilk").Number, 341) end)
    T("brickcolor.nearest_self.341", function() return EQ(BrickColor.new(Color3.fromRGB(254, 243, 187)).Number, 341) end)
    T("brickcolor.palette.85", function() return EQ(BrickColor.palette(85).Number, 341) end)
end
do
    T("brickcolor.number_to_name.342", function() return EQ(BrickColor.new(342).Name, "Mauve") end)
    T("brickcolor.tostring.342", function() return EQ(tostring(BrickColor.new(342)), "Mauve") end)
    T("brickcolor.rgb.342", function() local c = BrickColor.new(342).Color; return NEARV({c.R, c.G, c.B}, {224/255, 178/255, 208/255}, 1e-6) end)
    T("brickcolor.number_field.342", function() return EQ(BrickColor.new(342).Number, 342) end)
    T("brickcolor.name_to_number.342", function() return EQ(BrickColor.new("Mauve").Number, 342) end)
    T("brickcolor.nearest_self.342", function() return EQ(BrickColor.new(Color3.fromRGB(224, 178, 208)).Number, 342) end)
    T("brickcolor.palette.77", function() return EQ(BrickColor.palette(77).Number, 342) end)
end
do
    T("brickcolor.number_to_name.343", function() return EQ(BrickColor.new(343).Name, "Sunrise") end)
    T("brickcolor.tostring.343", function() return EQ(tostring(BrickColor.new(343)), "Sunrise") end)
    T("brickcolor.rgb.343", function() local c = BrickColor.new(343).Color; return NEARV({c.R, c.G, c.B}, {212/255, 144/255, 189/255}, 1e-6) end)
    T("brickcolor.number_field.343", function() return EQ(BrickColor.new(343).Number, 343) end)
    T("brickcolor.name_to_number.343", function() return EQ(BrickColor.new("Sunrise").Number, 343) end)
    T("brickcolor.nearest_self.343", function() return EQ(BrickColor.new(Color3.fromRGB(212, 144, 189)).Number, 343) end)
    T("brickcolor.palette.78", function() return EQ(BrickColor.palette(78).Number, 343) end)
end
do
    T("brickcolor.number_to_name.344", function() return EQ(BrickColor.new(344).Name, "Tawny") end)
    T("brickcolor.tostring.344", function() return EQ(tostring(BrickColor.new(344)), "Tawny") end)
    T("brickcolor.rgb.344", function() local c = BrickColor.new(344).Color; return NEARV({c.R, c.G, c.B}, {150/255, 85/255, 85/255}, 1e-6) end)
    T("brickcolor.number_field.344", function() return EQ(BrickColor.new(344).Number, 344) end)
    T("brickcolor.name_to_number.344", function() return EQ(BrickColor.new("Tawny").Number, 344) end)
    T("brickcolor.nearest_self.344", function() return EQ(BrickColor.new(Color3.fromRGB(150, 85, 85)).Number, 344) end)
    T("brickcolor.palette.91", function() return EQ(BrickColor.palette(91).Number, 344) end)
end
do
    T("brickcolor.number_to_name.345", function() return EQ(BrickColor.new(345).Name, "Rust") end)
    T("brickcolor.tostring.345", function() return EQ(tostring(BrickColor.new(345)), "Rust") end)
    T("brickcolor.rgb.345", function() local c = BrickColor.new(345).Color; return NEARV({c.R, c.G, c.B}, {143/255, 76/255, 42/255}, 1e-6) end)
    T("brickcolor.number_field.345", function() return EQ(BrickColor.new(345).Number, 345) end)
    T("brickcolor.nearest_self.345", function() return EQ(BrickColor.new(Color3.fromRGB(143, 76, 42)).Number, 345) end)
    T("brickcolor.palette.92", function() return EQ(BrickColor.palette(92).Number, 345) end)
end
do
    T("brickcolor.number_to_name.346", function() return EQ(BrickColor.new(346).Name, "Cashmere") end)
    T("brickcolor.tostring.346", function() return EQ(tostring(BrickColor.new(346)), "Cashmere") end)
    T("brickcolor.rgb.346", function() local c = BrickColor.new(346).Color; return NEARV({c.R, c.G, c.B}, {211/255, 190/255, 150/255}, 1e-6) end)
    T("brickcolor.number_field.346", function() return EQ(BrickColor.new(346).Number, 346) end)
    T("brickcolor.name_to_number.346", function() return EQ(BrickColor.new("Cashmere").Number, 346) end)
    T("brickcolor.nearest_self.346", function() return EQ(BrickColor.new(Color3.fromRGB(211, 190, 150)).Number, 346) end)
    T("brickcolor.palette.95", function() return EQ(BrickColor.palette(95).Number, 346) end)
end
do
    T("brickcolor.number_to_name.347", function() return EQ(BrickColor.new(347).Name, "Khaki") end)
    T("brickcolor.tostring.347", function() return EQ(tostring(BrickColor.new(347)), "Khaki") end)
    T("brickcolor.rgb.347", function() local c = BrickColor.new(347).Color; return NEARV({c.R, c.G, c.B}, {226/255, 220/255, 188/255}, 1e-6) end)
    T("brickcolor.number_field.347", function() return EQ(BrickColor.new(347).Number, 347) end)
    T("brickcolor.name_to_number.347", function() return EQ(BrickColor.new("Khaki").Number, 347) end)
    T("brickcolor.nearest_self.347", function() return EQ(BrickColor.new(Color3.fromRGB(226, 220, 188)).Number, 347) end)
    T("brickcolor.palette.96", function() return EQ(BrickColor.palette(96).Number, 347) end)
end
do
    T("brickcolor.number_to_name.348", function() return EQ(BrickColor.new(348).Name, "Lily white") end)
    T("brickcolor.tostring.348", function() return EQ(tostring(BrickColor.new(348)), "Lily white") end)
    T("brickcolor.rgb.348", function() local c = BrickColor.new(348).Color; return NEARV({c.R, c.G, c.B}, {237/255, 234/255, 234/255}, 1e-6) end)
    T("brickcolor.number_field.348", function() return EQ(BrickColor.new(348).Number, 348) end)
    T("brickcolor.name_to_number.348", function() return EQ(BrickColor.new("Lily white").Number, 348) end)
    T("brickcolor.nearest_self.348", function() return EQ(BrickColor.new(Color3.fromRGB(237, 234, 234)).Number, 348) end)
    T("brickcolor.palette.97", function() return EQ(BrickColor.palette(97).Number, 348) end)
end
do
    T("brickcolor.number_to_name.349", function() return EQ(BrickColor.new(349).Name, "Seashell") end)
    T("brickcolor.tostring.349", function() return EQ(tostring(BrickColor.new(349)), "Seashell") end)
    T("brickcolor.rgb.349", function() local c = BrickColor.new(349).Color; return NEARV({c.R, c.G, c.B}, {233/255, 218/255, 218/255}, 1e-6) end)
    T("brickcolor.number_field.349", function() return EQ(BrickColor.new(349).Number, 349) end)
    T("brickcolor.name_to_number.349", function() return EQ(BrickColor.new("Seashell").Number, 349) end)
    T("brickcolor.nearest_self.349", function() return EQ(BrickColor.new(Color3.fromRGB(233, 218, 218)).Number, 349) end)
    T("brickcolor.palette.98", function() return EQ(BrickColor.palette(98).Number, 349) end)
end
do
    T("brickcolor.number_to_name.350", function() return EQ(BrickColor.new(350).Name, "Burgundy") end)
    T("brickcolor.tostring.350", function() return EQ(tostring(BrickColor.new(350)), "Burgundy") end)
    T("brickcolor.rgb.350", function() local c = BrickColor.new(350).Color; return NEARV({c.R, c.G, c.B}, {136/255, 62/255, 62/255}, 1e-6) end)
    T("brickcolor.number_field.350", function() return EQ(BrickColor.new(350).Number, 350) end)
    T("brickcolor.name_to_number.350", function() return EQ(BrickColor.new("Burgundy").Number, 350) end)
    T("brickcolor.nearest_self.350", function() return EQ(BrickColor.new(Color3.fromRGB(136, 62, 62)).Number, 350) end)
    T("brickcolor.palette.102", function() return EQ(BrickColor.palette(102).Number, 350) end)
end
do
    T("brickcolor.number_to_name.351", function() return EQ(BrickColor.new(351).Name, "Cork") end)
    T("brickcolor.tostring.351", function() return EQ(tostring(BrickColor.new(351)), "Cork") end)
    T("brickcolor.rgb.351", function() local c = BrickColor.new(351).Color; return NEARV({c.R, c.G, c.B}, {188/255, 155/255, 93/255}, 1e-6) end)
    T("brickcolor.number_field.351", function() return EQ(BrickColor.new(351).Number, 351) end)
    T("brickcolor.name_to_number.351", function() return EQ(BrickColor.new("Cork").Number, 351) end)
    T("brickcolor.nearest_self.351", function() return EQ(BrickColor.new(Color3.fromRGB(188, 155, 93)).Number, 351) end)
    T("brickcolor.palette.104", function() return EQ(BrickColor.palette(104).Number, 351) end)
end
do
    T("brickcolor.number_to_name.352", function() return EQ(BrickColor.new(352).Name, "Burlap") end)
    T("brickcolor.tostring.352", function() return EQ(tostring(BrickColor.new(352)), "Burlap") end)
    T("brickcolor.rgb.352", function() local c = BrickColor.new(352).Color; return NEARV({c.R, c.G, c.B}, {199/255, 172/255, 120/255}, 1e-6) end)
    T("brickcolor.number_field.352", function() return EQ(BrickColor.new(352).Number, 352) end)
    T("brickcolor.name_to_number.352", function() return EQ(BrickColor.new("Burlap").Number, 352) end)
    T("brickcolor.nearest_self.352", function() return EQ(BrickColor.new(Color3.fromRGB(199, 172, 120)).Number, 352) end)
    T("brickcolor.palette.105", function() return EQ(BrickColor.palette(105).Number, 352) end)
end
do
    T("brickcolor.number_to_name.353", function() return EQ(BrickColor.new(353).Name, "Beige") end)
    T("brickcolor.tostring.353", function() return EQ(tostring(BrickColor.new(353)), "Beige") end)
    T("brickcolor.rgb.353", function() local c = BrickColor.new(353).Color; return NEARV({c.R, c.G, c.B}, {202/255, 191/255, 163/255}, 1e-6) end)
    T("brickcolor.number_field.353", function() return EQ(BrickColor.new(353).Number, 353) end)
    T("brickcolor.name_to_number.353", function() return EQ(BrickColor.new("Beige").Number, 353) end)
    T("brickcolor.nearest_self.353", function() return EQ(BrickColor.new(Color3.fromRGB(202, 191, 163)).Number, 353) end)
    T("brickcolor.palette.106", function() return EQ(BrickColor.palette(106).Number, 353) end)
end
do
    T("brickcolor.number_to_name.354", function() return EQ(BrickColor.new(354).Name, "Oyster") end)
    T("brickcolor.tostring.354", function() return EQ(tostring(BrickColor.new(354)), "Oyster") end)
    T("brickcolor.rgb.354", function() local c = BrickColor.new(354).Color; return NEARV({c.R, c.G, c.B}, {187/255, 179/255, 178/255}, 1e-6) end)
    T("brickcolor.number_field.354", function() return EQ(BrickColor.new(354).Number, 354) end)
    T("brickcolor.name_to_number.354", function() return EQ(BrickColor.new("Oyster").Number, 354) end)
    T("brickcolor.nearest_self.354", function() return EQ(BrickColor.new(Color3.fromRGB(187, 179, 178)).Number, 354) end)
    T("brickcolor.palette.107", function() return EQ(BrickColor.palette(107).Number, 354) end)
end
do
    T("brickcolor.number_to_name.355", function() return EQ(BrickColor.new(355).Name, "Pine Cone") end)
    T("brickcolor.tostring.355", function() return EQ(tostring(BrickColor.new(355)), "Pine Cone") end)
    T("brickcolor.rgb.355", function() local c = BrickColor.new(355).Color; return NEARV({c.R, c.G, c.B}, {108/255, 88/255, 75/255}, 1e-6) end)
    T("brickcolor.number_field.355", function() return EQ(BrickColor.new(355).Number, 355) end)
    T("brickcolor.name_to_number.355", function() return EQ(BrickColor.new("Pine Cone").Number, 355) end)
    T("brickcolor.nearest_self.355", function() return EQ(BrickColor.new(Color3.fromRGB(108, 88, 75)).Number, 355) end)
    T("brickcolor.palette.112", function() return EQ(BrickColor.palette(112).Number, 355) end)
end
do
    T("brickcolor.number_to_name.356", function() return EQ(BrickColor.new(356).Name, "Fawn brown") end)
    T("brickcolor.tostring.356", function() return EQ(tostring(BrickColor.new(356)), "Fawn brown") end)
    T("brickcolor.rgb.356", function() local c = BrickColor.new(356).Color; return NEARV({c.R, c.G, c.B}, {160/255, 132/255, 79/255}, 1e-6) end)
    T("brickcolor.number_field.356", function() return EQ(BrickColor.new(356).Number, 356) end)
    T("brickcolor.name_to_number.356", function() return EQ(BrickColor.new("Fawn brown").Number, 356) end)
    T("brickcolor.nearest_self.356", function() return EQ(BrickColor.new(Color3.fromRGB(160, 132, 79)).Number, 356) end)
    T("brickcolor.palette.113", function() return EQ(BrickColor.palette(113).Number, 356) end)
end
do
    T("brickcolor.number_to_name.357", function() return EQ(BrickColor.new(357).Name, "Hurricane grey") end)
    T("brickcolor.tostring.357", function() return EQ(tostring(BrickColor.new(357)), "Hurricane grey") end)
    T("brickcolor.rgb.357", function() local c = BrickColor.new(357).Color; return NEARV({c.R, c.G, c.B}, {149/255, 137/255, 136/255}, 1e-6) end)
    T("brickcolor.number_field.357", function() return EQ(BrickColor.new(357).Number, 357) end)
    T("brickcolor.name_to_number.357", function() return EQ(BrickColor.new("Hurricane grey").Number, 357) end)
    T("brickcolor.nearest_self.357", function() return EQ(BrickColor.new(Color3.fromRGB(149, 137, 136)).Number, 357) end)
    T("brickcolor.palette.115", function() return EQ(BrickColor.palette(115).Number, 357) end)
end
do
    T("brickcolor.number_to_name.358", function() return EQ(BrickColor.new(358).Name, "Cloudy grey") end)
    T("brickcolor.tostring.358", function() return EQ(tostring(BrickColor.new(358)), "Cloudy grey") end)
    T("brickcolor.rgb.358", function() local c = BrickColor.new(358).Color; return NEARV({c.R, c.G, c.B}, {171/255, 168/255, 158/255}, 1e-6) end)
    T("brickcolor.number_field.358", function() return EQ(BrickColor.new(358).Number, 358) end)
    T("brickcolor.name_to_number.358", function() return EQ(BrickColor.new("Cloudy grey").Number, 358) end)
    T("brickcolor.nearest_self.358", function() return EQ(BrickColor.new(Color3.fromRGB(171, 168, 158)).Number, 358) end)
    T("brickcolor.palette.116", function() return EQ(BrickColor.palette(116).Number, 358) end)
end
do
    T("brickcolor.number_to_name.359", function() return EQ(BrickColor.new(359).Name, "Linen") end)
    T("brickcolor.tostring.359", function() return EQ(tostring(BrickColor.new(359)), "Linen") end)
    T("brickcolor.rgb.359", function() local c = BrickColor.new(359).Color; return NEARV({c.R, c.G, c.B}, {175/255, 148/255, 131/255}, 1e-6) end)
    T("brickcolor.number_field.359", function() return EQ(BrickColor.new(359).Number, 359) end)
    T("brickcolor.name_to_number.359", function() return EQ(BrickColor.new("Linen").Number, 359) end)
    T("brickcolor.nearest_self.359", function() return EQ(BrickColor.new(Color3.fromRGB(175, 148, 131)).Number, 359) end)
    T("brickcolor.palette.117", function() return EQ(BrickColor.palette(117).Number, 359) end)
end
do
    T("brickcolor.number_to_name.360", function() return EQ(BrickColor.new(360).Name, "Copper") end)
    T("brickcolor.tostring.360", function() return EQ(tostring(BrickColor.new(360)), "Copper") end)
    T("brickcolor.rgb.360", function() local c = BrickColor.new(360).Color; return NEARV({c.R, c.G, c.B}, {150/255, 103/255, 102/255}, 1e-6) end)
    T("brickcolor.number_field.360", function() return EQ(BrickColor.new(360).Number, 360) end)
    T("brickcolor.name_to_number.360", function() return EQ(BrickColor.new("Copper").Number, 360) end)
    T("brickcolor.nearest_self.360", function() return EQ(BrickColor.new(Color3.fromRGB(150, 103, 102)).Number, 360) end)
    T("brickcolor.palette.118", function() return EQ(BrickColor.palette(118).Number, 360) end)
end
do
    T("brickcolor.number_to_name.361", function() return EQ(BrickColor.new(361).Name, "Medium brown") end)
    T("brickcolor.tostring.361", function() return EQ(tostring(BrickColor.new(361)), "Medium brown") end)
    T("brickcolor.rgb.361", function() local c = BrickColor.new(361).Color; return NEARV({c.R, c.G, c.B}, {86/255, 66/255, 54/255}, 1e-6) end)
    T("brickcolor.number_field.361", function() return EQ(BrickColor.new(361).Number, 361) end)
    T("brickcolor.name_to_number.361", function() return EQ(BrickColor.new("Medium brown").Number, 361) end)
    T("brickcolor.nearest_self.361", function() return EQ(BrickColor.new(Color3.fromRGB(86, 66, 54)).Number, 361) end)
    T("brickcolor.palette.120", function() return EQ(BrickColor.palette(120).Number, 361) end)
end
do
    T("brickcolor.number_to_name.362", function() return EQ(BrickColor.new(362).Name, "Bronze") end)
    T("brickcolor.tostring.362", function() return EQ(tostring(BrickColor.new(362)), "Bronze") end)
    T("brickcolor.rgb.362", function() local c = BrickColor.new(362).Color; return NEARV({c.R, c.G, c.B}, {126/255, 104/255, 63/255}, 1e-6) end)
    T("brickcolor.number_field.362", function() return EQ(BrickColor.new(362).Number, 362) end)
    T("brickcolor.name_to_number.362", function() return EQ(BrickColor.new("Bronze").Number, 362) end)
    T("brickcolor.nearest_self.362", function() return EQ(BrickColor.new(Color3.fromRGB(126, 104, 63)).Number, 362) end)
    T("brickcolor.palette.121", function() return EQ(BrickColor.palette(121).Number, 362) end)
end
do
    T("brickcolor.number_to_name.363", function() return EQ(BrickColor.new(363).Name, "Flint") end)
    T("brickcolor.tostring.363", function() return EQ(tostring(BrickColor.new(363)), "Flint") end)
    T("brickcolor.rgb.363", function() local c = BrickColor.new(363).Color; return NEARV({c.R, c.G, c.B}, {105/255, 102/255, 92/255}, 1e-6) end)
    T("brickcolor.number_field.363", function() return EQ(BrickColor.new(363).Number, 363) end)
    T("brickcolor.name_to_number.363", function() return EQ(BrickColor.new("Flint").Number, 363) end)
    T("brickcolor.nearest_self.363", function() return EQ(BrickColor.new(Color3.fromRGB(105, 102, 92)).Number, 363) end)
    T("brickcolor.palette.124", function() return EQ(BrickColor.palette(124).Number, 363) end)
end
do
    T("brickcolor.number_to_name.364", function() return EQ(BrickColor.new(364).Name, "Dark taupe") end)
    T("brickcolor.tostring.364", function() return EQ(tostring(BrickColor.new(364)), "Dark taupe") end)
    T("brickcolor.rgb.364", function() local c = BrickColor.new(364).Color; return NEARV({c.R, c.G, c.B}, {90/255, 76/255, 66/255}, 1e-6) end)
    T("brickcolor.number_field.364", function() return EQ(BrickColor.new(364).Number, 364) end)
    T("brickcolor.name_to_number.364", function() return EQ(BrickColor.new("Dark taupe").Number, 364) end)
    T("brickcolor.nearest_self.364", function() return EQ(BrickColor.new(Color3.fromRGB(90, 76, 66)).Number, 364) end)
    T("brickcolor.palette.125", function() return EQ(BrickColor.palette(125).Number, 364) end)
end
do
    T("brickcolor.number_to_name.365", function() return EQ(BrickColor.new(365).Name, "Burnt Sienna") end)
    T("brickcolor.tostring.365", function() return EQ(tostring(BrickColor.new(365)), "Burnt Sienna") end)
    T("brickcolor.rgb.365", function() local c = BrickColor.new(365).Color; return NEARV({c.R, c.G, c.B}, {106/255, 57/255, 9/255}, 1e-6) end)
    T("brickcolor.number_field.365", function() return EQ(BrickColor.new(365).Number, 365) end)
    T("brickcolor.name_to_number.365", function() return EQ(BrickColor.new("Burnt Sienna").Number, 365) end)
    T("brickcolor.nearest_self.365", function() return EQ(BrickColor.new(Color3.fromRGB(106, 57, 9)).Number, 365) end)
    T("brickcolor.palette.126", function() return EQ(BrickColor.palette(126).Number, 365) end)
end
do
    T("brickcolor.number_to_name.1001", function() return EQ(BrickColor.new(1001).Name, "Institutional white") end)
    T("brickcolor.tostring.1001", function() return EQ(tostring(BrickColor.new(1001)), "Institutional white") end)
    T("brickcolor.rgb.1001", function() local c = BrickColor.new(1001).Color; return NEARV({c.R, c.G, c.B}, {248/255, 248/255, 248/255}, 1e-6) end)
    T("brickcolor.number_field.1001", function() return EQ(BrickColor.new(1001).Number, 1001) end)
    T("brickcolor.name_to_number.1001", function() return EQ(BrickColor.new("Institutional white").Number, 1001) end)
    T("brickcolor.nearest_self.1001", function() return EQ(BrickColor.new(Color3.fromRGB(248, 248, 248)).Number, 1001) end)
    T("brickcolor.palette.86", function() return EQ(BrickColor.palette(86).Number, 1001) end)
end
do
    T("brickcolor.number_to_name.1002", function() return EQ(BrickColor.new(1002).Name, "Mid gray") end)
    T("brickcolor.tostring.1002", function() return EQ(tostring(BrickColor.new(1002)), "Mid gray") end)
    T("brickcolor.rgb.1002", function() local c = BrickColor.new(1002).Color; return NEARV({c.R, c.G, c.B}, {205/255, 205/255, 205/255}, 1e-6) end)
    T("brickcolor.number_field.1002", function() return EQ(BrickColor.new(1002).Number, 1002) end)
    T("brickcolor.name_to_number.1002", function() return EQ(BrickColor.new("Mid gray").Number, 1002) end)
    T("brickcolor.nearest_self.1002", function() return EQ(BrickColor.new(Color3.fromRGB(205, 205, 205)).Number, 1002) end)
    T("brickcolor.palette.108", function() return EQ(BrickColor.palette(108).Number, 1002) end)
end
do
    T("brickcolor.number_to_name.1003", function() return EQ(BrickColor.new(1003).Name, "Really black") end)
    T("brickcolor.tostring.1003", function() return EQ(tostring(BrickColor.new(1003)), "Really black") end)
    T("brickcolor.rgb.1003", function() local c = BrickColor.new(1003).Color; return NEARV({c.R, c.G, c.B}, {17/255, 17/255, 17/255}, 1e-6) end)
    T("brickcolor.number_field.1003", function() return EQ(BrickColor.new(1003).Number, 1003) end)
    T("brickcolor.name_to_number.1003", function() return EQ(BrickColor.new("Really black").Number, 1003) end)
    T("brickcolor.nearest_self.1003", function() return EQ(BrickColor.new(Color3.fromRGB(17, 17, 17)).Number, 1003) end)
    T("brickcolor.palette.127", function() return EQ(BrickColor.palette(127).Number, 1003) end)
end
do
    T("brickcolor.number_to_name.1004", function() return EQ(BrickColor.new(1004).Name, "Really red") end)
    T("brickcolor.tostring.1004", function() return EQ(tostring(BrickColor.new(1004)), "Really red") end)
    T("brickcolor.rgb.1004", function() local c = BrickColor.new(1004).Color; return NEARV({c.R, c.G, c.B}, {255/255, 0/255, 0/255}, 1e-6) end)
    T("brickcolor.number_field.1004", function() return EQ(BrickColor.new(1004).Number, 1004) end)
    T("brickcolor.name_to_number.1004", function() return EQ(BrickColor.new("Really red").Number, 1004) end)
    T("brickcolor.nearest_self.1004", function() return EQ(BrickColor.new(Color3.fromRGB(255, 0, 0)).Number, 1004) end)
    T("brickcolor.palette.67", function() return EQ(BrickColor.palette(67).Number, 1004) end)
end
do
    T("brickcolor.number_to_name.1005", function() return EQ(BrickColor.new(1005).Name, "Deep orange") end)
    T("brickcolor.tostring.1005", function() return EQ(tostring(BrickColor.new(1005)), "Deep orange") end)
    T("brickcolor.rgb.1005", function() local c = BrickColor.new(1005).Color; return NEARV({c.R, c.G, c.B}, {255/255, 176/255, 0/255}, 1e-6) end)
    T("brickcolor.number_field.1005", function() return EQ(BrickColor.new(1005).Number, 1005) end)
    T("brickcolor.nearest_self.1005", function() return EQ(BrickColor.new(Color3.fromRGB(255, 176, 0)).Number, 1005) end)
    T("brickcolor.palette.57", function() return EQ(BrickColor.palette(57).Number, 1005) end)
end
do
    T("brickcolor.number_to_name.1006", function() return EQ(BrickColor.new(1006).Name, "Alder") end)
    T("brickcolor.tostring.1006", function() return EQ(tostring(BrickColor.new(1006)), "Alder") end)
    T("brickcolor.rgb.1006", function() local c = BrickColor.new(1006).Color; return NEARV({c.R, c.G, c.B}, {180/255, 128/255, 255/255}, 1e-6) end)
    T("brickcolor.number_field.1006", function() return EQ(BrickColor.new(1006).Number, 1006) end)
    T("brickcolor.name_to_number.1006", function() return EQ(BrickColor.new("Alder").Number, 1006) end)
    T("brickcolor.nearest_self.1006", function() return EQ(BrickColor.new(Color3.fromRGB(180, 128, 255)).Number, 1006) end)
    T("brickcolor.palette.41", function() return EQ(BrickColor.palette(41).Number, 1006) end)
end
do
    T("brickcolor.number_to_name.1007", function() return EQ(BrickColor.new(1007).Name, "Dusty Rose") end)
    T("brickcolor.tostring.1007", function() return EQ(tostring(BrickColor.new(1007)), "Dusty Rose") end)
    T("brickcolor.rgb.1007", function() local c = BrickColor.new(1007).Color; return NEARV({c.R, c.G, c.B}, {163/255, 75/255, 75/255}, 1e-6) end)
    T("brickcolor.number_field.1007", function() return EQ(BrickColor.new(1007).Number, 1007) end)
    T("brickcolor.name_to_number.1007", function() return EQ(BrickColor.new("Dusty Rose").Number, 1007) end)
    T("brickcolor.nearest_self.1007", function() return EQ(BrickColor.new(Color3.fromRGB(163, 75, 75)).Number, 1007) end)
    T("brickcolor.palette.80", function() return EQ(BrickColor.palette(80).Number, 1007) end)
end
do
    T("brickcolor.number_to_name.1008", function() return EQ(BrickColor.new(1008).Name, "Olive") end)
    T("brickcolor.tostring.1008", function() return EQ(tostring(BrickColor.new(1008)), "Olive") end)
    T("brickcolor.rgb.1008", function() local c = BrickColor.new(1008).Color; return NEARV({c.R, c.G, c.B}, {193/255, 190/255, 66/255}, 1e-6) end)
    T("brickcolor.number_field.1008", function() return EQ(BrickColor.new(1008).Number, 1008) end)
    T("brickcolor.name_to_number.1008", function() return EQ(BrickColor.new("Olive").Number, 1008) end)
    T("brickcolor.nearest_self.1008", function() return EQ(BrickColor.new(Color3.fromRGB(193, 190, 66)).Number, 1008) end)
    T("brickcolor.palette.45", function() return EQ(BrickColor.palette(45).Number, 1008) end)
end
do
    T("brickcolor.number_to_name.1009", function() return EQ(BrickColor.new(1009).Name, "New Yeller") end)
    T("brickcolor.tostring.1009", function() return EQ(tostring(BrickColor.new(1009)), "New Yeller") end)
    T("brickcolor.rgb.1009", function() local c = BrickColor.new(1009).Color; return NEARV({c.R, c.G, c.B}, {255/255, 255/255, 0/255}, 1e-6) end)
    T("brickcolor.number_field.1009", function() return EQ(BrickColor.new(1009).Number, 1009) end)
    T("brickcolor.name_to_number.1009", function() return EQ(BrickColor.new("New Yeller").Number, 1009) end)
    T("brickcolor.nearest_self.1009", function() return EQ(BrickColor.new(Color3.fromRGB(255, 255, 0)).Number, 1009) end)
    T("brickcolor.palette.58", function() return EQ(BrickColor.palette(58).Number, 1009) end)
end
do
    T("brickcolor.number_to_name.1010", function() return EQ(BrickColor.new(1010).Name, "Really blue") end)
    T("brickcolor.tostring.1010", function() return EQ(tostring(BrickColor.new(1010)), "Really blue") end)
    T("brickcolor.rgb.1010", function() local c = BrickColor.new(1010).Color; return NEARV({c.R, c.G, c.B}, {0/255, 0/255, 255/255}, 1e-6) end)
    T("brickcolor.number_field.1010", function() return EQ(BrickColor.new(1010).Number, 1010) end)
    T("brickcolor.name_to_number.1010", function() return EQ(BrickColor.new("Really blue").Number, 1010) end)
    T("brickcolor.nearest_self.1010", function() return EQ(BrickColor.new(Color3.fromRGB(0, 0, 255)).Number, 1010) end)
    T("brickcolor.palette.22", function() return EQ(BrickColor.palette(22).Number, 1010) end)
end
do
    T("brickcolor.number_to_name.1011", function() return EQ(BrickColor.new(1011).Name, "Navy blue") end)
    T("brickcolor.tostring.1011", function() return EQ(tostring(BrickColor.new(1011)), "Navy blue") end)
    T("brickcolor.rgb.1011", function() local c = BrickColor.new(1011).Color; return NEARV({c.R, c.G, c.B}, {0/255, 32/255, 96/255}, 1e-6) end)
    T("brickcolor.number_field.1011", function() return EQ(BrickColor.new(1011).Number, 1011) end)
    T("brickcolor.name_to_number.1011", function() return EQ(BrickColor.new("Navy blue").Number, 1011) end)
    T("brickcolor.nearest_self.1011", function() return EQ(BrickColor.new(Color3.fromRGB(0, 32, 96)).Number, 1011) end)
    T("brickcolor.palette.6", function() return EQ(BrickColor.palette(6).Number, 1011) end)
end
do
    T("brickcolor.number_to_name.1012", function() return EQ(BrickColor.new(1012).Name, "Deep blue") end)
    T("brickcolor.tostring.1012", function() return EQ(tostring(BrickColor.new(1012)), "Deep blue") end)
    T("brickcolor.rgb.1012", function() local c = BrickColor.new(1012).Color; return NEARV({c.R, c.G, c.B}, {33/255, 84/255, 185/255}, 1e-6) end)
    T("brickcolor.number_field.1012", function() return EQ(BrickColor.new(1012).Number, 1012) end)
    T("brickcolor.name_to_number.1012", function() return EQ(BrickColor.new("Deep blue").Number, 1012) end)
    T("brickcolor.nearest_self.1012", function() return EQ(BrickColor.new(Color3.fromRGB(33, 84, 185)).Number, 1012) end)
    T("brickcolor.palette.4", function() return EQ(BrickColor.palette(4).Number, 1012) end)
end
do
    T("brickcolor.number_to_name.1013", function() return EQ(BrickColor.new(1013).Name, "Cyan") end)
    T("brickcolor.tostring.1013", function() return EQ(tostring(BrickColor.new(1013)), "Cyan") end)
    T("brickcolor.rgb.1013", function() local c = BrickColor.new(1013).Color; return NEARV({c.R, c.G, c.B}, {4/255, 175/255, 236/255}, 1e-6) end)
    T("brickcolor.number_field.1013", function() return EQ(BrickColor.new(1013).Number, 1013) end)
    T("brickcolor.name_to_number.1013", function() return EQ(BrickColor.new("Cyan").Number, 1013) end)
    T("brickcolor.nearest_self.1013", function() return EQ(BrickColor.new(Color3.fromRGB(4, 175, 236)).Number, 1013) end)
    T("brickcolor.palette.40", function() return EQ(BrickColor.palette(40).Number, 1013) end)
end
do
    T("brickcolor.number_to_name.1014", function() return EQ(BrickColor.new(1014).Name, "CGA brown") end)
    T("brickcolor.tostring.1014", function() return EQ(tostring(BrickColor.new(1014)), "CGA brown") end)
    T("brickcolor.rgb.1014", function() local c = BrickColor.new(1014).Color; return NEARV({c.R, c.G, c.B}, {170/255, 85/255, 0/255}, 1e-6) end)
    T("brickcolor.number_field.1014", function() return EQ(BrickColor.new(1014).Number, 1014) end)
    T("brickcolor.name_to_number.1014", function() return EQ(BrickColor.new("CGA brown").Number, 1014) end)
    T("brickcolor.nearest_self.1014", function() return EQ(BrickColor.new(Color3.fromRGB(170, 85, 0)).Number, 1014) end)
    T("brickcolor.palette.93", function() return EQ(BrickColor.palette(93).Number, 1014) end)
end
do
    T("brickcolor.number_to_name.1015", function() return EQ(BrickColor.new(1015).Name, "Magenta") end)
    T("brickcolor.tostring.1015", function() return EQ(tostring(BrickColor.new(1015)), "Magenta") end)
    T("brickcolor.rgb.1015", function() local c = BrickColor.new(1015).Color; return NEARV({c.R, c.G, c.B}, {170/255, 0/255, 170/255}, 1e-6) end)
    T("brickcolor.number_field.1015", function() return EQ(BrickColor.new(1015).Number, 1015) end)
    T("brickcolor.name_to_number.1015", function() return EQ(BrickColor.new("Magenta").Number, 1015) end)
    T("brickcolor.nearest_self.1015", function() return EQ(BrickColor.new(Color3.fromRGB(170, 0, 170)).Number, 1015) end)
    T("brickcolor.palette.55", function() return EQ(BrickColor.palette(55).Number, 1015) end)
end
do
    T("brickcolor.number_to_name.1016", function() return EQ(BrickColor.new(1016).Name, "Pink") end)
    T("brickcolor.tostring.1016", function() return EQ(tostring(BrickColor.new(1016)), "Pink") end)
    T("brickcolor.rgb.1016", function() local c = BrickColor.new(1016).Color; return NEARV({c.R, c.G, c.B}, {255/255, 102/255, 204/255}, 1e-6) end)
    T("brickcolor.number_field.1016", function() return EQ(BrickColor.new(1016).Number, 1016) end)
    T("brickcolor.name_to_number.1016", function() return EQ(BrickColor.new("Pink").Number, 1016) end)
    T("brickcolor.nearest_self.1016", function() return EQ(BrickColor.new(Color3.fromRGB(255, 102, 204)).Number, 1016) end)
    T("brickcolor.palette.53", function() return EQ(BrickColor.palette(53).Number, 1016) end)
end
do
    T("brickcolor.number_to_name.1017", function() return EQ(BrickColor.new(1017).Name, "Deep orange") end)
    T("brickcolor.tostring.1017", function() return EQ(tostring(BrickColor.new(1017)), "Deep orange") end)
    T("brickcolor.rgb.1017", function() local c = BrickColor.new(1017).Color; return NEARV({c.R, c.G, c.B}, {255/255, 175/255, 0/255}, 1e-6) end)
    T("brickcolor.number_field.1017", function() return EQ(BrickColor.new(1017).Number, 1017) end)
end
do
    T("brickcolor.number_to_name.1018", function() return EQ(BrickColor.new(1018).Name, "Teal") end)
    T("brickcolor.tostring.1018", function() return EQ(tostring(BrickColor.new(1018)), "Teal") end)
    T("brickcolor.rgb.1018", function() local c = BrickColor.new(1018).Color; return NEARV({c.R, c.G, c.B}, {18/255, 238/255, 212/255}, 1e-6) end)
    T("brickcolor.number_field.1018", function() return EQ(BrickColor.new(1018).Number, 1018) end)
    T("brickcolor.name_to_number.1018", function() return EQ(BrickColor.new("Teal").Number, 1018) end)
    T("brickcolor.nearest_self.1018", function() return EQ(BrickColor.new(Color3.fromRGB(18, 238, 212)).Number, 1018) end)
    T("brickcolor.palette.9", function() return EQ(BrickColor.palette(9).Number, 1018) end)
end
do
    T("brickcolor.number_to_name.1019", function() return EQ(BrickColor.new(1019).Name, "Toothpaste") end)
    T("brickcolor.tostring.1019", function() return EQ(tostring(BrickColor.new(1019)), "Toothpaste") end)
    T("brickcolor.rgb.1019", function() local c = BrickColor.new(1019).Color; return NEARV({c.R, c.G, c.B}, {0/255, 255/255, 255/255}, 1e-6) end)
    T("brickcolor.number_field.1019", function() return EQ(BrickColor.new(1019).Number, 1019) end)
    T("brickcolor.name_to_number.1019", function() return EQ(BrickColor.new("Toothpaste").Number, 1019) end)
    T("brickcolor.nearest_self.1019", function() return EQ(BrickColor.new(Color3.fromRGB(0, 255, 255)).Number, 1019) end)
    T("brickcolor.palette.18", function() return EQ(BrickColor.palette(18).Number, 1019) end)
end
do
    T("brickcolor.number_to_name.1020", function() return EQ(BrickColor.new(1020).Name, "Lime green") end)
    T("brickcolor.tostring.1020", function() return EQ(tostring(BrickColor.new(1020)), "Lime green") end)
    T("brickcolor.rgb.1020", function() local c = BrickColor.new(1020).Color; return NEARV({c.R, c.G, c.B}, {0/255, 255/255, 0/255}, 1e-6) end)
    T("brickcolor.number_field.1020", function() return EQ(BrickColor.new(1020).Number, 1020) end)
    T("brickcolor.name_to_number.1020", function() return EQ(BrickColor.new("Lime green").Number, 1020) end)
    T("brickcolor.nearest_self.1020", function() return EQ(BrickColor.new(Color3.fromRGB(0, 255, 0)).Number, 1020) end)
    T("brickcolor.palette.27", function() return EQ(BrickColor.palette(27).Number, 1020) end)
end
do
    T("brickcolor.number_to_name.1021", function() return EQ(BrickColor.new(1021).Name, "Camo") end)
    T("brickcolor.tostring.1021", function() return EQ(tostring(BrickColor.new(1021)), "Camo") end)
    T("brickcolor.rgb.1021", function() local c = BrickColor.new(1021).Color; return NEARV({c.R, c.G, c.B}, {58/255, 125/255, 21/255}, 1e-6) end)
    T("brickcolor.number_field.1021", function() return EQ(BrickColor.new(1021).Number, 1021) end)
    T("brickcolor.name_to_number.1021", function() return EQ(BrickColor.new("Camo").Number, 1021) end)
    T("brickcolor.nearest_self.1021", function() return EQ(BrickColor.new(Color3.fromRGB(58, 125, 21)).Number, 1021) end)
    T("brickcolor.palette.15", function() return EQ(BrickColor.palette(15).Number, 1021) end)
end
do
    T("brickcolor.number_to_name.1022", function() return EQ(BrickColor.new(1022).Name, "Grime") end)
    T("brickcolor.tostring.1022", function() return EQ(tostring(BrickColor.new(1022)), "Grime") end)
    T("brickcolor.rgb.1022", function() local c = BrickColor.new(1022).Color; return NEARV({c.R, c.G, c.B}, {127/255, 142/255, 100/255}, 1e-6) end)
    T("brickcolor.number_field.1022", function() return EQ(BrickColor.new(1022).Number, 1022) end)
    T("brickcolor.name_to_number.1022", function() return EQ(BrickColor.new("Grime").Number, 1022) end)
    T("brickcolor.nearest_self.1022", function() return EQ(BrickColor.new(Color3.fromRGB(127, 142, 100)).Number, 1022) end)
    T("brickcolor.palette.26", function() return EQ(BrickColor.palette(26).Number, 1022) end)
end
do
    T("brickcolor.number_to_name.1023", function() return EQ(BrickColor.new(1023).Name, "Lavender") end)
    T("brickcolor.tostring.1023", function() return EQ(tostring(BrickColor.new(1023)), "Lavender") end)
    T("brickcolor.rgb.1023", function() local c = BrickColor.new(1023).Color; return NEARV({c.R, c.G, c.B}, {140/255, 91/255, 159/255}, 1e-6) end)
    T("brickcolor.number_field.1023", function() return EQ(BrickColor.new(1023).Number, 1023) end)
    T("brickcolor.name_to_number.1023", function() return EQ(BrickColor.new("Lavender").Number, 1023) end)
    T("brickcolor.nearest_self.1023", function() return EQ(BrickColor.new(Color3.fromRGB(140, 91, 159)).Number, 1023) end)
    T("brickcolor.palette.31", function() return EQ(BrickColor.palette(31).Number, 1023) end)
end
do
    T("brickcolor.number_to_name.1024", function() return EQ(BrickColor.new(1024).Name, "Pastel light blue") end)
    T("brickcolor.tostring.1024", function() return EQ(tostring(BrickColor.new(1024)), "Pastel light blue") end)
    T("brickcolor.rgb.1024", function() local c = BrickColor.new(1024).Color; return NEARV({c.R, c.G, c.B}, {175/255, 221/255, 255/255}, 1e-6) end)
    T("brickcolor.number_field.1024", function() return EQ(BrickColor.new(1024).Number, 1024) end)
    T("brickcolor.name_to_number.1024", function() return EQ(BrickColor.new("Pastel light blue").Number, 1024) end)
    T("brickcolor.nearest_self.1024", function() return EQ(BrickColor.new(Color3.fromRGB(175, 221, 255)).Number, 1024) end)
    T("brickcolor.palette.38", function() return EQ(BrickColor.palette(38).Number, 1024) end)
end
do
    T("brickcolor.number_to_name.1025", function() return EQ(BrickColor.new(1025).Name, "Pastel orange") end)
    T("brickcolor.tostring.1025", function() return EQ(tostring(BrickColor.new(1025)), "Pastel orange") end)
    T("brickcolor.rgb.1025", function() local c = BrickColor.new(1025).Color; return NEARV({c.R, c.G, c.B}, {255/255, 201/255, 201/255}, 1e-6) end)
    T("brickcolor.number_field.1025", function() return EQ(BrickColor.new(1025).Number, 1025) end)
    T("brickcolor.name_to_number.1025", function() return EQ(BrickColor.new("Pastel orange").Number, 1025) end)
    T("brickcolor.nearest_self.1025", function() return EQ(BrickColor.new(Color3.fromRGB(255, 201, 201)).Number, 1025) end)
    T("brickcolor.palette.89", function() return EQ(BrickColor.palette(89).Number, 1025) end)
end
do
    T("brickcolor.number_to_name.1026", function() return EQ(BrickColor.new(1026).Name, "Pastel violet") end)
    T("brickcolor.tostring.1026", function() return EQ(tostring(BrickColor.new(1026)), "Pastel violet") end)
    T("brickcolor.rgb.1026", function() local c = BrickColor.new(1026).Color; return NEARV({c.R, c.G, c.B}, {177/255, 167/255, 255/255}, 1e-6) end)
    T("brickcolor.number_field.1026", function() return EQ(BrickColor.new(1026).Number, 1026) end)
    T("brickcolor.name_to_number.1026", function() return EQ(BrickColor.new("Pastel violet").Number, 1026) end)
    T("brickcolor.nearest_self.1026", function() return EQ(BrickColor.new(Color3.fromRGB(177, 167, 255)).Number, 1026) end)
    T("brickcolor.palette.52", function() return EQ(BrickColor.palette(52).Number, 1026) end)
end
do
    T("brickcolor.number_to_name.1027", function() return EQ(BrickColor.new(1027).Name, "Pastel blue-green") end)
    T("brickcolor.tostring.1027", function() return EQ(tostring(BrickColor.new(1027)), "Pastel blue-green") end)
    T("brickcolor.rgb.1027", function() local c = BrickColor.new(1027).Color; return NEARV({c.R, c.G, c.B}, {159/255, 243/255, 233/255}, 1e-6) end)
    T("brickcolor.number_field.1027", function() return EQ(BrickColor.new(1027).Number, 1027) end)
    T("brickcolor.name_to_number.1027", function() return EQ(BrickColor.new("Pastel blue-green").Number, 1027) end)
    T("brickcolor.nearest_self.1027", function() return EQ(BrickColor.new(Color3.fromRGB(159, 243, 233)).Number, 1027) end)
    T("brickcolor.palette.28", function() return EQ(BrickColor.palette(28).Number, 1027) end)
end
do
    T("brickcolor.number_to_name.1028", function() return EQ(BrickColor.new(1028).Name, "Pastel green") end)
    T("brickcolor.tostring.1028", function() return EQ(tostring(BrickColor.new(1028)), "Pastel green") end)
    T("brickcolor.rgb.1028", function() local c = BrickColor.new(1028).Color; return NEARV({c.R, c.G, c.B}, {204/255, 255/255, 204/255}, 1e-6) end)
    T("brickcolor.number_field.1028", function() return EQ(BrickColor.new(1028).Number, 1028) end)
    T("brickcolor.name_to_number.1028", function() return EQ(BrickColor.new("Pastel green").Number, 1028) end)
    T("brickcolor.nearest_self.1028", function() return EQ(BrickColor.new(Color3.fromRGB(204, 255, 204)).Number, 1028) end)
    T("brickcolor.palette.61", function() return EQ(BrickColor.palette(61).Number, 1028) end)
end
do
    T("brickcolor.number_to_name.1029", function() return EQ(BrickColor.new(1029).Name, "Pastel yellow") end)
    T("brickcolor.tostring.1029", function() return EQ(tostring(BrickColor.new(1029)), "Pastel yellow") end)
    T("brickcolor.rgb.1029", function() local c = BrickColor.new(1029).Color; return NEARV({c.R, c.G, c.B}, {255/255, 255/255, 204/255}, 1e-6) end)
    T("brickcolor.number_field.1029", function() return EQ(BrickColor.new(1029).Number, 1029) end)
    T("brickcolor.name_to_number.1029", function() return EQ(BrickColor.new("Pastel yellow").Number, 1029) end)
    T("brickcolor.nearest_self.1029", function() return EQ(BrickColor.new(Color3.fromRGB(255, 255, 204)).Number, 1029) end)
    T("brickcolor.palette.74", function() return EQ(BrickColor.palette(74).Number, 1029) end)
end
do
    T("brickcolor.number_to_name.1030", function() return EQ(BrickColor.new(1030).Name, "Pastel brown") end)
    T("brickcolor.tostring.1030", function() return EQ(tostring(BrickColor.new(1030)), "Pastel brown") end)
    T("brickcolor.rgb.1030", function() local c = BrickColor.new(1030).Color; return NEARV({c.R, c.G, c.B}, {255/255, 204/255, 153/255}, 1e-6) end)
    T("brickcolor.number_field.1030", function() return EQ(BrickColor.new(1030).Number, 1030) end)
    T("brickcolor.name_to_number.1030", function() return EQ(BrickColor.new("Pastel brown").Number, 1030) end)
    T("brickcolor.nearest_self.1030", function() return EQ(BrickColor.new(Color3.fromRGB(255, 204, 153)).Number, 1030) end)
    T("brickcolor.palette.99", function() return EQ(BrickColor.palette(99).Number, 1030) end)
end
do
    T("brickcolor.number_to_name.1031", function() return EQ(BrickColor.new(1031).Name, "Royal purple") end)
    T("brickcolor.tostring.1031", function() return EQ(tostring(BrickColor.new(1031)), "Royal purple") end)
    T("brickcolor.rgb.1031", function() local c = BrickColor.new(1031).Color; return NEARV({c.R, c.G, c.B}, {98/255, 37/255, 209/255}, 1e-6) end)
    T("brickcolor.number_field.1031", function() return EQ(BrickColor.new(1031).Number, 1031) end)
    T("brickcolor.name_to_number.1031", function() return EQ(BrickColor.new("Royal purple").Number, 1031) end)
    T("brickcolor.nearest_self.1031", function() return EQ(BrickColor.new(Color3.fromRGB(98, 37, 209)).Number, 1031) end)
    T("brickcolor.palette.32", function() return EQ(BrickColor.palette(32).Number, 1031) end)
end
do
    T("brickcolor.number_to_name.1032", function() return EQ(BrickColor.new(1032).Name, "Hot pink") end)
    T("brickcolor.tostring.1032", function() return EQ(tostring(BrickColor.new(1032)), "Hot pink") end)
    T("brickcolor.rgb.1032", function() local c = BrickColor.new(1032).Color; return NEARV({c.R, c.G, c.B}, {255/255, 0/255, 191/255}, 1e-6) end)
    T("brickcolor.number_field.1032", function() return EQ(BrickColor.new(1032).Number, 1032) end)
    T("brickcolor.name_to_number.1032", function() return EQ(BrickColor.new("Hot pink").Number, 1032) end)
    T("brickcolor.nearest_self.1032", function() return EQ(BrickColor.new(Color3.fromRGB(255, 0, 191)).Number, 1032) end)
    T("brickcolor.palette.54", function() return EQ(BrickColor.palette(54).Number, 1032) end)
end
do
    T("brickcolor.palette_out_of_range", function() return ERR(function() return BrickColor.palette(128) end) end)
    T("brickcolor.palette_negative", function() return ERR(function() return BrickColor.palette(-1) end) end)
    T("brickcolor.unknown_number", function() return EQ(BrickColor.new(987654).Name, "Medium stone grey") end)
    T("brickcolor.unknown_name", function() return EQ(BrickColor.new("No such colour zq").Name, "Medium stone grey") end)
    T("brickcolor.random_type", function() return TY(BrickColor.random(), "BrickColor") end)
    T("brickcolor.random_in_palette", function() local palette = {}
        for i = 0, 127 do palette[BrickColor.palette(i).Number] = true end
        for _ = 1, 50 do local b = BrickColor.random(); if not palette[b.Number] then return false, "not in palette: " .. b.Number end end
        return true end)
    T("brickcolor.count_palette_unique", function() local seen, n = {}, 0
        for i = 0, 127 do local num = BrickColor.palette(i).Number; if not seen[num] then seen[num] = true; n += 1 end end
        return EQ(n, 128) end)
end
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
