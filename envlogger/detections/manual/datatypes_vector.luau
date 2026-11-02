-- Vector3 / Vector2 / Vector3int16 / Vector2int16 semantics.
-- Vector3 is Luau's native float32 `vector` value type in Roblox; Vector2 is float32 userdata.
local f32 = function(x) return buffer.readf32((function() local b = buffer.create(4); buffer.writef32(b, 0, x); return b end)(), 0) end
local function V3(...) return Vector3.new(...) end
local function V2(...) return Vector2.new(...) end
local function V3EQ(v, x, y, z, eps)
    if typeof(v) ~= "Vector3" then return false, "expected Vector3 got " .. typeof(v) end
    return NEARV({v.X, v.Y, v.Z}, {x, y, z}, eps or 1e-6)
end
local function V2EQ(v, x, y, eps)
    if typeof(v) ~= "Vector2" then return false, "expected Vector2 got " .. typeof(v) end
    return NEARV({v.X, v.Y}, {x, y}, eps or 1e-6)
end

-- identity / Lua-level type of the value
T("v3.typeof", function() return TY(V3(1, 2, 3), "Vector3") end)
T("v3.type_is_vector", function() return EQ(type(V3(1, 2, 3)), "vector") end)
T("v3.rawequal_value_type", function() return EQ(rawequal(V3(1, 2, 3), V3(1, 2, 3)), true) end)
T("v3.table_key_by_value", function() local t = {}; t[V3(1, 2, 3)] = "k"; return EQ(t[V3(1, 2, 3)], "k") end)
T("v3.global_is_table", function() return TY(Vector3, "table") end)
T("v3.metatable_locked", function() return EQ(getmetatable(V3()), "The metatable is locked") end)
T("v2.typeof", function() return TY(V2(1, 2), "Vector2") end)
T("v2.type_is_userdata", function() return EQ(type(V2(1, 2)), "userdata") end)
T("v2.not_rawequal", function() return EQ(rawequal(V2(1, 2), V2(1, 2)), false) end)
T("v2.eq_by_value", function() return EQ(V2(1, 2) == V2(1, 2), true) end)
T("v2.table_key_by_identity", function() local t = {}; t[V2(1, 2)] = "k"; return EQ(t[V2(1, 2)], nil) end)
T("v2.metatable_locked", function() return EQ(getmetatable(V2()), "The metatable is locked") end)

-- constructors
T("v3.new_empty", function() return V3EQ(V3(), 0, 0, 0) end)
T("v3.new_partial1", function() return V3EQ(V3(5), 5, 0, 0) end)
T("v3.new_partial2", function() return V3EQ(V3(5, 6), 5, 6, 0) end)
T("v3.zero", function() return V3EQ(Vector3.zero, 0, 0, 0) end)
T("v3.one", function() return V3EQ(Vector3.one, 1, 1, 1) end)
T("v3.xAxis", function() return V3EQ(Vector3.xAxis, 1, 0, 0) end)
T("v3.yAxis", function() return V3EQ(Vector3.yAxis, 0, 1, 0) end)
T("v3.zAxis", function() return V3EQ(Vector3.zAxis, 0, 0, 1) end)
local normals = {Right = {1, 0, 0}, Top = {0, 1, 0}, Back = {0, 0, 1}, Left = {-1, 0, 0}, Bottom = {0, -1, 0}, Front = {0, 0, -1}}
for name, e in pairs(normals) do
    T("v3.FromNormalId." .. name, function() return V3EQ(Vector3.FromNormalId(Enum.NormalId[name]), e[1], e[2], e[3]) end)
end
T("v3.FromAxis.X", function() return V3EQ(Vector3.FromAxis(Enum.Axis.X), 1, 0, 0) end)
T("v3.FromAxis.Y", function() return V3EQ(Vector3.FromAxis(Enum.Axis.Y), 0, 1, 0) end)
T("v3.FromAxis.Z", function() return V3EQ(Vector3.FromAxis(Enum.Axis.Z), 0, 0, 1) end)
T("v2.new_empty", function() return V2EQ(V2(), 0, 0) end)
T("v2.new_partial", function() return V2EQ(V2(3), 3, 0) end)
T("v2.zero", function() return V2EQ(Vector2.zero, 0, 0) end)
T("v2.one", function() return V2EQ(Vector2.one, 1, 1) end)
T("v2.xAxis", function() return V2EQ(Vector2.xAxis, 1, 0) end)
T("v2.yAxis", function() return V2EQ(Vector2.yAxis, 0, 1) end)

