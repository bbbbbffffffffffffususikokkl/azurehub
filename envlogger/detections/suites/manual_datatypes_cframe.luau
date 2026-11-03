-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "manual_datatypes_cframe"
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

-- CFrame semantics: constructors, rotation conventions, algebra, space conversions.
-- Reference rotation matrices are computed here in double precision (CFrame stores float32,
-- hence the 1e-5 tolerances).
local function V3(...) return Vector3.new(...) end
local function CEQ(cf, comps, eps)
    if typeof(cf) ~= "CFrame" then return false, "expected CFrame got " .. typeof(cf) end
    return NEARV({cf:GetComponents()}, comps, eps or 1e-5)
end
local function V3EQ(v, x, y, z, eps)
    if typeof(v) ~= "Vector3" then return false, "expected Vector3 got " .. typeof(v) end
    return NEARV({v.X, v.Y, v.Z}, {x, y, z}, eps or 1e-5)
end
local function mmul(a, b)
    local r = {}
    for i = 0, 2 do
        for j = 0, 2 do
            r[i * 3 + j + 1] = a[i * 3 + 1] * b[j + 1] + a[i * 3 + 2] * b[j + 4] + a[i * 3 + 3] * b[j + 7]
        end
    end
    return r
end
local function Rx(t) local c, s = math.cos(t), math.sin(t); return {1, 0, 0, 0, c, -s, 0, s, c} end
local function Ry(t) local c, s = math.cos(t), math.sin(t); return {c, 0, s, 0, 1, 0, -s, 0, c} end
local function Rz(t) local c, s = math.cos(t), math.sin(t); return {c, -s, 0, s, c, 0, 0, 0, 1} end
local function comps(px, py, pz, m) return {px, py, pz, m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9]} end
local function CFEQ(a, b, eps) return NEARV({a:GetComponents()}, {b:GetComponents()}, eps or 1e-4) end

T("cf.typeof", function() return TY(CFrame.new(), "CFrame") end)
T("cf.type_userdata", function() return EQ(type(CFrame.new()), "userdata") end)
T("cf.global_table", function() return TY(CFrame, "table") end)
T("cf.metatable_locked", function() return EQ(getmetatable(CFrame.new()), "The metatable is locked") end)
T("cf.identity_const", function() return CEQ(CFrame.identity, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}) end)
T("cf.new_empty", function() return CEQ(CFrame.new(), {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}) end)
T("cf.new_xyz", function() return CEQ(CFrame.new(1, 2, 3), {1, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, 1}) end)
T("cf.new_vector", function() return CEQ(CFrame.new(V3(4, 5, 6)), {4, 5, 6, 1, 0, 0, 0, 1, 0, 0, 0, 1}) end)
T("cf.new_12", function()
    return CEQ(CFrame.new(1, 2, 3, 0, 0, 1, 0, 1, 0, -1, 0, 0), {1, 2, 3, 0, 0, 1, 0, 1, 0, -1, 0, 0})
end)
T("cf.new_quat_identity", function() return CEQ(CFrame.new(0, 0, 0, 0, 0, 0, 1), {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}) end)
T("cf.new_quat_y90", function()
    local s = math.sqrt(0.5)
    return CEQ(CFrame.new(0, 0, 0, 0, s, 0, s), comps(0, 0, 0, Ry(math.pi / 2)))
end)
T("cf.new_lookat_legacy", function()
    local cf = CFrame.new(V3(0, 0, 0), V3(10, 0, 0))
    return V3EQ(cf.LookVector, 1, 0, 0)
end)
T("cf.tostring_int", function() return EQ(tostring(CFrame.new(1, 2, 3)), "1, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, 1") end)
T("cf.tostring_identity", function() return EQ(tostring(CFrame.new()), "0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1") end)
T("cf.f32_position", function() return EQ(CFrame.new(0.1, 0, 0).X, 0.10000000149011612) end)

