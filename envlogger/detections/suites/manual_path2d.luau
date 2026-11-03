-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "manual_path2d"
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

-- Path2D + Path2DControlPoint behaviour.
-- Source: Creator Hub reference for Path2D / Path2DControlPoint (last updated 2026-10-30) and the
-- 0.745 API dump.  Only behaviour the reference states, or that holds for any cubic spline
-- (endpoint interpolation, symmetry, arc-length spacing on a straight line), is asserted.
local function U(xs, xo, ys, yo) return UDim2.new(xs, xo, ys, yo) end
local function CP(...) return Path2DControlPoint.new(...) end
local function off(x, y) return U(0, x, 0, y) end
local function UEQ(a, b, eps)
    eps = eps or 1e-4
    if typeof(a) ~= "UDim2" then return false, "expected UDim2 got " .. typeof(a) end
    local g = {a.X.Scale, a.X.Offset, a.Y.Scale, a.Y.Offset}
    local e = {b.X.Scale, b.X.Offset, b.Y.Scale, b.Y.Offset}
    for i = 1, 4 do
        if math.abs(g[i] - e[i]) > eps then
            return false, "expected " .. tostring(b) .. " got " .. tostring(a)
        end
    end
    return true
end
local function CPEQ(a, b)
    if typeof(a) ~= "Path2DControlPoint" then return false, "expected Path2DControlPoint got " .. typeof(a) end
    A(UEQ(a.Position, b.Position)); A(UEQ(a.LeftTangent, b.LeftTangent)); return UEQ(a.RightTangent, b.RightTangent)
end
local ZERO = U(0, 0, 0, 0)
local function line(a, b) local p = Instance.new("Path2D"); p:SetControlPoints({CP(a), CP(b)}); return p end

-- class
T("path2d.class.new", function() local p = Instance.new("Path2D"); A(TY(p, "Instance")); return EQ(p.ClassName, "Path2D") end)
T("path2d.class.isa.GuiBase", function() return EQ(Instance.new("Path2D"):IsA("GuiBase"), true) end)
T("path2d.class.isa.Instance", function() return EQ(Instance.new("Path2D"):IsA("Instance"), true) end)
T("path2d.class.isa_not.GuiObject", function() return EQ(Instance.new("Path2D"):IsA("GuiObject"), false) end)
T("path2d.class.isa_not.GuiBase2d", function() return EQ(Instance.new("Path2D"):IsA("GuiBase2d"), false) end)
T("path2d.class.isa_not.BasePart", function() return EQ(Instance.new("Path2D"):IsA("BasePart"), false) end)
T("path2d.class.name", function() return EQ(Instance.new("Path2D").Name, "Path2D") end)
T("path2d.class.parented_frame", function()
    local f = Instance.new("Frame"); local p = Instance.new("Path2D"); p.Parent = f
    A(EQ(p.Parent, f)); return EQ(f:FindFirstChildOfClass("Path2D"), p)
end)