-- float32 storage
for _, x in ipairs({0.1, 0.2, 0.3, 1.1, 1 / 3, 123.456, -7.77, 1e-3, 16777217, 3.14159265358979}) do
    T("v3.f32_store." .. x, function() return EQ(V3(x, 0, 0).X, f32(x)) end)
    T("v2.f32_store." .. x, function() return EQ(V2(0, x).Y, f32(x)) end)
end
T("v3.f32_overflow", function() return EQ(V3(1e39, 0, 0).X, math.huge) end)
T("v3.f32_neg_overflow", function() return EQ(V3(-1e39, 0, 0).X, -math.huge) end)
T("v3.f32_not_double", function() return EQ(V3(0.1, 0, 0).X == 0.1, false) end)
T("v3.lowercase_components", function() local v = V3(1, 2, 3); A(EQ(v.x, 1)); A(EQ(v.y, 2)); return EQ(v.z, 3) end)

-- properties
T("v3.Magnitude", function() return NEAR(V3(3, 4, 0).Magnitude, 5) end)
T("v3.Magnitude_3d", function() return NEAR(V3(2, 3, 6).Magnitude, 7) end)
T("v3.Unit", function() return V3EQ(V3(3, 4, 0).Unit, 0.6, 0.8, 0) end)
T("v3.Unit_len", function() return NEAR(V3(7, -2, 5).Unit.Magnitude, 1, 1e-5) end)
T("v3.Unit_zero_nan", function() local u = Vector3.zero.Unit; return EQ(u.X ~= u.X, true) end)
T("v2.Magnitude", function() return NEAR(V2(6, 8).Magnitude, 10) end)
T("v2.Unit", function() return V2EQ(V2(0, -5).Unit, 0, -1) end)

