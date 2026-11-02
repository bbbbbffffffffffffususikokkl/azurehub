-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "api_prop_defaults_02"
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
    local o = Instance.new("FileMesh")
    T("prop.default.FileMesh.MeshContent", function() local v = o.MeshContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.FileMesh.MeshId", function() return EQ(o.MeshId, "") end)
    T("prop.default.FileMesh.Offset", function() local v = o.Offset; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.FileMesh.Scale", function() local v = o.Scale; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {1, 1, 1}, 1e-6) end)
    T("prop.default.FileMesh.TextureContent", function() local v = o.TextureContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.FileMesh.TextureId", function() return EQ(o.TextureId, "") end)
    T("prop.default.FileMesh.VertexColor", function() local v = o.VertexColor; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {1, 1, 1}, 1e-6) end)
end
do
    local o = Instance.new("Flag")
    T("prop.default.Flag.CanBeDropped", function() return EQ(o.CanBeDropped, true) end)
    T("prop.default.Flag.Enabled", function() return EQ(o.Enabled, true) end)
    T("prop.default.Flag.Grip", function() local v = o.Grip; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.Flag.ManualActivationOnly", function() return EQ(o.ManualActivationOnly, false) end)
    T("prop.default.Flag.RequiresHandle", function() return EQ(o.RequiresHandle, true) end)
    T("prop.default.Flag.TeamColor", function() local v = o.TeamColor; A(TY(v, "BrickColor")); return EQ(v.Number, 194) end)
    T("prop.default.Flag.TextureContent", function() local v = o.TextureContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.Flag.ToolTip", function() return EQ(o.ToolTip, "") end)
end
do
    local o = Instance.new("FlagStand")
    T("prop.default.FlagStand.TeamColor", function() local v = o.TeamColor; A(TY(v, "BrickColor")); return EQ(v.Number, 194) end)
    T("prop.default.FlagStand.TopSurface", function() return EQ(o.TopSurface, Enum.SurfaceType.Studs) end)
end
do
    local o = Instance.new("FlangeSoundEffect")
    T("prop.default.FlangeSoundEffect.Depth", function() return NEAR(o.Depth, 0.44999998807907104) end)
    T("prop.default.FlangeSoundEffect.Mix", function() return NEAR(o.Mix, 0.8500000238418579) end)
    T("prop.default.FlangeSoundEffect.Rate", function() return NEAR(o.Rate, 5) end)
end
do
    local o = Instance.new("FloorWire")
    T("prop.default.FloorWire.CycleOffset", function() return NEAR(o.CycleOffset, 0) end)
    T("prop.default.FloorWire.From", function() return EQ(o.From, nil) end)
    T("prop.default.FloorWire.StudsBetweenTextures", function() return NEAR(o.StudsBetweenTextures, 4) end)
    T("prop.default.FloorWire.Texture", function() return EQ(o.Texture, "") end)
    T("prop.default.FloorWire.TextureSize", function() local v = o.TextureSize; A(TY(v, "Vector2")); return NEARV({v.X, v.Y}, {1, 1}, 1e-6) end)
    T("prop.default.FloorWire.To", function() return EQ(o.To, nil) end)
    T("prop.default.FloorWire.Velocity", function() return NEAR(o.Velocity, 2) end)
    T("prop.default.FloorWire.WireRadius", function() return NEAR(o.WireRadius, 0.0625) end)
end
do
    local o = Instance.new("ForceField")
    T("prop.default.ForceField.Visible", function() return EQ(o.Visible, true) end)
end
do
    local o = Instance.new("GetTextBoundsParams")
    T("prop.default.GetTextBoundsParams.RichText", function() return EQ(o.RichText, false) end)
    T("prop.default.GetTextBoundsParams.Size", function() return NEAR(o.Size, 20) end)
    T("prop.default.GetTextBoundsParams.Text", function() return EQ(o.Text, "") end)
    T("prop.default.GetTextBoundsParams.Width", function() return NEAR(o.Width, 0) end)
end
do
    local o = Instance.new("Glue")
    T("prop.default.Glue.C0", function() local v = o.C0; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.Glue.C1", function() local v = o.C1; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.Glue.Enabled", function() return EQ(o.Enabled, true) end)
    T("prop.default.Glue.F0", function() local v = o.F0; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.Glue.F1", function() local v = o.F1; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.Glue.F2", function() local v = o.F2; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.Glue.F3", function() local v = o.F3; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.Glue.Part0", function() return EQ(o.Part0, nil) end)
    T("prop.default.Glue.Part1", function() return EQ(o.Part1, nil) end)
    T("prop.default.Glue.part1", function() return EQ(o.part1, nil) end)
end
do
    local o = Instance.new("GroundController")
    T("prop.default.GroundController.AccelerationLean", function() return NEAR(o.AccelerationLean, 1) end)
    T("prop.default.GroundController.AccelerationTime", function() return NEAR(o.AccelerationTime, 0) end)
    T("prop.default.GroundController.BalanceMaxTorque", function() return NEAR(o.BalanceMaxTorque, 10000) end)
    T("prop.default.GroundController.BalanceRigidityEnabled", function() return EQ(o.BalanceRigidityEnabled, false) end)
    T("prop.default.GroundController.BalanceSpeed", function() return NEAR(o.BalanceSpeed, 100) end)
    T("prop.default.GroundController.DecelerationTime", function() return NEAR(o.DecelerationTime, 0) end)
    T("prop.default.GroundController.Friction", function() return NEAR(o.Friction, 2) end)
    T("prop.default.GroundController.FrictionWeight", function() return NEAR(o.FrictionWeight, 1) end)
    T("prop.default.GroundController.GroundOffset", function() return NEAR(o.GroundOffset, 1) end)
    T("prop.default.GroundController.MoveSpeedFactor", function() return NEAR(o.MoveSpeedFactor, 1) end)
    T("prop.default.GroundController.StandForce", function() return NEAR(o.StandForce, 10000) end)
    T("prop.default.GroundController.StandSpeed", function() return NEAR(o.StandSpeed, 100) end)
    T("prop.default.GroundController.TurnSpeedFactor", function() return NEAR(o.TurnSpeedFactor, 1) end)
end
do
    local o = Instance.new("GuiMain")
    T("prop.default.GuiMain.ClipToDeviceSafeArea", function() return EQ(o.ClipToDeviceSafeArea, true) end)
    T("prop.default.GuiMain.DisplayOrder", function() return EQ(o.DisplayOrder, 0) end)
    T("prop.default.GuiMain.SafeAreaCompatibility", function() return EQ(o.SafeAreaCompatibility, Enum.SafeAreaCompatibility.FullscreenExtension) end)
    T("prop.default.GuiMain.ScreenInsets", function() return EQ(o.ScreenInsets, Enum.ScreenInsets.CoreUISafeInsets) end)
end
do
    local o = Instance.new("Handles")
    T("prop.default.Handles.Adornee", function() return EQ(o.Adornee, nil) end)
    T("prop.default.Handles.Faces", function() local v = o.Faces; A(TY(v, "Faces")); local g, e = {v.Right, v.Top, v.Back, v.Left, v.Bottom, v.Front}, {true, true, true, true, true, true}; for i = 1, 6 do A(EQ(g[i], e[i])) end; return true end)
    T("prop.default.Handles.Style", function() return EQ(o.Style, Enum.HandlesStyle.Resize) end)
end
do
    local o = Instance.new("Hat")
    T("prop.default.Hat.AttachmentPoint", function() local v = o.AttachmentPoint; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
end
do
    local o = Instance.new("Hint")
    T("prop.default.Hint.Text", function() return EQ(o.Text, "") end)
end
do
    local o = Instance.new("Hole")
    T("prop.default.Hole.FaceId", function() return EQ(o.FaceId, Enum.NormalId.Right) end)
    T("prop.default.Hole.InOut", function() return EQ(o.InOut, Enum.InOut.Center) end)
    T("prop.default.Hole.LeftRight", function() return EQ(o.LeftRight, Enum.LeftRight.Center) end)
    T("prop.default.Hole.TopBottom", function() return EQ(o.TopBottom, Enum.TopBottom.Center) end)
end
do
    local o = Instance.new("HopperBin")
    T("prop.default.HopperBin.Active", function() return EQ(o.Active, false) end)
    T("prop.default.HopperBin.BinType", function() return EQ(o.BinType, Enum.BinType.Script) end)
    T("prop.default.HopperBin.TextureContent", function() local v = o.TextureContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
end
do
    local o = Instance.new("HumanoidDescription")
    T("prop.default.HumanoidDescription.BackAccessory", function() return EQ(o.BackAccessory, "") end)
    T("prop.default.HumanoidDescription.BodyTypeScale", function() return NEAR(o.BodyTypeScale, 0.30000001192092896) end)
    T("prop.default.HumanoidDescription.ClimbAnimation", function() return EQ(o.ClimbAnimation, 0) end)
    T("prop.default.HumanoidDescription.DepthScale", function() return NEAR(o.DepthScale, 1) end)
    T("prop.default.HumanoidDescription.Face", function() return EQ(o.Face, 0) end)
    T("prop.default.HumanoidDescription.FaceAccessory", function() return EQ(o.FaceAccessory, "") end)
    T("prop.default.HumanoidDescription.FallAnimation", function() return EQ(o.FallAnimation, 0) end)
    T("prop.default.HumanoidDescription.FrontAccessory", function() return EQ(o.FrontAccessory, "") end)
    T("prop.default.HumanoidDescription.GraphicTShirt", function() return EQ(o.GraphicTShirt, 0) end)
    T("prop.default.HumanoidDescription.HairAccessory", function() return EQ(o.HairAccessory, "") end)
    T("prop.default.HumanoidDescription.HatAccessory", function() return EQ(o.HatAccessory, "") end)
    T("prop.default.HumanoidDescription.Head", function() return EQ(o.Head, 0) end)
    T("prop.default.HumanoidDescription.HeadColor", function() local v = o.HeadColor; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {0, 0, 0}, 1e-5) end)
    T("prop.default.HumanoidDescription.HeadScale", function() return NEAR(o.HeadScale, 1) end)
    T("prop.default.HumanoidDescription.HeightScale", function() return NEAR(o.HeightScale, 1) end)
    T("prop.default.HumanoidDescription.IdleAnimation", function() return EQ(o.IdleAnimation, 0) end)
    T("prop.default.HumanoidDescription.JumpAnimation", function() return EQ(o.JumpAnimation, 0) end)
    T("prop.default.HumanoidDescription.LeftArm", function() return EQ(o.LeftArm, 0) end)
    T("prop.default.HumanoidDescription.LeftArmColor", function() local v = o.LeftArmColor; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {0, 0, 0}, 1e-5) end)
    T("prop.default.HumanoidDescription.LeftLeg", function() return EQ(o.LeftLeg, 0) end)
    T("prop.default.HumanoidDescription.LeftLegColor", function() local v = o.LeftLegColor; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {0, 0, 0}, 1e-5) end)
    T("prop.default.HumanoidDescription.MoodAnimation", function() return EQ(o.MoodAnimation, 0) end)
    T("prop.default.HumanoidDescription.NeckAccessory", function() return EQ(o.NeckAccessory, "") end)
    T("prop.default.HumanoidDescription.Pants", function() return EQ(o.Pants, 0) end)
    T("prop.default.HumanoidDescription.ProportionScale", function() return NEAR(o.ProportionScale, 1) end)
    T("prop.default.HumanoidDescription.RightArm", function() return EQ(o.RightArm, 0) end)
    T("prop.default.HumanoidDescription.RightArmColor", function() local v = o.RightArmColor; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {0, 0, 0}, 1e-5) end)
    T("prop.default.HumanoidDescription.RightLeg", function() return EQ(o.RightLeg, 0) end)
    T("prop.default.HumanoidDescription.RightLegColor", function() local v = o.RightLegColor; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {0, 0, 0}, 1e-5) end)
    T("prop.default.HumanoidDescription.RunAnimation", function() return EQ(o.RunAnimation, 0) end)
    T("prop.default.HumanoidDescription.Shirt", function() return EQ(o.Shirt, 0) end)
    T("prop.default.HumanoidDescription.ShouldersAccessory", function() return EQ(o.ShouldersAccessory, "") end)
    T("prop.default.HumanoidDescription.StaticFacialAnimation", function() return EQ(o.StaticFacialAnimation, false) end)
    T("prop.default.HumanoidDescription.SwimAnimation", function() return EQ(o.SwimAnimation, 0) end)
    T("prop.default.HumanoidDescription.Torso", function() return EQ(o.Torso, 0) end)
    T("prop.default.HumanoidDescription.TorsoColor", function() local v = o.TorsoColor; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {0, 0, 0}, 1e-5) end)
    T("prop.default.HumanoidDescription.UseAvatarSettings", function() return EQ(o.UseAvatarSettings, false) end)
    T("prop.default.HumanoidDescription.WaistAccessory", function() return EQ(o.WaistAccessory, "") end)
    T("prop.default.HumanoidDescription.WalkAnimation", function() return EQ(o.WalkAnimation, 0) end)
    T("prop.default.HumanoidDescription.WidthScale", function() return NEAR(o.WidthScale, 1) end)
