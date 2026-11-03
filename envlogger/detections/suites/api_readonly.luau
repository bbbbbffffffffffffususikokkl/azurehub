-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "api_readonly"
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
    local o = Instance.new("Part")
    T("readonly.Part.AssemblyCenterOfMass", function() return ERR(function() o.AssemblyCenterOfMass = o.AssemblyCenterOfMass end, "Unable to assign property AssemblyCenterOfMass. Property is read only") end)
    T("readonly.Part.AssemblyMass", function() return ERR(function() o.AssemblyMass = o.AssemblyMass end, "Unable to assign property AssemblyMass. Property is read only") end)
    T("readonly.Part.AssemblyRootPart", function() return ERR(function() o.AssemblyRootPart = o.AssemblyRootPart end, "Unable to assign property AssemblyRootPart. Property is read only") end)
    T("readonly.Part.CenterOfMass", function() return ERR(function() o.CenterOfMass = o.CenterOfMass end, "Unable to assign property CenterOfMass. Property is read only") end)
    T("readonly.Part.CurrentPhysicalProperties", function() return ERR(function() o.CurrentPhysicalProperties = o.CurrentPhysicalProperties end, "Unable to assign property CurrentPhysicalProperties. Property is read only") end)
    T("readonly.Part.ExtentsCFrame", function() return ERR(function() o.ExtentsCFrame = o.ExtentsCFrame end, "Unable to assign property ExtentsCFrame. Property is read only") end)
    T("readonly.Part.ExtentsSize", function() return ERR(function() o.ExtentsSize = o.ExtentsSize end, "Unable to assign property ExtentsSize. Property is read only") end)
    T("readonly.Part.Mass", function() return ERR(function() o.Mass = o.Mass end, "Unable to assign property Mass. Property is read only") end)
    T("readonly.Part.ReceiveAge", function() return ERR(function() o.ReceiveAge = o.ReceiveAge end, "Unable to assign property ReceiveAge. Property is read only") end)
    T("readonly.Part.ResizeIncrement", function() return ERR(function() o.ResizeIncrement = o.ResizeIncrement end, "Unable to assign property ResizeIncrement. Property is read only") end)
    T("readonly.Part.ResizeableFaces", function() return ERR(function() o.ResizeableFaces = o.ResizeableFaces end, "Unable to assign property ResizeableFaces. Property is read only") end)
    T("readonly.Part.SpecificGravity", function() return ERR(function() o.SpecificGravity = o.SpecificGravity end) end)
    T("readonly.Part.ClassName", function() return ERR(function() o.ClassName = o.ClassName end) end)
    T("readonly.Part.className", function() return ERR(function() o.className = o.className end) end)
end
do
    local o = Instance.new("MeshPart")
    T("readonly.MeshPart.MeshSize", function() return ERR(function() o.MeshSize = o.MeshSize end, "Unable to assign property MeshSize. Property is read only") end)
    T("readonly.MeshPart.AssemblyCenterOfMass", function() return ERR(function() o.AssemblyCenterOfMass = o.AssemblyCenterOfMass end, "Unable to assign property AssemblyCenterOfMass. Property is read only") end)
    T("readonly.MeshPart.AssemblyMass", function() return ERR(function() o.AssemblyMass = o.AssemblyMass end, "Unable to assign property AssemblyMass. Property is read only") end)
    T("readonly.MeshPart.AssemblyRootPart", function() return ERR(function() o.AssemblyRootPart = o.AssemblyRootPart end, "Unable to assign property AssemblyRootPart. Property is read only") end)
    T("readonly.MeshPart.CenterOfMass", function() return ERR(function() o.CenterOfMass = o.CenterOfMass end, "Unable to assign property CenterOfMass. Property is read only") end)
    T("readonly.MeshPart.CurrentPhysicalProperties", function() return ERR(function() o.CurrentPhysicalProperties = o.CurrentPhysicalProperties end, "Unable to assign property CurrentPhysicalProperties. Property is read only") end)
    T("readonly.MeshPart.ExtentsCFrame", function() return ERR(function() o.ExtentsCFrame = o.ExtentsCFrame end, "Unable to assign property ExtentsCFrame. Property is read only") end)
    T("readonly.MeshPart.ExtentsSize", function() return ERR(function() o.ExtentsSize = o.ExtentsSize end, "Unable to assign property ExtentsSize. Property is read only") end)
    T("readonly.MeshPart.Mass", function() return ERR(function() o.Mass = o.Mass end, "Unable to assign property Mass. Property is read only") end)
    T("readonly.MeshPart.ReceiveAge", function() return ERR(function() o.ReceiveAge = o.ReceiveAge end, "Unable to assign property ReceiveAge. Property is read only") end)
    T("readonly.MeshPart.ResizeIncrement", function() return ERR(function() o.ResizeIncrement = o.ResizeIncrement end, "Unable to assign property ResizeIncrement. Property is read only") end)
    T("readonly.MeshPart.ResizeableFaces", function() return ERR(function() o.ResizeableFaces = o.ResizeableFaces end, "Unable to assign property ResizeableFaces. Property is read only") end)
    T("readonly.MeshPart.SpecificGravity", function() return ERR(function() o.SpecificGravity = o.SpecificGravity end) end)
    T("readonly.MeshPart.ClassName", function() return ERR(function() o.ClassName = o.ClassName end) end)
    T("readonly.MeshPart.className", function() return ERR(function() o.className = o.className end) end)