-- properties
T("cf.Position", function() return V3EQ(CFrame.new(1, 2, 3).Position, 1, 2, 3) end)
T("cf.p_alias", function() return V3EQ(CFrame.new(1, 2, 3).p, 1, 2, 3) end)
T("cf.XYZ", function() local c = CFrame.new(7, 8, 9); A(EQ(c.X, 7)); A(EQ(c.Y, 8)); return EQ(c.Z, 9) end)
T("cf.LookVector_identity", function() return V3EQ(CFrame.new().LookVector, 0, 0, -1) end)
T("cf.RightVector_identity", function() return V3EQ(CFrame.new().RightVector, 1, 0, 0) end)
T("cf.UpVector_identity", function() return V3EQ(CFrame.new().UpVector, 0, 1, 0) end)
T("cf.XVector_identity", function() return V3EQ(CFrame.new().XVector, 1, 0, 0) end)
T("cf.YVector_identity", function() return V3EQ(CFrame.new().YVector, 0, 1, 0) end)
T("cf.ZVector_identity", function() return V3EQ(CFrame.new().ZVector, 0, 0, 1) end)
T("cf.Rotation_drops_position", function() return CEQ((CFrame.new(5, 5, 5) * CFrame.Angles(0, 1, 0)).Rotation, comps(0, 0, 0, Ry(1))) end)
T("cf.immutable", function() return ERR(function() local c = CFrame.new(); c.X = 1 end) end)
T("cf.invalid_member", function() return ERR(function() return CFrame.new().Foo end, "Foo is not a valid member of CFrame") end)

-- rotation conventions
local angles = {{0, 0, 0}, {math.pi / 2, 0, 0}, {0, math.pi / 2, 0}, {0, 0, math.pi / 2}, {0.3, -0.7, 1.1},
    {-1.2, 0.4, 0.9}, {2.5, 1.0, -2.0}, {0.1, 0.2, 0.3}, {math.pi, 0, 0}, {-0.5, -0.5, -0.5}}
for i, a in ipairs(angles) do
    local xyz = mmul(mmul(Rx(a[1]), Ry(a[2])), Rz(a[3]))
    local yxz = mmul(mmul(Ry(a[2]), Rx(a[1])), Rz(a[3]))
    T("cf.Angles." .. i, function() return CEQ(CFrame.Angles(a[1], a[2], a[3]), comps(0, 0, 0, xyz)) end)
    T("cf.fromEulerAnglesXYZ." .. i, function() return CEQ(CFrame.fromEulerAnglesXYZ(a[1], a[2], a[3]), comps(0, 0, 0, xyz)) end)
    T("cf.fromEulerAnglesYXZ." .. i, function() return CEQ(CFrame.fromEulerAnglesYXZ(a[1], a[2], a[3]), comps(0, 0, 0, yxz)) end)
    T("cf.fromOrientation." .. i, function() return CEQ(CFrame.fromOrientation(a[1], a[2], a[3]), comps(0, 0, 0, yxz)) end)
    T("cf.ToEulerAnglesXYZ.roundtrip." .. i, function()
        local cf = CFrame.Angles(a[1], a[2], a[3])
        return CFEQ(CFrame.Angles(cf:ToEulerAnglesXYZ()), cf)
    end)
    T("cf.ToEulerAnglesYXZ.roundtrip." .. i, function()
        local cf = CFrame.fromEulerAnglesYXZ(a[1], a[2], a[3])
        return CFEQ(CFrame.fromEulerAnglesYXZ(cf:ToEulerAnglesYXZ()), cf)
    end)
    T("cf.ToOrientation.roundtrip." .. i, function()
        local cf = CFrame.fromOrientation(a[1], a[2], a[3])
        return CFEQ(CFrame.fromOrientation(cf:ToOrientation()), cf)
    end)
    T("cf.ToAxisAngle.roundtrip." .. i, function()
        local cf = CFrame.Angles(a[1], a[2], a[3])
        local axis, ang = cf:ToAxisAngle()
        if ang == 0 or ang ~= ang then return true end
        return CFEQ(CFrame.fromAxisAngle(axis, ang), cf)
    end)
    T("cf.orthonormal." .. i, function()
        local cf = CFrame.Angles(a[1], a[2], a[3])
        A(NEAR(cf.RightVector:Dot(cf.UpVector), 0, 1e-5)); A(NEAR(cf.RightVector.Magnitude, 1, 1e-5))
        return V3EQ(cf.XVector:Cross(cf.YVector), cf.ZVector.X, cf.ZVector.Y, cf.ZVector.Z)
    end)
    T("cf.lookvector_is_negz." .. i, function()
        local cf = CFrame.Angles(a[1], a[2], a[3])
        return V3EQ(cf.LookVector, -cf.ZVector.X, -cf.ZVector.Y, -cf.ZVector.Z)
    end)
