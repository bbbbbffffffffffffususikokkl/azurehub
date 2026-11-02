-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "api_classes_02"
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
    local ok, o = pcall(Instance.new, "PathfindingLink")
    T("class.new.PathfindingLink", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "PathfindingLink") end)
    T("class.name.PathfindingLink", function() return EQ(o.Name, "PathfindingLink") end)
    T("class.tostring.PathfindingLink", function() return EQ(tostring(o), "PathfindingLink") end)
    T("class.parent.PathfindingLink", function() return EQ(o.Parent, nil) end)
    T("class.isa.PathfindingLink.PathfindingLink", function() return EQ(o:IsA("PathfindingLink"), true) end)
    T("class.isa.PathfindingLink.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.PathfindingLink", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "PathfindingModifier")
    T("class.new.PathfindingModifier", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "PathfindingModifier") end)
    T("class.name.PathfindingModifier", function() return EQ(o.Name, "PathfindingModifier") end)
    T("class.tostring.PathfindingModifier", function() return EQ(tostring(o), "PathfindingModifier") end)
    T("class.parent.PathfindingModifier", function() return EQ(o.Parent, nil) end)
    T("class.isa.PathfindingModifier.PathfindingModifier", function() return EQ(o:IsA("PathfindingModifier"), true) end)
    T("class.isa.PathfindingModifier.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.PathfindingModifier", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.PausedState", function() return ERR(function() return Instance.new("PausedState") end, "Unable to create an Instance of type \"PausedState\"") end)
end
do
    T("class.notcreatable.PausedStateBreakpoint", function() return ERR(function() return Instance.new("PausedStateBreakpoint") end, "Unable to create an Instance of type \"PausedStateBreakpoint\"") end)
end
do
    T("class.notcreatable.PausedStateException", function() return ERR(function() return Instance.new("PausedStateException") end, "Unable to create an Instance of type \"PausedStateException\"") end)
