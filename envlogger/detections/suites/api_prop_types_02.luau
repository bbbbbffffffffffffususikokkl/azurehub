-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "api_prop_types_02"
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
    local o = Instance.new("ClimbController")
    T("prop.type.ClimbController.AccelerationTime", function() return TY(o.AccelerationTime, "number") end)
    T("prop.type.ClimbController.Active", function() return TY(o.Active, "boolean") end)
    T("prop.type.ClimbController.BalanceMaxTorque", function() return TY(o.BalanceMaxTorque, "number") end)
    T("prop.type.ClimbController.BalanceRigidityEnabled", function() return TY(o.BalanceRigidityEnabled, "boolean") end)
    T("prop.type.ClimbController.BalanceSpeed", function() return TY(o.BalanceSpeed, "number") end)
    T("prop.type.ClimbController.MoveMaxForce", function() return TY(o.MoveMaxForce, "number") end)
    T("prop.type.ClimbController.MoveSpeedFactor", function() return TY(o.MoveSpeedFactor, "number") end)
end
do
    local o = Instance.new("Clouds")
    T("prop.type.Clouds.Color", function() return TY(o.Color, "Color3") end)
    T("prop.type.Clouds.Cover", function() return TY(o.Cover, "number") end)
    T("prop.type.Clouds.Density", function() return TY(o.Density, "number") end)
    T("prop.type.Clouds.Enabled", function() return TY(o.Enabled, "boolean") end)
end
do
    local o = Instance.new("CompressorSoundEffect")
    T("prop.type.CompressorSoundEffect.Attack", function() return TY(o.Attack, "number") end)
    T("prop.type.CompressorSoundEffect.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.CompressorSoundEffect.GainMakeup", function() return TY(o.GainMakeup, "number") end)
    T("prop.type.CompressorSoundEffect.Priority", function() return TY(o.Priority, "number") end)
    T("prop.type.CompressorSoundEffect.Ratio", function() return TY(o.Ratio, "number") end)
    T("prop.type.CompressorSoundEffect.Release", function() return TY(o.Release, "number") end)
    T("prop.type.CompressorSoundEffect.SideChain", function() return TY(o.SideChain, "nil") end)
    T("prop.type.CompressorSoundEffect.Threshold", function() return TY(o.Threshold, "number") end)
end
do
    local o = Instance.new("ConeHandleAdornment")
    T("prop.type.ConeHandleAdornment.AdornCullingMode", function() local v = o.AdornCullingMode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.AdornCullingMode) end)
    T("prop.type.ConeHandleAdornment.Adornee", function() return TY(o.Adornee, "nil") end)
    T("prop.type.ConeHandleAdornment.AlwaysOnTop", function() return TY(o.AlwaysOnTop, "boolean") end)
    T("prop.type.ConeHandleAdornment.CFrame", function() return TY(o.CFrame, "CFrame") end)
    T("prop.type.ConeHandleAdornment.Height", function() return TY(o.Height, "number") end)
    T("prop.type.ConeHandleAdornment.Hollow", function() return TY(o.Hollow, "boolean") end)
    T("prop.type.ConeHandleAdornment.Radius", function() return TY(o.Radius, "number") end)
    T("prop.type.ConeHandleAdornment.Shading", function() local v = o.Shading; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.AdornShading) end)
    T("prop.type.ConeHandleAdornment.SizeRelativeOffset", function() return TY(o.SizeRelativeOffset, "Vector3") end)
    T("prop.type.ConeHandleAdornment.ZIndex", function() return TY(o.ZIndex, "number") end)
end
do
    local o = Instance.new("ControllerManager")
    T("prop.type.ControllerManager.ActiveController", function() return TY(o.ActiveController, "nil") end)
    T("prop.type.ControllerManager.BaseMoveSpeed", function() return TY(o.BaseMoveSpeed, "number") end)
    T("prop.type.ControllerManager.BaseTurnSpeed", function() return TY(o.BaseTurnSpeed, "number") end)
    T("prop.type.ControllerManager.ClimbSensor", function() return TY(o.ClimbSensor, "nil") end)
    T("prop.type.ControllerManager.FacingDirection", function() return TY(o.FacingDirection, "Vector3") end)
    T("prop.type.ControllerManager.GroundSensor", function() return TY(o.GroundSensor, "nil") end)
    T("prop.type.ControllerManager.MovingDirection", function() return TY(o.MovingDirection, "Vector3") end)
    T("prop.type.ControllerManager.RootPart", function() return TY(o.RootPart, "nil") end)
    T("prop.type.ControllerManager.UpDirection", function() return TY(o.UpDirection, "Vector3") end)
end
do
    local o = Instance.new("ControllerPartSensor")
    T("prop.type.ControllerPartSensor.HitFrame", function() return TY(o.HitFrame, "CFrame") end)
    T("prop.type.ControllerPartSensor.HitNormal", function() return TY(o.HitNormal, "Vector3") end)
    T("prop.type.ControllerPartSensor.LadderSearchHeight", function() return TY(o.LadderSearchHeight, "number") end)
    T("prop.type.ControllerPartSensor.LadderSearchOffset", function() return TY(o.LadderSearchOffset, "number") end)
    T("prop.type.ControllerPartSensor.SearchDistance", function() return TY(o.SearchDistance, "number") end)
    T("prop.type.ControllerPartSensor.SensedMaterial", function() local v = o.SensedMaterial; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.Material) end)
    T("prop.type.ControllerPartSensor.SensedPart", function() return TY(o.SensedPart, "nil") end)
    T("prop.type.ControllerPartSensor.SensorMode", function() local v = o.SensorMode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.SensorMode) end)
    T("prop.type.ControllerPartSensor.UpdateType", function() local v = o.UpdateType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.SensorUpdateType) end)
end
do
    local o = Instance.new("CurveAnimation")
    T("prop.type.CurveAnimation.Length", function() return TY(o.Length, "number") end)
    T("prop.type.CurveAnimation.Loop", function() return TY(o.Loop, "boolean") end)
    T("prop.type.CurveAnimation.Priority", function() local v = o.Priority; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.AnimationPriority) end)
end
do
    local o = Instance.new("CustomEventReceiver")
    T("prop.type.CustomEventReceiver.Source", function() return TY(o.Source, "nil") end)
end
do
    local o = Instance.new("CylinderHandleAdornment")
    T("prop.type.CylinderHandleAdornment.Angle", function() return TY(o.Angle, "number") end)
    T("prop.type.CylinderHandleAdornment.Height", function() return TY(o.Height, "number") end)
    T("prop.type.CylinderHandleAdornment.InnerRadius", function() return TY(o.InnerRadius, "number") end)
    T("prop.type.CylinderHandleAdornment.Radius", function() return TY(o.Radius, "number") end)
    T("prop.type.CylinderHandleAdornment.Shading", function() local v = o.Shading; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.AdornShading) end)
end
do
    local o = Instance.new("CylinderMesh")
    T("prop.type.CylinderMesh.Offset", function() return TY(o.Offset, "Vector3") end)
    T("prop.type.CylinderMesh.Scale", function() return TY(o.Scale, "Vector3") end)
    T("prop.type.CylinderMesh.VertexColor", function() return TY(o.VertexColor, "Vector3") end)
end
do
    local o = Instance.new("CylindricalConstraint")
    T("prop.type.CylindricalConstraint.ActuatorType", function() local v = o.ActuatorType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.ActuatorType) end)
    T("prop.type.CylindricalConstraint.AngularActuatorType", function() local v = o.AngularActuatorType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.ActuatorType) end)
    T("prop.type.CylindricalConstraint.AngularLimitsEnabled", function() return TY(o.AngularLimitsEnabled, "boolean") end)
    T("prop.type.CylindricalConstraint.AngularResponsiveness", function() return TY(o.AngularResponsiveness, "number") end)
    T("prop.type.CylindricalConstraint.AngularRestitution", function() return TY(o.AngularRestitution, "number") end)
    T("prop.type.CylindricalConstraint.AngularSpeed", function() return TY(o.AngularSpeed, "number") end)
    T("prop.type.CylindricalConstraint.AngularVelocity", function() return TY(o.AngularVelocity, "number") end)
    T("prop.type.CylindricalConstraint.Color", function() return TY(o.Color, "BrickColor") end)
    T("prop.type.CylindricalConstraint.CurrentAngle", function() return TY(o.CurrentAngle, "number") end)
    T("prop.type.CylindricalConstraint.CurrentPosition", function() return TY(o.CurrentPosition, "number") end)
    T("prop.type.CylindricalConstraint.InclinationAngle", function() return TY(o.InclinationAngle, "number") end)
    T("prop.type.CylindricalConstraint.LimitsEnabled", function() return TY(o.LimitsEnabled, "boolean") end)
    T("prop.type.CylindricalConstraint.LinearResponsiveness", function() return TY(o.LinearResponsiveness, "number") end)
    T("prop.type.CylindricalConstraint.LowerAngle", function() return TY(o.LowerAngle, "number") end)
    T("prop.type.CylindricalConstraint.LowerLimit", function() return TY(o.LowerLimit, "number") end)
    T("prop.type.CylindricalConstraint.MotorMaxAcceleration", function() return TY(o.MotorMaxAcceleration, "number") end)
    T("prop.type.CylindricalConstraint.MotorMaxAngularAcceleration", function() return TY(o.MotorMaxAngularAcceleration, "number") end)
    T("prop.type.CylindricalConstraint.MotorMaxForce", function() return TY(o.MotorMaxForce, "number") end)
    T("prop.type.CylindricalConstraint.MotorMaxTorque", function() return TY(o.MotorMaxTorque, "number") end)
    T("prop.type.CylindricalConstraint.Restitution", function() return TY(o.Restitution, "number") end)
    T("prop.type.CylindricalConstraint.RotationAxisVisible", function() return TY(o.RotationAxisVisible, "boolean") end)
    T("prop.type.CylindricalConstraint.ServoMaxForce", function() return TY(o.ServoMaxForce, "number") end)
    T("prop.type.CylindricalConstraint.ServoMaxTorque", function() return TY(o.ServoMaxTorque, "number") end)
    T("prop.type.CylindricalConstraint.Size", function() return TY(o.Size, "number") end)
    T("prop.type.CylindricalConstraint.SoftlockAngularServoUponReachingTarget", function() return TY(o.SoftlockAngularServoUponReachingTarget, "boolean") end)
    T("prop.type.CylindricalConstraint.SoftlockServoUponReachingTarget", function() return TY(o.SoftlockServoUponReachingTarget, "boolean") end)
    T("prop.type.CylindricalConstraint.Speed", function() return TY(o.Speed, "number") end)
    T("prop.type.CylindricalConstraint.TargetAngle", function() return TY(o.TargetAngle, "number") end)
    T("prop.type.CylindricalConstraint.TargetPosition", function() return TY(o.TargetPosition, "number") end)
    T("prop.type.CylindricalConstraint.UpperAngle", function() return TY(o.UpperAngle, "number") end)
    T("prop.type.CylindricalConstraint.UpperLimit", function() return TY(o.UpperLimit, "number") end)
    T("prop.type.CylindricalConstraint.Velocity", function() return TY(o.Velocity, "number") end)
    T("prop.type.CylindricalConstraint.WorldRotationAxis", function() return TY(o.WorldRotationAxis, "Vector3") end)
end
do
    local o = Instance.new("DataStoreGetOptions")
    T("prop.type.DataStoreGetOptions.UseCache", function() return TY(o.UseCache, "boolean") end)
end
do
    local o = Instance.new("DataStoreOptions")
    T("prop.type.DataStoreOptions.AllScopes", function() return TY(o.AllScopes, "boolean") end)
end
do
    local o = Instance.new("Dialog")
    T("prop.type.Dialog.BehaviorType", function() local v = o.BehaviorType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.DialogBehaviorType) end)
    T("prop.type.Dialog.ConversationDistance", function() return TY(o.ConversationDistance, "number") end)
    T("prop.type.Dialog.GoodbyeChoiceActive", function() return TY(o.GoodbyeChoiceActive, "boolean") end)
    T("prop.type.Dialog.GoodbyeDialog", function() return TY(o.GoodbyeDialog, "string") end)
    T("prop.type.Dialog.InUse", function() return TY(o.InUse, "boolean") end)
    T("prop.type.Dialog.InitialPrompt", function() return TY(o.InitialPrompt, "string") end)
    T("prop.type.Dialog.Purpose", function() local v = o.Purpose; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.DialogPurpose) end)
    T("prop.type.Dialog.Tone", function() local v = o.Tone; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.DialogTone) end)
    T("prop.type.Dialog.TriggerDistance", function() return TY(o.TriggerDistance, "number") end)
    T("prop.type.Dialog.TriggerOffset", function() return TY(o.TriggerOffset, "Vector3") end)