end
do
    local o = Instance.new("Frame")
    T("readonly.Frame.GuiState", function() return ERR(function() o.GuiState = o.GuiState end, "Unable to assign property GuiState. Property is read only") end)
    T("readonly.Frame.AbsolutePosition", function() return ERR(function() o.AbsolutePosition = o.AbsolutePosition end, "Unable to assign property AbsolutePosition. Property is read only") end)
    T("readonly.Frame.AbsoluteRotation", function() return ERR(function() o.AbsoluteRotation = o.AbsoluteRotation end, "Unable to assign property AbsoluteRotation. Property is read only") end)
    T("readonly.Frame.AbsoluteSize", function() return ERR(function() o.AbsoluteSize = o.AbsoluteSize end, "Unable to assign property AbsoluteSize. Property is read only") end)
end
do
    local o = Instance.new("TextLabel")
    T("readonly.TextLabel.ContentText", function() return ERR(function() o.ContentText = o.ContentText end, "Unable to assign property ContentText. Property is read only") end)
    T("readonly.TextLabel.LocalizedText", function() return ERR(function() o.LocalizedText = o.LocalizedText end, "Unable to assign property LocalizedText. Property is read only") end)
    T("readonly.TextLabel.OpenTypeFeaturesError", function() return ERR(function() o.OpenTypeFeaturesError = o.OpenTypeFeaturesError end, "Unable to assign property OpenTypeFeaturesError. Property is read only") end)
    T("readonly.TextLabel.TextBounds", function() return ERR(function() o.TextBounds = o.TextBounds end, "Unable to assign property TextBounds. Property is read only") end)
    T("readonly.TextLabel.TextFits", function() return ERR(function() o.TextFits = o.TextFits end, "Unable to assign property TextFits. Property is read only") end)
    T("readonly.TextLabel.GuiState", function() return ERR(function() o.GuiState = o.GuiState end, "Unable to assign property GuiState. Property is read only") end)
    T("readonly.TextLabel.AbsolutePosition", function() return ERR(function() o.AbsolutePosition = o.AbsolutePosition end, "Unable to assign property AbsolutePosition. Property is read only") end)
    T("readonly.TextLabel.AbsoluteRotation", function() return ERR(function() o.AbsoluteRotation = o.AbsoluteRotation end, "Unable to assign property AbsoluteRotation. Property is read only") end)
    T("readonly.TextLabel.AbsoluteSize", function() return ERR(function() o.AbsoluteSize = o.AbsoluteSize end, "Unable to assign property AbsoluteSize. Property is read only") end)
end
do
    local o = Instance.new("TextButton")
    T("readonly.TextButton.ContentText", function() return ERR(function() o.ContentText = o.ContentText end, "Unable to assign property ContentText. Property is read only") end)
    T("readonly.TextButton.LocalizedText", function() return ERR(function() o.LocalizedText = o.LocalizedText end, "Unable to assign property LocalizedText. Property is read only") end)
    T("readonly.TextButton.OpenTypeFeaturesError", function() return ERR(function() o.OpenTypeFeaturesError = o.OpenTypeFeaturesError end, "Unable to assign property OpenTypeFeaturesError. Property is read only") end)
    T("readonly.TextButton.TextBounds", function() return ERR(function() o.TextBounds = o.TextBounds end, "Unable to assign property TextBounds. Property is read only") end)
    T("readonly.TextButton.TextFits", function() return ERR(function() o.TextFits = o.TextFits end, "Unable to assign property TextFits. Property is read only") end)