end
do
    local ok, o = pcall(Instance.new, "PhysicsActivitySensor")
    T("class.new.PhysicsActivitySensor", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "PhysicsActivitySensor") end)
    T("class.name.PhysicsActivitySensor", function() return EQ(o.Name, "PhysicsActivitySensor") end)
    T("class.tostring.PhysicsActivitySensor", function() return EQ(tostring(o), "PhysicsActivitySensor") end)
    T("class.parent.PhysicsActivitySensor", function() return EQ(o.Parent, nil) end)
    T("class.isa.PhysicsActivitySensor.PhysicsActivitySensor", function() return EQ(o:IsA("PhysicsActivitySensor"), true) end)
    T("class.isa.PhysicsActivitySensor.SensorBase", function() return EQ(o:IsA("SensorBase"), true) end)
    T("class.isa.PhysicsActivitySensor.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.PhysicsActivitySensor", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "PitchShiftSoundEffect")
    T("class.new.PitchShiftSoundEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "PitchShiftSoundEffect") end)
    T("class.name.PitchShiftSoundEffect", function() return EQ(o.Name, "PitchShiftSoundEffect") end)
    T("class.tostring.PitchShiftSoundEffect", function() return EQ(tostring(o), "PitchShiftSoundEffect") end)
    T("class.parent.PitchShiftSoundEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.PitchShiftSoundEffect.PitchShiftSoundEffect", function() return EQ(o:IsA("PitchShiftSoundEffect"), true) end)
    T("class.isa.PitchShiftSoundEffect.SoundEffect", function() return EQ(o:IsA("SoundEffect"), true) end)
    T("class.isa.PitchShiftSoundEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.PitchShiftSoundEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Plane")
    T("class.new.Plane", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Plane") end)
    T("class.name.Plane", function() return EQ(o.Name, "Plane") end)
    T("class.tostring.Plane", function() return EQ(tostring(o), "Plane") end)
    T("class.parent.Plane", function() return EQ(o.Parent, nil) end)
    T("class.isa.Plane.Plane", function() return EQ(o:IsA("Plane"), true) end)
    T("class.isa.Plane.PlaneConstraint", function() return EQ(o:IsA("PlaneConstraint"), true) end)
    T("class.isa.Plane.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.Plane.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Plane", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "PlaneConstraint")
    T("class.new.PlaneConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "PlaneConstraint") end)
    T("class.name.PlaneConstraint", function() return EQ(o.Name, "PlaneConstraint") end)
    T("class.tostring.PlaneConstraint", function() return EQ(tostring(o), "PlaneConstraint") end)
    T("class.parent.PlaneConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.PlaneConstraint.PlaneConstraint", function() return EQ(o:IsA("PlaneConstraint"), true) end)
    T("class.isa.PlaneConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.PlaneConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.PlaneConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.Platform", function() return ERR(function() return Instance.new("Platform") end, "Unable to create an Instance of type \"Platform\"") end)
end
do
    T("class.notcreatable.PlayerData", function() return ERR(function() return Instance.new("PlayerData") end, "Unable to create an Instance of type \"PlayerData\"") end)
end
do
    T("class.notcreatable.PlayerDataRecord", function() return ERR(function() return Instance.new("PlayerDataRecord") end, "Unable to create an Instance of type \"PlayerDataRecord\"") end)
end
do
    T("class.notcreatable.PlayerDataRecordConfig", function() return ERR(function() return Instance.new("PlayerDataRecordConfig") end, "Unable to create an Instance of type \"PlayerDataRecordConfig\"") end)
end
do
    T("class.notcreatable.PlayerGui", function() return ERR(function() return Instance.new("PlayerGui") end, "Unable to create an Instance of type \"PlayerGui\"") end)
end
do
    T("class.notcreatable.PlayerListConfiguration", function() return ERR(function() return Instance.new("PlayerListConfiguration") end, "Unable to create an Instance of type \"PlayerListConfiguration\"") end)
end
do
    T("class.notcreatable.PlayerMouse", function() return ERR(function() return Instance.new("PlayerMouse") end, "Unable to create an Instance of type \"PlayerMouse\"") end)
end
do
    T("class.notcreatable.PlayerScripts", function() return ERR(function() return Instance.new("PlayerScripts") end, "Unable to create an Instance of type \"PlayerScripts\"") end)
end
do
    T("class.notcreatable.Plugin", function() return ERR(function() return Instance.new("Plugin") end, "Unable to create an Instance of type \"Plugin\"") end)
end
do
    T("class.notcreatable.PluginConnection", function() return ERR(function() return Instance.new("PluginConnection") end, "Unable to create an Instance of type \"PluginConnection\"") end)
end
do
    T("class.notcreatable.PluginDragEvent", function() return ERR(function() return Instance.new("PluginDragEvent") end, "Unable to create an Instance of type \"PluginDragEvent\"") end)
end
do
    T("class.notcreatable.PluginGui", function() return ERR(function() return Instance.new("PluginGui") end, "Unable to create an Instance of type \"PluginGui\"") end)
end
do
    T("class.notcreatable.PluginManager", function() return ERR(function() return Instance.new("PluginManager") end, "Unable to create an Instance of type \"PluginManager\"") end)
end
do
    T("class.notcreatable.PluginManagerInterface", function() return ERR(function() return Instance.new("PluginManagerInterface") end, "Unable to create an Instance of type \"PluginManagerInterface\"") end)
end
do
    T("class.notcreatable.PluginMenu", function() return ERR(function() return Instance.new("PluginMenu") end, "Unable to create an Instance of type \"PluginMenu\"") end)
end
do
    T("class.notcreatable.PluginMouse", function() return ERR(function() return Instance.new("PluginMouse") end, "Unable to create an Instance of type \"PluginMouse\"") end)
end
do
    T("class.notcreatable.PluginToolbar", function() return ERR(function() return Instance.new("PluginToolbar") end, "Unable to create an Instance of type \"PluginToolbar\"") end)
end
do
    T("class.notcreatable.PluginToolbarButton", function() return ERR(function() return Instance.new("PluginToolbarButton") end, "Unable to create an Instance of type \"PluginToolbarButton\"") end)
end
do
    local ok, o = pcall(Instance.new, "PointLight")
    T("class.new.PointLight", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "PointLight") end)
    T("class.name.PointLight", function() return EQ(o.Name, "PointLight") end)
    T("class.tostring.PointLight", function() return EQ(tostring(o), "PointLight") end)
    T("class.parent.PointLight", function() return EQ(o.Parent, nil) end)
    T("class.isa.PointLight.PointLight", function() return EQ(o:IsA("PointLight"), true) end)
    T("class.isa.PointLight.Light", function() return EQ(o:IsA("Light"), true) end)
    T("class.isa.PointLight.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.PointLight", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Pose")
    T("class.new.Pose", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Pose") end)
    T("class.name.Pose", function() return EQ(o.Name, "Pose") end)
    T("class.tostring.Pose", function() return EQ(tostring(o), "Pose") end)
    T("class.parent.Pose", function() return EQ(o.Parent, nil) end)
    T("class.isa.Pose.Pose", function() return EQ(o:IsA("Pose"), true) end)
    T("class.isa.Pose.PoseBase", function() return EQ(o:IsA("PoseBase"), true) end)
    T("class.isa.Pose.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Pose", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.PoseBase", function() return ERR(function() return Instance.new("PoseBase") end, "Unable to create an Instance of type \"PoseBase\"") end)
end
do
    T("class.notcreatable.PostEffect", function() return ERR(function() return Instance.new("PostEffect") end, "Unable to create an Instance of type \"PostEffect\"") end)
end
do
    local ok, o = pcall(Instance.new, "PrismaticConstraint")
    T("class.new.PrismaticConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "PrismaticConstraint") end)
    T("class.name.PrismaticConstraint", function() return EQ(o.Name, "PrismaticConstraint") end)
    T("class.tostring.PrismaticConstraint", function() return EQ(tostring(o), "PrismaticConstraint") end)
    T("class.parent.PrismaticConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.PrismaticConstraint.PrismaticConstraint", function() return EQ(o:IsA("PrismaticConstraint"), true) end)
    T("class.isa.PrismaticConstraint.SlidingBallConstraint", function() return EQ(o:IsA("SlidingBallConstraint"), true) end)
    T("class.isa.PrismaticConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.PrismaticConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.PrismaticConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ProximityPrompt")
    T("class.new.ProximityPrompt", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ProximityPrompt") end)
    T("class.name.ProximityPrompt", function() return EQ(o.Name, "ProximityPrompt") end)
    T("class.tostring.ProximityPrompt", function() return EQ(tostring(o), "ProximityPrompt") end)
    T("class.parent.ProximityPrompt", function() return EQ(o.Parent, nil) end)
    T("class.isa.ProximityPrompt.ProximityPrompt", function() return EQ(o:IsA("ProximityPrompt"), true) end)
    T("class.isa.ProximityPrompt.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ProximityPrompt", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "PyramidHandleAdornment")
    T("class.new.PyramidHandleAdornment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "PyramidHandleAdornment") end)
    T("class.name.PyramidHandleAdornment", function() return EQ(o.Name, "PyramidHandleAdornment") end)
    T("class.tostring.PyramidHandleAdornment", function() return EQ(tostring(o), "PyramidHandleAdornment") end)
    T("class.parent.PyramidHandleAdornment", function() return EQ(o.Parent, nil) end)
    T("class.isa.PyramidHandleAdornment.PyramidHandleAdornment", function() return EQ(o:IsA("PyramidHandleAdornment"), true) end)
    T("class.isa.PyramidHandleAdornment.HandleAdornment", function() return EQ(o:IsA("HandleAdornment"), true) end)
    T("class.isa.PyramidHandleAdornment.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.PyramidHandleAdornment.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.PyramidHandleAdornment.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.PyramidHandleAdornment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.PyramidHandleAdornment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.QWidgetPluginGui", function() return ERR(function() return Instance.new("QWidgetPluginGui") end, "Unable to create an Instance of type \"QWidgetPluginGui\"") end)
end
do
    local ok, o = pcall(Instance.new, "RayValue")
    T("class.new.RayValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RayValue") end)
    T("class.name.RayValue", function() return EQ(o.Name, "RayValue") end)
    T("class.tostring.RayValue", function() return EQ(tostring(o), "RayValue") end)
    T("class.parent.RayValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.RayValue.RayValue", function() return EQ(o:IsA("RayValue"), true) end)
    T("class.isa.RayValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.RayValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RayValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    T("class.notcreatable.RecommendationPages", function() return ERR(function() return Instance.new("RecommendationPages") end, "Unable to create an Instance of type \"RecommendationPages\"") end)
end
do
    T("class.notcreatable.ReflectionMetadataItem", function() return ERR(function() return Instance.new("ReflectionMetadataItem") end, "Unable to create an Instance of type \"ReflectionMetadataItem\"") end)
end
do
    local ok, o = pcall(Instance.new, "RemoteEvent")
    T("class.new.RemoteEvent", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RemoteEvent") end)
    T("class.name.RemoteEvent", function() return EQ(o.Name, "RemoteEvent") end)
    T("class.tostring.RemoteEvent", function() return EQ(tostring(o), "RemoteEvent") end)
    T("class.parent.RemoteEvent", function() return EQ(o.Parent, nil) end)
    T("class.isa.RemoteEvent.RemoteEvent", function() return EQ(o:IsA("RemoteEvent"), true) end)
    T("class.isa.RemoteEvent.BaseRemoteEvent", function() return EQ(o:IsA("BaseRemoteEvent"), true) end)
    T("class.isa.RemoteEvent.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RemoteEvent", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "RemoteFunction")
    T("class.new.RemoteFunction", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RemoteFunction") end)
    T("class.name.RemoteFunction", function() return EQ(o.Name, "RemoteFunction") end)
    T("class.tostring.RemoteFunction", function() return EQ(tostring(o), "RemoteFunction") end)
    T("class.parent.RemoteFunction", function() return EQ(o.Parent, nil) end)
    T("class.isa.RemoteFunction.RemoteFunction", function() return EQ(o:IsA("RemoteFunction"), true) end)
    T("class.isa.RemoteFunction.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RemoteFunction", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ReverbSoundEffect")
    T("class.new.ReverbSoundEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ReverbSoundEffect") end)
    T("class.name.ReverbSoundEffect", function() return EQ(o.Name, "ReverbSoundEffect") end)
    T("class.tostring.ReverbSoundEffect", function() return EQ(tostring(o), "ReverbSoundEffect") end)
    T("class.parent.ReverbSoundEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.ReverbSoundEffect.ReverbSoundEffect", function() return EQ(o:IsA("ReverbSoundEffect"), true) end)
    T("class.isa.ReverbSoundEffect.SoundEffect", function() return EQ(o:IsA("SoundEffect"), true) end)
    T("class.isa.ReverbSoundEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ReverbSoundEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "RigidConstraint")
    T("class.new.RigidConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RigidConstraint") end)
    T("class.name.RigidConstraint", function() return EQ(o.Name, "RigidConstraint") end)
    T("class.tostring.RigidConstraint", function() return EQ(tostring(o), "RigidConstraint") end)
    T("class.parent.RigidConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.RigidConstraint.RigidConstraint", function() return EQ(o:IsA("RigidConstraint"), true) end)
    T("class.isa.RigidConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.RigidConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RigidConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.RobloxSerializableInstance", function() return ERR(function() return Instance.new("RobloxSerializableInstance") end, "Unable to create an Instance of type \"RobloxSerializableInstance\"") end)
end
do
    local ok, o = pcall(Instance.new, "RocketPropulsion")
    T("class.new.RocketPropulsion", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RocketPropulsion") end)
    T("class.name.RocketPropulsion", function() return EQ(o.Name, "RocketPropulsion") end)
    T("class.tostring.RocketPropulsion", function() return EQ(tostring(o), "RocketPropulsion") end)
    T("class.parent.RocketPropulsion", function() return EQ(o.Parent, nil) end)
    T("class.isa.RocketPropulsion.RocketPropulsion", function() return EQ(o:IsA("RocketPropulsion"), true) end)
    T("class.isa.RocketPropulsion.BodyMover", function() return EQ(o:IsA("BodyMover"), true) end)
    T("class.isa.RocketPropulsion.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RocketPropulsion", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "RodConstraint")
    T("class.new.RodConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RodConstraint") end)
    T("class.name.RodConstraint", function() return EQ(o.Name, "RodConstraint") end)
    T("class.tostring.RodConstraint", function() return EQ(tostring(o), "RodConstraint") end)
    T("class.parent.RodConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.RodConstraint.RodConstraint", function() return EQ(o:IsA("RodConstraint"), true) end)
    T("class.isa.RodConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.RodConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RodConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.RolloutValidation", function() return ERR(function() return Instance.new("RolloutValidation") end, "Unable to create an Instance of type \"RolloutValidation\"") end)
end
do
    T("class.notcreatable.RootImportData", function() return ERR(function() return Instance.new("RootImportData") end, "Unable to create an Instance of type \"RootImportData\"") end)
end
do
    local ok, o = pcall(Instance.new, "RopeConstraint")
    T("class.new.RopeConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RopeConstraint") end)
    T("class.name.RopeConstraint", function() return EQ(o.Name, "RopeConstraint") end)
    T("class.tostring.RopeConstraint", function() return EQ(tostring(o), "RopeConstraint") end)
    T("class.parent.RopeConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.RopeConstraint.RopeConstraint", function() return EQ(o:IsA("RopeConstraint"), true) end)
    T("class.isa.RopeConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.RopeConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RopeConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Rotate")
    T("class.new.Rotate", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Rotate") end)
    T("class.name.Rotate", function() return EQ(o.Name, "Rotate") end)
    T("class.tostring.Rotate", function() return EQ(tostring(o), "Rotate") end)
    T("class.parent.Rotate", function() return EQ(o.Parent, nil) end)
    T("class.isa.Rotate.Rotate", function() return EQ(o:IsA("Rotate"), true) end)
    T("class.isa.Rotate.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.Rotate.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Rotate", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "RotateP")
    T("class.new.RotateP", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RotateP") end)
    T("class.name.RotateP", function() return EQ(o.Name, "RotateP") end)
    T("class.tostring.RotateP", function() return EQ(tostring(o), "RotateP") end)
    T("class.parent.RotateP", function() return EQ(o.Parent, nil) end)
    T("class.isa.RotateP.RotateP", function() return EQ(o:IsA("RotateP"), true) end)
    T("class.isa.RotateP.DynamicRotate", function() return EQ(o:IsA("DynamicRotate"), true) end)
    T("class.isa.RotateP.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.RotateP.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RotateP", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "RotateV")
    T("class.new.RotateV", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RotateV") end)
    T("class.name.RotateV", function() return EQ(o.Name, "RotateV") end)
    T("class.tostring.RotateV", function() return EQ(tostring(o), "RotateV") end)
    T("class.parent.RotateV", function() return EQ(o.Parent, nil) end)
    T("class.isa.RotateV.RotateV", function() return EQ(o:IsA("RotateV"), true) end)
    T("class.isa.RotateV.DynamicRotate", function() return EQ(o:IsA("DynamicRotate"), true) end)
    T("class.isa.RotateV.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.RotateV.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RotateV", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "RotationCurve")
    T("class.new.RotationCurve", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "RotationCurve") end)
    T("class.name.RotationCurve", function() return EQ(o.Name, "RotationCurve") end)
    T("class.tostring.RotationCurve", function() return EQ(tostring(o), "RotationCurve") end)
    T("class.parent.RotationCurve", function() return EQ(o.Parent, nil) end)
    T("class.isa.RotationCurve.RotationCurve", function() return EQ(o:IsA("RotationCurve"), true) end)
    T("class.isa.RotationCurve.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.RotationCurve", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.RunningAverageItemDouble", function() return ERR(function() return Instance.new("RunningAverageItemDouble") end, "Unable to create an Instance of type \"RunningAverageItemDouble\"") end)
end
do
    T("class.notcreatable.RunningAverageItemInt", function() return ERR(function() return Instance.new("RunningAverageItemInt") end, "Unable to create an Instance of type \"RunningAverageItemInt\"") end)
end
do
    T("class.notcreatable.RunningAverageTimeIntervalItem", function() return ERR(function() return Instance.new("RunningAverageTimeIntervalItem") end, "Unable to create an Instance of type \"RunningAverageTimeIntervalItem\"") end)
end
do
    local ok, o = pcall(Instance.new, "ScreenGui")
    T("class.new.ScreenGui", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ScreenGui") end)
    T("class.name.ScreenGui", function() return EQ(o.Name, "ScreenGui") end)
    T("class.tostring.ScreenGui", function() return EQ(tostring(o), "ScreenGui") end)
    T("class.parent.ScreenGui", function() return EQ(o.Parent, nil) end)
    T("class.isa.ScreenGui.ScreenGui", function() return EQ(o:IsA("ScreenGui"), true) end)
    T("class.isa.ScreenGui.LayerCollector", function() return EQ(o:IsA("LayerCollector"), true) end)
    T("class.isa.ScreenGui.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.ScreenGui.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.ScreenGui.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ScreenGui", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ScreenshotCapture", function() return ERR(function() return Instance.new("ScreenshotCapture") end, "Unable to create an Instance of type \"ScreenshotCapture\"") end)
end
do
    T("class.notcreatable.ScreenshotHud", function() return ERR(function() return Instance.new("ScreenshotHud") end, "Unable to create an Instance of type \"ScreenshotHud\"") end)
end
do
    local ok, o = pcall(Instance.new, "Script")
    T("class.new.Script", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Script") end)
    T("class.name.Script", function() return EQ(o.Name, "Script") end)
    T("class.tostring.Script", function() return EQ(tostring(o), "Script") end)
    T("class.parent.Script", function() return EQ(o.Parent, nil) end)
    T("class.isa.Script.Script", function() return EQ(o:IsA("Script"), true) end)
    T("class.isa.Script.BaseScript", function() return EQ(o:IsA("BaseScript"), true) end)
    T("class.isa.Script.LuaSourceContainer", function() return EQ(o:IsA("LuaSourceContainer"), true) end)
    T("class.isa.Script.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Script", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ScriptBuilder", function() return ERR(function() return Instance.new("ScriptBuilder") end, "Unable to create an Instance of type \"ScriptBuilder\"") end)
end
do
    T("class.notcreatable.ScriptDebugger", function() return ERR(function() return Instance.new("ScriptDebugger") end, "Unable to create an Instance of type \"ScriptDebugger\"") end)
end
do
    T("class.notcreatable.ScriptDocument", function() return ERR(function() return Instance.new("ScriptDocument") end, "Unable to create an Instance of type \"ScriptDocument\"") end)
end
do
    T("class.notcreatable.ScriptRuntime", function() return ERR(function() return Instance.new("ScriptRuntime") end, "Unable to create an Instance of type \"ScriptRuntime\"") end)
end
do
    local ok, o = pcall(Instance.new, "ScrollingFrame")
    T("class.new.ScrollingFrame", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ScrollingFrame") end)
    T("class.name.ScrollingFrame", function() return EQ(o.Name, "ScrollingFrame") end)
    T("class.tostring.ScrollingFrame", function() return EQ(tostring(o), "ScrollingFrame") end)
    T("class.parent.ScrollingFrame", function() return EQ(o.Parent, nil) end)
    T("class.isa.ScrollingFrame.ScrollingFrame", function() return EQ(o:IsA("ScrollingFrame"), true) end)
    T("class.isa.ScrollingFrame.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.ScrollingFrame.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.ScrollingFrame.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.ScrollingFrame.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ScrollingFrame", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Seat")
    T("class.new.Seat", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Seat") end)
    T("class.name.Seat", function() return EQ(o.Name, "Seat") end)
    T("class.tostring.Seat", function() return EQ(tostring(o), "Seat") end)
    T("class.parent.Seat", function() return EQ(o.Parent, nil) end)
    T("class.isa.Seat.Seat", function() return EQ(o:IsA("Seat"), true) end)
    T("class.isa.Seat.Part", function() return EQ(o:IsA("Part"), true) end)
    T("class.isa.Seat.FormFactorPart", function() return EQ(o:IsA("FormFactorPart"), true) end)
    T("class.isa.Seat.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.Seat.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.Seat.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Seat", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SelectionBox")
    T("class.new.SelectionBox", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SelectionBox") end)
    T("class.name.SelectionBox", function() return EQ(o.Name, "SelectionBox") end)
    T("class.tostring.SelectionBox", function() return EQ(tostring(o), "SelectionBox") end)
    T("class.parent.SelectionBox", function() return EQ(o.Parent, nil) end)
    T("class.isa.SelectionBox.SelectionBox", function() return EQ(o:IsA("SelectionBox"), true) end)
    T("class.isa.SelectionBox.InstanceAdornment", function() return EQ(o:IsA("InstanceAdornment"), true) end)
    T("class.isa.SelectionBox.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.SelectionBox.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.SelectionBox.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SelectionBox", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.SelectionLasso", function() return ERR(function() return Instance.new("SelectionLasso") end, "Unable to create an Instance of type \"SelectionLasso\"") end)
end
do
    local ok, o = pcall(Instance.new, "SelectionSphere")
    T("class.new.SelectionSphere", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SelectionSphere") end)
    T("class.name.SelectionSphere", function() return EQ(o.Name, "SelectionSphere") end)
    T("class.tostring.SelectionSphere", function() return EQ(tostring(o), "SelectionSphere") end)
    T("class.parent.SelectionSphere", function() return EQ(o.Parent, nil) end)
    T("class.isa.SelectionSphere.SelectionSphere", function() return EQ(o:IsA("SelectionSphere"), true) end)
    T("class.isa.SelectionSphere.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.SelectionSphere.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.SelectionSphere.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.SelectionSphere.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SelectionSphere", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.SelfViewConfiguration", function() return ERR(function() return Instance.new("SelfViewConfiguration") end, "Unable to create an Instance of type \"SelfViewConfiguration\"") end)
end
do
    T("class.notcreatable.SensorBase", function() return ERR(function() return Instance.new("SensorBase") end, "Unable to create an Instance of type \"SensorBase\"") end)
end
do
    T("class.notcreatable.ServerReplicator", function() return ERR(function() return Instance.new("ServerReplicator") end, "Unable to create an Instance of type \"ServerReplicator\"") end)
end
do
    T("class.notcreatable.ServiceProvider", function() return ERR(function() return Instance.new("ServiceProvider") end, "Unable to create an Instance of type \"ServiceProvider\"") end)
end
do
    local ok, o = pcall(Instance.new, "Shirt")
    T("class.new.Shirt", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Shirt") end)
    T("class.name.Shirt", function() return EQ(o.Name, "Shirt") end)
    T("class.tostring.Shirt", function() return EQ(tostring(o), "Shirt") end)
    T("class.parent.Shirt", function() return EQ(o.Parent, nil) end)
    T("class.isa.Shirt.Shirt", function() return EQ(o:IsA("Shirt"), true) end)
    T("class.isa.Shirt.Clothing", function() return EQ(o:IsA("Clothing"), true) end)
    T("class.isa.Shirt.CharacterAppearance", function() return EQ(o:IsA("CharacterAppearance"), true) end)
    T("class.isa.Shirt.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Shirt", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ShirtGraphic")
    T("class.new.ShirtGraphic", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ShirtGraphic") end)
    T("class.name.ShirtGraphic", function() return EQ(o.Name, "ShirtGraphic") end)
    T("class.tostring.ShirtGraphic", function() return EQ(tostring(o), "ShirtGraphic") end)
    T("class.parent.ShirtGraphic", function() return EQ(o.Parent, nil) end)
    T("class.isa.ShirtGraphic.ShirtGraphic", function() return EQ(o:IsA("ShirtGraphic"), true) end)
    T("class.isa.ShirtGraphic.CharacterAppearance", function() return EQ(o:IsA("CharacterAppearance"), true) end)
    T("class.isa.ShirtGraphic.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ShirtGraphic", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SkateboardPlatform")
    T("class.new.SkateboardPlatform", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SkateboardPlatform") end)
    T("class.name.SkateboardPlatform", function() return EQ(o.Name, "SkateboardPlatform") end)
    T("class.tostring.SkateboardPlatform", function() return EQ(tostring(o), "SkateboardPlatform") end)
    T("class.parent.SkateboardPlatform", function() return EQ(o.Parent, nil) end)
    T("class.isa.SkateboardPlatform.SkateboardPlatform", function() return EQ(o:IsA("SkateboardPlatform"), true) end)
    T("class.isa.SkateboardPlatform.Part", function() return EQ(o:IsA("Part"), true) end)
    T("class.isa.SkateboardPlatform.FormFactorPart", function() return EQ(o:IsA("FormFactorPart"), true) end)
    T("class.isa.SkateboardPlatform.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.SkateboardPlatform.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.SkateboardPlatform.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SkateboardPlatform", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Skin")
    T("class.new.Skin", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Skin") end)
    T("class.name.Skin", function() return EQ(o.Name, "Skin") end)
    T("class.tostring.Skin", function() return EQ(tostring(o), "Skin") end)
    T("class.parent.Skin", function() return EQ(o.Parent, nil) end)
    T("class.isa.Skin.Skin", function() return EQ(o:IsA("Skin"), true) end)
    T("class.isa.Skin.CharacterAppearance", function() return EQ(o:IsA("CharacterAppearance"), true) end)
    T("class.isa.Skin.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Skin", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Sky")
    T("class.new.Sky", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Sky") end)
    T("class.name.Sky", function() return EQ(o.Name, "Sky") end)
    T("class.tostring.Sky", function() return EQ(tostring(o), "Sky") end)
    T("class.parent.Sky", function() return EQ(o.Parent, nil) end)
    T("class.isa.Sky.Sky", function() return EQ(o:IsA("Sky"), true) end)
    T("class.isa.Sky.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Sky", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.SlidingBallConstraint", function() return ERR(function() return Instance.new("SlidingBallConstraint") end, "Unable to create an Instance of type \"SlidingBallConstraint\"") end)
end
do
    T("class.notcreatable.SlimAnimationDataEntity", function() return ERR(function() return Instance.new("SlimAnimationDataEntity") end, "Unable to create an Instance of type \"SlimAnimationDataEntity\"") end)
end
do
    local ok, o = pcall(Instance.new, "Smoke")
    T("class.new.Smoke", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Smoke") end)
    T("class.name.Smoke", function() return EQ(o.Name, "Smoke") end)
    T("class.tostring.Smoke", function() return EQ(tostring(o), "Smoke") end)
    T("class.parent.Smoke", function() return EQ(o.Parent, nil) end)
    T("class.isa.Smoke.Smoke", function() return EQ(o:IsA("Smoke"), true) end)
    T("class.isa.Smoke.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Smoke", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Snap")
    T("class.new.Snap", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Snap") end)
    T("class.name.Snap", function() return EQ(o.Name, "Snap") end)
    T("class.tostring.Snap", function() return EQ(tostring(o), "Snap") end)
    T("class.parent.Snap", function() return EQ(o.Parent, nil) end)
    T("class.isa.Snap.Snap", function() return EQ(o:IsA("Snap"), true) end)
    T("class.isa.Snap.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.Snap.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Snap", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Sound")
    T("class.new.Sound", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Sound") end)
    T("class.name.Sound", function() return EQ(o.Name, "Sound") end)
    T("class.tostring.Sound", function() return EQ(tostring(o), "Sound") end)
    T("class.parent.Sound", function() return EQ(o.Parent, nil) end)
    T("class.isa.Sound.Sound", function() return EQ(o:IsA("Sound"), true) end)
    T("class.isa.Sound.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Sound", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.SoundEffect", function() return ERR(function() return Instance.new("SoundEffect") end, "Unable to create an Instance of type \"SoundEffect\"") end)
end
do
    local ok, o = pcall(Instance.new, "SoundGroup")
    T("class.new.SoundGroup", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SoundGroup") end)
    T("class.name.SoundGroup", function() return EQ(o.Name, "SoundGroup") end)
    T("class.tostring.SoundGroup", function() return EQ(tostring(o), "SoundGroup") end)
    T("class.parent.SoundGroup", function() return EQ(o.Parent, nil) end)
    T("class.isa.SoundGroup.SoundGroup", function() return EQ(o:IsA("SoundGroup"), true) end)
    T("class.isa.SoundGroup.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SoundGroup", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Sparkles")
    T("class.new.Sparkles", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Sparkles") end)
    T("class.name.Sparkles", function() return EQ(o.Name, "Sparkles") end)
    T("class.tostring.Sparkles", function() return EQ(tostring(o), "Sparkles") end)
    T("class.parent.Sparkles", function() return EQ(o.Parent, nil) end)
    T("class.isa.Sparkles.Sparkles", function() return EQ(o:IsA("Sparkles"), true) end)
    T("class.isa.Sparkles.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Sparkles", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SpawnLocation")
    T("class.new.SpawnLocation", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SpawnLocation") end)
    T("class.name.SpawnLocation", function() return EQ(o.Name, "SpawnLocation") end)
    T("class.tostring.SpawnLocation", function() return EQ(tostring(o), "SpawnLocation") end)
    T("class.parent.SpawnLocation", function() return EQ(o.Parent, nil) end)
    T("class.isa.SpawnLocation.SpawnLocation", function() return EQ(o:IsA("SpawnLocation"), true) end)
    T("class.isa.SpawnLocation.Part", function() return EQ(o:IsA("Part"), true) end)
    T("class.isa.SpawnLocation.FormFactorPart", function() return EQ(o:IsA("FormFactorPart"), true) end)
    T("class.isa.SpawnLocation.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.SpawnLocation.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.SpawnLocation.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SpawnLocation", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SpecialMesh")
    T("class.new.SpecialMesh", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SpecialMesh") end)
    T("class.name.SpecialMesh", function() return EQ(o.Name, "SpecialMesh") end)
    T("class.tostring.SpecialMesh", function() return EQ(tostring(o), "SpecialMesh") end)
    T("class.parent.SpecialMesh", function() return EQ(o.Parent, nil) end)
    T("class.isa.SpecialMesh.SpecialMesh", function() return EQ(o:IsA("SpecialMesh"), true) end)
    T("class.isa.SpecialMesh.FileMesh", function() return EQ(o:IsA("FileMesh"), true) end)
    T("class.isa.SpecialMesh.DataModelMesh", function() return EQ(o:IsA("DataModelMesh"), true) end)
    T("class.isa.SpecialMesh.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SpecialMesh", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SphereHandleAdornment")
    T("class.new.SphereHandleAdornment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SphereHandleAdornment") end)
    T("class.name.SphereHandleAdornment", function() return EQ(o.Name, "SphereHandleAdornment") end)
    T("class.tostring.SphereHandleAdornment", function() return EQ(tostring(o), "SphereHandleAdornment") end)
    T("class.parent.SphereHandleAdornment", function() return EQ(o.Parent, nil) end)
    T("class.isa.SphereHandleAdornment.SphereHandleAdornment", function() return EQ(o:IsA("SphereHandleAdornment"), true) end)
    T("class.isa.SphereHandleAdornment.HandleAdornment", function() return EQ(o:IsA("HandleAdornment"), true) end)
    T("class.isa.SphereHandleAdornment.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.SphereHandleAdornment.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.SphereHandleAdornment.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.SphereHandleAdornment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SphereHandleAdornment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SpotLight")
    T("class.new.SpotLight", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SpotLight") end)
    T("class.name.SpotLight", function() return EQ(o.Name, "SpotLight") end)
    T("class.tostring.SpotLight", function() return EQ(tostring(o), "SpotLight") end)
    T("class.parent.SpotLight", function() return EQ(o.Parent, nil) end)
    T("class.isa.SpotLight.SpotLight", function() return EQ(o:IsA("SpotLight"), true) end)
    T("class.isa.SpotLight.Light", function() return EQ(o:IsA("Light"), true) end)
    T("class.isa.SpotLight.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SpotLight", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SpringConstraint")
    T("class.new.SpringConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SpringConstraint") end)
    T("class.name.SpringConstraint", function() return EQ(o.Name, "SpringConstraint") end)
    T("class.tostring.SpringConstraint", function() return EQ(tostring(o), "SpringConstraint") end)
    T("class.parent.SpringConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.SpringConstraint.SpringConstraint", function() return EQ(o:IsA("SpringConstraint"), true) end)
    T("class.isa.SpringConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.SpringConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SpringConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.StackFrame", function() return ERR(function() return Instance.new("StackFrame") end, "Unable to create an Instance of type \"StackFrame\"") end)
end
do
    T("class.notcreatable.StandardPages", function() return ERR(function() return Instance.new("StandardPages") end, "Unable to create an Instance of type \"StandardPages\"") end)
end
do
    T("class.notcreatable.StandardQueue", function() return ERR(function() return Instance.new("StandardQueue") end, "Unable to create an Instance of type \"StandardQueue\"") end)
end
do
    T("class.notcreatable.StarterCharacterScripts", function() return ERR(function() return Instance.new("StarterCharacterScripts") end, "Unable to create an Instance of type \"StarterCharacterScripts\"") end)
end
do
    local ok, o = pcall(Instance.new, "StarterGear")
    T("class.new.StarterGear", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "StarterGear") end)
    T("class.name.StarterGear", function() return EQ(o.Name, "StarterGear") end)
    T("class.tostring.StarterGear", function() return EQ(tostring(o), "StarterGear") end)
    T("class.parent.StarterGear", function() return EQ(o.Parent, nil) end)
    T("class.isa.StarterGear.StarterGear", function() return EQ(o:IsA("StarterGear"), true) end)
    T("class.isa.StarterGear.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.StarterGear", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.StarterPlayerScripts", function() return ERR(function() return Instance.new("StarterPlayerScripts") end, "Unable to create an Instance of type \"StarterPlayerScripts\"") end)
end
do
    T("class.notcreatable.StatsItem", function() return ERR(function() return Instance.new("StatsItem") end, "Unable to create an Instance of type \"StatsItem\"") end)
end
do
    T("class.notcreatable.Status", function() return ERR(function() return Instance.new("Status") end, "Unable to create an Instance of type \"Status\"") end)
end
do
    local ok, o = pcall(Instance.new, "StringValue")
    T("class.new.StringValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "StringValue") end)
    T("class.name.StringValue", function() return EQ(o.Name, "StringValue") end)
    T("class.tostring.StringValue", function() return EQ(tostring(o), "StringValue") end)
    T("class.parent.StringValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.StringValue.StringValue", function() return EQ(o:IsA("StringValue"), true) end)
    T("class.isa.StringValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.StringValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.StringValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    T("class.notcreatable.StudioActionOverride", function() return ERR(function() return Instance.new("StudioActionOverride") end, "Unable to create an Instance of type \"StudioActionOverride\"") end)
end
do
    T("class.notcreatable.StudioObjectBase", function() return ERR(function() return Instance.new("StudioObjectBase") end, "Unable to create an Instance of type \"StudioObjectBase\"") end)
end
do
    T("class.notcreatable.StudioScreenshotCapture", function() return ERR(function() return Instance.new("StudioScreenshotCapture") end, "Unable to create an Instance of type \"StudioScreenshotCapture\"") end)
end
do
    T("class.notcreatable.StudioTheme", function() return ERR(function() return Instance.new("StudioTheme") end, "Unable to create an Instance of type \"StudioTheme\"") end)
end
do
    T("class.notcreatable.StudioWidget", function() return ERR(function() return Instance.new("StudioWidget") end, "Unable to create an Instance of type \"StudioWidget\"") end)
end
do
    T("class.notcreatable.StyleBase", function() return ERR(function() return Instance.new("StyleBase") end, "Unable to create an Instance of type \"StyleBase\"") end)
end
do
    local ok, o = pcall(Instance.new, "StyleDerive")
    T("class.new.StyleDerive", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "StyleDerive") end)
    T("class.name.StyleDerive", function() return EQ(o.Name, "StyleDerive") end)
    T("class.tostring.StyleDerive", function() return EQ(tostring(o), "StyleDerive") end)
    T("class.parent.StyleDerive", function() return EQ(o.Parent, nil) end)
    T("class.isa.StyleDerive.StyleDerive", function() return EQ(o:IsA("StyleDerive"), true) end)
    T("class.isa.StyleDerive.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.StyleDerive", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "StyleLink")
    T("class.new.StyleLink", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "StyleLink") end)
    T("class.name.StyleLink", function() return EQ(o.Name, "StyleLink") end)
    T("class.tostring.StyleLink", function() return EQ(tostring(o), "StyleLink") end)
    T("class.parent.StyleLink", function() return EQ(o.Parent, nil) end)
    T("class.isa.StyleLink.StyleLink", function() return EQ(o:IsA("StyleLink"), true) end)
    T("class.isa.StyleLink.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.StyleLink", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "StyleRule")
    T("class.new.StyleRule", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "StyleRule") end)
    T("class.name.StyleRule", function() return EQ(o.Name, "StyleRule") end)
    T("class.tostring.StyleRule", function() return EQ(tostring(o), "StyleRule") end)
    T("class.parent.StyleRule", function() return EQ(o.Parent, nil) end)
    T("class.isa.StyleRule.StyleRule", function() return EQ(o:IsA("StyleRule"), true) end)
    T("class.isa.StyleRule.StyleBase", function() return EQ(o:IsA("StyleBase"), true) end)
    T("class.isa.StyleRule.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.StyleRule", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "StyleSheet")
    T("class.new.StyleSheet", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "StyleSheet") end)
    T("class.name.StyleSheet", function() return EQ(o.Name, "StyleSheet") end)
    T("class.tostring.StyleSheet", function() return EQ(tostring(o), "StyleSheet") end)
    T("class.parent.StyleSheet", function() return EQ(o.Parent, nil) end)
    T("class.isa.StyleSheet.StyleSheet", function() return EQ(o:IsA("StyleSheet"), true) end)
    T("class.isa.StyleSheet.StyleBase", function() return EQ(o:IsA("StyleBase"), true) end)
    T("class.isa.StyleSheet.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.StyleSheet", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SunRaysEffect")
    T("class.new.SunRaysEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SunRaysEffect") end)
    T("class.name.SunRaysEffect", function() return EQ(o.Name, "SunRaysEffect") end)
    T("class.tostring.SunRaysEffect", function() return EQ(tostring(o), "SunRaysEffect") end)
    T("class.parent.SunRaysEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.SunRaysEffect.SunRaysEffect", function() return EQ(o:IsA("SunRaysEffect"), true) end)
    T("class.isa.SunRaysEffect.PostEffect", function() return EQ(o:IsA("PostEffect"), true) end)
    T("class.isa.SunRaysEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SunRaysEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SurfaceAppearance")
    T("class.new.SurfaceAppearance", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SurfaceAppearance") end)
    T("class.name.SurfaceAppearance", function() return EQ(o.Name, "SurfaceAppearance") end)
    T("class.tostring.SurfaceAppearance", function() return EQ(tostring(o), "SurfaceAppearance") end)
    T("class.parent.SurfaceAppearance", function() return EQ(o.Parent, nil) end)
    T("class.isa.SurfaceAppearance.SurfaceAppearance", function() return EQ(o:IsA("SurfaceAppearance"), true) end)
    T("class.isa.SurfaceAppearance.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SurfaceAppearance", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SurfaceGui")
    T("class.new.SurfaceGui", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SurfaceGui") end)
    T("class.name.SurfaceGui", function() return EQ(o.Name, "SurfaceGui") end)
    T("class.tostring.SurfaceGui", function() return EQ(tostring(o), "SurfaceGui") end)
    T("class.parent.SurfaceGui", function() return EQ(o.Parent, nil) end)
    T("class.isa.SurfaceGui.SurfaceGui", function() return EQ(o:IsA("SurfaceGui"), true) end)
    T("class.isa.SurfaceGui.SurfaceGuiBase", function() return EQ(o:IsA("SurfaceGuiBase"), true) end)
    T("class.isa.SurfaceGui.LayerCollector", function() return EQ(o:IsA("LayerCollector"), true) end)
    T("class.isa.SurfaceGui.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.SurfaceGui.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.SurfaceGui.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SurfaceGui", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.SurfaceGuiBase", function() return ERR(function() return Instance.new("SurfaceGuiBase") end, "Unable to create an Instance of type \"SurfaceGuiBase\"") end)
end
do
    local ok, o = pcall(Instance.new, "SurfaceLight")
    T("class.new.SurfaceLight", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SurfaceLight") end)
    T("class.name.SurfaceLight", function() return EQ(o.Name, "SurfaceLight") end)
    T("class.tostring.SurfaceLight", function() return EQ(tostring(o), "SurfaceLight") end)
    T("class.parent.SurfaceLight", function() return EQ(o.Parent, nil) end)
    T("class.isa.SurfaceLight.SurfaceLight", function() return EQ(o:IsA("SurfaceLight"), true) end)
    T("class.isa.SurfaceLight.Light", function() return EQ(o:IsA("Light"), true) end)
    T("class.isa.SurfaceLight.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SurfaceLight", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SurfaceSelection")
    T("class.new.SurfaceSelection", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SurfaceSelection") end)
    T("class.name.SurfaceSelection", function() return EQ(o.Name, "SurfaceSelection") end)
    T("class.tostring.SurfaceSelection", function() return EQ(tostring(o), "SurfaceSelection") end)
    T("class.parent.SurfaceSelection", function() return EQ(o.Parent, nil) end)
    T("class.isa.SurfaceSelection.SurfaceSelection", function() return EQ(o:IsA("SurfaceSelection"), true) end)
    T("class.isa.SurfaceSelection.PartAdornment", function() return EQ(o:IsA("PartAdornment"), true) end)
    T("class.isa.SurfaceSelection.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.SurfaceSelection.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.SurfaceSelection.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SurfaceSelection", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "SwimController")
    T("class.new.SwimController", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "SwimController") end)
    T("class.name.SwimController", function() return EQ(o.Name, "SwimController") end)
    T("class.tostring.SwimController", function() return EQ(tostring(o), "SwimController") end)
    T("class.parent.SwimController", function() return EQ(o.Parent, nil) end)
    T("class.isa.SwimController.SwimController", function() return EQ(o:IsA("SwimController"), true) end)
    T("class.isa.SwimController.ControllerBase", function() return EQ(o:IsA("ControllerBase"), true) end)
    T("class.isa.SwimController.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.SwimController", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.SyncScriptBuilder", function() return ERR(function() return Instance.new("SyncScriptBuilder") end, "Unable to create an Instance of type \"SyncScriptBuilder\"") end)
end
do
    local ok, o = pcall(Instance.new, "Team")
    T("class.new.Team", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Team") end)
    T("class.name.Team", function() return EQ(o.Name, "Team") end)
    T("class.tostring.Team", function() return EQ(tostring(o), "Team") end)
    T("class.parent.Team", function() return EQ(o.Parent, nil) end)
    T("class.isa.Team.Team", function() return EQ(o:IsA("Team"), true) end)
    T("class.isa.Team.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Team", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TeleportAsyncResult", function() return ERR(function() return Instance.new("TeleportAsyncResult") end, "Unable to create an Instance of type \"TeleportAsyncResult\"") end)
end
do
    local ok, o = pcall(Instance.new, "TeleportOptions")
    T("class.new.TeleportOptions", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TeleportOptions") end)
    T("class.name.TeleportOptions", function() return EQ(o.Name, "TeleportOptions") end)
    T("class.tostring.TeleportOptions", function() return EQ(tostring(o), "TeleportOptions") end)
    T("class.parent.TeleportOptions", function() return EQ(o.Parent, nil) end)
    T("class.isa.TeleportOptions.TeleportOptions", function() return EQ(o:IsA("TeleportOptions"), true) end)
    T("class.isa.TeleportOptions.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TeleportOptions", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.Terrain", function() return ERR(function() return Instance.new("Terrain") end, "Unable to create an Instance of type \"Terrain\"") end)
end
do
    local ok, o = pcall(Instance.new, "TerrainDetail")
    T("class.new.TerrainDetail", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TerrainDetail") end)
    T("class.name.TerrainDetail", function() return EQ(o.Name, "TerrainDetail") end)
    T("class.tostring.TerrainDetail", function() return EQ(tostring(o), "TerrainDetail") end)
    T("class.parent.TerrainDetail", function() return EQ(o.Parent, nil) end)
    T("class.isa.TerrainDetail.TerrainDetail", function() return EQ(o:IsA("TerrainDetail"), true) end)
    T("class.isa.TerrainDetail.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TerrainDetail", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TerrainIterateOperation", function() return ERR(function() return Instance.new("TerrainIterateOperation") end, "Unable to create an Instance of type \"TerrainIterateOperation\"") end)
end
do
    T("class.notcreatable.TerrainModifyOperation", function() return ERR(function() return Instance.new("TerrainModifyOperation") end, "Unable to create an Instance of type \"TerrainModifyOperation\"") end)
end
do
    T("class.notcreatable.TerrainReadOperation", function() return ERR(function() return Instance.new("TerrainReadOperation") end, "Unable to create an Instance of type \"TerrainReadOperation\"") end)
end
do
    local ok, o = pcall(Instance.new, "TerrainRegion")
    T("class.new.TerrainRegion", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TerrainRegion") end)
    T("class.name.TerrainRegion", function() return EQ(o.Name, "TerrainRegion") end)
    T("class.tostring.TerrainRegion", function() return EQ(tostring(o), "TerrainRegion") end)
    T("class.parent.TerrainRegion", function() return EQ(o.Parent, nil) end)
    T("class.isa.TerrainRegion.TerrainRegion", function() return EQ(o:IsA("TerrainRegion"), true) end)
    T("class.isa.TerrainRegion.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TerrainRegion", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TerrainWriteOperation", function() return ERR(function() return Instance.new("TerrainWriteOperation") end, "Unable to create an Instance of type \"TerrainWriteOperation\"") end)
end
do
    T("class.notcreatable.TestCase", function() return ERR(function() return Instance.new("TestCase") end, "Unable to create an Instance of type \"TestCase\"") end)
end
do
    T("class.notcreatable.TestExecutionContext", function() return ERR(function() return Instance.new("TestExecutionContext") end, "Unable to create an Instance of type \"TestExecutionContext\"") end)
end
do
    T("class.notcreatable.TestFailure", function() return ERR(function() return Instance.new("TestFailure") end, "Unable to create an Instance of type \"TestFailure\"") end)
end
do
    T("class.notcreatable.TestResult", function() return ERR(function() return Instance.new("TestResult") end, "Unable to create an Instance of type \"TestResult\"") end)
end
do
    T("class.notcreatable.TestRunResult", function() return ERR(function() return Instance.new("TestRunResult") end, "Unable to create an Instance of type \"TestRunResult\"") end)
end
do
    T("class.notcreatable.TestSuite", function() return ERR(function() return Instance.new("TestSuite") end, "Unable to create an Instance of type \"TestSuite\"") end)
end
do
    local ok, o = pcall(Instance.new, "TextBox")
    T("class.new.TextBox", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TextBox") end)
    T("class.name.TextBox", function() return EQ(o.Name, "TextBox") end)
    T("class.tostring.TextBox", function() return EQ(tostring(o), "TextBox") end)
    T("class.parent.TextBox", function() return EQ(o.Parent, nil) end)
    T("class.isa.TextBox.TextBox", function() return EQ(o:IsA("TextBox"), true) end)
    T("class.isa.TextBox.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.TextBox.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.TextBox.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.TextBox.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TextBox", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "TextButton")
    T("class.new.TextButton", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TextButton") end)
    T("class.name.TextButton", function() return EQ(o.Name, "TextButton") end)
    T("class.tostring.TextButton", function() return EQ(tostring(o), "TextButton") end)
    T("class.parent.TextButton", function() return EQ(o.Parent, nil) end)
    T("class.isa.TextButton.TextButton", function() return EQ(o:IsA("TextButton"), true) end)
    T("class.isa.TextButton.GuiButton", function() return EQ(o:IsA("GuiButton"), true) end)
    T("class.isa.TextButton.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.TextButton.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.TextButton.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.TextButton.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TextButton", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "TextChannel")
    T("class.new.TextChannel", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TextChannel") end)
    T("class.name.TextChannel", function() return EQ(o.Name, "TextChannel") end)
    T("class.tostring.TextChannel", function() return EQ(tostring(o), "TextChannel") end)
    T("class.parent.TextChannel", function() return EQ(o.Parent, nil) end)
    T("class.isa.TextChannel.TextChannel", function() return EQ(o:IsA("TextChannel"), true) end)
    T("class.isa.TextChannel.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TextChannel", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "TextChatCommand")
    T("class.new.TextChatCommand", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TextChatCommand") end)
    T("class.name.TextChatCommand", function() return EQ(o.Name, "TextChatCommand") end)
    T("class.tostring.TextChatCommand", function() return EQ(tostring(o), "TextChatCommand") end)
    T("class.parent.TextChatCommand", function() return EQ(o.Parent, nil) end)
    T("class.isa.TextChatCommand.TextChatCommand", function() return EQ(o:IsA("TextChatCommand"), true) end)
    T("class.isa.TextChatCommand.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TextChatCommand", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TextChatConfigurations", function() return ERR(function() return Instance.new("TextChatConfigurations") end, "Unable to create an Instance of type \"TextChatConfigurations\"") end)
end
do
    T("class.notcreatable.TextChatMessage", function() return ERR(function() return Instance.new("TextChatMessage") end, "Unable to create an Instance of type \"TextChatMessage\"") end)
end
do
    local ok, o = pcall(Instance.new, "TextChatMessageProperties")
    T("class.new.TextChatMessageProperties", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TextChatMessageProperties") end)
    T("class.name.TextChatMessageProperties", function() return EQ(o.Name, "TextChatMessageProperties") end)
    T("class.tostring.TextChatMessageProperties", function() return EQ(tostring(o), "TextChatMessageProperties") end)
    T("class.parent.TextChatMessageProperties", function() return EQ(o.Parent, nil) end)
    T("class.isa.TextChatMessageProperties.TextChatMessageProperties", function() return EQ(o:IsA("TextChatMessageProperties"), true) end)
    T("class.isa.TextChatMessageProperties.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TextChatMessageProperties", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TextFilterResult", function() return ERR(function() return Instance.new("TextFilterResult") end, "Unable to create an Instance of type \"TextFilterResult\"") end)
end
do
    T("class.notcreatable.TextFilterTranslatedResult", function() return ERR(function() return Instance.new("TextFilterTranslatedResult") end, "Unable to create an Instance of type \"TextFilterTranslatedResult\"") end)
end
do
    local ok, o = pcall(Instance.new, "TextLabel")
    T("class.new.TextLabel", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TextLabel") end)
    T("class.name.TextLabel", function() return EQ(o.Name, "TextLabel") end)
    T("class.tostring.TextLabel", function() return EQ(tostring(o), "TextLabel") end)
    T("class.parent.TextLabel", function() return EQ(o.Parent, nil) end)
    T("class.isa.TextLabel.TextLabel", function() return EQ(o:IsA("TextLabel"), true) end)
    T("class.isa.TextLabel.GuiLabel", function() return EQ(o:IsA("GuiLabel"), true) end)
    T("class.isa.TextLabel.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.TextLabel.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.TextLabel.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.TextLabel.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TextLabel", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TextSource", function() return ERR(function() return Instance.new("TextSource") end, "Unable to create an Instance of type \"TextSource\"") end)
end
do
    local ok, o = pcall(Instance.new, "Texture")
    T("class.new.Texture", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Texture") end)
    T("class.name.Texture", function() return EQ(o.Name, "Texture") end)
    T("class.tostring.Texture", function() return EQ(tostring(o), "Texture") end)
    T("class.parent.Texture", function() return EQ(o.Parent, nil) end)
    T("class.isa.Texture.Texture", function() return EQ(o:IsA("Texture"), true) end)
    T("class.isa.Texture.Decal", function() return EQ(o:IsA("Decal"), true) end)
    T("class.isa.Texture.FaceInstance", function() return EQ(o:IsA("FaceInstance"), true) end)
    T("class.isa.Texture.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Texture", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TextureGenerationPartGroup", function() return ERR(function() return Instance.new("TextureGenerationPartGroup") end, "Unable to create an Instance of type \"TextureGenerationPartGroup\"") end)
end
do
    T("class.notcreatable.TextureGenerationUnwrappingRequest", function() return ERR(function() return Instance.new("TextureGenerationUnwrappingRequest") end, "Unable to create an Instance of type \"TextureGenerationUnwrappingRequest\"") end)
end
do
    T("class.notcreatable.ThreadState", function() return ERR(function() return Instance.new("ThreadState") end, "Unable to create an Instance of type \"ThreadState\"") end)
end
do
    local ok, o = pcall(Instance.new, "Tool")
    T("class.new.Tool", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Tool") end)
    T("class.name.Tool", function() return EQ(o.Name, "Tool") end)
    T("class.tostring.Tool", function() return EQ(tostring(o), "Tool") end)
    T("class.parent.Tool", function() return EQ(o.Parent, nil) end)
    T("class.isa.Tool.Tool", function() return EQ(o:IsA("Tool"), true) end)
    T("class.isa.Tool.BackpackItem", function() return EQ(o:IsA("BackpackItem"), true) end)
    T("class.isa.Tool.Model", function() return EQ(o:IsA("Model"), true) end)
    T("class.isa.Tool.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.Tool.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Tool", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Torque")
    T("class.new.Torque", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Torque") end)
    T("class.name.Torque", function() return EQ(o.Name, "Torque") end)
    T("class.tostring.Torque", function() return EQ(tostring(o), "Torque") end)
    T("class.parent.Torque", function() return EQ(o.Parent, nil) end)
    T("class.isa.Torque.Torque", function() return EQ(o:IsA("Torque"), true) end)
    T("class.isa.Torque.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.Torque.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Torque", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "TorsionSpringConstraint")
    T("class.new.TorsionSpringConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TorsionSpringConstraint") end)
    T("class.name.TorsionSpringConstraint", function() return EQ(o.Name, "TorsionSpringConstraint") end)
    T("class.tostring.TorsionSpringConstraint", function() return EQ(tostring(o), "TorsionSpringConstraint") end)
    T("class.parent.TorsionSpringConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.TorsionSpringConstraint.TorsionSpringConstraint", function() return EQ(o:IsA("TorsionSpringConstraint"), true) end)
    T("class.isa.TorsionSpringConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.TorsionSpringConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TorsionSpringConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TotalCountTimeIntervalItem", function() return ERR(function() return Instance.new("TotalCountTimeIntervalItem") end, "Unable to create an Instance of type \"TotalCountTimeIntervalItem\"") end)
end
do
    T("class.notcreatable.TouchTransmitter", function() return ERR(function() return Instance.new("TouchTransmitter") end, "Unable to create an Instance of type \"TouchTransmitter\"") end)
end
do
    T("class.notcreatable.TrackerLodController", function() return ERR(function() return Instance.new("TrackerLodController") end, "Unable to create an Instance of type \"TrackerLodController\"") end)
end
do
    local ok, o = pcall(Instance.new, "Trail")
    T("class.new.Trail", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Trail") end)
    T("class.name.Trail", function() return EQ(o.Name, "Trail") end)
    T("class.tostring.Trail", function() return EQ(tostring(o), "Trail") end)
    T("class.parent.Trail", function() return EQ(o.Parent, nil) end)
    T("class.isa.Trail.Trail", function() return EQ(o:IsA("Trail"), true) end)
    T("class.isa.Trail.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Trail", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.Translator", function() return ERR(function() return Instance.new("Translator") end, "Unable to create an Instance of type \"Translator\"") end)
end
do
    local ok, o = pcall(Instance.new, "TremoloSoundEffect")
    T("class.new.TremoloSoundEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TremoloSoundEffect") end)
    T("class.name.TremoloSoundEffect", function() return EQ(o.Name, "TremoloSoundEffect") end)
    T("class.tostring.TremoloSoundEffect", function() return EQ(tostring(o), "TremoloSoundEffect") end)
    T("class.parent.TremoloSoundEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.TremoloSoundEffect.TremoloSoundEffect", function() return EQ(o:IsA("TremoloSoundEffect"), true) end)
    T("class.isa.TremoloSoundEffect.SoundEffect", function() return EQ(o:IsA("SoundEffect"), true) end)
    T("class.isa.TremoloSoundEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TremoloSoundEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TriangleMeshPart", function() return ERR(function() return Instance.new("TriangleMeshPart") end, "Unable to create an Instance of type \"TriangleMeshPart\"") end)
end
do
    local ok, o = pcall(Instance.new, "TrussPart")
    T("class.new.TrussPart", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "TrussPart") end)
    T("class.name.TrussPart", function() return EQ(o.Name, "TrussPart") end)
    T("class.tostring.TrussPart", function() return EQ(tostring(o), "TrussPart") end)
    T("class.parent.TrussPart", function() return EQ(o.Parent, nil) end)
    T("class.isa.TrussPart.TrussPart", function() return EQ(o:IsA("TrussPart"), true) end)
    T("class.isa.TrussPart.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.TrussPart.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.TrussPart.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.TrussPart", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Tween")
    T("class.new.Tween", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Tween") end)
    T("class.name.Tween", function() return EQ(o.Name, "Tween") end)
    T("class.tostring.Tween", function() return EQ(tostring(o), "Tween") end)
    T("class.parent.Tween", function() return EQ(o.Parent, nil) end)
    T("class.isa.Tween.Tween", function() return EQ(o:IsA("Tween"), true) end)
    T("class.isa.Tween.TweenBase", function() return EQ(o:IsA("TweenBase"), true) end)
    T("class.isa.Tween.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Tween", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.TweenBase", function() return ERR(function() return Instance.new("TweenBase") end, "Unable to create an Instance of type \"TweenBase\"") end)
end
do
    local ok, o = pcall(Instance.new, "UIAspectRatioConstraint")
    T("class.new.UIAspectRatioConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIAspectRatioConstraint") end)
    T("class.name.UIAspectRatioConstraint", function() return EQ(o.Name, "UIAspectRatioConstraint") end)
    T("class.tostring.UIAspectRatioConstraint", function() return EQ(tostring(o), "UIAspectRatioConstraint") end)
    T("class.parent.UIAspectRatioConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIAspectRatioConstraint.UIAspectRatioConstraint", function() return EQ(o:IsA("UIAspectRatioConstraint"), true) end)
    T("class.isa.UIAspectRatioConstraint.UIConstraint", function() return EQ(o:IsA("UIConstraint"), true) end)
    T("class.isa.UIAspectRatioConstraint.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIAspectRatioConstraint.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIAspectRatioConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIAspectRatioConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.UIBase", function() return ERR(function() return Instance.new("UIBase") end, "Unable to create an Instance of type \"UIBase\"") end)
end
do
    T("class.notcreatable.UIComponent", function() return ERR(function() return Instance.new("UIComponent") end, "Unable to create an Instance of type \"UIComponent\"") end)
end
do
    T("class.notcreatable.UIConstraint", function() return ERR(function() return Instance.new("UIConstraint") end, "Unable to create an Instance of type \"UIConstraint\"") end)
end
do
    local ok, o = pcall(Instance.new, "UICorner")
    T("class.new.UICorner", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UICorner") end)
    T("class.name.UICorner", function() return EQ(o.Name, "UICorner") end)
    T("class.tostring.UICorner", function() return EQ(tostring(o), "UICorner") end)
    T("class.parent.UICorner", function() return EQ(o.Parent, nil) end)
    T("class.isa.UICorner.UICorner", function() return EQ(o:IsA("UICorner"), true) end)
    T("class.isa.UICorner.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UICorner.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UICorner.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UICorner", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UIDragDetector")
    T("class.new.UIDragDetector", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIDragDetector") end)
    T("class.name.UIDragDetector", function() return EQ(o.Name, "UIDragDetector") end)
    T("class.tostring.UIDragDetector", function() return EQ(tostring(o), "UIDragDetector") end)
    T("class.parent.UIDragDetector", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIDragDetector.UIDragDetector", function() return EQ(o:IsA("UIDragDetector"), true) end)
    T("class.isa.UIDragDetector.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIDragDetector.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIDragDetector.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIDragDetector", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UIFlexItem")
    T("class.new.UIFlexItem", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIFlexItem") end)
    T("class.name.UIFlexItem", function() return EQ(o.Name, "UIFlexItem") end)
    T("class.tostring.UIFlexItem", function() return EQ(tostring(o), "UIFlexItem") end)
    T("class.parent.UIFlexItem", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIFlexItem.UIFlexItem", function() return EQ(o:IsA("UIFlexItem"), true) end)
    T("class.isa.UIFlexItem.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIFlexItem.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIFlexItem.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIFlexItem", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UIGradient")
    T("class.new.UIGradient", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIGradient") end)
    T("class.name.UIGradient", function() return EQ(o.Name, "UIGradient") end)
    T("class.tostring.UIGradient", function() return EQ(tostring(o), "UIGradient") end)
    T("class.parent.UIGradient", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIGradient.UIGradient", function() return EQ(o:IsA("UIGradient"), true) end)
    T("class.isa.UIGradient.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIGradient.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIGradient.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIGradient", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UIGridLayout")
    T("class.new.UIGridLayout", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIGridLayout") end)
    T("class.name.UIGridLayout", function() return EQ(o.Name, "UIGridLayout") end)
    T("class.tostring.UIGridLayout", function() return EQ(tostring(o), "UIGridLayout") end)
    T("class.parent.UIGridLayout", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIGridLayout.UIGridLayout", function() return EQ(o:IsA("UIGridLayout"), true) end)
    T("class.isa.UIGridLayout.UIGridStyleLayout", function() return EQ(o:IsA("UIGridStyleLayout"), true) end)
    T("class.isa.UIGridLayout.UILayout", function() return EQ(o:IsA("UILayout"), true) end)
    T("class.isa.UIGridLayout.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIGridLayout.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIGridLayout.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIGridLayout", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.UIGridStyleLayout", function() return ERR(function() return Instance.new("UIGridStyleLayout") end, "Unable to create an Instance of type \"UIGridStyleLayout\"") end)
end
do
    T("class.notcreatable.UILayout", function() return ERR(function() return Instance.new("UILayout") end, "Unable to create an Instance of type \"UILayout\"") end)
end
do
    local ok, o = pcall(Instance.new, "UIListLayout")
    T("class.new.UIListLayout", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIListLayout") end)
    T("class.name.UIListLayout", function() return EQ(o.Name, "UIListLayout") end)
    T("class.tostring.UIListLayout", function() return EQ(tostring(o), "UIListLayout") end)
    T("class.parent.UIListLayout", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIListLayout.UIListLayout", function() return EQ(o:IsA("UIListLayout"), true) end)
    T("class.isa.UIListLayout.UIGridStyleLayout", function() return EQ(o:IsA("UIGridStyleLayout"), true) end)
    T("class.isa.UIListLayout.UILayout", function() return EQ(o:IsA("UILayout"), true) end)
    T("class.isa.UIListLayout.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIListLayout.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIListLayout.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIListLayout", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UIPadding")
    T("class.new.UIPadding", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIPadding") end)
    T("class.name.UIPadding", function() return EQ(o.Name, "UIPadding") end)
    T("class.tostring.UIPadding", function() return EQ(tostring(o), "UIPadding") end)
    T("class.parent.UIPadding", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIPadding.UIPadding", function() return EQ(o:IsA("UIPadding"), true) end)
    T("class.isa.UIPadding.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIPadding.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIPadding.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIPadding", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UIPageLayout")
    T("class.new.UIPageLayout", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIPageLayout") end)
    T("class.name.UIPageLayout", function() return EQ(o.Name, "UIPageLayout") end)
    T("class.tostring.UIPageLayout", function() return EQ(tostring(o), "UIPageLayout") end)
    T("class.parent.UIPageLayout", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIPageLayout.UIPageLayout", function() return EQ(o:IsA("UIPageLayout"), true) end)
    T("class.isa.UIPageLayout.UIGridStyleLayout", function() return EQ(o:IsA("UIGridStyleLayout"), true) end)
    T("class.isa.UIPageLayout.UILayout", function() return EQ(o:IsA("UILayout"), true) end)
    T("class.isa.UIPageLayout.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIPageLayout.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIPageLayout.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIPageLayout", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UIScale")
    T("class.new.UIScale", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIScale") end)
    T("class.name.UIScale", function() return EQ(o.Name, "UIScale") end)
    T("class.tostring.UIScale", function() return EQ(tostring(o), "UIScale") end)
    T("class.parent.UIScale", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIScale.UIScale", function() return EQ(o:IsA("UIScale"), true) end)
    T("class.isa.UIScale.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIScale.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIScale.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIScale", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UISizeConstraint")
    T("class.new.UISizeConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UISizeConstraint") end)
    T("class.name.UISizeConstraint", function() return EQ(o.Name, "UISizeConstraint") end)
    T("class.tostring.UISizeConstraint", function() return EQ(tostring(o), "UISizeConstraint") end)
    T("class.parent.UISizeConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.UISizeConstraint.UISizeConstraint", function() return EQ(o:IsA("UISizeConstraint"), true) end)
    T("class.isa.UISizeConstraint.UIConstraint", function() return EQ(o:IsA("UIConstraint"), true) end)
    T("class.isa.UISizeConstraint.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UISizeConstraint.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UISizeConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UISizeConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UIStroke")
    T("class.new.UIStroke", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UIStroke") end)
    T("class.name.UIStroke", function() return EQ(o.Name, "UIStroke") end)
    T("class.tostring.UIStroke", function() return EQ(tostring(o), "UIStroke") end)
    T("class.parent.UIStroke", function() return EQ(o.Parent, nil) end)
    T("class.isa.UIStroke.UIStroke", function() return EQ(o:IsA("UIStroke"), true) end)
    T("class.isa.UIStroke.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UIStroke.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UIStroke.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UIStroke", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UITableLayout")
    T("class.new.UITableLayout", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UITableLayout") end)
    T("class.name.UITableLayout", function() return EQ(o.Name, "UITableLayout") end)
    T("class.tostring.UITableLayout", function() return EQ(tostring(o), "UITableLayout") end)
    T("class.parent.UITableLayout", function() return EQ(o.Parent, nil) end)
    T("class.isa.UITableLayout.UITableLayout", function() return EQ(o:IsA("UITableLayout"), true) end)
    T("class.isa.UITableLayout.UIGridStyleLayout", function() return EQ(o:IsA("UIGridStyleLayout"), true) end)
    T("class.isa.UITableLayout.UILayout", function() return EQ(o:IsA("UILayout"), true) end)
    T("class.isa.UITableLayout.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UITableLayout.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UITableLayout.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UITableLayout", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UITextSizeConstraint")
    T("class.new.UITextSizeConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UITextSizeConstraint") end)
    T("class.name.UITextSizeConstraint", function() return EQ(o.Name, "UITextSizeConstraint") end)
    T("class.tostring.UITextSizeConstraint", function() return EQ(tostring(o), "UITextSizeConstraint") end)
    T("class.parent.UITextSizeConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.UITextSizeConstraint.UITextSizeConstraint", function() return EQ(o:IsA("UITextSizeConstraint"), true) end)
    T("class.isa.UITextSizeConstraint.UIConstraint", function() return EQ(o:IsA("UIConstraint"), true) end)
    T("class.isa.UITextSizeConstraint.UIComponent", function() return EQ(o:IsA("UIComponent"), true) end)
    T("class.isa.UITextSizeConstraint.UIBase", function() return EQ(o:IsA("UIBase"), true) end)
    T("class.isa.UITextSizeConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UITextSizeConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UnionOperation")
    T("class.new.UnionOperation", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UnionOperation") end)
    T("class.name.UnionOperation", function() return EQ(o.Name, "UnionOperation") end)
    T("class.tostring.UnionOperation", function() return EQ(tostring(o), "UnionOperation") end)
    T("class.parent.UnionOperation", function() return EQ(o.Parent, nil) end)
    T("class.isa.UnionOperation.UnionOperation", function() return EQ(o:IsA("UnionOperation"), true) end)
    T("class.isa.UnionOperation.PartOperation", function() return EQ(o:IsA("PartOperation"), true) end)
    T("class.isa.UnionOperation.TriangleMeshPart", function() return EQ(o:IsA("TriangleMeshPart"), true) end)
    T("class.isa.UnionOperation.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.UnionOperation.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.UnionOperation.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UnionOperation", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UniversalConstraint")
    T("class.new.UniversalConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UniversalConstraint") end)
    T("class.name.UniversalConstraint", function() return EQ(o.Name, "UniversalConstraint") end)
    T("class.tostring.UniversalConstraint", function() return EQ(tostring(o), "UniversalConstraint") end)
    T("class.parent.UniversalConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.UniversalConstraint.UniversalConstraint", function() return EQ(o:IsA("UniversalConstraint"), true) end)
    T("class.isa.UniversalConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.UniversalConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UniversalConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "UnreliableRemoteEvent")
    T("class.new.UnreliableRemoteEvent", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "UnreliableRemoteEvent") end)
    T("class.name.UnreliableRemoteEvent", function() return EQ(o.Name, "UnreliableRemoteEvent") end)
    T("class.tostring.UnreliableRemoteEvent", function() return EQ(tostring(o), "UnreliableRemoteEvent") end)
    T("class.parent.UnreliableRemoteEvent", function() return EQ(o.Parent, nil) end)
    T("class.isa.UnreliableRemoteEvent.UnreliableRemoteEvent", function() return EQ(o:IsA("UnreliableRemoteEvent"), true) end)
    T("class.isa.UnreliableRemoteEvent.BaseRemoteEvent", function() return EQ(o:IsA("BaseRemoteEvent"), true) end)
    T("class.isa.UnreliableRemoteEvent.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.UnreliableRemoteEvent", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.UserSettings", function() return ERR(function() return Instance.new("UserSettings") end, "Unable to create an Instance of type \"UserSettings\"") end)
end
do
    T("class.notcreatable.ValueBase", function() return ERR(function() return Instance.new("ValueBase") end, "Unable to create an Instance of type \"ValueBase\"") end)
end
do
    local ok, o = pcall(Instance.new, "Vector3Value")
    T("class.new.Vector3Value", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Vector3Value") end)
    T("class.name.Vector3Value", function() return EQ(o.Name, "Vector3Value") end)
    T("class.tostring.Vector3Value", function() return EQ(tostring(o), "Vector3Value") end)
    T("class.parent.Vector3Value", function() return EQ(o.Parent, nil) end)
    T("class.isa.Vector3Value.Vector3Value", function() return EQ(o:IsA("Vector3Value"), true) end)
    T("class.isa.Vector3Value.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.Vector3Value.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Vector3Value", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    local ok, o = pcall(Instance.new, "VectorForce")
    T("class.new.VectorForce", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "VectorForce") end)
    T("class.name.VectorForce", function() return EQ(o.Name, "VectorForce") end)
    T("class.tostring.VectorForce", function() return EQ(tostring(o), "VectorForce") end)
    T("class.parent.VectorForce", function() return EQ(o.Parent, nil) end)
    T("class.isa.VectorForce.VectorForce", function() return EQ(o:IsA("VectorForce"), true) end)
    T("class.isa.VectorForce.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.VectorForce.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.VectorForce", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "VehicleSeat")
    T("class.new.VehicleSeat", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "VehicleSeat") end)
    T("class.name.VehicleSeat", function() return EQ(o.Name, "VehicleSeat") end)
    T("class.tostring.VehicleSeat", function() return EQ(tostring(o), "VehicleSeat") end)
    T("class.parent.VehicleSeat", function() return EQ(o.Parent, nil) end)
    T("class.isa.VehicleSeat.VehicleSeat", function() return EQ(o:IsA("VehicleSeat"), true) end)
    T("class.isa.VehicleSeat.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.VehicleSeat.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.VehicleSeat.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.VehicleSeat", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "VelocityMotor")
    T("class.new.VelocityMotor", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "VelocityMotor") end)
    T("class.name.VelocityMotor", function() return EQ(o.Name, "VelocityMotor") end)
    T("class.tostring.VelocityMotor", function() return EQ(tostring(o), "VelocityMotor") end)
    T("class.parent.VelocityMotor", function() return EQ(o.Parent, nil) end)
    T("class.isa.VelocityMotor.VelocityMotor", function() return EQ(o:IsA("VelocityMotor"), true) end)
    T("class.isa.VelocityMotor.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.VelocityMotor.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.VelocityMotor", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.VideoCapture", function() return ERR(function() return Instance.new("VideoCapture") end, "Unable to create an Instance of type \"VideoCapture\"") end)
end
do
    local ok, o = pcall(Instance.new, "VideoDeviceInput")
    T("class.new.VideoDeviceInput", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "VideoDeviceInput") end)
    T("class.name.VideoDeviceInput", function() return EQ(o.Name, "VideoDeviceInput") end)
    T("class.tostring.VideoDeviceInput", function() return EQ(tostring(o), "VideoDeviceInput") end)
    T("class.parent.VideoDeviceInput", function() return EQ(o.Parent, nil) end)
    T("class.isa.VideoDeviceInput.VideoDeviceInput", function() return EQ(o:IsA("VideoDeviceInput"), true) end)
    T("class.isa.VideoDeviceInput.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.VideoDeviceInput", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "VideoDisplay")
    T("class.new.VideoDisplay", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "VideoDisplay") end)
    T("class.name.VideoDisplay", function() return EQ(o.Name, "VideoDisplay") end)
    T("class.tostring.VideoDisplay", function() return EQ(tostring(o), "VideoDisplay") end)
    T("class.parent.VideoDisplay", function() return EQ(o.Parent, nil) end)
    T("class.isa.VideoDisplay.VideoDisplay", function() return EQ(o:IsA("VideoDisplay"), true) end)
    T("class.isa.VideoDisplay.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.VideoDisplay.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.VideoDisplay.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.VideoDisplay.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.VideoDisplay", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "VideoFrame")
    T("class.new.VideoFrame", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "VideoFrame") end)
    T("class.name.VideoFrame", function() return EQ(o.Name, "VideoFrame") end)
    T("class.tostring.VideoFrame", function() return EQ(tostring(o), "VideoFrame") end)
    T("class.parent.VideoFrame", function() return EQ(o.Parent, nil) end)
    T("class.isa.VideoFrame.VideoFrame", function() return EQ(o:IsA("VideoFrame"), true) end)
    T("class.isa.VideoFrame.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.VideoFrame.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.VideoFrame.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.VideoFrame.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.VideoFrame", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "VideoPlayer")
    T("class.new.VideoPlayer", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "VideoPlayer") end)
    T("class.name.VideoPlayer", function() return EQ(o.Name, "VideoPlayer") end)
    T("class.tostring.VideoPlayer", function() return EQ(tostring(o), "VideoPlayer") end)
    T("class.parent.VideoPlayer", function() return EQ(o.Parent, nil) end)
    T("class.isa.VideoPlayer.VideoPlayer", function() return EQ(o:IsA("VideoPlayer"), true) end)
    T("class.isa.VideoPlayer.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.VideoPlayer", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.VideoSampler", function() return ERR(function() return Instance.new("VideoSampler") end, "Unable to create an Instance of type \"VideoSampler\"") end)
end
do
    local ok, o = pcall(Instance.new, "ViewportFrame")
    T("class.new.ViewportFrame", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ViewportFrame") end)
    T("class.name.ViewportFrame", function() return EQ(o.Name, "ViewportFrame") end)
    T("class.tostring.ViewportFrame", function() return EQ(tostring(o), "ViewportFrame") end)
    T("class.parent.ViewportFrame", function() return EQ(o.Parent, nil) end)
    T("class.isa.ViewportFrame.ViewportFrame", function() return EQ(o:IsA("ViewportFrame"), true) end)
    T("class.isa.ViewportFrame.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.ViewportFrame.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.ViewportFrame.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.ViewportFrame.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ViewportFrame", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.VirtualInput", function() return ERR(function() return Instance.new("VirtualInput") end, "Unable to create an Instance of type \"VirtualInput\"") end)
end
do
    T("class.notcreatable.VoxelBuffer", function() return ERR(function() return Instance.new("VoxelBuffer") end, "Unable to create an Instance of type \"VoxelBuffer\"") end)
end
do
    T("class.notcreatable.WebSocketClient", function() return ERR(function() return Instance.new("WebSocketClient") end, "Unable to create an Instance of type \"WebSocketClient\"") end)
end
do
    T("class.notcreatable.WebStreamClient", function() return ERR(function() return Instance.new("WebStreamClient") end, "Unable to create an Instance of type \"WebStreamClient\"") end)
end
do
    local ok, o = pcall(Instance.new, "WedgePart")
    T("class.new.WedgePart", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "WedgePart") end)
    T("class.name.WedgePart", function() return EQ(o.Name, "WedgePart") end)
    T("class.tostring.WedgePart", function() return EQ(tostring(o), "WedgePart") end)
    T("class.parent.WedgePart", function() return EQ(o.Parent, nil) end)
    T("class.isa.WedgePart.WedgePart", function() return EQ(o:IsA("WedgePart"), true) end)
    T("class.isa.WedgePart.FormFactorPart", function() return EQ(o:IsA("FormFactorPart"), true) end)
    T("class.isa.WedgePart.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.WedgePart.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.WedgePart.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.WedgePart", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Weld")
    T("class.new.Weld", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Weld") end)
    T("class.name.Weld", function() return EQ(o.Name, "Weld") end)
    T("class.tostring.Weld", function() return EQ(tostring(o), "Weld") end)
    T("class.parent.Weld", function() return EQ(o.Parent, nil) end)
    T("class.isa.Weld.Weld", function() return EQ(o:IsA("Weld"), true) end)
    T("class.isa.Weld.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.Weld.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Weld", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "WeldConstraint")
    T("class.new.WeldConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "WeldConstraint") end)
    T("class.name.WeldConstraint", function() return EQ(o.Name, "WeldConstraint") end)
    T("class.tostring.WeldConstraint", function() return EQ(tostring(o), "WeldConstraint") end)
    T("class.parent.WeldConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.WeldConstraint.WeldConstraint", function() return EQ(o:IsA("WeldConstraint"), true) end)
    T("class.isa.WeldConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.WeldConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Wire")
    T("class.new.Wire", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Wire") end)
    T("class.name.Wire", function() return EQ(o.Name, "Wire") end)
    T("class.tostring.Wire", function() return EQ(tostring(o), "Wire") end)
    T("class.parent.Wire", function() return EQ(o.Parent, nil) end)
    T("class.isa.Wire.Wire", function() return EQ(o:IsA("Wire"), true) end)
    T("class.isa.Wire.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Wire", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "WireframeHandleAdornment")
    T("class.new.WireframeHandleAdornment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "WireframeHandleAdornment") end)
    T("class.name.WireframeHandleAdornment", function() return EQ(o.Name, "WireframeHandleAdornment") end)
    T("class.tostring.WireframeHandleAdornment", function() return EQ(tostring(o), "WireframeHandleAdornment") end)
    T("class.parent.WireframeHandleAdornment", function() return EQ(o.Parent, nil) end)
    T("class.isa.WireframeHandleAdornment.WireframeHandleAdornment", function() return EQ(o:IsA("WireframeHandleAdornment"), true) end)
    T("class.isa.WireframeHandleAdornment.HandleAdornment", function() return EQ(o:IsA("HandleAdornment"), true) end)
    T("class.isa.WireframeHandleAdornment.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.WireframeHandleAdornment.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.WireframeHandleAdornment.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.WireframeHandleAdornment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.WireframeHandleAdornment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "WorldModel")
    T("class.new.WorldModel", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "WorldModel") end)
    T("class.name.WorldModel", function() return EQ(o.Name, "WorldModel") end)
    T("class.tostring.WorldModel", function() return EQ(tostring(o), "WorldModel") end)
    T("class.parent.WorldModel", function() return EQ(o.Parent, nil) end)
    T("class.isa.WorldModel.WorldModel", function() return EQ(o:IsA("WorldModel"), true) end)
    T("class.isa.WorldModel.WorldRoot", function() return EQ(o:IsA("WorldRoot"), true) end)
    T("class.isa.WorldModel.Model", function() return EQ(o:IsA("Model"), true) end)
    T("class.isa.WorldModel.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.WorldModel.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.WorldModel", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.WorldRoot", function() return ERR(function() return Instance.new("WorldRoot") end, "Unable to create an Instance of type \"WorldRoot\"") end)
end
do
    local ok, o = pcall(Instance.new, "WrapDeformer")
    T("class.new.WrapDeformer", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "WrapDeformer") end)
    T("class.name.WrapDeformer", function() return EQ(o.Name, "WrapDeformer") end)
    T("class.tostring.WrapDeformer", function() return EQ(tostring(o), "WrapDeformer") end)
    T("class.parent.WrapDeformer", function() return EQ(o.Parent, nil) end)
    T("class.isa.WrapDeformer.WrapDeformer", function() return EQ(o:IsA("WrapDeformer"), true) end)
    T("class.isa.WrapDeformer.BaseWrap", function() return EQ(o:IsA("BaseWrap"), true) end)
    T("class.isa.WrapDeformer.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.WrapDeformer", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "WrapLayer")
    T("class.new.WrapLayer", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "WrapLayer") end)
    T("class.name.WrapLayer", function() return EQ(o.Name, "WrapLayer") end)
    T("class.tostring.WrapLayer", function() return EQ(tostring(o), "WrapLayer") end)
    T("class.parent.WrapLayer", function() return EQ(o.Parent, nil) end)
    T("class.isa.WrapLayer.WrapLayer", function() return EQ(o:IsA("WrapLayer"), true) end)
    T("class.isa.WrapLayer.BaseWrap", function() return EQ(o:IsA("BaseWrap"), true) end)
    T("class.isa.WrapLayer.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.WrapLayer", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "WrapTarget")
    T("class.new.WrapTarget", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "WrapTarget") end)
    T("class.name.WrapTarget", function() return EQ(o.Name, "WrapTarget") end)
    T("class.tostring.WrapTarget", function() return EQ(tostring(o), "WrapTarget") end)
    T("class.parent.WrapTarget", function() return EQ(o.Parent, nil) end)
    T("class.isa.WrapTarget.WrapTarget", function() return EQ(o:IsA("WrapTarget"), true) end)
    T("class.isa.WrapTarget.BaseWrap", function() return EQ(o:IsA("BaseWrap"), true) end)
    T("class.isa.WrapTarget.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.WrapTarget", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.bogus.Partt", function() return ERR(function() return Instance.new("Partt") end, "Unable to create an Instance of type \"Partt\"") end)
    T("class.bogus.NotAClass", function() return ERR(function() return Instance.new("NotAClass") end, "Unable to create an Instance of type \"NotAClass\"") end)
    T("class.bogus.instance", function() return ERR(function() return Instance.new("instance") end, "Unable to create an Instance of type \"instance\"") end)
    T("class.bogus.part", function() return ERR(function() return Instance.new("part") end, "Unable to create an Instance of type \"part\"") end)
    T("class.bogus.Players2", function() return ERR(function() return Instance.new("Players2") end, "Unable to create an Instance of type \"Players2\"") end)
    T("class.bogus.LuaSourceContainerX", function() return ERR(function() return Instance.new("LuaSourceContainerX") end, "Unable to create an Instance of type \"LuaSourceContainerX\"") end)
    T("class.bogus.empty", function() return ERR(function() return Instance.new("") end, "Unable to create an Instance of type \"\"") end)
    T("class.bogus.Vector3", function() return ERR(function() return Instance.new("Vector3") end, "Unable to create an Instance of type \"Vector3\"") end)
    T("class.bogus.Enum", function() return ERR(function() return Instance.new("Enum") end, "Unable to create an Instance of type \"Enum\"") end)
end
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