end
do
    local o = Instance.new("DialogChoice")
    T("prop.type.DialogChoice.GoodbyeChoiceActive", function() return TY(o.GoodbyeChoiceActive, "boolean") end)
    T("prop.type.DialogChoice.GoodbyeDialog", function() return TY(o.GoodbyeDialog, "string") end)
    T("prop.type.DialogChoice.ResponseDialog", function() return TY(o.ResponseDialog, "string") end)
    T("prop.type.DialogChoice.UserDialog", function() return TY(o.UserDialog, "string") end)
end
do
    local o = Instance.new("DigitsRigDescription")
    T("prop.type.DigitsRigDescription.Index1", function() return TY(o.Index1, "nil") end)
    T("prop.type.DigitsRigDescription.Index1TposeAdjustment", function() return TY(o.Index1TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Index2", function() return TY(o.Index2, "nil") end)
    T("prop.type.DigitsRigDescription.Index2TposeAdjustment", function() return TY(o.Index2TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Index3", function() return TY(o.Index3, "nil") end)
    T("prop.type.DigitsRigDescription.Index3TposeAdjustment", function() return TY(o.Index3TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.IndexRange", function() return TY(o.IndexRange, "Vector3") end)
    T("prop.type.DigitsRigDescription.IndexSize", function() return TY(o.IndexSize, "number") end)
    T("prop.type.DigitsRigDescription.Middle1", function() return TY(o.Middle1, "nil") end)
    T("prop.type.DigitsRigDescription.Middle1TposeAdjustment", function() return TY(o.Middle1TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Middle2", function() return TY(o.Middle2, "nil") end)
    T("prop.type.DigitsRigDescription.Middle2TposeAdjustment", function() return TY(o.Middle2TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Middle3", function() return TY(o.Middle3, "nil") end)
    T("prop.type.DigitsRigDescription.Middle3TposeAdjustment", function() return TY(o.Middle3TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.MiddleRange", function() return TY(o.MiddleRange, "Vector3") end)
    T("prop.type.DigitsRigDescription.MiddleSize", function() return TY(o.MiddleSize, "number") end)
    T("prop.type.DigitsRigDescription.Pinky1", function() return TY(o.Pinky1, "nil") end)
    T("prop.type.DigitsRigDescription.Pinky1TposeAdjustment", function() return TY(o.Pinky1TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Pinky2", function() return TY(o.Pinky2, "nil") end)
    T("prop.type.DigitsRigDescription.Pinky2TposeAdjustment", function() return TY(o.Pinky2TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Pinky3", function() return TY(o.Pinky3, "nil") end)
    T("prop.type.DigitsRigDescription.Pinky3TposeAdjustment", function() return TY(o.Pinky3TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.PinkyRange", function() return TY(o.PinkyRange, "Vector3") end)
    T("prop.type.DigitsRigDescription.PinkySize", function() return TY(o.PinkySize, "number") end)
    T("prop.type.DigitsRigDescription.Ring1", function() return TY(o.Ring1, "nil") end)
    T("prop.type.DigitsRigDescription.Ring1TposeAdjustment", function() return TY(o.Ring1TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Ring2", function() return TY(o.Ring2, "nil") end)
    T("prop.type.DigitsRigDescription.Ring2TposeAdjustment", function() return TY(o.Ring2TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Ring3", function() return TY(o.Ring3, "nil") end)
    T("prop.type.DigitsRigDescription.Ring3TposeAdjustment", function() return TY(o.Ring3TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.RingRange", function() return TY(o.RingRange, "Vector3") end)
    T("prop.type.DigitsRigDescription.RingSize", function() return TY(o.RingSize, "number") end)
    T("prop.type.DigitsRigDescription.Side", function() local v = o.Side; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.DigitsRigDescriptionSide) end)
    T("prop.type.DigitsRigDescription.Thumb1", function() return TY(o.Thumb1, "nil") end)
    T("prop.type.DigitsRigDescription.Thumb1TposeAdjustment", function() return TY(o.Thumb1TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Thumb2", function() return TY(o.Thumb2, "nil") end)
    T("prop.type.DigitsRigDescription.Thumb2TposeAdjustment", function() return TY(o.Thumb2TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.Thumb3", function() return TY(o.Thumb3, "nil") end)
    T("prop.type.DigitsRigDescription.Thumb3TposeAdjustment", function() return TY(o.Thumb3TposeAdjustment, "CFrame") end)
    T("prop.type.DigitsRigDescription.ThumbRange", function() return TY(o.ThumbRange, "Vector3") end)
    T("prop.type.DigitsRigDescription.ThumbSize", function() return TY(o.ThumbSize, "number") end)
end
do
    local o = Instance.new("DistortionSoundEffect")
    T("prop.type.DistortionSoundEffect.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.DistortionSoundEffect.Level", function() return TY(o.Level, "number") end)
    T("prop.type.DistortionSoundEffect.Priority", function() return TY(o.Priority, "number") end)
end
do
    local o = Instance.new("DoubleConstrainedValue")
    T("prop.type.DoubleConstrainedValue.ConstrainedValue", function() return TY(o.ConstrainedValue, "number") end)
    T("prop.type.DoubleConstrainedValue.MaxValue", function() return TY(o.MaxValue, "number") end)
    T("prop.type.DoubleConstrainedValue.MinValue", function() return TY(o.MinValue, "number") end)
    T("prop.type.DoubleConstrainedValue.Value", function() return TY(o.Value, "number") end)
end
do
    local o = Instance.new("DragDetector")
    T("prop.type.DragDetector.ActivatedCursorIcon", function() return TY(o.ActivatedCursorIcon, "string") end)
    T("prop.type.DragDetector.ActivatedCursorIconContent", function() return TY(o.ActivatedCursorIconContent, "Content") end)
    T("prop.type.DragDetector.ApplyAtCenterOfMass", function() return TY(o.ApplyAtCenterOfMass, "boolean") end)
    T("prop.type.DragDetector.Axis", function() return TY(o.Axis, "Vector3") end)
    T("prop.type.DragDetector.CursorIcon", function() return TY(o.CursorIcon, "string") end)
    T("prop.type.DragDetector.CursorIconContent", function() return TY(o.CursorIconContent, "Content") end)
    T("prop.type.DragDetector.DragFrame", function() return TY(o.DragFrame, "CFrame") end)
    T("prop.type.DragDetector.DragStyle", function() local v = o.DragStyle; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.DragDetectorDragStyle) end)
    T("prop.type.DragDetector.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.DragDetector.GamepadModeSwitchKeyCode", function() local v = o.GamepadModeSwitchKeyCode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.DragDetector.KeyboardModeSwitchKeyCode", function() local v = o.KeyboardModeSwitchKeyCode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.DragDetector.MaxActivationDistance", function() return TY(o.MaxActivationDistance, "number") end)
    T("prop.type.DragDetector.MaxDragAngle", function() return TY(o.MaxDragAngle, "number") end)
    T("prop.type.DragDetector.MaxDragTranslation", function() return TY(o.MaxDragTranslation, "Vector3") end)
    T("prop.type.DragDetector.MaxForce", function() return TY(o.MaxForce, "number") end)
    T("prop.type.DragDetector.MaxTorque", function() return TY(o.MaxTorque, "number") end)
    T("prop.type.DragDetector.MinDragAngle", function() return TY(o.MinDragAngle, "number") end)
    T("prop.type.DragDetector.MinDragTranslation", function() return TY(o.MinDragTranslation, "Vector3") end)
    T("prop.type.DragDetector.Orientation", function() return TY(o.Orientation, "Vector3") end)
    T("prop.type.DragDetector.PermissionPolicy", function() local v = o.PermissionPolicy; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.DragDetectorPermissionPolicy) end)
    T("prop.type.DragDetector.ReferenceInstance", function() return TY(o.ReferenceInstance, "nil") end)
    T("prop.type.DragDetector.ResponseStyle", function() local v = o.ResponseStyle; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.DragDetectorResponseStyle) end)
    T("prop.type.DragDetector.Responsiveness", function() return TY(o.Responsiveness, "number") end)
    T("prop.type.DragDetector.RunLocally", function() return TY(o.RunLocally, "boolean") end)
    T("prop.type.DragDetector.SecondaryAxis", function() return TY(o.SecondaryAxis, "Vector3") end)
    T("prop.type.DragDetector.TrackballRadialPullFactor", function() return TY(o.TrackballRadialPullFactor, "number") end)
    T("prop.type.DragDetector.TrackballRollFactor", function() return TY(o.TrackballRollFactor, "number") end)
    T("prop.type.DragDetector.VRSwitchKeyCode", function() local v = o.VRSwitchKeyCode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.DragDetector.WorldAxis", function() return TY(o.WorldAxis, "Vector3") end)
    T("prop.type.DragDetector.WorldSecondaryAxis", function() return TY(o.WorldSecondaryAxis, "Vector3") end)
end
do
    local o = Instance.new("EchoSoundEffect")
    T("prop.type.EchoSoundEffect.Delay", function() return TY(o.Delay, "number") end)
    T("prop.type.EchoSoundEffect.DryLevel", function() return TY(o.DryLevel, "number") end)
    T("prop.type.EchoSoundEffect.Feedback", function() return TY(o.Feedback, "number") end)
    T("prop.type.EchoSoundEffect.WetLevel", function() return TY(o.WetLevel, "number") end)
end
do
    local o = Instance.new("EqualizerSoundEffect")
    T("prop.type.EqualizerSoundEffect.HighGain", function() return TY(o.HighGain, "number") end)
    T("prop.type.EqualizerSoundEffect.LowGain", function() return TY(o.LowGain, "number") end)
    T("prop.type.EqualizerSoundEffect.MidGain", function() return TY(o.MidGain, "number") end)
end
do
    local o = Instance.new("EulerRotationCurve")
    T("prop.type.EulerRotationCurve.RotationOrder", function() local v = o.RotationOrder; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.RotationOrder) end)
end
do
    local o = Instance.new("ExperienceInviteOptions")
    T("prop.type.ExperienceInviteOptions.InviteMessageId", function() return TY(o.InviteMessageId, "string") end)
    T("prop.type.ExperienceInviteOptions.InviteUser", function() return TY(o.InviteUser, "number") end)
    T("prop.type.ExperienceInviteOptions.LaunchData", function() return TY(o.LaunchData, "string") end)
    T("prop.type.ExperienceInviteOptions.PromptMessage", function() return TY(o.PromptMessage, "string") end)
end
do
    local o = Instance.new("FaceControls")
    T("prop.type.FaceControls.ChinRaiser", function() return TY(o.ChinRaiser, "number") end)
    T("prop.type.FaceControls.ChinRaiserUpperLip", function() return TY(o.ChinRaiserUpperLip, "number") end)
    T("prop.type.FaceControls.Corrugator", function() return TY(o.Corrugator, "number") end)
    T("prop.type.FaceControls.EyesLookDown", function() return TY(o.EyesLookDown, "number") end)
    T("prop.type.FaceControls.EyesLookLeft", function() return TY(o.EyesLookLeft, "number") end)
    T("prop.type.FaceControls.EyesLookRight", function() return TY(o.EyesLookRight, "number") end)
    T("prop.type.FaceControls.EyesLookUp", function() return TY(o.EyesLookUp, "number") end)
    T("prop.type.FaceControls.FlatPucker", function() return TY(o.FlatPucker, "number") end)
    T("prop.type.FaceControls.Funneler", function() return TY(o.Funneler, "number") end)
    T("prop.type.FaceControls.JawDrop", function() return TY(o.JawDrop, "number") end)
    T("prop.type.FaceControls.JawLeft", function() return TY(o.JawLeft, "number") end)
    T("prop.type.FaceControls.JawRight", function() return TY(o.JawRight, "number") end)
    T("prop.type.FaceControls.LeftBrowLowerer", function() return TY(o.LeftBrowLowerer, "number") end)
    T("prop.type.FaceControls.LeftCheekPuff", function() return TY(o.LeftCheekPuff, "number") end)
    T("prop.type.FaceControls.LeftCheekRaiser", function() return TY(o.LeftCheekRaiser, "number") end)
    T("prop.type.FaceControls.LeftDimpler", function() return TY(o.LeftDimpler, "number") end)
    T("prop.type.FaceControls.LeftEyeClosed", function() return TY(o.LeftEyeClosed, "number") end)
    T("prop.type.FaceControls.LeftEyeUpperLidRaiser", function() return TY(o.LeftEyeUpperLidRaiser, "number") end)
    T("prop.type.FaceControls.LeftInnerBrowRaiser", function() return TY(o.LeftInnerBrowRaiser, "number") end)
    T("prop.type.FaceControls.LeftLipCornerDown", function() return TY(o.LeftLipCornerDown, "number") end)
    T("prop.type.FaceControls.LeftLipCornerPuller", function() return TY(o.LeftLipCornerPuller, "number") end)
    T("prop.type.FaceControls.LeftLipStretcher", function() return TY(o.LeftLipStretcher, "number") end)
    T("prop.type.FaceControls.LeftLowerLipDepressor", function() return TY(o.LeftLowerLipDepressor, "number") end)
    T("prop.type.FaceControls.LeftNoseWrinkler", function() return TY(o.LeftNoseWrinkler, "number") end)
    T("prop.type.FaceControls.LeftOuterBrowRaiser", function() return TY(o.LeftOuterBrowRaiser, "number") end)
    T("prop.type.FaceControls.LeftUpperLipRaiser", function() return TY(o.LeftUpperLipRaiser, "number") end)
    T("prop.type.FaceControls.LipPresser", function() return TY(o.LipPresser, "number") end)
    T("prop.type.FaceControls.LipsTogether", function() return TY(o.LipsTogether, "number") end)
    T("prop.type.FaceControls.LowerLipSuck", function() return TY(o.LowerLipSuck, "number") end)
    T("prop.type.FaceControls.MouthLeft", function() return TY(o.MouthLeft, "number") end)
    T("prop.type.FaceControls.MouthRight", function() return TY(o.MouthRight, "number") end)
    T("prop.type.FaceControls.Pucker", function() return TY(o.Pucker, "number") end)
    T("prop.type.FaceControls.RightBrowLowerer", function() return TY(o.RightBrowLowerer, "number") end)
    T("prop.type.FaceControls.RightCheekPuff", function() return TY(o.RightCheekPuff, "number") end)
    T("prop.type.FaceControls.RightCheekRaiser", function() return TY(o.RightCheekRaiser, "number") end)
    T("prop.type.FaceControls.RightDimpler", function() return TY(o.RightDimpler, "number") end)
    T("prop.type.FaceControls.RightEyeClosed", function() return TY(o.RightEyeClosed, "number") end)
    T("prop.type.FaceControls.RightEyeUpperLidRaiser", function() return TY(o.RightEyeUpperLidRaiser, "number") end)
    T("prop.type.FaceControls.RightInnerBrowRaiser", function() return TY(o.RightInnerBrowRaiser, "number") end)
    T("prop.type.FaceControls.RightLipCornerDown", function() return TY(o.RightLipCornerDown, "number") end)
    T("prop.type.FaceControls.RightLipCornerPuller", function() return TY(o.RightLipCornerPuller, "number") end)
    T("prop.type.FaceControls.RightLipStretcher", function() return TY(o.RightLipStretcher, "number") end)
    T("prop.type.FaceControls.RightLowerLipDepressor", function() return TY(o.RightLowerLipDepressor, "number") end)
    T("prop.type.FaceControls.RightNoseWrinkler", function() return TY(o.RightNoseWrinkler, "number") end)
    T("prop.type.FaceControls.RightOuterBrowRaiser", function() return TY(o.RightOuterBrowRaiser, "number") end)
    T("prop.type.FaceControls.RightUpperLipRaiser", function() return TY(o.RightUpperLipRaiser, "number") end)
    T("prop.type.FaceControls.TongueDown", function() return TY(o.TongueDown, "number") end)
    T("prop.type.FaceControls.TongueOut", function() return TY(o.TongueOut, "number") end)
    T("prop.type.FaceControls.TongueUp", function() return TY(o.TongueUp, "number") end)
    T("prop.type.FaceControls.UpperLipSuck", function() return TY(o.UpperLipSuck, "number") end)
end
do
    local o = Instance.new("FileMesh")
    T("prop.type.FileMesh.MeshContent", function() return TY(o.MeshContent, "Content") end)
    T("prop.type.FileMesh.MeshId", function() return TY(o.MeshId, "string") end)
    T("prop.type.FileMesh.Offset", function() return TY(o.Offset, "Vector3") end)
    T("prop.type.FileMesh.Scale", function() return TY(o.Scale, "Vector3") end)
    T("prop.type.FileMesh.TextureContent", function() return TY(o.TextureContent, "Content") end)
    T("prop.type.FileMesh.TextureId", function() return TY(o.TextureId, "string") end)
    T("prop.type.FileMesh.VertexColor", function() return TY(o.VertexColor, "Vector3") end)
end
do
    local o = Instance.new("Flag")
    T("prop.type.Flag.CanBeDropped", function() return TY(o.CanBeDropped, "boolean") end)
    T("prop.type.Flag.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.Flag.Grip", function() return TY(o.Grip, "CFrame") end)
    T("prop.type.Flag.GripForward", function() return TY(o.GripForward, "Vector3") end)
    T("prop.type.Flag.GripPos", function() return TY(o.GripPos, "Vector3") end)
    T("prop.type.Flag.GripRight", function() return TY(o.GripRight, "Vector3") end)
    T("prop.type.Flag.GripUp", function() return TY(o.GripUp, "Vector3") end)
    T("prop.type.Flag.ManualActivationOnly", function() return TY(o.ManualActivationOnly, "boolean") end)
    T("prop.type.Flag.RequiresHandle", function() return TY(o.RequiresHandle, "boolean") end)
    T("prop.type.Flag.TeamColor", function() return TY(o.TeamColor, "BrickColor") end)
    T("prop.type.Flag.TextureContent", function() return TY(o.TextureContent, "Content") end)
    T("prop.type.Flag.TextureId", function() return TY(o.TextureId, "string") end)
    T("prop.type.Flag.ToolTip", function() return TY(o.ToolTip, "string") end)
end
do
    local o = Instance.new("FlagStand")
    T("prop.type.FlagStand.TeamColor", function() return TY(o.TeamColor, "BrickColor") end)
    T("prop.type.FlagStand.TopSurface", function() local v = o.TopSurface; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.SurfaceType) end)
end
do
    local o = Instance.new("FlangeSoundEffect")
    T("prop.type.FlangeSoundEffect.Depth", function() return TY(o.Depth, "number") end)
    T("prop.type.FlangeSoundEffect.Mix", function() return TY(o.Mix, "number") end)
    T("prop.type.FlangeSoundEffect.Rate", function() return TY(o.Rate, "number") end)
end
do
    local o = Instance.new("FloatCurve")
    T("prop.type.FloatCurve.Length", function() return TY(o.Length, "number") end)
end
do
    local o = Instance.new("FloorWire")
    T("prop.type.FloorWire.CycleOffset", function() return TY(o.CycleOffset, "number") end)
    T("prop.type.FloorWire.From", function() return TY(o.From, "nil") end)
    T("prop.type.FloorWire.StudsBetweenTextures", function() return TY(o.StudsBetweenTextures, "number") end)
    T("prop.type.FloorWire.Texture", function() return TY(o.Texture, "string") end)
    T("prop.type.FloorWire.TextureSize", function() return TY(o.TextureSize, "Vector2") end)
    T("prop.type.FloorWire.To", function() return TY(o.To, "nil") end)
    T("prop.type.FloorWire.Velocity", function() return TY(o.Velocity, "number") end)
    T("prop.type.FloorWire.WireRadius", function() return TY(o.WireRadius, "number") end)
end
do
    local o = Instance.new("FluidForceSensor")
    T("prop.type.FluidForceSensor.BuoyancyForce", function() return TY(o.BuoyancyForce, "Vector3") end)
    T("prop.type.FluidForceSensor.BuoyancyTorque", function() return TY(o.BuoyancyTorque, "Vector3") end)
    T("prop.type.FluidForceSensor.CenterOfPressure", function() return TY(o.CenterOfPressure, "Vector3") end)
    T("prop.type.FluidForceSensor.Force", function() return TY(o.Force, "Vector3") end)
    T("prop.type.FluidForceSensor.Torque", function() return TY(o.Torque, "Vector3") end)
end
do
    local o = Instance.new("ForceField")
    T("prop.type.ForceField.Visible", function() return TY(o.Visible, "boolean") end)
end
do
    local o = Instance.new("GetTextBoundsParams")
    T("prop.type.GetTextBoundsParams.Font", function() return TY(o.Font, "Font") end)
    T("prop.type.GetTextBoundsParams.RichText", function() return TY(o.RichText, "boolean") end)
    T("prop.type.GetTextBoundsParams.Size", function() return TY(o.Size, "number") end)
    T("prop.type.GetTextBoundsParams.Text", function() return TY(o.Text, "string") end)
    T("prop.type.GetTextBoundsParams.Width", function() return TY(o.Width, "number") end)
end
do
    local o = Instance.new("Glue")
    T("prop.type.Glue.Active", function() return TY(o.Active, "boolean") end)
    T("prop.type.Glue.C0", function() return TY(o.C0, "CFrame") end)
    T("prop.type.Glue.C1", function() return TY(o.C1, "CFrame") end)
    T("prop.type.Glue.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.Glue.F0", function() return TY(o.F0, "Vector3") end)
    T("prop.type.Glue.F1", function() return TY(o.F1, "Vector3") end)
    T("prop.type.Glue.F2", function() return TY(o.F2, "Vector3") end)
    T("prop.type.Glue.F3", function() return TY(o.F3, "Vector3") end)
    T("prop.type.Glue.Part0", function() return TY(o.Part0, "nil") end)
    T("prop.type.Glue.Part1", function() return TY(o.Part1, "nil") end)
    T("prop.type.Glue.part1", function() return TY(o.part1, "nil") end)
end
do
    local o = Instance.new("GroundController")
    T("prop.type.GroundController.AccelerationLean", function() return TY(o.AccelerationLean, "number") end)
    T("prop.type.GroundController.AccelerationTime", function() return TY(o.AccelerationTime, "number") end)
    T("prop.type.GroundController.Active", function() return TY(o.Active, "boolean") end)
    T("prop.type.GroundController.BalanceMaxTorque", function() return TY(o.BalanceMaxTorque, "number") end)
    T("prop.type.GroundController.BalanceRigidityEnabled", function() return TY(o.BalanceRigidityEnabled, "boolean") end)
    T("prop.type.GroundController.BalanceSpeed", function() return TY(o.BalanceSpeed, "number") end)
    T("prop.type.GroundController.DecelerationTime", function() return TY(o.DecelerationTime, "number") end)
    T("prop.type.GroundController.Friction", function() return TY(o.Friction, "number") end)
    T("prop.type.GroundController.FrictionWeight", function() return TY(o.FrictionWeight, "number") end)
    T("prop.type.GroundController.GroundOffset", function() return TY(o.GroundOffset, "number") end)
    T("prop.type.GroundController.MoveSpeedFactor", function() return TY(o.MoveSpeedFactor, "number") end)
    T("prop.type.GroundController.StandForce", function() return TY(o.StandForce, "number") end)
    T("prop.type.GroundController.StandSpeed", function() return TY(o.StandSpeed, "number") end)
    T("prop.type.GroundController.TurnSpeedFactor", function() return TY(o.TurnSpeedFactor, "number") end)
end
do
    local o = Instance.new("GuiMain")
    T("prop.type.GuiMain.ClipToDeviceSafeArea", function() return TY(o.ClipToDeviceSafeArea, "boolean") end)
    T("prop.type.GuiMain.DisplayOrder", function() return TY(o.DisplayOrder, "number") end)
    T("prop.type.GuiMain.IgnoreGuiInset", function() return TY(o.IgnoreGuiInset, "boolean") end)
    T("prop.type.GuiMain.SafeAreaCompatibility", function() local v = o.SafeAreaCompatibility; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.SafeAreaCompatibility) end)
    T("prop.type.GuiMain.ScreenInsets", function() local v = o.ScreenInsets; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.ScreenInsets) end)
end
do
    local o = Instance.new("Handles")
    T("prop.type.Handles.Adornee", function() return TY(o.Adornee, "nil") end)
    T("prop.type.Handles.Faces", function() return TY(o.Faces, "Faces") end)
    T("prop.type.Handles.Style", function() local v = o.Style; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.HandlesStyle) end)
end
do
    local o = Instance.new("Hat")
    T("prop.type.Hat.AttachmentForward", function() return TY(o.AttachmentForward, "Vector3") end)
    T("prop.type.Hat.AttachmentPoint", function() return TY(o.AttachmentPoint, "CFrame") end)
    T("prop.type.Hat.AttachmentPos", function() return TY(o.AttachmentPos, "Vector3") end)
    T("prop.type.Hat.AttachmentRight", function() return TY(o.AttachmentRight, "Vector3") end)
    T("prop.type.Hat.AttachmentUp", function() return TY(o.AttachmentUp, "Vector3") end)
end
do
    local o = Instance.new("Hint")
    T("prop.type.Hint.Text", function() return TY(o.Text, "string") end)
end
do
    local o = Instance.new("Hole")
    T("prop.type.Hole.FaceId", function() local v = o.FaceId; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.NormalId) end)
    T("prop.type.Hole.InOut", function() local v = o.InOut; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.InOut) end)
    T("prop.type.Hole.LeftRight", function() local v = o.LeftRight; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.LeftRight) end)
    T("prop.type.Hole.TopBottom", function() local v = o.TopBottom; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.TopBottom) end)
end
do
    local o = Instance.new("HopperBin")
    T("prop.type.HopperBin.Active", function() return TY(o.Active, "boolean") end)
    T("prop.type.HopperBin.BinType", function() local v = o.BinType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.BinType) end)
    T("prop.type.HopperBin.TextureContent", function() return TY(o.TextureContent, "Content") end)
    T("prop.type.HopperBin.TextureId", function() return TY(o.TextureId, "string") end)
end
do
    local o = Instance.new("HumanoidDescription")
    T("prop.type.HumanoidDescription.BackAccessory", function() return TY(o.BackAccessory, "string") end)
    T("prop.type.HumanoidDescription.BodyTypeScale", function() return TY(o.BodyTypeScale, "number") end)
    T("prop.type.HumanoidDescription.ClimbAnimation", function() return TY(o.ClimbAnimation, "number") end)
    T("prop.type.HumanoidDescription.DepthScale", function() return TY(o.DepthScale, "number") end)
    T("prop.type.HumanoidDescription.Face", function() return TY(o.Face, "number") end)
    T("prop.type.HumanoidDescription.FaceAccessory", function() return TY(o.FaceAccessory, "string") end)
    T("prop.type.HumanoidDescription.FallAnimation", function() return TY(o.FallAnimation, "number") end)
    T("prop.type.HumanoidDescription.FrontAccessory", function() return TY(o.FrontAccessory, "string") end)
    T("prop.type.HumanoidDescription.GraphicTShirt", function() return TY(o.GraphicTShirt, "number") end)
    T("prop.type.HumanoidDescription.HairAccessory", function() return TY(o.HairAccessory, "string") end)
    T("prop.type.HumanoidDescription.HatAccessory", function() return TY(o.HatAccessory, "string") end)
    T("prop.type.HumanoidDescription.Head", function() return TY(o.Head, "number") end)
    T("prop.type.HumanoidDescription.HeadColor", function() return TY(o.HeadColor, "Color3") end)
    T("prop.type.HumanoidDescription.HeadScale", function() return TY(o.HeadScale, "number") end)
    T("prop.type.HumanoidDescription.HeightScale", function() return TY(o.HeightScale, "number") end)
    T("prop.type.HumanoidDescription.IdleAnimation", function() return TY(o.IdleAnimation, "number") end)
    T("prop.type.HumanoidDescription.JumpAnimation", function() return TY(o.JumpAnimation, "number") end)
    T("prop.type.HumanoidDescription.LeftArm", function() return TY(o.LeftArm, "number") end)
    T("prop.type.HumanoidDescription.LeftArmColor", function() return TY(o.LeftArmColor, "Color3") end)
    T("prop.type.HumanoidDescription.LeftLeg", function() return TY(o.LeftLeg, "number") end)
    T("prop.type.HumanoidDescription.LeftLegColor", function() return TY(o.LeftLegColor, "Color3") end)
    T("prop.type.HumanoidDescription.MoodAnimation", function() return TY(o.MoodAnimation, "number") end)
    T("prop.type.HumanoidDescription.NeckAccessory", function() return TY(o.NeckAccessory, "string") end)
    T("prop.type.HumanoidDescription.Pants", function() return TY(o.Pants, "number") end)
    T("prop.type.HumanoidDescription.ProportionScale", function() return TY(o.ProportionScale, "number") end)
    T("prop.type.HumanoidDescription.RightArm", function() return TY(o.RightArm, "number") end)
    T("prop.type.HumanoidDescription.RightArmColor", function() return TY(o.RightArmColor, "Color3") end)
    T("prop.type.HumanoidDescription.RightLeg", function() return TY(o.RightLeg, "number") end)
    T("prop.type.HumanoidDescription.RightLegColor", function() return TY(o.RightLegColor, "Color3") end)
    T("prop.type.HumanoidDescription.RunAnimation", function() return TY(o.RunAnimation, "number") end)
    T("prop.type.HumanoidDescription.Shirt", function() return TY(o.Shirt, "number") end)
    T("prop.type.HumanoidDescription.ShouldersAccessory", function() return TY(o.ShouldersAccessory, "string") end)
    T("prop.type.HumanoidDescription.StaticFacialAnimation", function() return TY(o.StaticFacialAnimation, "boolean") end)
    T("prop.type.HumanoidDescription.SwimAnimation", function() return TY(o.SwimAnimation, "number") end)
    T("prop.type.HumanoidDescription.Torso", function() return TY(o.Torso, "number") end)
    T("prop.type.HumanoidDescription.TorsoColor", function() return TY(o.TorsoColor, "Color3") end)
    T("prop.type.HumanoidDescription.UseAvatarSettings", function() return TY(o.UseAvatarSettings, "boolean") end)
    T("prop.type.HumanoidDescription.WaistAccessory", function() return TY(o.WaistAccessory, "string") end)
    T("prop.type.HumanoidDescription.WalkAnimation", function() return TY(o.WalkAnimation, "number") end)
    T("prop.type.HumanoidDescription.WidthScale", function() return TY(o.WidthScale, "number") end)
end
do
    local o = Instance.new("HumanoidRigDescription")
    T("prop.type.HumanoidRigDescription.Chest", function() return TY(o.Chest, "nil") end)
    T("prop.type.HumanoidRigDescription.ChestRangeMax", function() return TY(o.ChestRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.ChestRangeMin", function() return TY(o.ChestRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.ChestSize", function() return TY(o.ChestSize, "number") end)
    T("prop.type.HumanoidRigDescription.ChestTposeAdjustment", function() return TY(o.ChestTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.HeadBase", function() return TY(o.HeadBase, "nil") end)
    T("prop.type.HumanoidRigDescription.HeadBaseRangeMax", function() return TY(o.HeadBaseRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.HeadBaseRangeMin", function() return TY(o.HeadBaseRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.HeadBaseSize", function() return TY(o.HeadBaseSize, "number") end)
    T("prop.type.HumanoidRigDescription.HeadBaseTposeAdjustment", function() return TY(o.HeadBaseTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.LeftAnkle", function() return TY(o.LeftAnkle, "nil") end)
    T("prop.type.HumanoidRigDescription.LeftAnkleRangeMax", function() return TY(o.LeftAnkleRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftAnkleRangeMin", function() return TY(o.LeftAnkleRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftAnkleSize", function() return TY(o.LeftAnkleSize, "number") end)
    T("prop.type.HumanoidRigDescription.LeftAnkleTposeAdjustment", function() return TY(o.LeftAnkleTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.LeftClavicle", function() return TY(o.LeftClavicle, "nil") end)
    T("prop.type.HumanoidRigDescription.LeftClavicleRangeMax", function() return TY(o.LeftClavicleRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftClavicleRangeMin", function() return TY(o.LeftClavicleRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftClavicleSize", function() return TY(o.LeftClavicleSize, "number") end)
    T("prop.type.HumanoidRigDescription.LeftClavicleTposeAdjustment", function() return TY(o.LeftClavicleTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.LeftElbow", function() return TY(o.LeftElbow, "nil") end)
    T("prop.type.HumanoidRigDescription.LeftElbowRangeMax", function() return TY(o.LeftElbowRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftElbowRangeMin", function() return TY(o.LeftElbowRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftElbowSize", function() return TY(o.LeftElbowSize, "number") end)
    T("prop.type.HumanoidRigDescription.LeftElbowTposeAdjustment", function() return TY(o.LeftElbowTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.LeftHip", function() return TY(o.LeftHip, "nil") end)
    T("prop.type.HumanoidRigDescription.LeftHipRangeMax", function() return TY(o.LeftHipRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftHipRangeMin", function() return TY(o.LeftHipRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftHipSize", function() return TY(o.LeftHipSize, "number") end)
    T("prop.type.HumanoidRigDescription.LeftHipTposeAdjustment", function() return TY(o.LeftHipTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.LeftKnee", function() return TY(o.LeftKnee, "nil") end)
    T("prop.type.HumanoidRigDescription.LeftKneeRangeMax", function() return TY(o.LeftKneeRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftKneeRangeMin", function() return TY(o.LeftKneeRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftKneeSize", function() return TY(o.LeftKneeSize, "number") end)
    T("prop.type.HumanoidRigDescription.LeftKneeTposeAdjustment", function() return TY(o.LeftKneeTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.LeftShoulder", function() return TY(o.LeftShoulder, "nil") end)
    T("prop.type.HumanoidRigDescription.LeftShoulderRangeMax", function() return TY(o.LeftShoulderRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftShoulderRangeMin", function() return TY(o.LeftShoulderRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftShoulderSize", function() return TY(o.LeftShoulderSize, "number") end)
    T("prop.type.HumanoidRigDescription.LeftShoulderTposeAdjustment", function() return TY(o.LeftShoulderTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.LeftToeBase", function() return TY(o.LeftToeBase, "nil") end)
    T("prop.type.HumanoidRigDescription.LeftToeBaseRangeMax", function() return TY(o.LeftToeBaseRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftToeBaseRangeMin", function() return TY(o.LeftToeBaseRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftToeBaseSize", function() return TY(o.LeftToeBaseSize, "number") end)
    T("prop.type.HumanoidRigDescription.LeftToeBaseTposeAdjustment", function() return TY(o.LeftToeBaseTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.LeftWrist", function() return TY(o.LeftWrist, "nil") end)
    T("prop.type.HumanoidRigDescription.LeftWristRangeMax", function() return TY(o.LeftWristRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftWristRangeMin", function() return TY(o.LeftWristRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.LeftWristSize", function() return TY(o.LeftWristSize, "number") end)
    T("prop.type.HumanoidRigDescription.LeftWristTposeAdjustment", function() return TY(o.LeftWristTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.Neck", function() return TY(o.Neck, "nil") end)
    T("prop.type.HumanoidRigDescription.NeckRangeMax", function() return TY(o.NeckRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.NeckRangeMin", function() return TY(o.NeckRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.NeckSize", function() return TY(o.NeckSize, "number") end)
    T("prop.type.HumanoidRigDescription.NeckTposeAdjustment", function() return TY(o.NeckTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.OriginOffset", function() return TY(o.OriginOffset, "CFrame") end)
    T("prop.type.HumanoidRigDescription.RightAnkle", function() return TY(o.RightAnkle, "nil") end)
    T("prop.type.HumanoidRigDescription.RightAnkleRangeMax", function() return TY(o.RightAnkleRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightAnkleRangeMin", function() return TY(o.RightAnkleRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightAnkleSize", function() return TY(o.RightAnkleSize, "number") end)
    T("prop.type.HumanoidRigDescription.RightAnkleTposeAdjustment", function() return TY(o.RightAnkleTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.RightClavicle", function() return TY(o.RightClavicle, "nil") end)
    T("prop.type.HumanoidRigDescription.RightClavicleRangeMax", function() return TY(o.RightClavicleRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightClavicleRangeMin", function() return TY(o.RightClavicleRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightClavicleSize", function() return TY(o.RightClavicleSize, "number") end)
    T("prop.type.HumanoidRigDescription.RightClavicleTposeAdjustment", function() return TY(o.RightClavicleTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.RightElbow", function() return TY(o.RightElbow, "nil") end)
    T("prop.type.HumanoidRigDescription.RightElbowRangeMax", function() return TY(o.RightElbowRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightElbowRangeMin", function() return TY(o.RightElbowRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightElbowSize", function() return TY(o.RightElbowSize, "number") end)
    T("prop.type.HumanoidRigDescription.RightElbowTposeAdjustment", function() return TY(o.RightElbowTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.RightHip", function() return TY(o.RightHip, "nil") end)
    T("prop.type.HumanoidRigDescription.RightHipRangeMax", function() return TY(o.RightHipRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightHipRangeMin", function() return TY(o.RightHipRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightHipSize", function() return TY(o.RightHipSize, "number") end)
    T("prop.type.HumanoidRigDescription.RightHipTposeAdjustment", function() return TY(o.RightHipTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.RightKnee", function() return TY(o.RightKnee, "nil") end)
    T("prop.type.HumanoidRigDescription.RightKneeRangeMax", function() return TY(o.RightKneeRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightKneeRangeMin", function() return TY(o.RightKneeRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightKneeSize", function() return TY(o.RightKneeSize, "number") end)
    T("prop.type.HumanoidRigDescription.RightKneeTposeAdjustment", function() return TY(o.RightKneeTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.RightShoulder", function() return TY(o.RightShoulder, "nil") end)
    T("prop.type.HumanoidRigDescription.RightShoulderRangeMax", function() return TY(o.RightShoulderRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightShoulderRangeMin", function() return TY(o.RightShoulderRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightShoulderSize", function() return TY(o.RightShoulderSize, "number") end)
    T("prop.type.HumanoidRigDescription.RightShoulderTposeAdjustment", function() return TY(o.RightShoulderTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.RightToeBase", function() return TY(o.RightToeBase, "nil") end)
    T("prop.type.HumanoidRigDescription.RightToeBaseRangeMax", function() return TY(o.RightToeBaseRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightToeBaseRangeMin", function() return TY(o.RightToeBaseRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightToeBaseSize", function() return TY(o.RightToeBaseSize, "number") end)
    T("prop.type.HumanoidRigDescription.RightToeBaseTposeAdjustment", function() return TY(o.RightToeBaseTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.RightWrist", function() return TY(o.RightWrist, "nil") end)
    T("prop.type.HumanoidRigDescription.RightWristRangeMax", function() return TY(o.RightWristRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightWristRangeMin", function() return TY(o.RightWristRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RightWristSize", function() return TY(o.RightWristSize, "number") end)
    T("prop.type.HumanoidRigDescription.RightWristTposeAdjustment", function() return TY(o.RightWristTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.Root", function() return TY(o.Root, "nil") end)
    T("prop.type.HumanoidRigDescription.RootRangeMax", function() return TY(o.RootRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RootRangeMin", function() return TY(o.RootRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.RootSize", function() return TY(o.RootSize, "number") end)
    T("prop.type.HumanoidRigDescription.RootTposeAdjustment", function() return TY(o.RootTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.Spine", function() return TY(o.Spine, "nil") end)
    T("prop.type.HumanoidRigDescription.SpineRangeMax", function() return TY(o.SpineRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.SpineRangeMin", function() return TY(o.SpineRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.SpineSize", function() return TY(o.SpineSize, "number") end)
    T("prop.type.HumanoidRigDescription.SpineTposeAdjustment", function() return TY(o.SpineTposeAdjustment, "CFrame") end)
    T("prop.type.HumanoidRigDescription.Waist", function() return TY(o.Waist, "nil") end)
    T("prop.type.HumanoidRigDescription.WaistRangeMax", function() return TY(o.WaistRangeMax, "Vector3") end)
    T("prop.type.HumanoidRigDescription.WaistRangeMin", function() return TY(o.WaistRangeMin, "Vector3") end)
    T("prop.type.HumanoidRigDescription.WaistSize", function() return TY(o.WaistSize, "number") end)
    T("prop.type.HumanoidRigDescription.WaistTposeAdjustment", function() return TY(o.WaistTposeAdjustment, "CFrame") end)
end
do
    local o = Instance.new("IKControl")
    T("prop.type.IKControl.ChainRoot", function() return TY(o.ChainRoot, "nil") end)
    T("prop.type.IKControl.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.IKControl.EndEffector", function() return TY(o.EndEffector, "nil") end)
    T("prop.type.IKControl.EndEffectorOffset", function() return TY(o.EndEffectorOffset, "CFrame") end)
    T("prop.type.IKControl.Offset", function() return TY(o.Offset, "CFrame") end)
    T("prop.type.IKControl.Pole", function() return TY(o.Pole, "nil") end)
    T("prop.type.IKControl.Priority", function() return TY(o.Priority, "number") end)
    T("prop.type.IKControl.SmoothTime", function() return TY(o.SmoothTime, "number") end)
    T("prop.type.IKControl.Target", function() return TY(o.Target, "nil") end)
    T("prop.type.IKControl.Type", function() local v = o.Type; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.IKControlType) end)
    T("prop.type.IKControl.Weight", function() return TY(o.Weight, "number") end)
end
do
    local o = Instance.new("ImageHandleAdornment")
    T("prop.type.ImageHandleAdornment.Color3", function() return TY(o.Color3, "Color3") end)
    T("prop.type.ImageHandleAdornment.Image", function() return TY(o.Image, "string") end)
    T("prop.type.ImageHandleAdornment.ImageContent", function() return TY(o.ImageContent, "Content") end)
    T("prop.type.ImageHandleAdornment.Size", function() return TY(o.Size, "Vector2") end)
end
do
    local o = Instance.new("InputAction")
    T("prop.type.InputAction.DisplayName", function() return TY(o.DisplayName, "string") end)
    T("prop.type.InputAction.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.InputAction.PreferredBinding", function() return TY(o.PreferredBinding, "nil") end)
    T("prop.type.InputAction.Type", function() local v = o.Type; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.InputActionType) end)
end
do
    local o = Instance.new("InputBinding")
    T("prop.type.InputBinding.Backward", function() local v = o.Backward; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.InputBinding.ClampMagnitudeToOne", function() return TY(o.ClampMagnitudeToOne, "boolean") end)
    T("prop.type.InputBinding.Deadzone", function() return TY(o.Deadzone, "NumberRange") end)
    T("prop.type.InputBinding.DisplayImage", function() return TY(o.DisplayImage, "Content") end)
    T("prop.type.InputBinding.DisplayName", function() return TY(o.DisplayName, "string") end)
    T("prop.type.InputBinding.Down", function() local v = o.Down; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.InputBinding.Forward", function() local v = o.Forward; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.InputBinding.KeyCode", function() local v = o.KeyCode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.InputBinding.Left", function() local v = o.Left; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.InputBinding.PointerIndex", function() return TY(o.PointerIndex, "number") end)
    T("prop.type.InputBinding.PressedThreshold", function() return TY(o.PressedThreshold, "number") end)
    T("prop.type.InputBinding.PrimaryModifier", function() local v = o.PrimaryModifier; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.InputBinding.ReleasedThreshold", function() return TY(o.ReleasedThreshold, "number") end)
    T("prop.type.InputBinding.ResponseCurve", function() return TY(o.ResponseCurve, "number") end)
    T("prop.type.InputBinding.Right", function() local v = o.Right; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.InputBinding.Scale", function() return TY(o.Scale, "number") end)
    T("prop.type.InputBinding.SecondaryModifier", function() local v = o.SecondaryModifier; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.InputBinding.Type", function() local v = o.Type; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.InputBindingType) end)
    T("prop.type.InputBinding.UIButton", function() return TY(o.UIButton, "nil") end)
    T("prop.type.InputBinding.UIModifier", function() return TY(o.UIModifier, "nil") end)
    T("prop.type.InputBinding.Up", function() local v = o.Up; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.KeyCode) end)
    T("prop.type.InputBinding.Vector2Scale", function() return TY(o.Vector2Scale, "Vector2") end)
    T("prop.type.InputBinding.Vector3Scale", function() return TY(o.Vector3Scale, "Vector3") end)
end
do
    local o = Instance.new("InputContext")
    T("prop.type.InputContext.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.InputContext.Priority", function() return TY(o.Priority, "number") end)
    T("prop.type.InputContext.Sink", function() return TY(o.Sink, "boolean") end)
end
do
    local o = Instance.new("IntConstrainedValue")
    T("prop.type.IntConstrainedValue.ConstrainedValue", function() return TY(o.ConstrainedValue, "number") end)
    T("prop.type.IntConstrainedValue.MaxValue", function() return TY(o.MaxValue, "number") end)
    T("prop.type.IntConstrainedValue.MinValue", function() return TY(o.MinValue, "number") end)
    T("prop.type.IntConstrainedValue.Value", function() return TY(o.Value, "number") end)
end
do
    local o = Instance.new("IntersectOperation")
    T("prop.type.IntersectOperation.BottomSurface", function() local v = o.BottomSurface; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.SurfaceType) end)
    T("prop.type.IntersectOperation.CollisionFidelity", function() local v = o.CollisionFidelity; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.CollisionFidelity) end)
    T("prop.type.IntersectOperation.CollisionPrecision", function() return TY(o.CollisionPrecision, "number") end)
    T("prop.type.IntersectOperation.Color", function() return TY(o.Color, "Color3") end)
    T("prop.type.IntersectOperation.FluidFidelity", function() local v = o.FluidFidelity; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.FluidFidelity) end)
    T("prop.type.IntersectOperation.MeshSize", function() return TY(o.MeshSize, "Vector3") end)
    T("prop.type.IntersectOperation.RenderFidelity", function() local v = o.RenderFidelity; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.RenderFidelity) end)
    T("prop.type.IntersectOperation.SmoothingAngle", function() return TY(o.SmoothingAngle, "number") end)
    T("prop.type.IntersectOperation.TriangleCount", function() return TY(o.TriangleCount, "number") end)
    T("prop.type.IntersectOperation.UsePartColor", function() return TY(o.UsePartColor, "boolean") end)
end
do
    local o = Instance.new("Keyframe")
    T("prop.type.Keyframe.Time", function() return TY(o.Time, "number") end)
end
do
    local o = Instance.new("KeyframeMarker")
    T("prop.type.KeyframeMarker.Value", function() return TY(o.Value, "string") end)
end
do
    local o = Instance.new("KeyframeSequence")
    T("prop.type.KeyframeSequence.Length", function() return TY(o.Length, "number") end)
    T("prop.type.KeyframeSequence.Loop", function() return TY(o.Loop, "boolean") end)
    T("prop.type.KeyframeSequence.Priority", function() local v = o.Priority; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.AnimationPriority) end)
end
do
    local o = Instance.new("LineForce")
    T("prop.type.LineForce.ApplyAtCenterOfMass", function() return TY(o.ApplyAtCenterOfMass, "boolean") end)
    T("prop.type.LineForce.InverseSquareLaw", function() return TY(o.InverseSquareLaw, "boolean") end)
    T("prop.type.LineForce.Magnitude", function() return TY(o.Magnitude, "number") end)
    T("prop.type.LineForce.MaxForce", function() return TY(o.MaxForce, "number") end)
    T("prop.type.LineForce.ReactionForceEnabled", function() return TY(o.ReactionForceEnabled, "boolean") end)
end
do
    local o = Instance.new("LineHandleAdornment")
    T("prop.type.LineHandleAdornment.Length", function() return TY(o.Length, "number") end)
    T("prop.type.LineHandleAdornment.Thickness", function() return TY(o.Thickness, "number") end)
end
do
    local o = Instance.new("LocalizationTable")
    T("prop.type.LocalizationTable.DevelopmentLanguage", function() return TY(o.DevelopmentLanguage, "string") end)
    T("prop.type.LocalizationTable.Root", function() return TY(o.Root, "nil") end)
    T("prop.type.LocalizationTable.SourceLocaleId", function() return TY(o.SourceLocaleId, "string") end)
end
do
    local o = Instance.new("MakeupDescription")
    T("prop.type.MakeupDescription.AssetId", function() return TY(o.AssetId, "number") end)
    T("prop.type.MakeupDescription.Instance", function() return TY(o.Instance, "nil") end)
    T("prop.type.MakeupDescription.MakeupType", function() local v = o.MakeupType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.MakeupType) end)
    T("prop.type.MakeupDescription.Order", function() return TY(o.Order, "number") end)
end
do
    local o = Instance.new("MarkerCurve")
    T("prop.type.MarkerCurve.Length", function() return TY(o.Length, "number") end)
end
do
    local o = Instance.new("MaterialVariant")
    T("prop.type.MaterialVariant.AlphaMode", function() local v = o.AlphaMode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.AlphaMode) end)
    T("prop.type.MaterialVariant.BaseMaterial", function() local v = o.BaseMaterial; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.Material) end)
    T("prop.type.MaterialVariant.CustomPhysicalProperties", function() return TY(o.CustomPhysicalProperties, "nil") end)
    T("prop.type.MaterialVariant.EmissiveStrength", function() return TY(o.EmissiveStrength, "number") end)
    T("prop.type.MaterialVariant.EmissiveTint", function() return TY(o.EmissiveTint, "Color3") end)
    T("prop.type.MaterialVariant.MaterialPattern", function() local v = o.MaterialPattern; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.MaterialPattern) end)
    T("prop.type.MaterialVariant.StudsPerTile", function() return TY(o.StudsPerTile, "number") end)
end
do
    local o = Instance.new("Message")
    T("prop.type.Message.Text", function() return TY(o.Text, "string") end)
end
do
    local o = Instance.new("Motor")
    T("prop.type.Motor.CurrentAngle", function() return TY(o.CurrentAngle, "number") end)
    T("prop.type.Motor.DesiredAngle", function() return TY(o.DesiredAngle, "number") end)
    T("prop.type.Motor.MaxVelocity", function() return TY(o.MaxVelocity, "number") end)
end
do
    local o = Instance.new("NegateOperation")
    T("prop.type.NegateOperation.Anchored", function() return TY(o.Anchored, "boolean") end)
    T("prop.type.NegateOperation.BottomSurface", function() local v = o.BottomSurface; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.SurfaceType) end)
    T("prop.type.NegateOperation.CanCollide", function() return TY(o.CanCollide, "boolean") end)
    T("prop.type.NegateOperation.Color", function() return TY(o.Color, "Color3") end)
    T("prop.type.NegateOperation.RenderFidelity", function() local v = o.RenderFidelity; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.RenderFidelity) end)
    T("prop.type.NegateOperation.SmoothingAngle", function() return TY(o.SmoothingAngle, "number") end)
    T("prop.type.NegateOperation.Transparency", function() return TY(o.Transparency, "number") end)
    T("prop.type.NegateOperation.TriangleCount", function() return TY(o.TriangleCount, "number") end)
    T("prop.type.NegateOperation.UsePartColor", function() return TY(o.UsePartColor, "boolean") end)
end
do
    local o = Instance.new("NoCollisionConstraint")
    T("prop.type.NoCollisionConstraint.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.NoCollisionConstraint.Part0", function() return TY(o.Part0, "nil") end)
    T("prop.type.NoCollisionConstraint.Part1", function() return TY(o.Part1, "nil") end)
end
do
    local o = Instance.new("NumberPose")
    T("prop.type.NumberPose.EasingDirection", function() local v = o.EasingDirection; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.PoseEasingDirection) end)
    T("prop.type.NumberPose.EasingStyle", function() local v = o.EasingStyle; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.PoseEasingStyle) end)
    T("prop.type.NumberPose.Value", function() return TY(o.Value, "number") end)
    T("prop.type.NumberPose.Weight", function() return TY(o.Weight, "number") end)
end
do
    local o = Instance.new("ParabolaAdornment")
    T("prop.type.ParabolaAdornment.Color3", function() return TY(o.Color3, "Color3") end)
end
do
    local o = Instance.new("PartOperation")
    T("prop.type.PartOperation.BottomSurface", function() local v = o.BottomSurface; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.SurfaceType) end)
    T("prop.type.PartOperation.Color", function() return TY(o.Color, "Color3") end)
    T("prop.type.PartOperation.RenderFidelity", function() local v = o.RenderFidelity; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.RenderFidelity) end)
    T("prop.type.PartOperation.SmoothingAngle", function() return TY(o.SmoothingAngle, "number") end)
    T("prop.type.PartOperation.TriangleCount", function() return TY(o.TriangleCount, "number") end)
    T("prop.type.PartOperation.UsePartColor", function() return TY(o.UsePartColor, "boolean") end)
end
do
    local o = Instance.new("PathfindingLink")
    T("prop.type.PathfindingLink.Attachment0", function() return TY(o.Attachment0, "nil") end)
    T("prop.type.PathfindingLink.Attachment1", function() return TY(o.Attachment1, "nil") end)
    T("prop.type.PathfindingLink.IsBidirectional", function() return TY(o.IsBidirectional, "boolean") end)
    T("prop.type.PathfindingLink.Label", function() return TY(o.Label, "string") end)
end
do
    local o = Instance.new("PathfindingModifier")
    T("prop.type.PathfindingModifier.Label", function() return TY(o.Label, "string") end)
    T("prop.type.PathfindingModifier.PassThrough", function() return TY(o.PassThrough, "boolean") end)
end
do
    local o = Instance.new("PhysicsActivitySensor")
    T("prop.type.PhysicsActivitySensor.Active", function() return TY(o.Active, "boolean") end)
    T("prop.type.PhysicsActivitySensor.Position", function() return TY(o.Position, "Vector3") end)
    T("prop.type.PhysicsActivitySensor.Size", function() return TY(o.Size, "Vector3") end)
end
do
    local o = Instance.new("PitchShiftSoundEffect")
    T("prop.type.PitchShiftSoundEffect.Octave", function() return TY(o.Octave, "number") end)
end
do
    local o = Instance.new("Plane")
    T("prop.type.Plane.Color", function() return TY(o.Color, "BrickColor") end)
end
do
    local o = Instance.new("PlaneConstraint")
    T("prop.type.PlaneConstraint.Color", function() return TY(o.Color, "BrickColor") end)
end
do
    local o = Instance.new("Pose")
    T("prop.type.Pose.CFrame", function() return TY(o.CFrame, "CFrame") end)
    T("prop.type.Pose.EasingDirection", function() local v = o.EasingDirection; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.PoseEasingDirection) end)
    T("prop.type.Pose.EasingStyle", function() local v = o.EasingStyle; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.PoseEasingStyle) end)
    T("prop.type.Pose.MaskWeight", function() return TY(o.MaskWeight, "number") end)
    T("prop.type.Pose.Weight", function() return TY(o.Weight, "number") end)
end
do
    local o = Instance.new("PrismaticConstraint")
    T("prop.type.PrismaticConstraint.ActuatorType", function() local v = o.ActuatorType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.ActuatorType) end)
    T("prop.type.PrismaticConstraint.Color", function() return TY(o.Color, "BrickColor") end)
    T("prop.type.PrismaticConstraint.CurrentPosition", function() return TY(o.CurrentPosition, "number") end)
    T("prop.type.PrismaticConstraint.LimitsEnabled", function() return TY(o.LimitsEnabled, "boolean") end)
    T("prop.type.PrismaticConstraint.LinearResponsiveness", function() return TY(o.LinearResponsiveness, "number") end)
    T("prop.type.PrismaticConstraint.LowerLimit", function() return TY(o.LowerLimit, "number") end)
    T("prop.type.PrismaticConstraint.MotorMaxAcceleration", function() return TY(o.MotorMaxAcceleration, "number") end)
    T("prop.type.PrismaticConstraint.MotorMaxForce", function() return TY(o.MotorMaxForce, "number") end)
    T("prop.type.PrismaticConstraint.Restitution", function() return TY(o.Restitution, "number") end)
    T("prop.type.PrismaticConstraint.ServoMaxForce", function() return TY(o.ServoMaxForce, "number") end)
    T("prop.type.PrismaticConstraint.Size", function() return TY(o.Size, "number") end)
    T("prop.type.PrismaticConstraint.SoftlockServoUponReachingTarget", function() return TY(o.SoftlockServoUponReachingTarget, "boolean") end)
    T("prop.type.PrismaticConstraint.Speed", function() return TY(o.Speed, "number") end)
    T("prop.type.PrismaticConstraint.TargetPosition", function() return TY(o.TargetPosition, "number") end)
    T("prop.type.PrismaticConstraint.UpperLimit", function() return TY(o.UpperLimit, "number") end)
    T("prop.type.PrismaticConstraint.Velocity", function() return TY(o.Velocity, "number") end)
end
do
    local o = Instance.new("PyramidHandleAdornment")
    T("prop.type.PyramidHandleAdornment.Height", function() return TY(o.Height, "number") end)
    T("prop.type.PyramidHandleAdornment.Shading", function() local v = o.Shading; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.AdornShading) end)
    T("prop.type.PyramidHandleAdornment.Sides", function() return TY(o.Sides, "number") end)
    T("prop.type.PyramidHandleAdornment.Size", function() return TY(o.Size, "number") end)
end
do
    local o = Instance.new("RayValue")
    T("prop.type.RayValue.Value", function() return TY(o.Value, "Ray") end)
end
do
    local o = Instance.new("ReverbSoundEffect")
    T("prop.type.ReverbSoundEffect.DecayTime", function() return TY(o.DecayTime, "number") end)
    T("prop.type.ReverbSoundEffect.Density", function() return TY(o.Density, "number") end)
    T("prop.type.ReverbSoundEffect.Diffusion", function() return TY(o.Diffusion, "number") end)
    T("prop.type.ReverbSoundEffect.DryLevel", function() return TY(o.DryLevel, "number") end)
    T("prop.type.ReverbSoundEffect.WetLevel", function() return TY(o.WetLevel, "number") end)
end
do
    local o = Instance.new("RigidConstraint")
    T("prop.type.RigidConstraint.Color", function() return TY(o.Color, "BrickColor") end)
end
do
    local o = Instance.new("RocketPropulsion")
    T("prop.type.RocketPropulsion.CartoonFactor", function() return TY(o.CartoonFactor, "number") end)
    T("prop.type.RocketPropulsion.MaxSpeed", function() return TY(o.MaxSpeed, "number") end)
    T("prop.type.RocketPropulsion.MaxThrust", function() return TY(o.MaxThrust, "number") end)
    T("prop.type.RocketPropulsion.MaxTorque", function() return TY(o.MaxTorque, "Vector3") end)
    T("prop.type.RocketPropulsion.Target", function() return TY(o.Target, "nil") end)
    T("prop.type.RocketPropulsion.TargetOffset", function() return TY(o.TargetOffset, "Vector3") end)
    T("prop.type.RocketPropulsion.TargetRadius", function() return TY(o.TargetRadius, "number") end)
    T("prop.type.RocketPropulsion.ThrustD", function() return TY(o.ThrustD, "number") end)
    T("prop.type.RocketPropulsion.ThrustP", function() return TY(o.ThrustP, "number") end)
    T("prop.type.RocketPropulsion.TurnD", function() return TY(o.TurnD, "number") end)
    T("prop.type.RocketPropulsion.TurnP", function() return TY(o.TurnP, "number") end)
end
do
    local o = Instance.new("RodConstraint")
    T("prop.type.RodConstraint.Color", function() return TY(o.Color, "BrickColor") end)
    T("prop.type.RodConstraint.CurrentDistance", function() return TY(o.CurrentDistance, "number") end)
    T("prop.type.RodConstraint.Length", function() return TY(o.Length, "number") end)
    T("prop.type.RodConstraint.LimitAngle0", function() return TY(o.LimitAngle0, "number") end)
    T("prop.type.RodConstraint.LimitAngle1", function() return TY(o.LimitAngle1, "number") end)
    T("prop.type.RodConstraint.LimitsEnabled", function() return TY(o.LimitsEnabled, "boolean") end)
    T("prop.type.RodConstraint.Thickness", function() return TY(o.Thickness, "number") end)
end
do
    local o = Instance.new("RotateP")
    T("prop.type.RotateP.BaseAngle", function() return TY(o.BaseAngle, "number") end)
end
do
    local o = Instance.new("RotateV")
    T("prop.type.RotateV.BaseAngle", function() return TY(o.BaseAngle, "number") end)
end
do
    local o = Instance.new("RotationCurve")
    T("prop.type.RotationCurve.Length", function() return TY(o.Length, "number") end)
end
do
    local o = Instance.new("SelectionSphere")
    T("prop.type.SelectionSphere.SurfaceColor", function() return TY(o.SurfaceColor, "BrickColor") end)
    T("prop.type.SelectionSphere.SurfaceColor3", function() return TY(o.SurfaceColor3, "Color3") end)
    T("prop.type.SelectionSphere.SurfaceTransparency", function() return TY(o.SurfaceTransparency, "number") end)
end
do
    local o = Instance.new("SkateboardPlatform")
    T("prop.type.SkateboardPlatform.Controller", function() return TY(o.Controller, "nil") end)
    T("prop.type.SkateboardPlatform.ControllingHumanoid", function() return TY(o.ControllingHumanoid, "nil") end)
    T("prop.type.SkateboardPlatform.Steer", function() return TY(o.Steer, "number") end)
    T("prop.type.SkateboardPlatform.StickyWheels", function() return TY(o.StickyWheels, "boolean") end)
    T("prop.type.SkateboardPlatform.Throttle", function() return TY(o.Throttle, "number") end)
    T("prop.type.SkateboardPlatform.TopSurface", function() local v = o.TopSurface; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.SurfaceType) end)
end
do
    local o = Instance.new("Skin")
    T("prop.type.Skin.SkinColor", function() return TY(o.SkinColor, "BrickColor") end)
end
do
    local o = Instance.new("SpecialMesh")
    T("prop.type.SpecialMesh.MeshContent", function() return TY(o.MeshContent, "Content") end)
    T("prop.type.SpecialMesh.MeshId", function() return TY(o.MeshId, "string") end)
    T("prop.type.SpecialMesh.MeshType", function() local v = o.MeshType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.MeshType) end)
    T("prop.type.SpecialMesh.TextureContent", function() return TY(o.TextureContent, "Content") end)
    T("prop.type.SpecialMesh.TextureId", function() return TY(o.TextureId, "string") end)
end
do
    local o = Instance.new("StarterGear")
    T("prop.type.StarterGear.Loaded", function() return TY(o.Loaded, "boolean") end)
end
do
    local o = Instance.new("StyleDerive")
    T("prop.type.StyleDerive.Priority", function() return TY(o.Priority, "number") end)
    T("prop.type.StyleDerive.StyleSheet", function() return TY(o.StyleSheet, "nil") end)
end
do
    local o = Instance.new("StyleLink")
    T("prop.type.StyleLink.StyleSheet", function() return TY(o.StyleSheet, "nil") end)
end
do
    local o = Instance.new("StyleRule")
    T("prop.type.StyleRule.Priority", function() return TY(o.Priority, "number") end)
    T("prop.type.StyleRule.Selector", function() return TY(o.Selector, "string") end)
    T("prop.type.StyleRule.SelectorError", function() return TY(o.SelectorError, "string") end)
end
do
    local o = Instance.new("SurfaceAppearance")
    T("prop.type.SurfaceAppearance.AlphaMode", function() local v = o.AlphaMode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.AlphaMode) end)
    T("prop.type.SurfaceAppearance.Color", function() return TY(o.Color, "Color3") end)
    T("prop.type.SurfaceAppearance.ColorMapContent", function() return TY(o.ColorMapContent, "Content") end)
    T("prop.type.SurfaceAppearance.EmissiveMaskContent", function() return TY(o.EmissiveMaskContent, "Content") end)
    T("prop.type.SurfaceAppearance.EmissiveStrength", function() return TY(o.EmissiveStrength, "number") end)
    T("prop.type.SurfaceAppearance.EmissiveTint", function() return TY(o.EmissiveTint, "Color3") end)
    T("prop.type.SurfaceAppearance.MetalnessMapContent", function() return TY(o.MetalnessMapContent, "Content") end)
    T("prop.type.SurfaceAppearance.NormalMapContent", function() return TY(o.NormalMapContent, "Content") end)
    T("prop.type.SurfaceAppearance.ResampleMode", function() local v = o.ResampleMode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.ResamplerMode) end)
    T("prop.type.SurfaceAppearance.RoughnessMapContent", function() return TY(o.RoughnessMapContent, "Content") end)
    T("prop.type.SurfaceAppearance.SurfaceSlot", function() return TY(o.SurfaceSlot, "number") end)
end
do
    local o = Instance.new("SurfaceSelection")
    T("prop.type.SurfaceSelection.Adornee", function() return TY(o.Adornee, "nil") end)
    T("prop.type.SurfaceSelection.TargetSurface", function() local v = o.TargetSurface; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.NormalId) end)
end
do
    local o = Instance.new("SwimController")
    T("prop.type.SwimController.AccelerationTime", function() return TY(o.AccelerationTime, "number") end)
    T("prop.type.SwimController.PitchMaxTorque", function() return TY(o.PitchMaxTorque, "number") end)
    T("prop.type.SwimController.PitchSpeedFactor", function() return TY(o.PitchSpeedFactor, "number") end)
    T("prop.type.SwimController.RollMaxTorque", function() return TY(o.RollMaxTorque, "number") end)
    T("prop.type.SwimController.RollSpeedFactor", function() return TY(o.RollSpeedFactor, "number") end)
end
do
    local o = Instance.new("TeleportOptions")
    T("prop.type.TeleportOptions.ReservedServerAccessCode", function() return TY(o.ReservedServerAccessCode, "string") end)
    T("prop.type.TeleportOptions.ReservedServerId", function() return TY(o.ReservedServerId, "string") end)
    T("prop.type.TeleportOptions.ServerInstanceId", function() return TY(o.ServerInstanceId, "string") end)
    T("prop.type.TeleportOptions.ShouldReserveServer", function() return TY(o.ShouldReserveServer, "boolean") end)
    T("prop.type.TeleportOptions.VipServerId", function() return TY(o.VipServerId, "string") end)
end
do
    local o = Instance.new("TerrainDetail")
    T("prop.type.TerrainDetail.EmissiveStrength", function() return TY(o.EmissiveStrength, "number") end)
    T("prop.type.TerrainDetail.EmissiveTint", function() return TY(o.EmissiveTint, "Color3") end)
    T("prop.type.TerrainDetail.Face", function() local v = o.Face; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.TerrainFace) end)
    T("prop.type.TerrainDetail.MaterialPattern", function() local v = o.MaterialPattern; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.MaterialPattern) end)
    T("prop.type.TerrainDetail.StudsPerTile", function() return TY(o.StudsPerTile, "number") end)
end
do
    local o = Instance.new("TerrainRegion")
    T("prop.type.TerrainRegion.IsSmooth", function() return TY(o.IsSmooth, "boolean") end)
    T("prop.type.TerrainRegion.SizeInCells", function() return TY(o.SizeInCells, "Vector3") end)
end
do
    local o = Instance.new("TextChannel")
    T("prop.type.TextChannel.AddPlayersOnJoin", function() return TY(o.AddPlayersOnJoin, "boolean") end)
    T("prop.type.TextChannel.DirectChatRequester", function() return TY(o.DirectChatRequester, "nil") end)
end
do
    local o = Instance.new("TextChatCommand")
    T("prop.type.TextChatCommand.AutocompleteVisible", function() return TY(o.AutocompleteVisible, "boolean") end)
    T("prop.type.TextChatCommand.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.TextChatCommand.PrimaryAlias", function() return TY(o.PrimaryAlias, "string") end)
    T("prop.type.TextChatCommand.SecondaryAlias", function() return TY(o.SecondaryAlias, "string") end)
end
do
    local o = Instance.new("TextChatMessageProperties")
    T("prop.type.TextChatMessageProperties.PrefixText", function() return TY(o.PrefixText, "string") end)
    T("prop.type.TextChatMessageProperties.Text", function() return TY(o.Text, "string") end)
    T("prop.type.TextChatMessageProperties.Translation", function() return TY(o.Translation, "string") end)
end
do
    local o = Instance.new("Torque")
    T("prop.type.Torque.RelativeTo", function() local v = o.RelativeTo; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.ActuatorRelativeTo) end)
    T("prop.type.Torque.Torque", function() return TY(o.Torque, "Vector3") end)
end
do
    local o = Instance.new("TorsionSpringConstraint")
    T("prop.type.TorsionSpringConstraint.Coils", function() return TY(o.Coils, "number") end)
    T("prop.type.TorsionSpringConstraint.Color", function() return TY(o.Color, "BrickColor") end)
    T("prop.type.TorsionSpringConstraint.CurrentAngle", function() return TY(o.CurrentAngle, "number") end)
    T("prop.type.TorsionSpringConstraint.Damping", function() return TY(o.Damping, "number") end)
    T("prop.type.TorsionSpringConstraint.LimitEnabled", function() return TY(o.LimitEnabled, "boolean") end)
    T("prop.type.TorsionSpringConstraint.LimitsEnabled", function() return TY(o.LimitsEnabled, "boolean") end)
    T("prop.type.TorsionSpringConstraint.MaxAngle", function() return TY(o.MaxAngle, "number") end)
    T("prop.type.TorsionSpringConstraint.MaxTorque", function() return TY(o.MaxTorque, "number") end)
    T("prop.type.TorsionSpringConstraint.Radius", function() return TY(o.Radius, "number") end)
    T("prop.type.TorsionSpringConstraint.Restitution", function() return TY(o.Restitution, "number") end)
    T("prop.type.TorsionSpringConstraint.Stiffness", function() return TY(o.Stiffness, "number") end)
end
do
    local o = Instance.new("TremoloSoundEffect")
    T("prop.type.TremoloSoundEffect.Depth", function() return TY(o.Depth, "number") end)
    T("prop.type.TremoloSoundEffect.Duty", function() return TY(o.Duty, "number") end)
    T("prop.type.TremoloSoundEffect.Frequency", function() return TY(o.Frequency, "number") end)
end
do
    local o = Instance.new("Tween")
    T("prop.type.Tween.Instance", function() return TY(o.Instance, "nil") end)
    T("prop.type.Tween.PlaybackState", function() local v = o.PlaybackState; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.PlaybackState) end)
    T("prop.type.Tween.TweenInfo", function() return TY(o.TweenInfo, "TweenInfo") end)
end
do
    local o = Instance.new("UIAspectRatioConstraint")
    T("prop.type.UIAspectRatioConstraint.AspectRatio", function() return TY(o.AspectRatio, "number") end)
    T("prop.type.UIAspectRatioConstraint.AspectType", function() local v = o.AspectType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.AspectType) end)
    T("prop.type.UIAspectRatioConstraint.DominantAxis", function() local v = o.DominantAxis; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.DominantAxis) end)
end
do
    local o = Instance.new("UIDragDetector")
    T("prop.type.UIDragDetector.ActivatedCursorIcon", function() return TY(o.ActivatedCursorIcon, "string") end)
    T("prop.type.UIDragDetector.ActivatedCursorIconContent", function() return TY(o.ActivatedCursorIconContent, "Content") end)
    T("prop.type.UIDragDetector.BoundingBehavior", function() local v = o.BoundingBehavior; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.UIDragDetectorBoundingBehavior) end)
    T("prop.type.UIDragDetector.BoundingUI", function() return TY(o.BoundingUI, "nil") end)
    T("prop.type.UIDragDetector.CursorIcon", function() return TY(o.CursorIcon, "string") end)
    T("prop.type.UIDragDetector.CursorIconContent", function() return TY(o.CursorIconContent, "Content") end)
    T("prop.type.UIDragDetector.DragAxis", function() return TY(o.DragAxis, "Vector2") end)
    T("prop.type.UIDragDetector.DragRelativity", function() local v = o.DragRelativity; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.UIDragDetectorDragRelativity) end)
    T("prop.type.UIDragDetector.DragRotation", function() return TY(o.DragRotation, "number") end)
    T("prop.type.UIDragDetector.DragSpace", function() local v = o.DragSpace; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.UIDragDetectorDragSpace) end)
    T("prop.type.UIDragDetector.DragStyle", function() local v = o.DragStyle; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.UIDragDetectorDragStyle) end)
    T("prop.type.UIDragDetector.DragUDim2", function() return TY(o.DragUDim2, "UDim2") end)
    T("prop.type.UIDragDetector.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.UIDragDetector.MaxDragAngle", function() return TY(o.MaxDragAngle, "number") end)
    T("prop.type.UIDragDetector.MaxDragTranslation", function() return TY(o.MaxDragTranslation, "UDim2") end)
    T("prop.type.UIDragDetector.MinDragAngle", function() return TY(o.MinDragAngle, "number") end)
    T("prop.type.UIDragDetector.MinDragTranslation", function() return TY(o.MinDragTranslation, "UDim2") end)
    T("prop.type.UIDragDetector.ReferenceUIInstance", function() return TY(o.ReferenceUIInstance, "nil") end)
    T("prop.type.UIDragDetector.ResponseStyle", function() local v = o.ResponseStyle; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.UIDragDetectorResponseStyle) end)
    T("prop.type.UIDragDetector.Selectable", function() return TY(o.Selectable, "boolean") end)
    T("prop.type.UIDragDetector.SelectionModeDragSpeed", function() return TY(o.SelectionModeDragSpeed, "UDim2") end)
    T("prop.type.UIDragDetector.SelectionModeRotateSpeed", function() return TY(o.SelectionModeRotateSpeed, "number") end)
    T("prop.type.UIDragDetector.UIDragSpeedAxisMapping", function() local v = o.UIDragSpeedAxisMapping; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.UIDragSpeedAxisMapping) end)
end
do
    local o = Instance.new("UIFlexItem")
    T("prop.type.UIFlexItem.FlexMode", function() local v = o.FlexMode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.UIFlexMode) end)
    T("prop.type.UIFlexItem.GrowRatio", function() return TY(o.GrowRatio, "number") end)
    T("prop.type.UIFlexItem.ItemLineAlignment", function() local v = o.ItemLineAlignment; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.ItemLineAlignment) end)
    T("prop.type.UIFlexItem.ShrinkRatio", function() return TY(o.ShrinkRatio, "number") end)
end
do
    local o = Instance.new("UIPageLayout")
    T("prop.type.UIPageLayout.AbsoluteContentSize", function() return TY(o.AbsoluteContentSize, "Vector2") end)
    T("prop.type.UIPageLayout.Animated", function() return TY(o.Animated, "boolean") end)
    T("prop.type.UIPageLayout.Circular", function() return TY(o.Circular, "boolean") end)
    T("prop.type.UIPageLayout.EasingDirection", function() local v = o.EasingDirection; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.EasingDirection) end)
    T("prop.type.UIPageLayout.EasingStyle", function() local v = o.EasingStyle; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.EasingStyle) end)
    T("prop.type.UIPageLayout.FillDirection", function() local v = o.FillDirection; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.FillDirection) end)
    T("prop.type.UIPageLayout.GamepadInputEnabled", function() return TY(o.GamepadInputEnabled, "boolean") end)
    T("prop.type.UIPageLayout.HorizontalAlignment", function() local v = o.HorizontalAlignment; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.HorizontalAlignment) end)
    T("prop.type.UIPageLayout.Padding", function() return TY(o.Padding, "UDim") end)
    T("prop.type.UIPageLayout.ScrollWheelInputEnabled", function() return TY(o.ScrollWheelInputEnabled, "boolean") end)
    T("prop.type.UIPageLayout.SortOrder", function() local v = o.SortOrder; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.SortOrder) end)
    T("prop.type.UIPageLayout.TouchInputEnabled", function() return TY(o.TouchInputEnabled, "boolean") end)
    T("prop.type.UIPageLayout.TweenTime", function() return TY(o.TweenTime, "number") end)
    T("prop.type.UIPageLayout.VerticalAlignment", function() local v = o.VerticalAlignment; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.VerticalAlignment) end)
end
do
    local o = Instance.new("UISizeConstraint")
    T("prop.type.UISizeConstraint.MaxSize", function() return TY(o.MaxSize, "Vector2") end)
    T("prop.type.UISizeConstraint.MinSize", function() return TY(o.MinSize, "Vector2") end)
end
do
    local o = Instance.new("UITableLayout")
    T("prop.type.UITableLayout.FillEmptySpaceColumns", function() return TY(o.FillEmptySpaceColumns, "boolean") end)
    T("prop.type.UITableLayout.FillEmptySpaceRows", function() return TY(o.FillEmptySpaceRows, "boolean") end)
    T("prop.type.UITableLayout.MajorAxis", function() local v = o.MajorAxis; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.TableMajorAxis) end)
    T("prop.type.UITableLayout.Padding", function() return TY(o.Padding, "UDim2") end)
end
do
    local o = Instance.new("UITextSizeConstraint")
    T("prop.type.UITextSizeConstraint.MaxTextSize", function() return TY(o.MaxTextSize, "number") end)
    T("prop.type.UITextSizeConstraint.MinTextSize", function() return TY(o.MinTextSize, "number") end)
end
do
    local o = Instance.new("UniversalConstraint")
    T("prop.type.UniversalConstraint.Color", function() return TY(o.Color, "BrickColor") end)
    T("prop.type.UniversalConstraint.LimitsEnabled", function() return TY(o.LimitsEnabled, "boolean") end)
    T("prop.type.UniversalConstraint.MaxAngle", function() return TY(o.MaxAngle, "number") end)
    T("prop.type.UniversalConstraint.Radius", function() return TY(o.Radius, "number") end)
    T("prop.type.UniversalConstraint.Restitution", function() return TY(o.Restitution, "number") end)
end
do
    local o = Instance.new("VelocityMotor")
    T("prop.type.VelocityMotor.CurrentAngle", function() return TY(o.CurrentAngle, "number") end)
    T("prop.type.VelocityMotor.DesiredAngle", function() return TY(o.DesiredAngle, "number") end)
    T("prop.type.VelocityMotor.Hole", function() return TY(o.Hole, "nil") end)
    T("prop.type.VelocityMotor.MaxVelocity", function() return TY(o.MaxVelocity, "number") end)
end
do
    local o = Instance.new("VideoDeviceInput")
    T("prop.type.VideoDeviceInput.Active", function() return TY(o.Active, "boolean") end)
    T("prop.type.VideoDeviceInput.CameraId", function() return TY(o.CameraId, "string") end)
    T("prop.type.VideoDeviceInput.CaptureQuality", function() local v = o.CaptureQuality; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.VideoDeviceCaptureQuality) end)
    T("prop.type.VideoDeviceInput.IsReady", function() return TY(o.IsReady, "boolean") end)
end
do
    local o = Instance.new("VideoDisplay")
    T("prop.type.VideoDisplay.ResampleMode", function() local v = o.ResampleMode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.ResamplerMode) end)
    T("prop.type.VideoDisplay.ScaleType", function() local v = o.ScaleType; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.ScaleType) end)
    T("prop.type.VideoDisplay.TileSize", function() return TY(o.TileSize, "UDim2") end)
    T("prop.type.VideoDisplay.VideoColor3", function() return TY(o.VideoColor3, "Color3") end)
    T("prop.type.VideoDisplay.VideoRectOffset", function() return TY(o.VideoRectOffset, "Vector2") end)
    T("prop.type.VideoDisplay.VideoRectSize", function() return TY(o.VideoRectSize, "Vector2") end)
    T("prop.type.VideoDisplay.VideoTransparency", function() return TY(o.VideoTransparency, "number") end)
end
do
    local o = Instance.new("VideoFrame")
    T("prop.type.VideoFrame.InternalVideoUsage", function() local v = o.InternalVideoUsage; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.InternalVideoUsage) end)
    T("prop.type.VideoFrame.IsLoaded", function() return TY(o.IsLoaded, "boolean") end)
    T("prop.type.VideoFrame.Looped", function() return TY(o.Looped, "boolean") end)
    T("prop.type.VideoFrame.MaximumResolution", function() local v = o.MaximumResolution; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.VideoSampleSize) end)
    T("prop.type.VideoFrame.Playing", function() return TY(o.Playing, "boolean") end)
    T("prop.type.VideoFrame.Resolution", function() return TY(o.Resolution, "Vector2") end)
    T("prop.type.VideoFrame.RollOffMaxDistance", function() return TY(o.RollOffMaxDistance, "number") end)
    T("prop.type.VideoFrame.RollOffMinDistance", function() return TY(o.RollOffMinDistance, "number") end)
    T("prop.type.VideoFrame.RollOffMode", function() local v = o.RollOffMode; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.RollOffMode) end)
    T("prop.type.VideoFrame.TimeLength", function() return TY(o.TimeLength, "number") end)
    T("prop.type.VideoFrame.TimePosition", function() return TY(o.TimePosition, "number") end)
    T("prop.type.VideoFrame.Video", function() return TY(o.Video, "string") end)
    T("prop.type.VideoFrame.VideoContent", function() return TY(o.VideoContent, "Content") end)
    T("prop.type.VideoFrame.Volume", function() return TY(o.Volume, "number") end)
end
do
    local o = Instance.new("VideoPlayer")
    T("prop.type.VideoPlayer.InternalVideoUsage", function() local v = o.InternalVideoUsage; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.InternalVideoUsage) end)
    T("prop.type.VideoPlayer.IsLoaded", function() return TY(o.IsLoaded, "boolean") end)
    T("prop.type.VideoPlayer.IsPlaying", function() return TY(o.IsPlaying, "boolean") end)
    T("prop.type.VideoPlayer.Looping", function() return TY(o.Looping, "boolean") end)
    T("prop.type.VideoPlayer.MaximumResolution", function() local v = o.MaximumResolution; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.VideoSampleSize) end)
    T("prop.type.VideoPlayer.PlaybackSpeed", function() return TY(o.PlaybackSpeed, "number") end)
    T("prop.type.VideoPlayer.Resolution", function() return TY(o.Resolution, "Vector2") end)
    T("prop.type.VideoPlayer.TimeLength", function() return TY(o.TimeLength, "number") end)
    T("prop.type.VideoPlayer.TimePosition", function() return TY(o.TimePosition, "number") end)
    T("prop.type.VideoPlayer.VideoContent", function() return TY(o.VideoContent, "Content") end)
    T("prop.type.VideoPlayer.Volume", function() return TY(o.Volume, "number") end)
end
do
    local o = Instance.new("Wire")
    T("prop.type.Wire.Connected", function() return TY(o.Connected, "boolean") end)
    T("prop.type.Wire.SourceInstance", function() return TY(o.SourceInstance, "nil") end)
    T("prop.type.Wire.SourceName", function() return TY(o.SourceName, "string") end)
    T("prop.type.Wire.TargetInstance", function() return TY(o.TargetInstance, "nil") end)
    T("prop.type.Wire.TargetName", function() return TY(o.TargetName, "string") end)
end
do
    local o = Instance.new("WireframeHandleAdornment")
    T("prop.type.WireframeHandleAdornment.Scale", function() return TY(o.Scale, "Vector3") end)
    T("prop.type.WireframeHandleAdornment.Thickness", function() return TY(o.Thickness, "number") end)
end
do
    local o = Instance.new("WorldModel")
    T("prop.type.WorldModel.UseWorkspaceCollisionGroups", function() return TY(o.UseWorkspaceCollisionGroups, "boolean") end)
end
do
    local o = Instance.new("WrapDeformer")
    T("prop.type.WrapDeformer.CageMeshContent", function() return TY(o.CageMeshContent, "Content") end)
    T("prop.type.WrapDeformer.CageMeshId", function() return TY(o.CageMeshId, "string") end)
    T("prop.type.WrapDeformer.CageOrigin", function() return TY(o.CageOrigin, "CFrame") end)
    T("prop.type.WrapDeformer.CageOriginWorld", function() return TY(o.CageOriginWorld, "CFrame") end)
    T("prop.type.WrapDeformer.ImportOrigin", function() return TY(o.ImportOrigin, "CFrame") end)
    T("prop.type.WrapDeformer.ImportOriginWorld", function() return TY(o.ImportOriginWorld, "CFrame") end)
end
do
    local o = Instance.new("WrapLayer")
    T("prop.type.WrapLayer.AutoSkin", function() local v = o.AutoSkin; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.WrapLayerAutoSkin) end)
    T("prop.type.WrapLayer.BindOffset", function() return TY(o.BindOffset, "CFrame") end)
    T("prop.type.WrapLayer.CageMeshContent", function() return TY(o.CageMeshContent, "Content") end)
    T("prop.type.WrapLayer.CageMeshId", function() return TY(o.CageMeshId, "string") end)
    T("prop.type.WrapLayer.CageOrigin", function() return TY(o.CageOrigin, "CFrame") end)
    T("prop.type.WrapLayer.CageOriginWorld", function() return TY(o.CageOriginWorld, "CFrame") end)
    T("prop.type.WrapLayer.Enabled", function() return TY(o.Enabled, "boolean") end)
    T("prop.type.WrapLayer.ImportOrigin", function() return TY(o.ImportOrigin, "CFrame") end)
    T("prop.type.WrapLayer.ImportOriginWorld", function() return TY(o.ImportOriginWorld, "CFrame") end)
    T("prop.type.WrapLayer.Order", function() return TY(o.Order, "number") end)
    T("prop.type.WrapLayer.Puffiness", function() return TY(o.Puffiness, "number") end)
    T("prop.type.WrapLayer.ReferenceMeshContent", function() return TY(o.ReferenceMeshContent, "Content") end)
    T("prop.type.WrapLayer.ReferenceMeshId", function() return TY(o.ReferenceMeshId, "string") end)
    T("prop.type.WrapLayer.ReferenceOrigin", function() return TY(o.ReferenceOrigin, "CFrame") end)
    T("prop.type.WrapLayer.ReferenceOriginWorld", function() return TY(o.ReferenceOriginWorld, "CFrame") end)
    T("prop.type.WrapLayer.RotateScaleDeformationMap", function() return TY(o.RotateScaleDeformationMap, "Content") end)
    T("prop.type.WrapLayer.ScaleOnlyDeformationMap", function() return TY(o.ScaleOnlyDeformationMap, "Content") end)
    T("prop.type.WrapLayer.ShrinkFactor", function() return TY(o.ShrinkFactor, "number") end)
    T("prop.type.WrapLayer.TargetShaping", function() return TY(o.TargetShaping, "number") end)
end
do
    local o = Instance.new("WrapTarget")
    T("prop.type.WrapTarget.CageMeshContent", function() return TY(o.CageMeshContent, "Content") end)
    T("prop.type.WrapTarget.CageMeshId", function() return TY(o.CageMeshId, "string") end)
    T("prop.type.WrapTarget.CageOrigin", function() return TY(o.CageOrigin, "CFrame") end)
    T("prop.type.WrapTarget.CageOriginWorld", function() return TY(o.CageOriginWorld, "CFrame") end)
    T("prop.type.WrapTarget.ImportOrigin", function() return TY(o.ImportOrigin, "CFrame") end)
    T("prop.type.WrapTarget.ImportOriginWorld", function() return TY(o.ImportOriginWorld, "CFrame") end)
    T("prop.type.WrapTarget.Stiffness", function() return TY(o.Stiffness, "number") end)
end
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