-- defaults (API dump 0.745)
T("path2d.default.Closed", function() return EQ(Instance.new("Path2D").Closed, false) end)
T("path2d.default.Color3", function() return EQ(Instance.new("Path2D").Color3, Color3.new(0, 0, 0)) end)
T("path2d.default.Thickness", function() return EQ(Instance.new("Path2D").Thickness, 1) end)
T("path2d.default.Visible", function() return EQ(Instance.new("Path2D").Visible, true) end)
T("path2d.default.ZIndex", function() return EQ(Instance.new("Path2D").ZIndex, 1) end)
T("path2d.default.no_points", function() return EQ(#Instance.new("Path2D"):GetControlPoints(), 0) end)
T("path2d.default.max_points", function() return EQ(Instance.new("Path2D"):GetMaxControlPoints(), 100) end)

-- members
for _, m in ipairs({"GetBoundingRect", "GetControlPoint", "GetControlPoints", "GetLength", "GetMaxControlPoints",
    "GetPositionOnCurve", "GetPositionOnCurveArcLength", "GetTangentOnCurve", "GetTangentOnCurveArcLength",
    "InsertControlPoint", "RemoveControlPoint", "SetControlPoints", "UpdateControlPoint"}) do
    T("path2d.method." .. m, function() return TY(Instance.new("Path2D")[m], "function") end)
end
T("path2d.event.ControlPointChanged", function()
    local s = Instance.new("Path2D").ControlPointChanged
    A(TY(s, "RBXScriptSignal")); return EQ(tostring(s), "Signal ControlPointChanged")
end)
T("path2d.invalid_member", function()
    return ERR(function() return Instance.new("Path2D").ControlPoints end, 'ControlPoints is not a valid member of Path2D "Path2D"')
end)

-- property writes
T("path2d.write.Thickness", function() local p = Instance.new("Path2D"); p.Thickness = 5; return EQ(p.Thickness, 5) end)
T("path2d.write.Thickness_half", function() local p = Instance.new("Path2D"); p.Thickness = 2.5; return EQ(p.Thickness, 2.5) end)
T("path2d.write.Thickness_float32", function()
    local p = Instance.new("Path2D"); p.Thickness = 0.1
    A(EQ(p.Thickness == 0.1, false)); return NEAR(p.Thickness, 0.10000000149011612, 1e-12)
end)
T("path2d.write.Thickness_clamp_high", function() local p = Instance.new("Path2D"); p.Thickness = 150; return EQ(p.Thickness, 100) end)
T("path2d.write.Thickness_clamp_low", function() local p = Instance.new("Path2D"); p.Thickness = -3; return EQ(p.Thickness, 0) end)
T("path2d.write.Closed", function() local p = Instance.new("Path2D"); p.Closed = true; return EQ(p.Closed, true) end)
T("path2d.write.Color3", function() local p = Instance.new("Path2D"); p.Color3 = Color3.new(1, 0, 0); return EQ(p.Color3, Color3.new(1, 0, 0)) end)
T("path2d.write.Visible", function() local p = Instance.new("Path2D"); p.Visible = false; return EQ(p.Visible, false) end)
T("path2d.write.ZIndex", function() local p = Instance.new("Path2D"); p.ZIndex = 7; return EQ(p.ZIndex, 7) end)
T("path2d.write.Thickness_type", function()
    return ERR(function() Instance.new("Path2D").Thickness = "thick" end, "Unable to assign property Thickness")
end)
T("path2d.write.Color3_type", function()
    return ERR(function() Instance.new("Path2D").Color3 = 5 end, "Unable to assign property Color3. Color3 expected, got number")
end)
T("path2d.write.Changed", function()
    local p, got = Instance.new("Path2D"), nil
    p.Changed:Connect(function(prop) got = prop end)
    p.Thickness = 3
    task.wait()
    return EQ(got, "Thickness")
end)
T("path2d.write.PropertyChangedSignal", function()
    local p, n = Instance.new("Path2D"), 0
    p:GetPropertyChangedSignal("Closed"):Connect(function() n += 1 end)
    p.Closed = true
    p.Thickness = 4
    task.wait()
    return EQ(n, 1)
end)

-- control point storage
T("path2d.cp.set_count", function() return EQ(#line(off(0, 0), off(100, 0)):GetControlPoints(), 2) end)
T("path2d.cp.set_values", function()
    local a, b = CP(off(1, 2), off(3, 4), off(5, 6)), CP(off(7, 8))
    local p = Instance.new("Path2D"); p:SetControlPoints({a, b})
    local pts = p:GetControlPoints()
    A(CPEQ(pts[1], a)); return CPEQ(pts[2], b)
end)
T("path2d.cp.get_one_based", function()
    local p = line(off(10, 0), off(20, 0))
    A(CPEQ(p:GetControlPoint(1), CP(off(10, 0)))); return CPEQ(p:GetControlPoint(2), CP(off(20, 0)))
end)
T("path2d.cp.get_index0_errors", function() return ERR(function() return line(off(0, 0), off(1, 0)):GetControlPoint(0) end) end)
T("path2d.cp.get_past_end_errors", function() return ERR(function() return line(off(0, 0), off(1, 0)):GetControlPoint(3) end) end)
T("path2d.cp.get_empty_errors", function() return ERR(function() return Instance.new("Path2D"):GetControlPoint(1) end) end)
T("path2d.cp.returns_table", function() return TY(Instance.new("Path2D"):GetControlPoints(), "table") end)
T("path2d.cp.returns_copy", function()
    local p = line(off(0, 0), off(100, 0))
    local t = p:GetControlPoints()
    t[1] = nil; t[3] = CP(off(5, 5))
    return EQ(#p:GetControlPoints(), 2)
end)
T("path2d.cp.fresh_table_each_call", function()
    local p = line(off(0, 0), off(100, 0))
    return EQ(rawequal(p:GetControlPoints(), p:GetControlPoints()), false)
end)
T("path2d.cp.set_replaces", function()
    local p = line(off(0, 0), off(100, 0))
    p:SetControlPoints({CP(off(9, 9)), CP(off(8, 8)), CP(off(7, 7))})
    A(EQ(#p:GetControlPoints(), 3)); return CPEQ(p:GetControlPoint(1), CP(off(9, 9)))
end)
T("path2d.cp.set_empty", function()
    local p = line(off(0, 0), off(100, 0)); p:SetControlPoints({}); return EQ(#p:GetControlPoints(), 0)
end)
T("path2d.cp.insert_middle", function()
    local p = line(off(0, 0), off(100, 0))
    p:InsertControlPoint(2, CP(off(50, 50)))
    A(EQ(#p:GetControlPoints(), 3)); A(CPEQ(p:GetControlPoint(2), CP(off(50, 50)))); return CPEQ(p:GetControlPoint(3), CP(off(100, 0)))
end)
T("path2d.cp.insert_front", function()
    local p = line(off(0, 0), off(100, 0))
    p:InsertControlPoint(1, CP(off(-5, 0)))
    A(CPEQ(p:GetControlPoint(1), CP(off(-5, 0)))); return CPEQ(p:GetControlPoint(2), CP(off(0, 0)))
end)
T("path2d.cp.remove_first", function()
    local p = line(off(0, 0), off(100, 0)); p:InsertControlPoint(2, CP(off(50, 0)))
    p:RemoveControlPoint(1)
    A(EQ(#p:GetControlPoints(), 2)); return CPEQ(p:GetControlPoint(1), CP(off(50, 0)))
end)
T("path2d.cp.remove_last", function()
    local p = line(off(0, 0), off(100, 0)); p:RemoveControlPoint(2)
    A(EQ(#p:GetControlPoints(), 1)); return CPEQ(p:GetControlPoint(1), CP(off(0, 0)))
end)
T("path2d.cp.update", function()
    local p = line(off(0, 0), off(100, 0))
    p:UpdateControlPoint(2, CP(off(100, 40), off(-10, 0), off(10, 0)))
    A(EQ(#p:GetControlPoints(), 2)); return CPEQ(p:GetControlPoint(2), CP(off(100, 40), off(-10, 0), off(10, 0)))
end)
T("path2d.cp.max_is_constant", function()
    local p = line(off(0, 0), off(100, 0)); return EQ(p:GetMaxControlPoints(), 100)
end)
T("path2d.cp.event_on_set", function()
    local p, n = Instance.new("Path2D"), 0
    p.ControlPointChanged:Connect(function() n += 1 end)
    p:SetControlPoints({CP(off(0, 0)), CP(off(1, 1))})
    task.wait()
    return EQ(n >= 1, true)
end)
T("path2d.cp.event_on_insert", function()
    local p, n = line(off(0, 0), off(1, 1)), 0
    p.ControlPointChanged:Connect(function() n += 1 end)
    p:InsertControlPoint(2, CP(off(5, 5)))
    task.wait()
    return EQ(n >= 1, true)
end)
T("path2d.cp.event_on_update", function()
    local p, n = line(off(0, 0), off(1, 1)), 0
    p.ControlPointChanged:Connect(function() n += 1 end)
    p:UpdateControlPoint(1, CP(off(2, 2)))
    task.wait()
    return EQ(n >= 1, true)
end)
T("path2d.cp.event_on_remove", function()
    local p, n = line(off(0, 0), off(1, 1)), 0
    p.ControlPointChanged:Connect(function() n += 1 end)
    p:RemoveControlPoint(1)
    task.wait()
    return EQ(n >= 1, true)
end)
T("path2d.cp.event_not_on_visual", function()
    local p, n = line(off(0, 0), off(1, 1)), 0
    p.ControlPointChanged:Connect(function() n += 1 end)
    p.Thickness = 9; p.Color3 = Color3.new(0, 1, 0)
    task.wait()
    return EQ(n, 0)
end)

-- curve queries need two points
for _, m in ipairs({"GetPositionOnCurve", "GetPositionOnCurveArcLength", "GetTangentOnCurve", "GetTangentOnCurveArcLength"}) do
    T("path2d.curve.empty_errors." .. m, function() local p = Instance.new("Path2D"); return ERR(function() return p[m](p, 0.5) end) end)
    T("path2d.curve.single_errors." .. m, function()
        local p = Instance.new("Path2D"); p:SetControlPoints({CP(off(3, 3))})
        return ERR(function() return p[m](p, 0.5) end)
    end)
end

-- straight horizontal line, zero tangents
local H = {[0] = 0, [0.5] = 50, [1] = 100}
for t, x in pairs(H) do
    T("path2d.curve.h.pos." .. t, function() return UEQ(line(off(0, 0), off(100, 0)):GetPositionOnCurve(t), off(x, 0), 1e-3) end)
    T("path2d.curve.h.arc." .. t, function() return UEQ(line(off(0, 0), off(100, 0)):GetPositionOnCurveArcLength(t), off(x, 0), 1e-3) end)
end
for _, t in ipairs({0.1, 0.25, 0.4, 0.6, 0.75, 0.9}) do
    T("path2d.curve.h.arc_even." .. t, function()
        local u = line(off(0, 0), off(100, 0)):GetPositionOnCurveArcLength(t)
        A(NEAR(u.Y.Offset, 0, 1e-3)); return NEAR(u.X.Offset, 100 * t, 0.02)
    end)
    T("path2d.curve.h.pos_on_line." .. t, function()
        local u = line(off(0, 0), off(100, 0)):GetPositionOnCurve(t)
        A(NEAR(u.Y.Offset, 0, 1e-3)); return EQ(u.X.Offset >= 0 and u.X.Offset <= 100, true)
    end)
end
T("path2d.curve.h.pos_monotonic", function()
    local p, last = line(off(0, 0), off(100, 0)), -1
    for i = 0, 10 do
        local x = p:GetPositionOnCurve(i / 10).X.Offset
        if x < last - 1e-6 then return false, "not monotonic at " .. i end
        last = x
    end
    return true
end)
T("path2d.curve.h.result_type", function() return TY(line(off(0, 0), off(100, 0)):GetPositionOnCurve(0.3), "UDim2") end)
T("path2d.curve.h.tangent_type", function() return TY(line(off(0, 0), off(100, 0)):GetTangentOnCurve(0.5), "Vector2") end)
T("path2d.curve.h.tangent_dir", function()
    local v = line(off(0, 0), off(100, 0)):GetTangentOnCurve(0.5)
    A(EQ(v.X > 0, true)); return NEAR(v.Y, 0, 1e-4)
end)
T("path2d.curve.h.tangent_arc_dir", function()
    local v = line(off(0, 0), off(100, 0)):GetTangentOnCurveArcLength(0.5)
    A(EQ(v.X > 0, true)); return NEAR(v.Y, 0, 1e-4)
end)
T("path2d.curve.h.reverse_tangent", function()
    local v = line(off(100, 0), off(0, 0)):GetTangentOnCurve(0.5)
    A(EQ(v.X < 0, true)); return NEAR(v.Y, 0, 1e-4)
end)

-- vertical and diagonal lines
T("path2d.curve.v.mid", function() return UEQ(line(off(0, 0), off(0, 80)):GetPositionOnCurve(0.5), off(0, 40), 1e-3) end)
T("path2d.curve.v.tangent", function()
    local v = line(off(0, 0), off(0, 80)):GetTangentOnCurve(0.5)
    A(NEAR(v.X, 0, 1e-4)); return EQ(v.Y > 0, true)
end)
T("path2d.curve.d.mid", function() return UEQ(line(off(0, 0), off(30, 40)):GetPositionOnCurve(0.5), off(15, 20), 1e-3) end)
T("path2d.curve.d.arc_mid", function() return UEQ(line(off(0, 0), off(30, 40)):GetPositionOnCurveArcLength(0.5), off(15, 20), 0.05) end)
T("path2d.curve.d.end", function() return UEQ(line(off(10, 20), off(30, 40)):GetPositionOnCurve(1), off(30, 40), 1e-3) end)
T("path2d.curve.d.start", function() return UEQ(line(off(10, 20), off(30, 40)):GetPositionOnCurve(0), off(10, 20), 1e-3) end)
T("path2d.curve.d.tangent_parallel", function()
    local v = line(off(0, 0), off(30, 40)):GetTangentOnCurve(0.5)
    return NEAR(v.X * 40 - v.Y * 30, 0, 1e-3)
end)

-- polyline of two segments
local function L3()
    local p = Instance.new("Path2D"); p:SetControlPoints({CP(off(0, 0)), CP(off(100, 0)), CP(off(100, 100))}); return p
end
T("path2d.curve.l3.start", function() return UEQ(L3():GetPositionOnCurve(0), off(0, 0), 1e-3) end)
T("path2d.curve.l3.finish", function() return UEQ(L3():GetPositionOnCurve(1), off(100, 100), 1e-3) end)
T("path2d.curve.l3.arc_corner", function() return UEQ(L3():GetPositionOnCurveArcLength(0.5), off(100, 0), 0.5) end)
T("path2d.curve.l3.arc_finish", function() return UEQ(L3():GetPositionOnCurveArcLength(1), off(100, 100), 1e-3) end)
T("path2d.curve.l3.arc_quarter", function() return UEQ(L3():GetPositionOnCurveArcLength(0.25), off(50, 0), 0.5) end)
T("path2d.curve.l3.arc_three_quarter", function() return UEQ(L3():GetPositionOnCurveArcLength(0.75), off(100, 50), 0.5) end)

-- tangents bend the curve; symmetric handles keep the midpoint centred
T("path2d.curve.bend.symmetric_x", function()
    local p = Instance.new("Path2D")
    p:SetControlPoints({CP(off(0, 0), off(0, 0), off(0, 50)), CP(off(100, 0), off(0, 50), off(0, 0))})
    local u = p:GetPositionOnCurve(0.5)
    A(NEAR(u.X.Offset, 50, 1e-3)); return EQ(math.abs(u.Y.Offset) > 1, true)
end)
T("path2d.curve.bend.endpoints_fixed", function()
    local p = Instance.new("Path2D")
    p:SetControlPoints({CP(off(0, 0), off(0, 0), off(0, 50)), CP(off(100, 0), off(0, 50), off(0, 0))})
    A(UEQ(p:GetPositionOnCurve(0), off(0, 0), 1e-3)); return UEQ(p:GetPositionOnCurve(1), off(100, 0), 1e-3)
end)
T("path2d.curve.bend.mirror", function()
    local function mk(dy)
        local p = Instance.new("Path2D")
        p:SetControlPoints({CP(off(0, 0), off(0, 0), off(0, dy)), CP(off(100, 0), off(0, dy), off(0, 0))})
        return p:GetPositionOnCurve(0.5).Y.Offset
    end
    return NEAR(mk(50), -mk(-50), 1e-3)
end)

-- closing a path needs at least three points
T("path2d.closed.two_points_ignored", function()
    local p = line(off(0, 0), off(100, 0)); p.Closed = true
    return UEQ(p:GetPositionOnCurve(1), off(100, 0), 1e-3)
end)
T("path2d.closed.three_points_loop", function()
    local p = L3(); p.Closed = true
    return UEQ(p:GetPositionOnCurve(1), off(0, 0), 1e-2)
end)
T("path2d.closed.three_points_arc_loop", function()
    local p = L3(); p.Closed = true
    return UEQ(p:GetPositionOnCurveArcLength(1), off(0, 0), 1e-2)
end)

-- remaining query results are well typed
T("path2d.query.length_type", function() return TY(line(off(0, 0), off(100, 0)):GetLength(), "number") end)
T("path2d.query.length_nonnegative", function() return EQ(line(off(0, 0), off(100, 0)):GetLength() >= 0, true) end)
T("path2d.query.rect_type", function() return TY(line(off(0, 0), off(100, 0)):GetBoundingRect(), "Rect") end)

-- Path2DControlPoint datatype
T("p2dcp.type", function() return TY(CP(), "Path2DControlPoint") end)
T("p2dcp.lua_type", function() return EQ(type(CP()), "userdata") end)
T("p2dcp.new_empty", function()
    local c = CP(); A(UEQ(c.Position, ZERO)); A(UEQ(c.LeftTangent, ZERO)); return UEQ(c.RightTangent, ZERO)
end)
T("p2dcp.new_position", function()
    local c = CP(U(0.5, 10, 0.25, 20)); A(UEQ(c.Position, U(0.5, 10, 0.25, 20))); A(UEQ(c.LeftTangent, ZERO)); return UEQ(c.RightTangent, ZERO)
end)
T("p2dcp.new_full", function()
    local c = CP(off(1, 2), off(3, 4), off(5, 6))
    A(UEQ(c.Position, off(1, 2))); A(UEQ(c.LeftTangent, off(3, 4))); return UEQ(c.RightTangent, off(5, 6))
end)
T("p2dcp.field_types", function()
    local c = CP(off(1, 2), off(3, 4), off(5, 6))
    A(TY(c.Position, "UDim2")); A(TY(c.LeftTangent, "UDim2")); return TY(c.RightTangent, "UDim2")
end)
T("p2dcp.eq_value", function() return EQ(CP(off(1, 2)) == CP(off(1, 2)), true) end)
T("p2dcp.ne_value", function() return EQ(CP(off(1, 2)) == CP(off(2, 1)), false) end)
T("p2dcp.immutable_position", function() return ERR(function() local c = CP(); c.Position = off(1, 1) end) end)
T("p2dcp.immutable_left", function() return ERR(function() local c = CP(); c.LeftTangent = off(1, 1) end) end)
T("p2dcp.invalid_member", function() return ERR(function() return CP().Tangent end) end)
T("p2dcp.bad_arg", function() return ERR(function() return Path2DControlPoint.new(5) end) end)
T("p2dcp.global_type", function() return TY(Path2DControlPoint, "table") end)
T("p2dcp.metatable_locked", function() return EQ(getmetatable(CP()), "The metatable is locked") end)
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