end
T("cf.Angles_y90_look", function() return V3EQ(CFrame.Angles(0, math.rad(90), 0).LookVector, -1, 0, 0) end)
T("cf.Angles_x90_look", function() return V3EQ(CFrame.Angles(math.rad(90), 0, 0).LookVector, 0, 1, 0) end)
T("cf.fromAxisAngle_y", function() return CEQ(CFrame.fromAxisAngle(V3(0, 1, 0), 0.8), comps(0, 0, 0, Ry(0.8))) end)
T("cf.ToAxisAngle_y", function()
    local axis, ang = CFrame.Angles(0, 0.8, 0):ToAxisAngle()
    A(V3EQ(axis, 0, 1, 0)); return NEAR(ang, 0.8, 1e-5)
end)

-- algebra and space conversions
local frames = {
    CFrame.new(1, 2, 3),
    CFrame.new(-4, 5, 6) * CFrame.Angles(0.3, 0.2, 0.1),
    CFrame.new(10, 0, -10) * CFrame.Angles(0, math.pi / 2, 0),
    CFrame.new(0.5, -0.25, 8) * CFrame.Angles(1, -1, 0.5),
    CFrame.new(100, 50, 25) * CFrame.Angles(-2, 0.5, 2),
}
local points = {V3(0, 0, 0), V3(1, 0, 0), V3(3, -4, 5), V3(-10, 2.5, 0.75)}
for i, cf in ipairs(frames) do
    T("cf.inverse_identity." .. i, function() return CFEQ(cf * cf:Inverse(), CFrame.new()) end)
    T("cf.inverse_left." .. i, function() return CFEQ(cf:Inverse() * cf, CFrame.new()) end)
    T("cf.inverse_inverse." .. i, function() return CFEQ(cf:Inverse():Inverse(), cf) end)
    T("cf.lerp0." .. i, function() return CFEQ(cf:Lerp(CFrame.new(9, 9, 9), 0), cf) end)
    T("cf.lerp1." .. i, function() return CFEQ(cf:Lerp(CFrame.new(9, 9, 9), 1), CFrame.new(9, 9, 9)) end)
    T("cf.lerp_pos_half." .. i, function()
        local p = cf:Lerp(CFrame.new(9, 9, 9), 0.5).Position
        local e = (cf.Position + V3(9, 9, 9)) / 2
        return V3EQ(p, e.X, e.Y, e.Z, 1e-4)
    end)
    T("cf.ToWorldSpace." .. i, function() local o = CFrame.new(1, 1, 1) * CFrame.Angles(0, 0.5, 0); return CFEQ(cf:ToWorldSpace(o), cf * o) end)
    T("cf.ToObjectSpace." .. i, function() local o = CFrame.new(1, 1, 1); return CFEQ(cf:ToObjectSpace(o), cf:Inverse() * o) end)
    T("cf.ToObjectSpace_roundtrip." .. i, function() local o = CFrame.new(3, 2, 1); return CFEQ(cf * cf:ToObjectSpace(o), o) end)
    T("cf.add_vector." .. i, function() local r = cf + V3(1, 2, 3); A(CFEQ(r.Rotation, cf.Rotation)); return V3EQ(r.Position, cf.X + 1, cf.Y + 2, cf.Z + 3, 1e-4) end)
    T("cf.sub_vector." .. i, function() local r = cf - V3(1, 2, 3); return V3EQ(r.Position, cf.X - 1, cf.Y - 2, cf.Z - 3, 1e-4) end)
    for j, p in ipairs(points) do
        T(("cf.PointToWorldSpace.%d.%d"):format(i, j), function()
            local w = cf:PointToWorldSpace(p); local e = cf * p
            return V3EQ(w, e.X, e.Y, e.Z, 1e-4)
        end)
        T(("cf.PointToObjectSpace.%d.%d"):format(i, j), function()
            local o = cf:PointToObjectSpace(cf * p)
            return V3EQ(o, p.X, p.Y, p.Z, 1e-4)
        end)
        T(("cf.VectorToWorldSpace.%d.%d"):format(i, j), function()
            local w = cf:VectorToWorldSpace(p); local e = cf.Rotation * p
            return V3EQ(w, e.X, e.Y, e.Z, 1e-4)
        end)
        T(("cf.VectorToObjectSpace.%d.%d"):format(i, j), function()
            local o = cf:VectorToObjectSpace(cf:VectorToWorldSpace(p))
            return V3EQ(o, p.X, p.Y, p.Z, 1e-4)
        end)
        T(("cf.mul_point_manual.%d.%d"):format(i, j), function()
            local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
            local w = cf * p
            return V3EQ(w, x + r00 * p.X + r01 * p.Y + r02 * p.Z, y + r10 * p.X + r11 * p.Y + r12 * p.Z,
                z + r20 * p.X + r21 * p.Y + r22 * p.Z, 1e-4)
        end)
    end