end
do
    local o = Instance.new("ImageLabel")
    T("readonly.ImageLabel.IsLoaded", function() return ERR(function() o.IsLoaded = o.IsLoaded end, "Unable to assign property IsLoaded. Property is read only") end)
end
do
    local o = Instance.new("ImageButton")
    T("readonly.ImageButton.IsLoaded", function() return ERR(function() o.IsLoaded = o.IsLoaded end, "Unable to assign property IsLoaded. Property is read only") end)
end
do
    local o = Instance.new("Sound")
    T("readonly.Sound.IsLoaded", function() return ERR(function() o.IsLoaded = o.IsLoaded end, "Unable to assign property IsLoaded. Property is read only") end)
    T("readonly.Sound.IsPaused", function() return ERR(function() o.IsPaused = o.IsPaused end, "Unable to assign property IsPaused. Property is read only") end)
    T("readonly.Sound.IsPlaying", function() return ERR(function() o.IsPlaying = o.IsPlaying end, "Unable to assign property IsPlaying. Property is read only") end)
    T("readonly.Sound.PlaybackLoudness", function() return ERR(function() o.PlaybackLoudness = o.PlaybackLoudness end, "Unable to assign property PlaybackLoudness. Property is read only") end)
    T("readonly.Sound.TimeLength", function() return ERR(function() o.TimeLength = o.TimeLength end, "Unable to assign property TimeLength. Property is read only") end)
    T("readonly.Sound.isPlaying", function() return ERR(function() o.isPlaying = o.isPlaying end) end)
end
do
    local o = Instance.new("Humanoid")
    T("readonly.Humanoid.FloorMaterial", function() return ERR(function() o.FloorMaterial = o.FloorMaterial end, "Unable to assign property FloorMaterial. Property is read only") end)
    T("readonly.Humanoid.MoveDirection", function() return ERR(function() o.MoveDirection = o.MoveDirection end, "Unable to assign property MoveDirection. Property is read only") end)
    T("readonly.Humanoid.RootPart", function() return ERR(function() o.RootPart = o.RootPart end, "Unable to assign property RootPart. Property is read only") end)
    T("readonly.Humanoid.SeatPart", function() return ERR(function() o.SeatPart = o.SeatPart end, "Unable to assign property SeatPart. Property is read only") end)
end
do
    local o = Instance.new("Camera")
    T("readonly.Camera.NearPlaneZ", function() return ERR(function() o.NearPlaneZ = o.NearPlaneZ end, "Unable to assign property NearPlaneZ. Property is read only") end)
    T("readonly.Camera.ViewportSize", function() return ERR(function() o.ViewportSize = o.ViewportSize end, "Unable to assign property ViewportSize. Property is read only") end)
end
do
    local o = Instance.new("Attachment")
    T("readonly.Attachment.WorldRotation", function() return ERR(function() o.WorldRotation = o.WorldRotation end) end)
end
do
    local o = Instance.new("Weld")
    T("readonly.Weld.Active", function() return ERR(function() o.Active = o.Active end, "Unable to assign property Active. Property is read only") end)
end
do
    local o = Instance.new("WeldConstraint")
    T("readonly.WeldConstraint.Active", function() return ERR(function() o.Active = o.Active end, "Unable to assign property Active. Property is read only") end)
end
do
    local o = Instance.new("Motor6D")
    T("readonly.Motor6D.Active", function() return ERR(function() o.Active = o.Active end, "Unable to assign property Active. Property is read only") end)
end
do
    local o = Instance.new("UIListLayout")
    T("readonly.UIListLayout.AbsoluteContentSize", function() return ERR(function() o.AbsoluteContentSize = o.AbsoluteContentSize end, "Unable to assign property AbsoluteContentSize. Property is read only") end)
end
do
    local o = Instance.new("UIGridLayout")
    T("readonly.UIGridLayout.AbsoluteCellCount", function() return ERR(function() o.AbsoluteCellCount = o.AbsoluteCellCount end, "Unable to assign property AbsoluteCellCount. Property is read only") end)
    T("readonly.UIGridLayout.AbsoluteCellSize", function() return ERR(function() o.AbsoluteCellSize = o.AbsoluteCellSize end, "Unable to assign property AbsoluteCellSize. Property is read only") end)
    T("readonly.UIGridLayout.AbsoluteContentSize", function() return ERR(function() o.AbsoluteContentSize = o.AbsoluteContentSize end, "Unable to assign property AbsoluteContentSize. Property is read only") end)