-- arithmetic
local samples = {{1, 2, 3}, {-4, 5.5, 0.25}, {10, -10, 2}, {0.5, 0.5, -0.5}, {100, 200, -300}, {7, 0, -1}}
for i, a in ipairs(samples) do
    for j, b in ipairs(samples) do
        if i < j then
            local va, vb = V3(a[1], a[2], a[3]), V3(b[1], b[2], b[3])
            T(("v3.add.%d.%d"):format(i, j), function() return V3EQ(va + vb, a[1] + b[1], a[2] + b[2], a[3] + b[3], 1e-5) end)
            T(("v3.sub.%d.%d"):format(i, j), function() return V3EQ(va - vb, a[1] - b[1], a[2] - b[2], a[3] - b[3], 1e-5) end)
            T(("v3.mul.%d.%d"):format(i, j), function() return V3EQ(va * vb, a[1] * b[1], a[2] * b[2], a[3] * b[3], 1e-5) end)
            T(("v3.dot.%d.%d"):format(i, j), function() return NEAR(va:Dot(vb), a[1] * b[1] + a[2] * b[2] + a[3] * b[3], 1e-5) end)
            T(("v3.cross.%d.%d"):format(i, j), function()
                return V3EQ(va:Cross(vb), a[2] * b[3] - a[3] * b[2], a[3] * b[1] - a[1] * b[3], a[1] * b[2] - a[2] * b[1], 1e-5)
            end)
            T(("v3.lerp.%d.%d"):format(i, j), function()
                return V3EQ(va:Lerp(vb, 0.25), a[1] + (b[1] - a[1]) * 0.25, a[2] + (b[2] - a[2]) * 0.25, a[3] + (b[3] - a[3]) * 0.25, 1e-5)
            end)
            T(("v3.max.%d.%d"):format(i, j), function()
                return V3EQ(va:Max(vb), math.max(a[1], b[1]), math.max(a[2], b[2]), math.max(a[3], b[3]))
            end)
            T(("v3.min.%d.%d"):format(i, j), function()
                return V3EQ(va:Min(vb), math.min(a[1], b[1]), math.min(a[2], b[2]), math.min(a[3], b[3]))
            end)
            local a2, b2 = V2(a[1], a[2]), V2(b[1], b[2])
            T(("v2.add.%d.%d"):format(i, j), function() return V2EQ(a2 + b2, a[1] + b[1], a[2] + b[2], 1e-5) end)
            T(("v2.dot.%d.%d"):format(i, j), function() return NEAR(a2:Dot(b2), a[1] * b[1] + a[2] * b[2], 1e-5) end)
            T(("v2.cross.%d.%d"):format(i, j), function() return NEAR(a2:Cross(b2), a[1] * b[2] - a[2] * b[1], 1e-5) end)
            T(("v2.lerp.%d.%d"):format(i, j), function() return V2EQ(a2:Lerp(b2, 0.5), (a[1] + b[1]) / 2, (a[2] + b[2]) / 2, 1e-5) end)
        end
    end
    local v = V3(a[1], a[2], a[3])
    T(("v3.scale.%d"):format(i), function() return V3EQ(v * 2, a[1] * 2, a[2] * 2, a[3] * 2, 1e-5) end)
    T(("v3.scale_left.%d"):format(i), function() return V3EQ(3 * v, a[1] * 3, a[2] * 3, a[3] * 3, 1e-5) end)
    T(("v3.div.%d"):format(i), function() return V3EQ(v / 4, a[1] / 4, a[2] / 4, a[3] / 4, 1e-5) end)
    T(("v3.unm.%d"):format(i), function() return V3EQ(-v, -a[1], -a[2], -a[3]) end)
    T(("v3.abs.%d"):format(i), function() return V3EQ(v:Abs(), math.abs(a[1]), math.abs(a[2]), math.abs(a[3])) end)
    T(("v3.floor.%d"):format(i), function() return V3EQ(v:Floor(), math.floor(a[1]), math.floor(a[2]), math.floor(a[3])) end)
    T(("v3.ceil.%d"):format(i), function() return V3EQ(v:Ceil(), math.ceil(a[1]), math.ceil(a[2]), math.ceil(a[3])) end)
    T(("v3.sign.%d"):format(i), function() return V3EQ(v:Sign(), math.sign(a[1]), math.sign(a[2]), math.sign(a[3])) end)
    T(("v3.tostring_exact.%d"):format(i), function()
        local function s(n) return tostring(n) end
        return EQ(tostring(v), s(a[1]) .. ", " .. s(a[2]) .. ", " .. s(a[3]))
    end)