end
T("cf.components_alias", function() return EQ(select("#", CFrame.new():components()), 12) end)
T("cf.GetComponents_count", function() return EQ(select("#", CFrame.new():GetComponents()), 12) end)
T("cf.mul_compose", function() return CFEQ(CFrame.new(1, 0, 0) * CFrame.new(0, 2, 0), CFrame.new(1, 2, 0)) end)
T("cf.mul_rotated_offset", function()
    return V3EQ((CFrame.Angles(0, math.pi / 2, 0) * CFrame.new(0, 0, -5)).Position, -5, 0, 0)
end)
T("cf.eq", function() return EQ(CFrame.new(1, 2, 3) == CFrame.new(1, 2, 3), true) end)
T("cf.ne", function() return EQ(CFrame.new(1, 2, 3) == CFrame.new(1, 2, 4), false) end)
T("cf.not_rawequal", function() return EQ(rawequal(CFrame.new(), CFrame.new()), false) end)
T("cf.lookAt", function()
    local cf = CFrame.lookAt(V3(0, 0, 0), V3(0, 0, 10))
    A(V3EQ(cf.Position, 0, 0, 0)); return V3EQ(cf.LookVector, 0, 0, 1)
end)
T("cf.lookAt_up", function()
    local cf = CFrame.lookAt(V3(1, 1, 1), V3(1, 1, -9))
    A(V3EQ(cf.UpVector, 0, 1, 0)); return V3EQ(cf.RightVector, 1, 0, 0)
end)
T("cf.fromMatrix", function()
    local cf = CFrame.fromMatrix(V3(1, 2, 3), V3(0, 0, -1), V3(0, 1, 0), V3(1, 0, 0))
    A(V3EQ(cf.Position, 1, 2, 3)); A(V3EQ(cf.XVector, 0, 0, -1)); return V3EQ(cf.ZVector, 1, 0, 0)
end)
T("cf.fromMatrix_derived_z", function()
    local cf = CFrame.fromMatrix(V3(), V3(1, 0, 0), V3(0, 1, 0))
    return V3EQ(cf.ZVector, 0, 0, 1)
end)
T("cf.Orthonormalize", function()
    local cf = CFrame.new(0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 1):Orthonormalize()
    return NEAR(cf.RightVector.Magnitude, 1, 1e-5)
end)
T("cf.FuzzyEq", function() return EQ(CFrame.new(1, 2, 3):FuzzyEq(CFrame.new(1, 2, 3.000001)), true) end)
T("cf.mul_number_errors", function() return ERR(function() return CFrame.new() * 2 end) end)
T("cf.add_cframe_errors", function() return ERR(function() return CFrame.new() + CFrame.new() end) end)
T("cf.new_bad_args", function() return ERR(function() return CFrame.new("a", {}, true) end) end)
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