end
do
    local o = Instance.new("BillboardGui")
    T("readonly.BillboardGui.CurrentDistance", function() return ERR(function() o.CurrentDistance = o.CurrentDistance end, "Unable to assign property CurrentDistance. Property is read only") end)
end
do
    local o = Instance.new("ScrollingFrame")
    T("readonly.ScrollingFrame.AbsoluteCanvasSize", function() return ERR(function() o.AbsoluteCanvasSize = o.AbsoluteCanvasSize end, "Unable to assign property AbsoluteCanvasSize. Property is read only") end)
    T("readonly.ScrollingFrame.AbsoluteWindowSize", function() return ERR(function() o.AbsoluteWindowSize = o.AbsoluteWindowSize end, "Unable to assign property AbsoluteWindowSize. Property is read only") end)
end
do
    local o = Instance.new("TextBox")
    T("readonly.TextBox.ContentText", function() return ERR(function() o.ContentText = o.ContentText end, "Unable to assign property ContentText. Property is read only") end)
    T("readonly.TextBox.OpenTypeFeaturesError", function() return ERR(function() o.OpenTypeFeaturesError = o.OpenTypeFeaturesError end, "Unable to assign property OpenTypeFeaturesError. Property is read only") end)
    T("readonly.TextBox.TextBounds", function() return ERR(function() o.TextBounds = o.TextBounds end, "Unable to assign property TextBounds. Property is read only") end)
    T("readonly.TextBox.TextFits", function() return ERR(function() o.TextFits = o.TextFits end, "Unable to assign property TextFits. Property is read only") end)
end
do
    local o = Instance.new("Seat")
    T("readonly.Seat.Occupant", function() return ERR(function() o.Occupant = o.Occupant end, "Unable to assign property Occupant. Property is read only") end)
end
do
    local o = Instance.new("VehicleSeat")
    T("readonly.VehicleSeat.AreHingesDetected", function() return ERR(function() o.AreHingesDetected = o.AreHingesDetected end, "Unable to assign property AreHingesDetected. Property is read only") end)
    T("readonly.VehicleSeat.Occupant", function() return ERR(function() o.Occupant = o.Occupant end, "Unable to assign property Occupant. Property is read only") end)
end
do
    local o = Instance.new("UnionOperation")
    T("readonly.UnionOperation.MeshSize", function() return ERR(function() o.MeshSize = o.MeshSize end, "Unable to assign property MeshSize. Property is read only") end)
end
do
    local o = Instance.new("Animator")
    T("readonly.Animator.EvaluationThrottled", function() return ERR(function() o.EvaluationThrottled = o.EvaluationThrottled end, "Unable to assign property EvaluationThrottled. Property is read only") end)
    T("readonly.Animator.RootMotion", function() return ERR(function() o.RootMotion = o.RootMotion end, "Unable to assign property RootMotion. Property is read only") end)
    T("readonly.Animator.RootMotionWeight", function() return ERR(function() o.RootMotionWeight = o.RootMotionWeight end, "Unable to assign property RootMotionWeight. Property is read only") end)
end
do
    local o = Instance.new("AlignPosition")
    T("readonly.AlignPosition.Active", function() return ERR(function() o.Active = o.Active end, "Unable to assign property Active. Property is read only") end)
end
do
    local o = Instance.new("AlignOrientation")
    T("readonly.AlignOrientation.Active", function() return ERR(function() o.Active = o.Active end, "Unable to assign property Active. Property is read only") end)
end
do
    local o = Instance.new("HingeConstraint")
    T("readonly.HingeConstraint.CurrentAngle", function() return ERR(function() o.CurrentAngle = o.CurrentAngle end, "Unable to assign property CurrentAngle. Property is read only") end)
end
do
    local o = Instance.new("RopeConstraint")
    T("readonly.RopeConstraint.CurrentDistance", function() return ERR(function() o.CurrentDistance = o.CurrentDistance end, "Unable to assign property CurrentDistance. Property is read only") end)
end
do
    local o = Instance.new("SpringConstraint")
    T("readonly.SpringConstraint.CurrentLength", function() return ERR(function() o.CurrentLength = o.CurrentLength end, "Unable to assign property CurrentLength. Property is read only") end)