end
do
    local o = Instance.new("HumanoidRigDescription")
    T("prop.default.HumanoidRigDescription.Chest", function() return EQ(o.Chest, nil) end)
    T("prop.default.HumanoidRigDescription.ChestRangeMax", function() local v = o.ChestRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.ChestRangeMin", function() local v = o.ChestRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.ChestSize", function() return NEAR(o.ChestSize, 0) end)
    T("prop.default.HumanoidRigDescription.ChestTposeAdjustment", function() local v = o.ChestTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.HeadBase", function() return EQ(o.HeadBase, nil) end)
    T("prop.default.HumanoidRigDescription.HeadBaseRangeMax", function() local v = o.HeadBaseRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.HeadBaseRangeMin", function() local v = o.HeadBaseRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.HeadBaseSize", function() return NEAR(o.HeadBaseSize, 0) end)
    T("prop.default.HumanoidRigDescription.HeadBaseTposeAdjustment", function() local v = o.HeadBaseTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.LeftAnkle", function() return EQ(o.LeftAnkle, nil) end)
    T("prop.default.HumanoidRigDescription.LeftAnkleRangeMax", function() local v = o.LeftAnkleRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftAnkleRangeMin", function() local v = o.LeftAnkleRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftAnkleSize", function() return NEAR(o.LeftAnkleSize, 0) end)
    T("prop.default.HumanoidRigDescription.LeftAnkleTposeAdjustment", function() local v = o.LeftAnkleTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.LeftClavicle", function() return EQ(o.LeftClavicle, nil) end)
    T("prop.default.HumanoidRigDescription.LeftClavicleRangeMax", function() local v = o.LeftClavicleRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftClavicleRangeMin", function() local v = o.LeftClavicleRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftClavicleSize", function() return NEAR(o.LeftClavicleSize, 0) end)
    T("prop.default.HumanoidRigDescription.LeftClavicleTposeAdjustment", function() local v = o.LeftClavicleTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.LeftElbow", function() return EQ(o.LeftElbow, nil) end)
    T("prop.default.HumanoidRigDescription.LeftElbowRangeMax", function() local v = o.LeftElbowRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftElbowRangeMin", function() local v = o.LeftElbowRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftElbowSize", function() return NEAR(o.LeftElbowSize, 0) end)
    T("prop.default.HumanoidRigDescription.LeftElbowTposeAdjustment", function() local v = o.LeftElbowTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.LeftHip", function() return EQ(o.LeftHip, nil) end)
    T("prop.default.HumanoidRigDescription.LeftHipRangeMax", function() local v = o.LeftHipRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftHipRangeMin", function() local v = o.LeftHipRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftHipSize", function() return NEAR(o.LeftHipSize, 0) end)
    T("prop.default.HumanoidRigDescription.LeftHipTposeAdjustment", function() local v = o.LeftHipTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.LeftKnee", function() return EQ(o.LeftKnee, nil) end)
    T("prop.default.HumanoidRigDescription.LeftKneeRangeMax", function() local v = o.LeftKneeRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftKneeRangeMin", function() local v = o.LeftKneeRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftKneeSize", function() return NEAR(o.LeftKneeSize, 0) end)
    T("prop.default.HumanoidRigDescription.LeftKneeTposeAdjustment", function() local v = o.LeftKneeTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.LeftShoulder", function() return EQ(o.LeftShoulder, nil) end)
    T("prop.default.HumanoidRigDescription.LeftShoulderRangeMax", function() local v = o.LeftShoulderRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftShoulderRangeMin", function() local v = o.LeftShoulderRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftShoulderSize", function() return NEAR(o.LeftShoulderSize, 0) end)
    T("prop.default.HumanoidRigDescription.LeftShoulderTposeAdjustment", function() local v = o.LeftShoulderTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.LeftToeBase", function() return EQ(o.LeftToeBase, nil) end)
    T("prop.default.HumanoidRigDescription.LeftToeBaseRangeMax", function() local v = o.LeftToeBaseRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftToeBaseRangeMin", function() local v = o.LeftToeBaseRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftToeBaseSize", function() return NEAR(o.LeftToeBaseSize, 0) end)
    T("prop.default.HumanoidRigDescription.LeftToeBaseTposeAdjustment", function() local v = o.LeftToeBaseTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.LeftWrist", function() return EQ(o.LeftWrist, nil) end)
    T("prop.default.HumanoidRigDescription.LeftWristRangeMax", function() local v = o.LeftWristRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftWristRangeMin", function() local v = o.LeftWristRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.LeftWristSize", function() return NEAR(o.LeftWristSize, 0) end)
    T("prop.default.HumanoidRigDescription.LeftWristTposeAdjustment", function() local v = o.LeftWristTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.Neck", function() return EQ(o.Neck, nil) end)
    T("prop.default.HumanoidRigDescription.NeckRangeMax", function() local v = o.NeckRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.NeckRangeMin", function() local v = o.NeckRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.NeckSize", function() return NEAR(o.NeckSize, 0) end)
    T("prop.default.HumanoidRigDescription.NeckTposeAdjustment", function() local v = o.NeckTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.OriginOffset", function() local v = o.OriginOffset; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.RightAnkle", function() return EQ(o.RightAnkle, nil) end)
    T("prop.default.HumanoidRigDescription.RightAnkleRangeMax", function() local v = o.RightAnkleRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightAnkleRangeMin", function() local v = o.RightAnkleRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightAnkleSize", function() return NEAR(o.RightAnkleSize, 0) end)
    T("prop.default.HumanoidRigDescription.RightAnkleTposeAdjustment", function() local v = o.RightAnkleTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.RightClavicle", function() return EQ(o.RightClavicle, nil) end)
    T("prop.default.HumanoidRigDescription.RightClavicleRangeMax", function() local v = o.RightClavicleRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightClavicleRangeMin", function() local v = o.RightClavicleRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightClavicleSize", function() return NEAR(o.RightClavicleSize, 0) end)
    T("prop.default.HumanoidRigDescription.RightClavicleTposeAdjustment", function() local v = o.RightClavicleTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.RightElbow", function() return EQ(o.RightElbow, nil) end)
    T("prop.default.HumanoidRigDescription.RightElbowRangeMax", function() local v = o.RightElbowRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightElbowRangeMin", function() local v = o.RightElbowRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightElbowSize", function() return NEAR(o.RightElbowSize, 0) end)
    T("prop.default.HumanoidRigDescription.RightElbowTposeAdjustment", function() local v = o.RightElbowTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.RightHip", function() return EQ(o.RightHip, nil) end)
    T("prop.default.HumanoidRigDescription.RightHipRangeMax", function() local v = o.RightHipRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightHipRangeMin", function() local v = o.RightHipRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightHipSize", function() return NEAR(o.RightHipSize, 0) end)
    T("prop.default.HumanoidRigDescription.RightHipTposeAdjustment", function() local v = o.RightHipTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.RightKnee", function() return EQ(o.RightKnee, nil) end)
    T("prop.default.HumanoidRigDescription.RightKneeRangeMax", function() local v = o.RightKneeRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightKneeRangeMin", function() local v = o.RightKneeRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightKneeSize", function() return NEAR(o.RightKneeSize, 0) end)
    T("prop.default.HumanoidRigDescription.RightKneeTposeAdjustment", function() local v = o.RightKneeTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.RightShoulder", function() return EQ(o.RightShoulder, nil) end)
    T("prop.default.HumanoidRigDescription.RightShoulderRangeMax", function() local v = o.RightShoulderRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightShoulderRangeMin", function() local v = o.RightShoulderRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightShoulderSize", function() return NEAR(o.RightShoulderSize, 0) end)
    T("prop.default.HumanoidRigDescription.RightShoulderTposeAdjustment", function() local v = o.RightShoulderTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.RightToeBase", function() return EQ(o.RightToeBase, nil) end)
    T("prop.default.HumanoidRigDescription.RightToeBaseRangeMax", function() local v = o.RightToeBaseRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightToeBaseRangeMin", function() local v = o.RightToeBaseRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightToeBaseSize", function() return NEAR(o.RightToeBaseSize, 0) end)
    T("prop.default.HumanoidRigDescription.RightToeBaseTposeAdjustment", function() local v = o.RightToeBaseTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.RightWrist", function() return EQ(o.RightWrist, nil) end)
    T("prop.default.HumanoidRigDescription.RightWristRangeMax", function() local v = o.RightWristRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightWristRangeMin", function() local v = o.RightWristRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RightWristSize", function() return NEAR(o.RightWristSize, 0) end)
    T("prop.default.HumanoidRigDescription.RightWristTposeAdjustment", function() local v = o.RightWristTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.Root", function() return EQ(o.Root, nil) end)
    T("prop.default.HumanoidRigDescription.RootRangeMax", function() local v = o.RootRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RootRangeMin", function() local v = o.RootRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.RootSize", function() return NEAR(o.RootSize, 0) end)
    T("prop.default.HumanoidRigDescription.RootTposeAdjustment", function() local v = o.RootTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.Spine", function() return EQ(o.Spine, nil) end)
    T("prop.default.HumanoidRigDescription.SpineRangeMax", function() local v = o.SpineRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.SpineRangeMin", function() local v = o.SpineRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.SpineSize", function() return NEAR(o.SpineSize, 0) end)
    T("prop.default.HumanoidRigDescription.SpineTposeAdjustment", function() local v = o.SpineTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.HumanoidRigDescription.Waist", function() return EQ(o.Waist, nil) end)
    T("prop.default.HumanoidRigDescription.WaistRangeMax", function() local v = o.WaistRangeMax; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.WaistRangeMin", function() local v = o.WaistRangeMin; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.HumanoidRigDescription.WaistSize", function() return NEAR(o.WaistSize, 0) end)
    T("prop.default.HumanoidRigDescription.WaistTposeAdjustment", function() local v = o.WaistTposeAdjustment; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
end
do
    local o = Instance.new("IKControl")
    T("prop.default.IKControl.ChainRoot", function() return EQ(o.ChainRoot, nil) end)
    T("prop.default.IKControl.Enabled", function() return EQ(o.Enabled, true) end)
    T("prop.default.IKControl.EndEffector", function() return EQ(o.EndEffector, nil) end)
    T("prop.default.IKControl.EndEffectorOffset", function() local v = o.EndEffectorOffset; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.IKControl.Offset", function() local v = o.Offset; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.IKControl.Pole", function() return EQ(o.Pole, nil) end)
    T("prop.default.IKControl.Priority", function() return EQ(o.Priority, 0) end)
    T("prop.default.IKControl.SmoothTime", function() return NEAR(o.SmoothTime, 0.05000000074505806) end)
    T("prop.default.IKControl.Target", function() return EQ(o.Target, nil) end)
    T("prop.default.IKControl.Type", function() return EQ(o.Type, Enum.IKControlType.Transform) end)
    T("prop.default.IKControl.Weight", function() return NEAR(o.Weight, 1) end)
end
do
    local o = Instance.new("ImageHandleAdornment")
    T("prop.default.ImageHandleAdornment.Color3", function() local v = o.Color3; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {0.9490196704864502, 0.9529412388801575, 0.9529412388801575}, 1e-5) end)
    T("prop.default.ImageHandleAdornment.Image", function() return EQ(o.Image, "rbxasset://textures/SurfacesDefault.png") end)
    T("prop.default.ImageHandleAdornment.Size", function() local v = o.Size; A(TY(v, "Vector2")); return NEARV({v.X, v.Y}, {1, 1}, 1e-6) end)
end
do
    local o = Instance.new("InputAction")
    T("prop.default.InputAction.DisplayName", function() return EQ(o.DisplayName, "") end)
    T("prop.default.InputAction.Enabled", function() return EQ(o.Enabled, true) end)
    T("prop.default.InputAction.Type", function() return EQ(o.Type, Enum.InputActionType.Bool) end)
end
do
    local o = Instance.new("InputBinding")
    T("prop.default.InputBinding.Backward", function() return EQ(o.Backward, Enum.KeyCode.None) end)
    T("prop.default.InputBinding.ClampMagnitudeToOne", function() return EQ(o.ClampMagnitudeToOne, true) end)
    T("prop.default.InputBinding.Deadzone", function() local v = o.Deadzone; A(TY(v, "NumberRange")); return NEARV({v.Min, v.Max}, {0.10000000149011612, 1}) end)
    T("prop.default.InputBinding.DisplayImage", function() local v = o.DisplayImage; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.InputBinding.DisplayName", function() return EQ(o.DisplayName, "") end)
    T("prop.default.InputBinding.Down", function() return EQ(o.Down, Enum.KeyCode.None) end)
    T("prop.default.InputBinding.Forward", function() return EQ(o.Forward, Enum.KeyCode.None) end)
    T("prop.default.InputBinding.KeyCode", function() return EQ(o.KeyCode, Enum.KeyCode.None) end)
    T("prop.default.InputBinding.Left", function() return EQ(o.Left, Enum.KeyCode.None) end)
    T("prop.default.InputBinding.PointerIndex", function() return EQ(o.PointerIndex, 0) end)
    T("prop.default.InputBinding.PressedThreshold", function() return NEAR(o.PressedThreshold, 0.5) end)
    T("prop.default.InputBinding.PrimaryModifier", function() return EQ(o.PrimaryModifier, Enum.KeyCode.None) end)
    T("prop.default.InputBinding.ReleasedThreshold", function() return NEAR(o.ReleasedThreshold, 0.20000000298023224) end)
    T("prop.default.InputBinding.ResponseCurve", function() return NEAR(o.ResponseCurve, 1) end)
    T("prop.default.InputBinding.Right", function() return EQ(o.Right, Enum.KeyCode.None) end)
    T("prop.default.InputBinding.Scale", function() return NEAR(o.Scale, 1) end)
    T("prop.default.InputBinding.SecondaryModifier", function() return EQ(o.SecondaryModifier, Enum.KeyCode.None) end)
    T("prop.default.InputBinding.Type", function() return EQ(o.Type, Enum.InputBindingType.Automatic) end)
    T("prop.default.InputBinding.UIButton", function() return EQ(o.UIButton, nil) end)
    T("prop.default.InputBinding.UIModifier", function() return EQ(o.UIModifier, nil) end)
    T("prop.default.InputBinding.Up", function() return EQ(o.Up, Enum.KeyCode.None) end)
    T("prop.default.InputBinding.Vector2Scale", function() local v = o.Vector2Scale; A(TY(v, "Vector2")); return NEARV({v.X, v.Y}, {1, 1}, 1e-6) end)
    T("prop.default.InputBinding.Vector3Scale", function() local v = o.Vector3Scale; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {1, 1, 1}, 1e-6) end)
end
do
    local o = Instance.new("InputContext")
    T("prop.default.InputContext.Enabled", function() return EQ(o.Enabled, true) end)
    T("prop.default.InputContext.Priority", function() return EQ(o.Priority, 1000) end)
    T("prop.default.InputContext.Sink", function() return EQ(o.Sink, false) end)
end
do
    local o = Instance.new("IntConstrainedValue")
    T("prop.default.IntConstrainedValue.ConstrainedValue", function() return EQ(o.ConstrainedValue, 0) end)
    T("prop.default.IntConstrainedValue.MaxValue", function() return EQ(o.MaxValue, 10) end)
    T("prop.default.IntConstrainedValue.MinValue", function() return EQ(o.MinValue, 0) end)
    T("prop.default.IntConstrainedValue.Value", function() return EQ(o.Value, 0) end)
end
do
    local o = Instance.new("IntersectOperation")
    T("prop.default.IntersectOperation.BottomSurface", function() return EQ(o.BottomSurface, Enum.SurfaceType.Smooth) end)
    T("prop.default.IntersectOperation.Color", function() local v = o.Color; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {1, 1, 1}, 1e-5) end)
    T("prop.default.IntersectOperation.SmoothingAngle", function() return NEAR(o.SmoothingAngle, 0) end)
    T("prop.default.IntersectOperation.UsePartColor", function() return EQ(o.UsePartColor, false) end)
end
do
    local o = Instance.new("Keyframe")
    T("prop.default.Keyframe.Time", function() return NEAR(o.Time, 0) end)
end
do
    local o = Instance.new("KeyframeMarker")
    T("prop.default.KeyframeMarker.Value", function() return EQ(o.Value, "") end)
end
do
    local o = Instance.new("KeyframeSequence")
    T("prop.default.KeyframeSequence.Loop", function() return EQ(o.Loop, true) end)
    T("prop.default.KeyframeSequence.Priority", function() return EQ(o.Priority, Enum.AnimationPriority.Action) end)
end
do
    local o = Instance.new("LineForce")
    T("prop.default.LineForce.ApplyAtCenterOfMass", function() return EQ(o.ApplyAtCenterOfMass, false) end)
    T("prop.default.LineForce.InverseSquareLaw", function() return EQ(o.InverseSquareLaw, false) end)
    T("prop.default.LineForce.Magnitude", function() return NEAR(o.Magnitude, 1000) end)
    T("prop.default.LineForce.MaxForce", function() return EQ(o.MaxForce, math.huge) end)
    T("prop.default.LineForce.ReactionForceEnabled", function() return EQ(o.ReactionForceEnabled, false) end)
end
do
    local o = Instance.new("LineHandleAdornment")
    T("prop.default.LineHandleAdornment.Length", function() return NEAR(o.Length, 5) end)
    T("prop.default.LineHandleAdornment.Thickness", function() return NEAR(o.Thickness, 1) end)
end
do
    local o = Instance.new("LocalizationTable")
    T("prop.default.LocalizationTable.DevelopmentLanguage", function() return EQ(o.DevelopmentLanguage, "en-us") end)
    T("prop.default.LocalizationTable.Root", function() return EQ(o.Root, nil) end)
    T("prop.default.LocalizationTable.SourceLocaleId", function() return EQ(o.SourceLocaleId, "en-us") end)
end
do
    local o = Instance.new("MakeupDescription")
    T("prop.default.MakeupDescription.AssetId", function() return EQ(o.AssetId, 0) end)
    T("prop.default.MakeupDescription.Instance", function() return EQ(o.Instance, nil) end)
    T("prop.default.MakeupDescription.MakeupType", function() return EQ(o.MakeupType, Enum.MakeupType.Face) end)
    T("prop.default.MakeupDescription.Order", function() return EQ(o.Order, 0) end)
end
do
    local o = Instance.new("MaterialVariant")
    T("prop.default.MaterialVariant.AlphaMode", function() return EQ(o.AlphaMode, Enum.AlphaMode.Opaque) end)
    T("prop.default.MaterialVariant.BaseMaterial", function() return EQ(o.BaseMaterial, Enum.Material.Plastic) end)
    T("prop.default.MaterialVariant.CustomPhysicalProperties", function() return EQ(o.CustomPhysicalProperties, nil) end)
    T("prop.default.MaterialVariant.EmissiveStrength", function() return NEAR(o.EmissiveStrength, 1) end)
    T("prop.default.MaterialVariant.EmissiveTint", function() local v = o.EmissiveTint; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {1, 1, 1}, 1e-5) end)
    T("prop.default.MaterialVariant.MaterialPattern", function() return EQ(o.MaterialPattern, Enum.MaterialPattern.Regular) end)
    T("prop.default.MaterialVariant.StudsPerTile", function() return NEAR(o.StudsPerTile, 10) end)
end
do
    local o = Instance.new("Message")
    T("prop.default.Message.Text", function() return EQ(o.Text, "") end)
end
do
    local o = Instance.new("Motor")
    T("prop.default.Motor.DesiredAngle", function() return NEAR(o.DesiredAngle, 0) end)
    T("prop.default.Motor.MaxVelocity", function() return NEAR(o.MaxVelocity, 0) end)
end
do
    local o = Instance.new("NegateOperation")
    T("prop.default.NegateOperation.Anchored", function() return EQ(o.Anchored, true) end)
    T("prop.default.NegateOperation.BottomSurface", function() return EQ(o.BottomSurface, Enum.SurfaceType.Smooth) end)
    T("prop.default.NegateOperation.CanCollide", function() return EQ(o.CanCollide, false) end)
    T("prop.default.NegateOperation.Color", function() local v = o.Color; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {1, 1, 1}, 1e-5) end)
    T("prop.default.NegateOperation.SmoothingAngle", function() return NEAR(o.SmoothingAngle, 0) end)
    T("prop.default.NegateOperation.Transparency", function() return NEAR(o.Transparency, 0.10000000149011612) end)
    T("prop.default.NegateOperation.UsePartColor", function() return EQ(o.UsePartColor, false) end)
end
do
    local o = Instance.new("NoCollisionConstraint")
    T("prop.default.NoCollisionConstraint.Enabled", function() return EQ(o.Enabled, true) end)
    T("prop.default.NoCollisionConstraint.Part0", function() return EQ(o.Part0, nil) end)
    T("prop.default.NoCollisionConstraint.Part1", function() return EQ(o.Part1, nil) end)
end
do
    local o = Instance.new("NumberPose")
    T("prop.default.NumberPose.EasingDirection", function() return EQ(o.EasingDirection, Enum.PoseEasingDirection.In) end)
    T("prop.default.NumberPose.EasingStyle", function() return EQ(o.EasingStyle, Enum.PoseEasingStyle.Linear) end)
    T("prop.default.NumberPose.Value", function() return NEAR(o.Value, 0) end)
    T("prop.default.NumberPose.Weight", function() return NEAR(o.Weight, 1) end)
end
do
    local o = Instance.new("ParabolaAdornment")
    T("prop.default.ParabolaAdornment.Color3", function() local v = o.Color3; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {0.9490196704864502, 0.9529412388801575, 0.9529412388801575}, 1e-5) end)
end
do
    local o = Instance.new("PartOperation")
    T("prop.default.PartOperation.BottomSurface", function() return EQ(o.BottomSurface, Enum.SurfaceType.Smooth) end)
    T("prop.default.PartOperation.Color", function() local v = o.Color; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {1, 1, 1}, 1e-5) end)
    T("prop.default.PartOperation.SmoothingAngle", function() return NEAR(o.SmoothingAngle, 0) end)
    T("prop.default.PartOperation.UsePartColor", function() return EQ(o.UsePartColor, false) end)
end
do
    local o = Instance.new("PathfindingLink")
    T("prop.default.PathfindingLink.Attachment0", function() return EQ(o.Attachment0, nil) end)
    T("prop.default.PathfindingLink.Attachment1", function() return EQ(o.Attachment1, nil) end)
    T("prop.default.PathfindingLink.IsBidirectional", function() return EQ(o.IsBidirectional, true) end)
    T("prop.default.PathfindingLink.Label", function() return EQ(o.Label, "") end)
end
do
    local o = Instance.new("PathfindingModifier")
    T("prop.default.PathfindingModifier.Label", function() return EQ(o.Label, "") end)
    T("prop.default.PathfindingModifier.PassThrough", function() return EQ(o.PassThrough, false) end)
end
do
    local o = Instance.new("PhysicsActivitySensor")
    T("prop.default.PhysicsActivitySensor.Position", function() local v = o.Position; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.PhysicsActivitySensor.Size", function() local v = o.Size; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
end
do
    local o = Instance.new("PitchShiftSoundEffect")
    T("prop.default.PitchShiftSoundEffect.Octave", function() return NEAR(o.Octave, 1.25) end)
end
do
    local o = Instance.new("Plane")
    T("prop.default.Plane.Color", function() local v = o.Color; A(TY(v, "BrickColor")); return EQ(v.Number, 194) end)
end
do
    local o = Instance.new("PlaneConstraint")
    T("prop.default.PlaneConstraint.Color", function() local v = o.Color; A(TY(v, "BrickColor")); return EQ(v.Number, 194) end)
end
do
    local o = Instance.new("Pose")
    T("prop.default.Pose.CFrame", function() local v = o.CFrame; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.Pose.EasingDirection", function() return EQ(o.EasingDirection, Enum.PoseEasingDirection.In) end)
    T("prop.default.Pose.EasingStyle", function() return EQ(o.EasingStyle, Enum.PoseEasingStyle.Linear) end)
    T("prop.default.Pose.MaskWeight", function() return NEAR(o.MaskWeight, 0) end)
    T("prop.default.Pose.Weight", function() return NEAR(o.Weight, 1) end)
end
do
    local o = Instance.new("PrismaticConstraint")
    T("prop.default.PrismaticConstraint.ActuatorType", function() return EQ(o.ActuatorType, Enum.ActuatorType.None) end)
    T("prop.default.PrismaticConstraint.Color", function() local v = o.Color; A(TY(v, "BrickColor")); return EQ(v.Number, 1009) end)
    T("prop.default.PrismaticConstraint.LimitsEnabled", function() return EQ(o.LimitsEnabled, false) end)
    T("prop.default.PrismaticConstraint.LinearResponsiveness", function() return NEAR(o.LinearResponsiveness, 45) end)
    T("prop.default.PrismaticConstraint.LowerLimit", function() return NEAR(o.LowerLimit, 0) end)
    T("prop.default.PrismaticConstraint.MotorMaxAcceleration", function() return EQ(o.MotorMaxAcceleration, math.huge) end)
    T("prop.default.PrismaticConstraint.MotorMaxForce", function() return NEAR(o.MotorMaxForce, 0) end)
    T("prop.default.PrismaticConstraint.Restitution", function() return NEAR(o.Restitution, 0) end)
    T("prop.default.PrismaticConstraint.ServoMaxForce", function() return NEAR(o.ServoMaxForce, 0) end)
    T("prop.default.PrismaticConstraint.Size", function() return NEAR(o.Size, 0.15000000596046448) end)
    T("prop.default.PrismaticConstraint.SoftlockServoUponReachingTarget", function() return EQ(o.SoftlockServoUponReachingTarget, false) end)
    T("prop.default.PrismaticConstraint.Speed", function() return NEAR(o.Speed, 0) end)
    T("prop.default.PrismaticConstraint.TargetPosition", function() return NEAR(o.TargetPosition, 0) end)
    T("prop.default.PrismaticConstraint.UpperLimit", function() return NEAR(o.UpperLimit, 5) end)
    T("prop.default.PrismaticConstraint.Velocity", function() return NEAR(o.Velocity, 0) end)
end
do
    local o = Instance.new("PyramidHandleAdornment")
    T("prop.default.PyramidHandleAdornment.Height", function() return NEAR(o.Height, 2) end)
    T("prop.default.PyramidHandleAdornment.Shading", function() return EQ(o.Shading, Enum.AdornShading.Default) end)
    T("prop.default.PyramidHandleAdornment.Sides", function() return EQ(o.Sides, 4) end)
    T("prop.default.PyramidHandleAdornment.Size", function() return NEAR(o.Size, 1) end)
end
do
    local o = Instance.new("RayValue")
    T("prop.default.RayValue.Value", function() local v = o.Value; A(TY(v, "Ray")); return NEARV({v.Origin.X, v.Origin.Y, v.Origin.Z, v.Direction.X, v.Direction.Y, v.Direction.Z}, {0, 0, 0, 0, 0, 0}) end)
end
do
    local o = Instance.new("ReverbSoundEffect")
    T("prop.default.ReverbSoundEffect.DecayTime", function() return NEAR(o.DecayTime, 1.5) end)
    T("prop.default.ReverbSoundEffect.Density", function() return NEAR(o.Density, 1) end)
    T("prop.default.ReverbSoundEffect.Diffusion", function() return NEAR(o.Diffusion, 1) end)
    T("prop.default.ReverbSoundEffect.DryLevel", function() return NEAR(o.DryLevel, -6) end)
    T("prop.default.ReverbSoundEffect.WetLevel", function() return NEAR(o.WetLevel, 0) end)
end
do
    local o = Instance.new("RigidConstraint")
    T("prop.default.RigidConstraint.Color", function() local v = o.Color; A(TY(v, "BrickColor")); return EQ(v.Number, 194) end)
end
do
    local o = Instance.new("RocketPropulsion")
    T("prop.default.RocketPropulsion.CartoonFactor", function() return NEAR(o.CartoonFactor, 0.699999988079071) end)
    T("prop.default.RocketPropulsion.MaxSpeed", function() return NEAR(o.MaxSpeed, 30) end)
    T("prop.default.RocketPropulsion.MaxThrust", function() return NEAR(o.MaxThrust, 4000) end)
    T("prop.default.RocketPropulsion.MaxTorque", function() local v = o.MaxTorque; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {400000, 400000, 0}, 1e-6) end)
    T("prop.default.RocketPropulsion.Target", function() return EQ(o.Target, nil) end)
    T("prop.default.RocketPropulsion.TargetOffset", function() local v = o.TargetOffset; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
    T("prop.default.RocketPropulsion.TargetRadius", function() return NEAR(o.TargetRadius, 4) end)
    T("prop.default.RocketPropulsion.ThrustD", function() return NEAR(o.ThrustD, 0.0010000000474974513) end)
    T("prop.default.RocketPropulsion.ThrustP", function() return NEAR(o.ThrustP, 5) end)
    T("prop.default.RocketPropulsion.TurnD", function() return NEAR(o.TurnD, 500) end)
    T("prop.default.RocketPropulsion.TurnP", function() return NEAR(o.TurnP, 3000) end)
end
do
    local o = Instance.new("RodConstraint")
    T("prop.default.RodConstraint.Color", function() local v = o.Color; A(TY(v, "BrickColor")); return EQ(v.Number, 26) end)
    T("prop.default.RodConstraint.Length", function() return NEAR(o.Length, 5) end)
    T("prop.default.RodConstraint.LimitAngle0", function() return NEAR(o.LimitAngle0, 90) end)
    T("prop.default.RodConstraint.LimitAngle1", function() return NEAR(o.LimitAngle1, 90) end)
    T("prop.default.RodConstraint.LimitsEnabled", function() return EQ(o.LimitsEnabled, false) end)
    T("prop.default.RodConstraint.Thickness", function() return NEAR(o.Thickness, 0.10000000149011612) end)
end
do
    local o = Instance.new("RotateP")
    T("prop.default.RotateP.BaseAngle", function() return NEAR(o.BaseAngle, 0) end)
end
do
    local o = Instance.new("RotateV")
    T("prop.default.RotateV.BaseAngle", function() return NEAR(o.BaseAngle, 0) end)
end
do
    local o = Instance.new("SelectionSphere")
    T("prop.default.SelectionSphere.SurfaceColor3", function() local v = o.SurfaceColor3; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {0.050980400294065475, 0.4117650091648102, 0.6745100021362305}, 1e-5) end)
    T("prop.default.SelectionSphere.SurfaceTransparency", function() return NEAR(o.SurfaceTransparency, 1) end)
end
do
    local o = Instance.new("SkateboardPlatform")
    T("prop.default.SkateboardPlatform.Steer", function() return EQ(o.Steer, 0) end)
    T("prop.default.SkateboardPlatform.StickyWheels", function() return EQ(o.StickyWheels, true) end)
    T("prop.default.SkateboardPlatform.Throttle", function() return EQ(o.Throttle, 0) end)
    T("prop.default.SkateboardPlatform.TopSurface", function() return EQ(o.TopSurface, Enum.SurfaceType.Studs) end)
end
do
    local o = Instance.new("Skin")
    T("prop.default.Skin.SkinColor", function() local v = o.SkinColor; A(TY(v, "BrickColor")); return EQ(v.Number, 226) end)
end
do
    local o = Instance.new("SpecialMesh")
    T("prop.default.SpecialMesh.MeshContent", function() local v = o.MeshContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.SpecialMesh.MeshType", function() return EQ(o.MeshType, Enum.MeshType.Head) end)
    T("prop.default.SpecialMesh.TextureContent", function() local v = o.TextureContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
end
do
    local o = Instance.new("StyleDerive")
    T("prop.default.StyleDerive.Priority", function() return EQ(o.Priority, 0) end)
    T("prop.default.StyleDerive.StyleSheet", function() return EQ(o.StyleSheet, nil) end)
end
do
    local o = Instance.new("StyleLink")
    T("prop.default.StyleLink.StyleSheet", function() return EQ(o.StyleSheet, nil) end)
end
do
    local o = Instance.new("StyleRule")
    T("prop.default.StyleRule.Priority", function() return EQ(o.Priority, 0) end)
    T("prop.default.StyleRule.Selector", function() return EQ(o.Selector, "") end)
end
do
    local o = Instance.new("SurfaceAppearance")
    T("prop.default.SurfaceAppearance.AlphaMode", function() return EQ(o.AlphaMode, Enum.AlphaMode.Overlay) end)
    T("prop.default.SurfaceAppearance.Color", function() local v = o.Color; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {1, 1, 1}, 1e-5) end)
    T("prop.default.SurfaceAppearance.ColorMapContent", function() local v = o.ColorMapContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.SurfaceAppearance.EmissiveMaskContent", function() local v = o.EmissiveMaskContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.SurfaceAppearance.EmissiveStrength", function() return NEAR(o.EmissiveStrength, 1) end)
    T("prop.default.SurfaceAppearance.EmissiveTint", function() local v = o.EmissiveTint; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {1, 1, 1}, 1e-5) end)
    T("prop.default.SurfaceAppearance.MetalnessMapContent", function() local v = o.MetalnessMapContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.SurfaceAppearance.NormalMapContent", function() local v = o.NormalMapContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.SurfaceAppearance.ResampleMode", function() return EQ(o.ResampleMode, Enum.ResamplerMode.Default) end)
    T("prop.default.SurfaceAppearance.RoughnessMapContent", function() local v = o.RoughnessMapContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.SurfaceAppearance.SurfaceSlot", function() return EQ(o.SurfaceSlot, -1) end)
end
do
    local o = Instance.new("SurfaceSelection")
    T("prop.default.SurfaceSelection.Adornee", function() return EQ(o.Adornee, nil) end)
    T("prop.default.SurfaceSelection.TargetSurface", function() return EQ(o.TargetSurface, Enum.NormalId.Right) end)
end
do
    local o = Instance.new("SwimController")
    T("prop.default.SwimController.AccelerationTime", function() return NEAR(o.AccelerationTime, 0) end)
    T("prop.default.SwimController.PitchMaxTorque", function() return NEAR(o.PitchMaxTorque, 10000) end)
    T("prop.default.SwimController.PitchSpeedFactor", function() return NEAR(o.PitchSpeedFactor, 1) end)
    T("prop.default.SwimController.RollMaxTorque", function() return NEAR(o.RollMaxTorque, 10000) end)
    T("prop.default.SwimController.RollSpeedFactor", function() return NEAR(o.RollSpeedFactor, 1) end)
end
do
    local o = Instance.new("TeleportOptions")
    T("prop.default.TeleportOptions.ReservedServerAccessCode", function() return EQ(o.ReservedServerAccessCode, "") end)
    T("prop.default.TeleportOptions.ReservedServerId", function() return EQ(o.ReservedServerId, "") end)
    T("prop.default.TeleportOptions.ServerInstanceId", function() return EQ(o.ServerInstanceId, "") end)
    T("prop.default.TeleportOptions.ShouldReserveServer", function() return EQ(o.ShouldReserveServer, false) end)
    T("prop.default.TeleportOptions.VipServerId", function() return EQ(o.VipServerId, "") end)
end
do
    local o = Instance.new("TerrainDetail")
    T("prop.default.TerrainDetail.EmissiveStrength", function() return NEAR(o.EmissiveStrength, 1) end)
    T("prop.default.TerrainDetail.EmissiveTint", function() local v = o.EmissiveTint; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {1, 1, 1}, 1e-5) end)
    T("prop.default.TerrainDetail.Face", function() return EQ(o.Face, Enum.TerrainFace.Side) end)
    T("prop.default.TerrainDetail.MaterialPattern", function() return EQ(o.MaterialPattern, Enum.MaterialPattern.Regular) end)
    T("prop.default.TerrainDetail.StudsPerTile", function() return NEAR(o.StudsPerTile, 10) end)
end
do
    local o = Instance.new("TextChannel")
    T("prop.default.TextChannel.AddPlayersOnJoin", function() return EQ(o.AddPlayersOnJoin, false) end)
end
do
    local o = Instance.new("TextChatCommand")
    T("prop.default.TextChatCommand.AutocompleteVisible", function() return EQ(o.AutocompleteVisible, true) end)
    T("prop.default.TextChatCommand.Enabled", function() return EQ(o.Enabled, true) end)
    T("prop.default.TextChatCommand.PrimaryAlias", function() return EQ(o.PrimaryAlias, "") end)
    T("prop.default.TextChatCommand.SecondaryAlias", function() return EQ(o.SecondaryAlias, "") end)
end
do
    local o = Instance.new("TextChatMessageProperties")
    T("prop.default.TextChatMessageProperties.PrefixText", function() return EQ(o.PrefixText, "") end)
    T("prop.default.TextChatMessageProperties.Text", function() return EQ(o.Text, "") end)
    T("prop.default.TextChatMessageProperties.Translation", function() return EQ(o.Translation, "") end)
end
do
    local o = Instance.new("Torque")
    T("prop.default.Torque.RelativeTo", function() return EQ(o.RelativeTo, Enum.ActuatorRelativeTo.Attachment0) end)
    T("prop.default.Torque.Torque", function() local v = o.Torque; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {0, 0, 0}, 1e-6) end)
end
do
    local o = Instance.new("TorsionSpringConstraint")
    T("prop.default.TorsionSpringConstraint.Coils", function() return NEAR(o.Coils, 8) end)
    T("prop.default.TorsionSpringConstraint.Color", function() local v = o.Color; A(TY(v, "BrickColor")); return EQ(v.Number, 200) end)
    T("prop.default.TorsionSpringConstraint.Damping", function() return NEAR(o.Damping, 0.009999999776482582) end)
    T("prop.default.TorsionSpringConstraint.LimitEnabled", function() return EQ(o.LimitEnabled, false) end)
    T("prop.default.TorsionSpringConstraint.LimitsEnabled", function() return EQ(o.LimitsEnabled, false) end)
    T("prop.default.TorsionSpringConstraint.MaxAngle", function() return NEAR(o.MaxAngle, 45) end)
    T("prop.default.TorsionSpringConstraint.MaxTorque", function() return EQ(o.MaxTorque, math.huge) end)
    T("prop.default.TorsionSpringConstraint.Radius", function() return NEAR(o.Radius, 0.4000000059604645) end)
    T("prop.default.TorsionSpringConstraint.Restitution", function() return NEAR(o.Restitution, 0) end)
    T("prop.default.TorsionSpringConstraint.Stiffness", function() return NEAR(o.Stiffness, 100) end)
end
do
    local o = Instance.new("TremoloSoundEffect")
    T("prop.default.TremoloSoundEffect.Depth", function() return NEAR(o.Depth, 1) end)
    T("prop.default.TremoloSoundEffect.Duty", function() return NEAR(o.Duty, 0.5) end)
    T("prop.default.TremoloSoundEffect.Frequency", function() return NEAR(o.Frequency, 5) end)
end
do
    local o = Instance.new("UIAspectRatioConstraint")
    T("prop.default.UIAspectRatioConstraint.AspectRatio", function() return NEAR(o.AspectRatio, 1) end)
    T("prop.default.UIAspectRatioConstraint.AspectType", function() return EQ(o.AspectType, Enum.AspectType.FitWithinMaxSize) end)
    T("prop.default.UIAspectRatioConstraint.DominantAxis", function() return EQ(o.DominantAxis, Enum.DominantAxis.Width) end)
end
do
    local o = Instance.new("UIDragDetector")
    T("prop.default.UIDragDetector.ActivatedCursorIcon", function() return EQ(o.ActivatedCursorIcon, "") end)
    T("prop.default.UIDragDetector.ActivatedCursorIconContent", function() local v = o.ActivatedCursorIconContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.UIDragDetector.BoundingBehavior", function() return EQ(o.BoundingBehavior, Enum.UIDragDetectorBoundingBehavior.Automatic) end)
    T("prop.default.UIDragDetector.BoundingUI", function() return EQ(o.BoundingUI, nil) end)
    T("prop.default.UIDragDetector.CursorIcon", function() return EQ(o.CursorIcon, "") end)
    T("prop.default.UIDragDetector.CursorIconContent", function() local v = o.CursorIconContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.UIDragDetector.DragAxis", function() local v = o.DragAxis; A(TY(v, "Vector2")); return NEARV({v.X, v.Y}, {1, 0}, 1e-6) end)
    T("prop.default.UIDragDetector.DragRelativity", function() return EQ(o.DragRelativity, Enum.UIDragDetectorDragRelativity.Absolute) end)
    T("prop.default.UIDragDetector.DragRotation", function() return NEAR(o.DragRotation, 0) end)
    T("prop.default.UIDragDetector.DragSpace", function() return EQ(o.DragSpace, Enum.UIDragDetectorDragSpace.Parent) end)
    T("prop.default.UIDragDetector.DragStyle", function() return EQ(o.DragStyle, Enum.UIDragDetectorDragStyle.TranslatePlane) end)
    T("prop.default.UIDragDetector.DragUDim2", function() local v = o.DragUDim2; A(TY(v, "UDim2")); return NEARV({v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset}, {0, 0, 0, 0}) end)
    T("prop.default.UIDragDetector.Enabled", function() return EQ(o.Enabled, true) end)
    T("prop.default.UIDragDetector.MaxDragAngle", function() return NEAR(o.MaxDragAngle, 0) end)
    T("prop.default.UIDragDetector.MaxDragTranslation", function() local v = o.MaxDragTranslation; A(TY(v, "UDim2")); return NEARV({v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset}, {0, 0, 0, 0}) end)
    T("prop.default.UIDragDetector.MinDragAngle", function() return NEAR(o.MinDragAngle, 0) end)
    T("prop.default.UIDragDetector.MinDragTranslation", function() local v = o.MinDragTranslation; A(TY(v, "UDim2")); return NEARV({v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset}, {0, 0, 0, 0}) end)
    T("prop.default.UIDragDetector.ReferenceUIInstance", function() return EQ(o.ReferenceUIInstance, nil) end)
    T("prop.default.UIDragDetector.ResponseStyle", function() return EQ(o.ResponseStyle, Enum.UIDragDetectorResponseStyle.Offset) end)
    T("prop.default.UIDragDetector.Selectable", function() return EQ(o.Selectable, true) end)
    T("prop.default.UIDragDetector.SelectionModeDragSpeed", function() local v = o.SelectionModeDragSpeed; A(TY(v, "UDim2")); return NEARV({v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset}, {0, 300, 0, 300}) end)
    T("prop.default.UIDragDetector.SelectionModeRotateSpeed", function() return NEAR(o.SelectionModeRotateSpeed, 90) end)
    T("prop.default.UIDragDetector.UIDragSpeedAxisMapping", function() return EQ(o.UIDragSpeedAxisMapping, Enum.UIDragSpeedAxisMapping.XY) end)
end
do
    local o = Instance.new("UIFlexItem")
    T("prop.default.UIFlexItem.FlexMode", function() return EQ(o.FlexMode, Enum.UIFlexMode.None) end)
    T("prop.default.UIFlexItem.GrowRatio", function() return NEAR(o.GrowRatio, 0) end)
    T("prop.default.UIFlexItem.ItemLineAlignment", function() return EQ(o.ItemLineAlignment, Enum.ItemLineAlignment.Automatic) end)
    T("prop.default.UIFlexItem.ShrinkRatio", function() return NEAR(o.ShrinkRatio, 0) end)
end
do
    local o = Instance.new("UIPageLayout")
    T("prop.default.UIPageLayout.Animated", function() return EQ(o.Animated, true) end)
    T("prop.default.UIPageLayout.Circular", function() return EQ(o.Circular, false) end)
    T("prop.default.UIPageLayout.EasingDirection", function() return EQ(o.EasingDirection, Enum.EasingDirection.Out) end)
    T("prop.default.UIPageLayout.EasingStyle", function() return EQ(o.EasingStyle, Enum.EasingStyle.Back) end)
    T("prop.default.UIPageLayout.FillDirection", function() return EQ(o.FillDirection, Enum.FillDirection.Horizontal) end)
    T("prop.default.UIPageLayout.GamepadInputEnabled", function() return EQ(o.GamepadInputEnabled, true) end)
    T("prop.default.UIPageLayout.HorizontalAlignment", function() return EQ(o.HorizontalAlignment, Enum.HorizontalAlignment.Left) end)
    T("prop.default.UIPageLayout.Padding", function() local v = o.Padding; A(TY(v, "UDim")); return NEARV({v.Scale, v.Offset}, {0, 0}) end)
    T("prop.default.UIPageLayout.ScrollWheelInputEnabled", function() return EQ(o.ScrollWheelInputEnabled, true) end)
    T("prop.default.UIPageLayout.SortOrder", function() return EQ(o.SortOrder, Enum.SortOrder.Name) end)
    T("prop.default.UIPageLayout.TouchInputEnabled", function() return EQ(o.TouchInputEnabled, true) end)
    T("prop.default.UIPageLayout.TweenTime", function() return NEAR(o.TweenTime, 1) end)
    T("prop.default.UIPageLayout.VerticalAlignment", function() return EQ(o.VerticalAlignment, Enum.VerticalAlignment.Top) end)
end
do
    local o = Instance.new("UISizeConstraint")
    T("prop.default.UISizeConstraint.MaxSize", function() local v = o.MaxSize; A(TY(v, "Vector2")); return NEARV({v.X, v.Y}, {math.huge, math.huge}, 1e-6) end)
    T("prop.default.UISizeConstraint.MinSize", function() local v = o.MinSize; A(TY(v, "Vector2")); return NEARV({v.X, v.Y}, {0, 0}, 1e-6) end)
end
do
    local o = Instance.new("UITableLayout")
    T("prop.default.UITableLayout.FillEmptySpaceColumns", function() return EQ(o.FillEmptySpaceColumns, false) end)
    T("prop.default.UITableLayout.FillEmptySpaceRows", function() return EQ(o.FillEmptySpaceRows, false) end)
    T("prop.default.UITableLayout.MajorAxis", function() return EQ(o.MajorAxis, Enum.TableMajorAxis.RowMajor) end)
    T("prop.default.UITableLayout.Padding", function() local v = o.Padding; A(TY(v, "UDim2")); return NEARV({v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset}, {0, 0, 0, 0}) end)
end
do
    local o = Instance.new("UITextSizeConstraint")
    T("prop.default.UITextSizeConstraint.MaxTextSize", function() return EQ(o.MaxTextSize, 100) end)
    T("prop.default.UITextSizeConstraint.MinTextSize", function() return EQ(o.MinTextSize, 1) end)
end
do
    local o = Instance.new("UniversalConstraint")
    T("prop.default.UniversalConstraint.Color", function() local v = o.Color; A(TY(v, "BrickColor")); return EQ(v.Number, 1009) end)
    T("prop.default.UniversalConstraint.LimitsEnabled", function() return EQ(o.LimitsEnabled, false) end)
    T("prop.default.UniversalConstraint.MaxAngle", function() return NEAR(o.MaxAngle, 45) end)
    T("prop.default.UniversalConstraint.Radius", function() return NEAR(o.Radius, 0.20000000298023224) end)
    T("prop.default.UniversalConstraint.Restitution", function() return NEAR(o.Restitution, 0) end)
end
do
    local o = Instance.new("VelocityMotor")
    T("prop.default.VelocityMotor.DesiredAngle", function() return NEAR(o.DesiredAngle, 0) end)
    T("prop.default.VelocityMotor.Hole", function() return EQ(o.Hole, nil) end)
    T("prop.default.VelocityMotor.MaxVelocity", function() return NEAR(o.MaxVelocity, 0) end)
end
do
    local o = Instance.new("VideoDeviceInput")
    T("prop.default.VideoDeviceInput.Active", function() return EQ(o.Active, false) end)
    T("prop.default.VideoDeviceInput.CameraId", function() return EQ(o.CameraId, "") end)
    T("prop.default.VideoDeviceInput.CaptureQuality", function() return EQ(o.CaptureQuality, Enum.VideoDeviceCaptureQuality.Default) end)
end
do
    local o = Instance.new("VideoDisplay")
    T("prop.default.VideoDisplay.ResampleMode", function() return EQ(o.ResampleMode, Enum.ResamplerMode.Default) end)
    T("prop.default.VideoDisplay.ScaleType", function() return EQ(o.ScaleType, Enum.ScaleType.Stretch) end)
    T("prop.default.VideoDisplay.TileSize", function() local v = o.TileSize; A(TY(v, "UDim2")); return NEARV({v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset}, {1, 0, 1, 0}) end)
    T("prop.default.VideoDisplay.VideoColor3", function() local v = o.VideoColor3; A(TY(v, "Color3")); return NEARV({v.R, v.G, v.B}, {1, 1, 1}, 1e-5) end)
    T("prop.default.VideoDisplay.VideoRectOffset", function() local v = o.VideoRectOffset; A(TY(v, "Vector2")); return NEARV({v.X, v.Y}, {0, 0}, 1e-6) end)
    T("prop.default.VideoDisplay.VideoRectSize", function() local v = o.VideoRectSize; A(TY(v, "Vector2")); return NEARV({v.X, v.Y}, {0, 0}, 1e-6) end)
    T("prop.default.VideoDisplay.VideoTransparency", function() return NEAR(o.VideoTransparency, 0) end)
end
do
    local o = Instance.new("VideoFrame")
    T("prop.default.VideoFrame.InternalVideoUsage", function() return EQ(o.InternalVideoUsage, Enum.InternalVideoUsage.Default) end)
    T("prop.default.VideoFrame.Looped", function() return EQ(o.Looped, false) end)
    T("prop.default.VideoFrame.MaximumResolution", function() return EQ(o.MaximumResolution, Enum.VideoSampleSize.Full) end)
    T("prop.default.VideoFrame.Playing", function() return EQ(o.Playing, false) end)
    T("prop.default.VideoFrame.RollOffMaxDistance", function() return NEAR(o.RollOffMaxDistance, 10000) end)
    T("prop.default.VideoFrame.RollOffMinDistance", function() return NEAR(o.RollOffMinDistance, 1) end)
    T("prop.default.VideoFrame.RollOffMode", function() return EQ(o.RollOffMode, Enum.RollOffMode.Inverse) end)
    T("prop.default.VideoFrame.Video", function() return EQ(o.Video, "") end)
    T("prop.default.VideoFrame.VideoContent", function() local v = o.VideoContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.VideoFrame.Volume", function() return NEAR(o.Volume, 1) end)
end
do
    local o = Instance.new("VideoPlayer")
    T("prop.default.VideoPlayer.InternalVideoUsage", function() return EQ(o.InternalVideoUsage, Enum.InternalVideoUsage.Default) end)
    T("prop.default.VideoPlayer.Looping", function() return EQ(o.Looping, false) end)
    T("prop.default.VideoPlayer.MaximumResolution", function() return EQ(o.MaximumResolution, Enum.VideoSampleSize.Full) end)
    T("prop.default.VideoPlayer.PlaybackSpeed", function() return NEAR(o.PlaybackSpeed, 1) end)
    T("prop.default.VideoPlayer.VideoContent", function() local v = o.VideoContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.VideoPlayer.Volume", function() return NEAR(o.Volume, 1) end)
end
do
    local o = Instance.new("Wire")
    T("prop.default.Wire.SourceInstance", function() return EQ(o.SourceInstance, nil) end)
    T("prop.default.Wire.SourceName", function() return EQ(o.SourceName, "Output") end)
    T("prop.default.Wire.TargetInstance", function() return EQ(o.TargetInstance, nil) end)
    T("prop.default.Wire.TargetName", function() return EQ(o.TargetName, "Input") end)
end
do
    local o = Instance.new("WireframeHandleAdornment")
    T("prop.default.WireframeHandleAdornment.Scale", function() local v = o.Scale; A(TY(v, "Vector3")); return NEARV({v.X, v.Y, v.Z}, {1, 1, 1}, 1e-6) end)
    T("prop.default.WireframeHandleAdornment.Thickness", function() return NEAR(o.Thickness, 1) end)
end
do
    local o = Instance.new("WorldModel")
    T("prop.default.WorldModel.UseWorkspaceCollisionGroups", function() return EQ(o.UseWorkspaceCollisionGroups, false) end)
end
do
    local o = Instance.new("WrapDeformer")
    T("prop.default.WrapDeformer.CageMeshContent", function() local v = o.CageMeshContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.WrapDeformer.CageOrigin", function() local v = o.CageOrigin; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.WrapDeformer.ImportOrigin", function() local v = o.ImportOrigin; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
end
do
    local o = Instance.new("WrapLayer")
    T("prop.default.WrapLayer.AutoSkin", function() return EQ(o.AutoSkin, Enum.WrapLayerAutoSkin.Disabled) end)
    T("prop.default.WrapLayer.BindOffset", function() local v = o.BindOffset; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.WrapLayer.CageMeshContent", function() local v = o.CageMeshContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.WrapLayer.CageOrigin", function() local v = o.CageOrigin; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.WrapLayer.Enabled", function() return EQ(o.Enabled, true) end)
    T("prop.default.WrapLayer.ImportOrigin", function() local v = o.ImportOrigin; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.WrapLayer.Order", function() return EQ(o.Order, 1) end)
    T("prop.default.WrapLayer.Puffiness", function() return NEAR(o.Puffiness, 1) end)
    T("prop.default.WrapLayer.ReferenceMeshContent", function() local v = o.ReferenceMeshContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.WrapLayer.ReferenceMeshId", function() return EQ(o.ReferenceMeshId, "") end)
    T("prop.default.WrapLayer.ReferenceOrigin", function() local v = o.ReferenceOrigin; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.WrapLayer.ShrinkFactor", function() return NEAR(o.ShrinkFactor, 0) end)
    T("prop.default.WrapLayer.TargetShaping", function() return NEAR(o.TargetShaping, 0) end)
end
do
    local o = Instance.new("WrapTarget")
    T("prop.default.WrapTarget.CageMeshContent", function() local v = o.CageMeshContent; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None) end)
    T("prop.default.WrapTarget.CageOrigin", function() local v = o.CageOrigin; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.WrapTarget.ImportOrigin", function() local v = o.ImportOrigin; A(TY(v, "CFrame")); return NEARV({v:GetComponents()}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}, 1e-5) end)
    T("prop.default.WrapTarget.Stiffness", function() return NEAR(o.Stiffness, 0) end)
end
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