end
T("v3.eq", function() return EQ(V3(1, 2, 3) == V3(1, 2, 3), true) end)
T("v3.ne", function() return EQ(V3(1, 2, 3) ~= V3(1, 2, 4), true) end)
T("v3.compare_errors", function() return ERR(function() return V3(1, 1, 1) < V3(2, 2, 2) end) end)
T("v3.concat_errors", function() return ERR(function() return "v" .. V3() end) end)
T("v3.len_errors", function() return ERR(function() return #V3() end) end)
T("v3.FuzzyEq_true", function() return EQ(V3(1, 1, 1):FuzzyEq(V3(1, 1, 1.0000001)), true) end)
T("v3.FuzzyEq_false", function() return EQ(V3(1, 1, 1):FuzzyEq(V3(1, 1, 1.1)), false) end)
T("v3.FuzzyEq_eps", function() return EQ(V3(1, 1, 1):FuzzyEq(V3(1, 1, 1.05), 0.1), true) end)
T("v3.Angle_right", function() return NEAR(V3(1, 0, 0):Angle(V3(0, 1, 0)), math.pi / 2, 1e-6) end)
T("v3.Angle_opposite", function() return NEAR(V3(1, 0, 0):Angle(V3(-1, 0, 0)), math.pi, 1e-6) end)
T("v3.Angle_same", function() return NEAR(V3(2, 0, 0):Angle(V3(5, 0, 0)), 0, 1e-6) end)
T("v3.cross_axes", function() return V3EQ(Vector3.xAxis:Cross(Vector3.yAxis), 0, 0, 1) end)
T("v3.add_number_errors", function() return ERR(function() return V3(1, 1, 1) + 1 end) end)
T("v3.mul_bad_errors", function() return ERR(function() return V3(1, 1, 1) * "x" end) end)
T("v3.invalid_member", function() return ERR(function() return V3().Foo end, "Foo is not a valid member of Vector3") end)
T("v3.immutable", function() return ERR(function() local v = V3(); v.X = 1 end) end)
T("v3.tostring_int", function() return EQ(tostring(V3(1, 2, 3)), "1, 2, 3") end)
T("v3.tostring_zero", function() return EQ(tostring(V3()), "0, 0, 0") end)
T("v3.tostring_neg", function() return EQ(tostring(V3(-1, -2.5, 4)), "-1, -2.5, 4") end)
T("v2.tostring_int", function() return EQ(tostring(V2(1, 2)), "1, 2") end)
T("v2.tostring_half", function() return EQ(tostring(V2(0.5, -0.25)), "0.5, -0.25") end)

-- Vector2 specifics
T("v2.mul_vec", function() return V2EQ(V2(2, 3) * V2(4, 5), 8, 15) end)
T("v2.div_num", function() return V2EQ(V2(2, 3) / 2, 1, 1.5) end)
T("v2.unm", function() return V2EQ(-V2(2, -3), -2, 3) end)
T("v2.Abs", function() return V2EQ(V2(-2, 3):Abs(), 2, 3) end)
T("v2.Floor", function() return V2EQ(V2(-2.5, 3.5):Floor(), -3, 3) end)
T("v2.Ceil", function() return V2EQ(V2(-2.5, 3.5):Ceil(), -2, 4) end)
T("v2.Sign", function() return V2EQ(V2(-2.5, 3.5):Sign(), -1, 1) end)
T("v2.Max", function() return V2EQ(V2(1, 9):Max(V2(5, 2)), 5, 9) end)
T("v2.Min", function() return V2EQ(V2(1, 9):Min(V2(5, 2)), 1, 2) end)
T("v2.Angle", function() return NEAR(V2(1, 0):Angle(V2(0, 1)), math.pi / 2, 1e-6) end)
T("v2.FuzzyEq", function() return EQ(V2(1, 1):FuzzyEq(V2(1, 1.0000001)), true) end)
T("v2.immutable_msg", function()
    return ERR(function() local v = V2(); v.X = 1 end, "X member of Vector2 is read-only and cannot be assigned to")
end)
T("v2.immutable_msg_y", function()
    return ERR(function() local v = V2(); v.Y = 1 end, "Y member of Vector2 is read-only and cannot be assigned to")
end)
T("v2.invalid_member", function() return ERR(function() return V2().Z end) end)

-- int16 vectors
T("v3i16.typeof", function() return TY(Vector3int16.new(1, 2, 3), "Vector3int16") end)
T("v3i16.fields", function() local v = Vector3int16.new(1, -2, 3); A(EQ(v.X, 1)); A(EQ(v.Y, -2)); return EQ(v.Z, 3) end)
T("v3i16.add", function() local v = Vector3int16.new(1, 2, 3) + Vector3int16.new(10, 20, 30); return EQ(v, Vector3int16.new(11, 22, 33)) end)
T("v3i16.sub", function() local v = Vector3int16.new(10, 20, 30) - Vector3int16.new(1, 2, 3); return EQ(v, Vector3int16.new(9, 18, 27)) end)
T("v3i16.tostring", function() return EQ(tostring(Vector3int16.new(1, 2, 3)), "1, 2, 3") end)
T("v3i16.empty", function() return EQ(Vector3int16.new(), Vector3int16.new(0, 0, 0)) end)
T("v2i16.typeof", function() return TY(Vector2int16.new(1, 2), "Vector2int16") end)
T("v2i16.fields", function() local v = Vector2int16.new(7, -8); A(EQ(v.X, 7)); return EQ(v.Y, -8) end)
T("v2i16.add", function() return EQ(Vector2int16.new(1, 2) + Vector2int16.new(3, 4), Vector2int16.new(4, 6)) end)
T("v2i16.tostring", function() return EQ(tostring(Vector2int16.new(1, 2)), "1, 2") end)