end
do
    local o = Instance.new("AdGui")
    T("readonly.AdGui.Status", function() return ERR(function() o.Status = o.Status end, "Unable to assign property Status. Property is read only") end)
end
do
    local o = Instance.new("AdPlacement")
    T("readonly.AdPlacement.RewardId", function() return ERR(function() o.RewardId = o.RewardId end, "Unable to assign property RewardId. Property is read only") end)
    T("readonly.AdPlacement.RewardImageContent", function() return ERR(function() o.RewardImageContent = o.RewardImageContent end, "Unable to assign property RewardImageContent. Property is read only") end)
    T("readonly.AdPlacement.RewardName", function() return ERR(function() o.RewardName = o.RewardName end, "Unable to assign property RewardName. Property is read only") end)
    T("readonly.AdPlacement.Visible", function() return ERR(function() o.Visible = o.Visible end, "Unable to assign property Visible. Property is read only") end)
end
do
    local o = Instance.new("AdPortal")
    T("readonly.AdPortal.Status", function() return ERR(function() o.Status = o.Status end, "Unable to assign property Status. Property is read only") end)
end
do
    local o = Instance.new("AirController")
    T("readonly.AirController.Active", function() return ERR(function() o.Active = o.Active end, "Unable to assign property Active. Property is read only") end)
end
do
    local o = Instance.new("AnimationConstraint")
    T("readonly.AnimationConstraint.C0", function() return ERR(function() o.C0 = o.C0 end) end)
    T("readonly.AnimationConstraint.C1", function() return ERR(function() o.C1 = o.C1 end) end)
    T("readonly.AnimationConstraint.Part0", function() return ERR(function() o.Part0 = o.Part0 end) end)
    T("readonly.AnimationConstraint.Part1", function() return ERR(function() o.Part1 = o.Part1 end) end)
end
do
    local o = Instance.new("AtmosphereSensor")
    T("readonly.AtmosphereSensor.AirDensity", function() return ERR(function() o.AirDensity = o.AirDensity end, "Unable to assign property AirDensity. Property is read only") end)
    T("readonly.AtmosphereSensor.RelativeWindVelocity", function() return ERR(function() o.RelativeWindVelocity = o.RelativeWindVelocity end, "Unable to assign property RelativeWindVelocity. Property is read only") end)
end
do
    local o = Instance.new("AudioAnalyzer")
    T("readonly.AudioAnalyzer.PeakLevel", function() return ERR(function() o.PeakLevel = o.PeakLevel end, "Unable to assign property PeakLevel. Property is read only") end)
    T("readonly.AudioAnalyzer.RmsLevel", function() return ERR(function() o.RmsLevel = o.RmsLevel end, "Unable to assign property RmsLevel. Property is read only") end)
end
do
    local o = Instance.new("AudioPlayer")
    T("readonly.AudioPlayer.IsReady", function() return ERR(function() o.IsReady = o.IsReady end, "Unable to assign property IsReady. Property is read only") end)
    T("readonly.AudioPlayer.TimeLength", function() return ERR(function() o.TimeLength = o.TimeLength end, "Unable to assign property TimeLength. Property is read only") end)
end
do
    local o = Instance.new("Bone")
    T("readonly.Bone.TransformedCFrame", function() return ERR(function() o.TransformedCFrame = o.TransformedCFrame end, "Unable to assign property TransformedCFrame. Property is read only") end)
    T("readonly.Bone.TransformedWorldCFrame", function() return ERR(function() o.TransformedWorldCFrame = o.TransformedWorldCFrame end, "Unable to assign property TransformedWorldCFrame. Property is read only") end)
    T("readonly.Bone.WorldRotation", function() return ERR(function() o.WorldRotation = o.WorldRotation end) end)
end
do
    local o = Instance.new("ClimbController")
    T("readonly.ClimbController.Active", function() return ERR(function() o.Active = o.Active end, "Unable to assign property Active. Property is read only") end)
end
do
    local o = Instance.new("CurveAnimation")
    T("readonly.CurveAnimation.Length", function() return ERR(function() o.Length = o.Length end, "Unable to assign property Length. Property is read only") end)
end
do
    local o = Instance.new("CylindricalConstraint")
    T("readonly.CylindricalConstraint.CurrentAngle", function() return ERR(function() o.CurrentAngle = o.CurrentAngle end, "Unable to assign property CurrentAngle. Property is read only") end)
    T("readonly.CylindricalConstraint.WorldRotationAxis", function() return ERR(function() o.WorldRotationAxis = o.WorldRotationAxis end, "Unable to assign property WorldRotationAxis. Property is read only") end)
    T("readonly.CylindricalConstraint.CurrentPosition", function() return ERR(function() o.CurrentPosition = o.CurrentPosition end, "Unable to assign property CurrentPosition. Property is read only") end)
end
do
    local o = Instance.new("FloatCurve")
    T("readonly.FloatCurve.Length", function() return ERR(function() o.Length = o.Length end, "Unable to assign property Length. Property is read only") end)
end
do
    local o = Instance.new("FluidForceSensor")
    T("readonly.FluidForceSensor.BuoyancyForce", function() return ERR(function() o.BuoyancyForce = o.BuoyancyForce end, "Unable to assign property BuoyancyForce. Property is read only") end)
    T("readonly.FluidForceSensor.BuoyancyTorque", function() return ERR(function() o.BuoyancyTorque = o.BuoyancyTorque end, "Unable to assign property BuoyancyTorque. Property is read only") end)
    T("readonly.FluidForceSensor.CenterOfPressure", function() return ERR(function() o.CenterOfPressure = o.CenterOfPressure end, "Unable to assign property CenterOfPressure. Property is read only") end)
    T("readonly.FluidForceSensor.Force", function() return ERR(function() o.Force = o.Force end, "Unable to assign property Force. Property is read only") end)
    T("readonly.FluidForceSensor.Torque", function() return ERR(function() o.Torque = o.Torque end, "Unable to assign property Torque. Property is read only") end)
end
do
    local o = Instance.new("InputAction")
    T("readonly.InputAction.PreferredBinding", function() return ERR(function() o.PreferredBinding = o.PreferredBinding end, "Unable to assign property PreferredBinding. Property is read only") end)
end
do
    local o = Instance.new("KeyframeSequence")
    T("readonly.KeyframeSequence.Length", function() return ERR(function() o.Length = o.Length end, "Unable to assign property Length. Property is read only") end)
end
do
    local o = Instance.new("MarkerCurve")
    T("readonly.MarkerCurve.Length", function() return ERR(function() o.Length = o.Length end, "Unable to assign property Length. Property is read only") end)
end
do
    local o = Instance.new("PhysicsActivitySensor")
    T("readonly.PhysicsActivitySensor.Active", function() return ERR(function() o.Active = o.Active end, "Unable to assign property Active. Property is read only") end)
end
do
    local o = Instance.new("PrismaticConstraint")
    T("readonly.PrismaticConstraint.CurrentPosition", function() return ERR(function() o.CurrentPosition = o.CurrentPosition end, "Unable to assign property CurrentPosition. Property is read only") end)
end
do
    local o = Instance.new("RodConstraint")
    T("readonly.RodConstraint.CurrentDistance", function() return ERR(function() o.CurrentDistance = o.CurrentDistance end, "Unable to assign property CurrentDistance. Property is read only") end)
end
do
    local o = Instance.new("RotationCurve")
    T("readonly.RotationCurve.Length", function() return ERR(function() o.Length = o.Length end, "Unable to assign property Length. Property is read only") end)
end
do
    local o = Instance.new("SkateboardPlatform")
    T("readonly.SkateboardPlatform.Controller", function() return ERR(function() o.Controller = o.Controller end, "Unable to assign property Controller. Property is read only") end)
    T("readonly.SkateboardPlatform.ControllingHumanoid", function() return ERR(function() o.ControllingHumanoid = o.ControllingHumanoid end, "Unable to assign property ControllingHumanoid. Property is read only") end)
end
do
    local o = Instance.new("StarterGear")
    T("readonly.StarterGear.Loaded", function() return ERR(function() o.Loaded = o.Loaded end, "Unable to assign property Loaded. Property is read only") end)
end
do
    local o = Instance.new("StyleRule")
    T("readonly.StyleRule.SelectorError", function() return ERR(function() o.SelectorError = o.SelectorError end, "Unable to assign property SelectorError. Property is read only") end)
end
do
    local o = Instance.new("TerrainRegion")
    T("readonly.TerrainRegion.IsSmooth", function() return ERR(function() o.IsSmooth = o.IsSmooth end) end)
    T("readonly.TerrainRegion.SizeInCells", function() return ERR(function() o.SizeInCells = o.SizeInCells end, "Unable to assign property SizeInCells. Property is read only") end)
end
do
    local o = Instance.new("TextChannel")
    T("readonly.TextChannel.DirectChatRequester", function() return ERR(function() o.DirectChatRequester = o.DirectChatRequester end, "Unable to assign property DirectChatRequester. Property is read only") end)
end
do
    local o = Instance.new("TorsionSpringConstraint")
    T("readonly.TorsionSpringConstraint.CurrentAngle", function() return ERR(function() o.CurrentAngle = o.CurrentAngle end, "Unable to assign property CurrentAngle. Property is read only") end)
end
do
    local o = Instance.new("Tween")
    T("readonly.Tween.Instance", function() return ERR(function() o.Instance = o.Instance end, "Unable to assign property Instance. Property is read only") end)
    T("readonly.Tween.TweenInfo", function() return ERR(function() o.TweenInfo = o.TweenInfo end, "Unable to assign property TweenInfo. Property is read only") end)
    T("readonly.Tween.PlaybackState", function() return ERR(function() o.PlaybackState = o.PlaybackState end, "Unable to assign property PlaybackState. Property is read only") end)
end
do
    local o = Instance.new("UIPageLayout")
    T("readonly.UIPageLayout.CurrentPage", function() return ERR(function() o.CurrentPage = o.CurrentPage end, "Unable to assign property CurrentPage. Property is read only") end)
end
do
    local o = Instance.new("VideoDeviceInput")
    T("readonly.VideoDeviceInput.IsReady", function() return ERR(function() o.IsReady = o.IsReady end, "Unable to assign property IsReady. Property is read only") end)
end
do
    local o = Instance.new("VideoFrame")
    T("readonly.VideoFrame.IsLoaded", function() return ERR(function() o.IsLoaded = o.IsLoaded end, "Unable to assign property IsLoaded. Property is read only") end)
    T("readonly.VideoFrame.Resolution", function() return ERR(function() o.Resolution = o.Resolution end, "Unable to assign property Resolution. Property is read only") end)
    T("readonly.VideoFrame.TimeLength", function() return ERR(function() o.TimeLength = o.TimeLength end, "Unable to assign property TimeLength. Property is read only") end)
end
do
    local o = Instance.new("VideoPlayer")
    T("readonly.VideoPlayer.IsLoaded", function() return ERR(function() o.IsLoaded = o.IsLoaded end, "Unable to assign property IsLoaded. Property is read only") end)
    T("readonly.VideoPlayer.IsPlaying", function() return ERR(function() o.IsPlaying = o.IsPlaying end, "Unable to assign property IsPlaying. Property is read only") end)
    T("readonly.VideoPlayer.Resolution", function() return ERR(function() o.Resolution = o.Resolution end, "Unable to assign property Resolution. Property is read only") end)
    T("readonly.VideoPlayer.TimeLength", function() return ERR(function() o.TimeLength = o.TimeLength end, "Unable to assign property TimeLength. Property is read only") end)
end
do
    local o = Instance.new("Wire")
    T("readonly.Wire.Connected", function() return ERR(function() o.Connected = o.Connected end, "Unable to assign property Connected. Property is read only") end)
end
do
    local o = Instance.new("WrapDeformer")
    T("readonly.WrapDeformer.CageOriginWorld", function() return ERR(function() o.CageOriginWorld = o.CageOriginWorld end, "Unable to assign property CageOriginWorld. Property is read only") end)
    T("readonly.WrapDeformer.ImportOriginWorld", function() return ERR(function() o.ImportOriginWorld = o.ImportOriginWorld end, "Unable to assign property ImportOriginWorld. Property is read only") end)
end
do
    local o = Instance.new("WrapLayer")
    T("readonly.WrapLayer.ReferenceOriginWorld", function() return ERR(function() o.ReferenceOriginWorld = o.ReferenceOriginWorld end, "Unable to assign property ReferenceOriginWorld. Property is read only") end)
    T("readonly.WrapLayer.CageOriginWorld", function() return ERR(function() o.CageOriginWorld = o.CageOriginWorld end, "Unable to assign property CageOriginWorld. Property is read only") end)
    T("readonly.WrapLayer.ImportOriginWorld", function() return ERR(function() o.ImportOriginWorld = o.ImportOriginWorld end, "Unable to assign property ImportOriginWorld. Property is read only") end)
end
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
