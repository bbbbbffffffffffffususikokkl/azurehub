-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "api_classes_01"
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
    local ok, o = pcall(Instance.new, "Accessory")
    T("class.new.Accessory", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Accessory") end)
    T("class.name.Accessory", function() return EQ(o.Name, "Accessory") end)
    T("class.tostring.Accessory", function() return EQ(tostring(o), "Accessory") end)
    T("class.parent.Accessory", function() return EQ(o.Parent, nil) end)
    T("class.isa.Accessory.Accessory", function() return EQ(o:IsA("Accessory"), true) end)
    T("class.isa.Accessory.Accoutrement", function() return EQ(o:IsA("Accoutrement"), true) end)
    T("class.isa.Accessory.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Accessory", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AccessoryDescription")
    T("class.new.AccessoryDescription", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AccessoryDescription") end)
    T("class.name.AccessoryDescription", function() return EQ(o.Name, "AccessoryDescription") end)
    T("class.tostring.AccessoryDescription", function() return EQ(tostring(o), "AccessoryDescription") end)
    T("class.parent.AccessoryDescription", function() return EQ(o.Parent, nil) end)
    T("class.isa.AccessoryDescription.AccessoryDescription", function() return EQ(o:IsA("AccessoryDescription"), true) end)
    T("class.isa.AccessoryDescription.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AccessoryDescription", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Accoutrement")
    T("class.new.Accoutrement", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Accoutrement") end)
    T("class.name.Accoutrement", function() return EQ(o.Name, "Accoutrement") end)
    T("class.tostring.Accoutrement", function() return EQ(tostring(o), "Accoutrement") end)
    T("class.parent.Accoutrement", function() return EQ(o.Parent, nil) end)
    T("class.isa.Accoutrement.Accoutrement", function() return EQ(o:IsA("Accoutrement"), true) end)
    T("class.isa.Accoutrement.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Accoutrement", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Actor")
    T("class.new.Actor", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Actor") end)
    T("class.name.Actor", function() return EQ(o.Name, "Actor") end)
    T("class.tostring.Actor", function() return EQ(tostring(o), "Actor") end)
    T("class.parent.Actor", function() return EQ(o.Parent, nil) end)
    T("class.isa.Actor.Actor", function() return EQ(o:IsA("Actor"), true) end)
    T("class.isa.Actor.Model", function() return EQ(o:IsA("Model"), true) end)
    T("class.isa.Actor.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.Actor.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Actor", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AdGui")
    T("class.new.AdGui", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AdGui") end)
    T("class.name.AdGui", function() return EQ(o.Name, "AdGui") end)
    T("class.tostring.AdGui", function() return EQ(tostring(o), "AdGui") end)
    T("class.parent.AdGui", function() return EQ(o.Parent, nil) end)
    T("class.isa.AdGui.AdGui", function() return EQ(o:IsA("AdGui"), true) end)
    T("class.isa.AdGui.SurfaceGuiBase", function() return EQ(o:IsA("SurfaceGuiBase"), true) end)
    T("class.isa.AdGui.LayerCollector", function() return EQ(o:IsA("LayerCollector"), true) end)
    T("class.isa.AdGui.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.AdGui.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.AdGui.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AdGui", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AdPlacement")
    T("class.new.AdPlacement", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AdPlacement") end)
    T("class.name.AdPlacement", function() return EQ(o.Name, "AdPlacement") end)
    T("class.tostring.AdPlacement", function() return EQ(tostring(o), "AdPlacement") end)
    T("class.parent.AdPlacement", function() return EQ(o.Parent, nil) end)
    T("class.isa.AdPlacement.AdPlacement", function() return EQ(o:IsA("AdPlacement"), true) end)
    T("class.isa.AdPlacement.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AdPlacement", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AdPortal")
    T("class.new.AdPortal", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AdPortal") end)
    T("class.name.AdPortal", function() return EQ(o.Name, "AdPortal") end)
    T("class.tostring.AdPortal", function() return EQ(tostring(o), "AdPortal") end)
    T("class.parent.AdPortal", function() return EQ(o.Parent, nil) end)
    T("class.isa.AdPortal.AdPortal", function() return EQ(o:IsA("AdPortal"), true) end)
    T("class.isa.AdPortal.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AdPortal", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AirController")
    T("class.new.AirController", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AirController") end)
    T("class.name.AirController", function() return EQ(o.Name, "AirController") end)
    T("class.tostring.AirController", function() return EQ(tostring(o), "AirController") end)
    T("class.parent.AirController", function() return EQ(o.Parent, nil) end)
    T("class.isa.AirController.AirController", function() return EQ(o:IsA("AirController"), true) end)
    T("class.isa.AirController.ControllerBase", function() return EQ(o:IsA("ControllerBase"), true) end)
    T("class.isa.AirController.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AirController", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AlignOrientation")
    T("class.new.AlignOrientation", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AlignOrientation") end)
    T("class.name.AlignOrientation", function() return EQ(o.Name, "AlignOrientation") end)
    T("class.tostring.AlignOrientation", function() return EQ(tostring(o), "AlignOrientation") end)
    T("class.parent.AlignOrientation", function() return EQ(o.Parent, nil) end)
    T("class.isa.AlignOrientation.AlignOrientation", function() return EQ(o:IsA("AlignOrientation"), true) end)
    T("class.isa.AlignOrientation.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.AlignOrientation.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AlignOrientation", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AlignPosition")
    T("class.new.AlignPosition", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AlignPosition") end)
    T("class.name.AlignPosition", function() return EQ(o.Name, "AlignPosition") end)
    T("class.tostring.AlignPosition", function() return EQ(tostring(o), "AlignPosition") end)
    T("class.parent.AlignPosition", function() return EQ(o.Parent, nil) end)
    T("class.isa.AlignPosition.AlignPosition", function() return EQ(o:IsA("AlignPosition"), true) end)
    T("class.isa.AlignPosition.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.AlignPosition.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AlignPosition", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AngularVelocity")
    T("class.new.AngularVelocity", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AngularVelocity") end)
    T("class.name.AngularVelocity", function() return EQ(o.Name, "AngularVelocity") end)
    T("class.tostring.AngularVelocity", function() return EQ(tostring(o), "AngularVelocity") end)
    T("class.parent.AngularVelocity", function() return EQ(o.Parent, nil) end)
    T("class.isa.AngularVelocity.AngularVelocity", function() return EQ(o:IsA("AngularVelocity"), true) end)
    T("class.isa.AngularVelocity.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.AngularVelocity.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AngularVelocity", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Animation")
    T("class.new.Animation", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Animation") end)
    T("class.name.Animation", function() return EQ(o.Name, "Animation") end)
    T("class.tostring.Animation", function() return EQ(tostring(o), "Animation") end)
    T("class.parent.Animation", function() return EQ(o.Parent, nil) end)
    T("class.isa.Animation.Animation", function() return EQ(o:IsA("Animation"), true) end)
    T("class.isa.Animation.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Animation", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.AnimationClip", function() return ERR(function() return Instance.new("AnimationClip") end, "Unable to create an Instance of type \"AnimationClip\"") end)
end
do
    local ok, o = pcall(Instance.new, "AnimationConstraint")
    T("class.new.AnimationConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AnimationConstraint") end)
    T("class.name.AnimationConstraint", function() return EQ(o.Name, "AnimationConstraint") end)
    T("class.tostring.AnimationConstraint", function() return EQ(tostring(o), "AnimationConstraint") end)
    T("class.parent.AnimationConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.AnimationConstraint.AnimationConstraint", function() return EQ(o:IsA("AnimationConstraint"), true) end)
    T("class.isa.AnimationConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.AnimationConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AnimationConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AnimationController")
    T("class.new.AnimationController", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AnimationController") end)
    T("class.name.AnimationController", function() return EQ(o.Name, "AnimationController") end)
    T("class.tostring.AnimationController", function() return EQ(tostring(o), "AnimationController") end)
    T("class.parent.AnimationController", function() return EQ(o.Parent, nil) end)
    T("class.isa.AnimationController.AnimationController", function() return EQ(o:IsA("AnimationController"), true) end)
    T("class.isa.AnimationController.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AnimationController", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.AnimationImportData", function() return ERR(function() return Instance.new("AnimationImportData") end, "Unable to create an Instance of type \"AnimationImportData\"") end)
end
do
    T("class.notcreatable.AnimationNode", function() return ERR(function() return Instance.new("AnimationNode") end, "Unable to create an Instance of type \"AnimationNode\"") end)
end
do
    local ok, o = pcall(Instance.new, "AnimationPlayer")
    T("class.new.AnimationPlayer", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AnimationPlayer") end)
    T("class.name.AnimationPlayer", function() return EQ(o.Name, "AnimationPlayer") end)
    T("class.tostring.AnimationPlayer", function() return EQ(tostring(o), "AnimationPlayer") end)
    T("class.parent.AnimationPlayer", function() return EQ(o.Parent, nil) end)
    T("class.isa.AnimationPlayer.AnimationPlayer", function() return EQ(o:IsA("AnimationPlayer"), true) end)
    T("class.isa.AnimationPlayer.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AnimationPlayer", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.AnimationStreamTrack", function() return ERR(function() return Instance.new("AnimationStreamTrack") end, "Unable to create an Instance of type \"AnimationStreamTrack\"") end)
end
do
    T("class.notcreatable.AnimationTrack", function() return ERR(function() return Instance.new("AnimationTrack") end, "Unable to create an Instance of type \"AnimationTrack\"") end)
end
do
    local ok, o = pcall(Instance.new, "Animator")
    T("class.new.Animator", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Animator") end)
    T("class.name.Animator", function() return EQ(o.Name, "Animator") end)
    T("class.tostring.Animator", function() return EQ(tostring(o), "Animator") end)
    T("class.parent.Animator", function() return EQ(o.Parent, nil) end)
    T("class.isa.Animator.Animator", function() return EQ(o:IsA("Animator"), true) end)
    T("class.isa.Animator.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Animator", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.AppHandle", function() return ERR(function() return Instance.new("AppHandle") end, "Unable to create an Instance of type \"AppHandle\"") end)
end
do
    local ok, o = pcall(Instance.new, "ArcHandles")
    T("class.new.ArcHandles", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ArcHandles") end)
    T("class.name.ArcHandles", function() return EQ(o.Name, "ArcHandles") end)
    T("class.tostring.ArcHandles", function() return EQ(tostring(o), "ArcHandles") end)
    T("class.parent.ArcHandles", function() return EQ(o.Parent, nil) end)
    T("class.isa.ArcHandles.ArcHandles", function() return EQ(o:IsA("ArcHandles"), true) end)
    T("class.isa.ArcHandles.HandlesBase", function() return EQ(o:IsA("HandlesBase"), true) end)
    T("class.isa.ArcHandles.PartAdornment", function() return EQ(o:IsA("PartAdornment"), true) end)
    T("class.isa.ArcHandles.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.ArcHandles.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.ArcHandles.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ArcHandles", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.AssetImportSession", function() return ERR(function() return Instance.new("AssetImportSession") end, "Unable to create an Instance of type \"AssetImportSession\"") end)
end
do
    T("class.notcreatable.AssetPatchSettings", function() return ERR(function() return Instance.new("AssetPatchSettings") end, "Unable to create an Instance of type \"AssetPatchSettings\"") end)
end
do
    T("class.notcreatable.AssetSoundEffect", function() return ERR(function() return Instance.new("AssetSoundEffect") end, "Unable to create an Instance of type \"AssetSoundEffect\"") end)
end
do
    local ok, o = pcall(Instance.new, "Atmosphere")
    T("class.new.Atmosphere", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Atmosphere") end)
    T("class.name.Atmosphere", function() return EQ(o.Name, "Atmosphere") end)
    T("class.tostring.Atmosphere", function() return EQ(tostring(o), "Atmosphere") end)
    T("class.parent.Atmosphere", function() return EQ(o.Parent, nil) end)
    T("class.isa.Atmosphere.Atmosphere", function() return EQ(o:IsA("Atmosphere"), true) end)
    T("class.isa.Atmosphere.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Atmosphere", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AtmosphereSensor")
    T("class.new.AtmosphereSensor", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AtmosphereSensor") end)
    T("class.name.AtmosphereSensor", function() return EQ(o.Name, "AtmosphereSensor") end)
    T("class.tostring.AtmosphereSensor", function() return EQ(tostring(o), "AtmosphereSensor") end)
    T("class.parent.AtmosphereSensor", function() return EQ(o.Parent, nil) end)
    T("class.isa.AtmosphereSensor.AtmosphereSensor", function() return EQ(o:IsA("AtmosphereSensor"), true) end)
    T("class.isa.AtmosphereSensor.SensorBase", function() return EQ(o:IsA("SensorBase"), true) end)
    T("class.isa.AtmosphereSensor.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AtmosphereSensor", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Attachment")
    T("class.new.Attachment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Attachment") end)
    T("class.name.Attachment", function() return EQ(o.Name, "Attachment") end)
    T("class.tostring.Attachment", function() return EQ(tostring(o), "Attachment") end)
    T("class.parent.Attachment", function() return EQ(o.Parent, nil) end)
    T("class.isa.Attachment.Attachment", function() return EQ(o:IsA("Attachment"), true) end)
    T("class.isa.Attachment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Attachment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioAnalyzer")
    T("class.new.AudioAnalyzer", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioAnalyzer") end)
    T("class.name.AudioAnalyzer", function() return EQ(o.Name, "AudioAnalyzer") end)
    T("class.tostring.AudioAnalyzer", function() return EQ(tostring(o), "AudioAnalyzer") end)
    T("class.parent.AudioAnalyzer", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioAnalyzer.AudioAnalyzer", function() return EQ(o:IsA("AudioAnalyzer"), true) end)
    T("class.isa.AudioAnalyzer.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioAnalyzer", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioChannelMixer")
    T("class.new.AudioChannelMixer", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioChannelMixer") end)
    T("class.name.AudioChannelMixer", function() return EQ(o.Name, "AudioChannelMixer") end)
    T("class.tostring.AudioChannelMixer", function() return EQ(tostring(o), "AudioChannelMixer") end)
    T("class.parent.AudioChannelMixer", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioChannelMixer.AudioChannelMixer", function() return EQ(o:IsA("AudioChannelMixer"), true) end)
    T("class.isa.AudioChannelMixer.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioChannelMixer", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioChannelSplitter")
    T("class.new.AudioChannelSplitter", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioChannelSplitter") end)
    T("class.name.AudioChannelSplitter", function() return EQ(o.Name, "AudioChannelSplitter") end)
    T("class.tostring.AudioChannelSplitter", function() return EQ(tostring(o), "AudioChannelSplitter") end)
    T("class.parent.AudioChannelSplitter", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioChannelSplitter.AudioChannelSplitter", function() return EQ(o:IsA("AudioChannelSplitter"), true) end)
    T("class.isa.AudioChannelSplitter.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioChannelSplitter", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioChorus")
    T("class.new.AudioChorus", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioChorus") end)
    T("class.name.AudioChorus", function() return EQ(o.Name, "AudioChorus") end)
    T("class.tostring.AudioChorus", function() return EQ(tostring(o), "AudioChorus") end)
    T("class.parent.AudioChorus", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioChorus.AudioChorus", function() return EQ(o:IsA("AudioChorus"), true) end)
    T("class.isa.AudioChorus.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioChorus", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioCompressor")
    T("class.new.AudioCompressor", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioCompressor") end)
    T("class.name.AudioCompressor", function() return EQ(o.Name, "AudioCompressor") end)
    T("class.tostring.AudioCompressor", function() return EQ(tostring(o), "AudioCompressor") end)
    T("class.parent.AudioCompressor", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioCompressor.AudioCompressor", function() return EQ(o:IsA("AudioCompressor"), true) end)
    T("class.isa.AudioCompressor.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioCompressor", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioDeviceInput")
    T("class.new.AudioDeviceInput", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioDeviceInput") end)
    T("class.name.AudioDeviceInput", function() return EQ(o.Name, "AudioDeviceInput") end)
    T("class.tostring.AudioDeviceInput", function() return EQ(tostring(o), "AudioDeviceInput") end)
    T("class.parent.AudioDeviceInput", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioDeviceInput.AudioDeviceInput", function() return EQ(o:IsA("AudioDeviceInput"), true) end)
    T("class.isa.AudioDeviceInput.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioDeviceInput", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioDeviceOutput")
    T("class.new.AudioDeviceOutput", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioDeviceOutput") end)
    T("class.name.AudioDeviceOutput", function() return EQ(o.Name, "AudioDeviceOutput") end)
    T("class.tostring.AudioDeviceOutput", function() return EQ(tostring(o), "AudioDeviceOutput") end)
    T("class.parent.AudioDeviceOutput", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioDeviceOutput.AudioDeviceOutput", function() return EQ(o:IsA("AudioDeviceOutput"), true) end)
    T("class.isa.AudioDeviceOutput.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioDeviceOutput", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioDistortion")
    T("class.new.AudioDistortion", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioDistortion") end)
    T("class.name.AudioDistortion", function() return EQ(o.Name, "AudioDistortion") end)
    T("class.tostring.AudioDistortion", function() return EQ(tostring(o), "AudioDistortion") end)
    T("class.parent.AudioDistortion", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioDistortion.AudioDistortion", function() return EQ(o:IsA("AudioDistortion"), true) end)
    T("class.isa.AudioDistortion.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioDistortion", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioEcho")
    T("class.new.AudioEcho", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioEcho") end)
    T("class.name.AudioEcho", function() return EQ(o.Name, "AudioEcho") end)
    T("class.tostring.AudioEcho", function() return EQ(tostring(o), "AudioEcho") end)
    T("class.parent.AudioEcho", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioEcho.AudioEcho", function() return EQ(o:IsA("AudioEcho"), true) end)
    T("class.isa.AudioEcho.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioEcho", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioEmitter")
    T("class.new.AudioEmitter", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioEmitter") end)
    T("class.name.AudioEmitter", function() return EQ(o.Name, "AudioEmitter") end)
    T("class.tostring.AudioEmitter", function() return EQ(tostring(o), "AudioEmitter") end)
    T("class.parent.AudioEmitter", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioEmitter.AudioEmitter", function() return EQ(o:IsA("AudioEmitter"), true) end)
    T("class.isa.AudioEmitter.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioEmitter", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioEqualizer")
    T("class.new.AudioEqualizer", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioEqualizer") end)
    T("class.name.AudioEqualizer", function() return EQ(o.Name, "AudioEqualizer") end)
    T("class.tostring.AudioEqualizer", function() return EQ(tostring(o), "AudioEqualizer") end)
    T("class.parent.AudioEqualizer", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioEqualizer.AudioEqualizer", function() return EQ(o:IsA("AudioEqualizer"), true) end)
    T("class.isa.AudioEqualizer.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioEqualizer", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioFader")
    T("class.new.AudioFader", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioFader") end)
    T("class.name.AudioFader", function() return EQ(o.Name, "AudioFader") end)
    T("class.tostring.AudioFader", function() return EQ(tostring(o), "AudioFader") end)
    T("class.parent.AudioFader", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioFader.AudioFader", function() return EQ(o:IsA("AudioFader"), true) end)
    T("class.isa.AudioFader.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioFader", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioFilter")
    T("class.new.AudioFilter", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioFilter") end)
    T("class.name.AudioFilter", function() return EQ(o.Name, "AudioFilter") end)
    T("class.tostring.AudioFilter", function() return EQ(tostring(o), "AudioFilter") end)
    T("class.parent.AudioFilter", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioFilter.AudioFilter", function() return EQ(o:IsA("AudioFilter"), true) end)
    T("class.isa.AudioFilter.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioFilter", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioFlanger")
    T("class.new.AudioFlanger", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioFlanger") end)
    T("class.name.AudioFlanger", function() return EQ(o.Name, "AudioFlanger") end)
    T("class.tostring.AudioFlanger", function() return EQ(tostring(o), "AudioFlanger") end)
    T("class.parent.AudioFlanger", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioFlanger.AudioFlanger", function() return EQ(o:IsA("AudioFlanger"), true) end)
    T("class.isa.AudioFlanger.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioFlanger", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioGate")
    T("class.new.AudioGate", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioGate") end)
    T("class.name.AudioGate", function() return EQ(o.Name, "AudioGate") end)
    T("class.tostring.AudioGate", function() return EQ(tostring(o), "AudioGate") end)
    T("class.parent.AudioGate", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioGate.AudioGate", function() return EQ(o:IsA("AudioGate"), true) end)
    T("class.isa.AudioGate.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioGate", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioLimiter")
    T("class.new.AudioLimiter", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioLimiter") end)
    T("class.name.AudioLimiter", function() return EQ(o.Name, "AudioLimiter") end)
    T("class.tostring.AudioLimiter", function() return EQ(tostring(o), "AudioLimiter") end)
    T("class.parent.AudioLimiter", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioLimiter.AudioLimiter", function() return EQ(o:IsA("AudioLimiter"), true) end)
    T("class.isa.AudioLimiter.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioLimiter", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioListener")
    T("class.new.AudioListener", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioListener") end)
    T("class.name.AudioListener", function() return EQ(o.Name, "AudioListener") end)
    T("class.tostring.AudioListener", function() return EQ(tostring(o), "AudioListener") end)
    T("class.parent.AudioListener", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioListener.AudioListener", function() return EQ(o:IsA("AudioListener"), true) end)
    T("class.isa.AudioListener.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioListener", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.AudioPages", function() return ERR(function() return Instance.new("AudioPages") end, "Unable to create an Instance of type \"AudioPages\"") end)
end
do
    local ok, o = pcall(Instance.new, "AudioPitchShifter")
    T("class.new.AudioPitchShifter", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioPitchShifter") end)
    T("class.name.AudioPitchShifter", function() return EQ(o.Name, "AudioPitchShifter") end)
    T("class.tostring.AudioPitchShifter", function() return EQ(tostring(o), "AudioPitchShifter") end)
    T("class.parent.AudioPitchShifter", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioPitchShifter.AudioPitchShifter", function() return EQ(o:IsA("AudioPitchShifter"), true) end)
    T("class.isa.AudioPitchShifter.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioPitchShifter", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioPlayer")
    T("class.new.AudioPlayer", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioPlayer") end)
    T("class.name.AudioPlayer", function() return EQ(o.Name, "AudioPlayer") end)
    T("class.tostring.AudioPlayer", function() return EQ(tostring(o), "AudioPlayer") end)
    T("class.parent.AudioPlayer", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioPlayer.AudioPlayer", function() return EQ(o:IsA("AudioPlayer"), true) end)
    T("class.isa.AudioPlayer.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioPlayer", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioReverb")
    T("class.new.AudioReverb", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioReverb") end)
    T("class.name.AudioReverb", function() return EQ(o.Name, "AudioReverb") end)
    T("class.tostring.AudioReverb", function() return EQ(tostring(o), "AudioReverb") end)
    T("class.parent.AudioReverb", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioReverb.AudioReverb", function() return EQ(o:IsA("AudioReverb"), true) end)
    T("class.isa.AudioReverb.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioReverb", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "AudioTremolo")
    T("class.new.AudioTremolo", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "AudioTremolo") end)
    T("class.name.AudioTremolo", function() return EQ(o.Name, "AudioTremolo") end)
    T("class.tostring.AudioTremolo", function() return EQ(tostring(o), "AudioTremolo") end)
    T("class.parent.AudioTremolo", function() return EQ(o.Parent, nil) end)
    T("class.isa.AudioTremolo.AudioTremolo", function() return EQ(o:IsA("AudioTremolo"), true) end)
    T("class.isa.AudioTremolo.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.AudioTremolo", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.AuroraScriptObject", function() return ERR(function() return Instance.new("AuroraScriptObject") end, "Unable to create an Instance of type \"AuroraScriptObject\"") end)
end
do
    local ok, o = pcall(Instance.new, "Backpack")
    T("class.new.Backpack", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Backpack") end)
    T("class.name.Backpack", function() return EQ(o.Name, "Backpack") end)
    T("class.tostring.Backpack", function() return EQ(tostring(o), "Backpack") end)
    T("class.parent.Backpack", function() return EQ(o.Parent, nil) end)
    T("class.isa.Backpack.Backpack", function() return EQ(o:IsA("Backpack"), true) end)
    T("class.isa.Backpack.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Backpack", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.BackpackItem", function() return ERR(function() return Instance.new("BackpackItem") end, "Unable to create an Instance of type \"BackpackItem\"") end)
end
do
    local ok, o = pcall(Instance.new, "BallSocketConstraint")
    T("class.new.BallSocketConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BallSocketConstraint") end)
    T("class.name.BallSocketConstraint", function() return EQ(o.Name, "BallSocketConstraint") end)
    T("class.tostring.BallSocketConstraint", function() return EQ(tostring(o), "BallSocketConstraint") end)
    T("class.parent.BallSocketConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.BallSocketConstraint.BallSocketConstraint", function() return EQ(o:IsA("BallSocketConstraint"), true) end)
    T("class.isa.BallSocketConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.BallSocketConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BallSocketConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.BanHistoryPages", function() return ERR(function() return Instance.new("BanHistoryPages") end, "Unable to create an Instance of type \"BanHistoryPages\"") end)
end
do
    T("class.notcreatable.BaseCoreGuiConfiguration", function() return ERR(function() return Instance.new("BaseCoreGuiConfiguration") end, "Unable to create an Instance of type \"BaseCoreGuiConfiguration\"") end)
end
do
    T("class.notcreatable.BaseImportData", function() return ERR(function() return Instance.new("BaseImportData") end, "Unable to create an Instance of type \"BaseImportData\"") end)
end
do
    T("class.notcreatable.BasePart", function() return ERR(function() return Instance.new("BasePart") end, "Unable to create an Instance of type \"BasePart\"") end)
end
do
    T("class.notcreatable.BasePlayerGui", function() return ERR(function() return Instance.new("BasePlayerGui") end, "Unable to create an Instance of type \"BasePlayerGui\"") end)
end
do
    T("class.notcreatable.BaseRemoteEvent", function() return ERR(function() return Instance.new("BaseRemoteEvent") end, "Unable to create an Instance of type \"BaseRemoteEvent\"") end)
end
do
    T("class.notcreatable.BaseScript", function() return ERR(function() return Instance.new("BaseScript") end, "Unable to create an Instance of type \"BaseScript\"") end)
end
do
    T("class.notcreatable.BaseWrap", function() return ERR(function() return Instance.new("BaseWrap") end, "Unable to create an Instance of type \"BaseWrap\"") end)
end
do
    local ok, o = pcall(Instance.new, "Beam")
    T("class.new.Beam", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Beam") end)
    T("class.name.Beam", function() return EQ(o.Name, "Beam") end)
    T("class.tostring.Beam", function() return EQ(tostring(o), "Beam") end)
    T("class.parent.Beam", function() return EQ(o.Parent, nil) end)
    T("class.isa.Beam.Beam", function() return EQ(o:IsA("Beam"), true) end)
    T("class.isa.Beam.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Beam", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.BevelMesh", function() return ERR(function() return Instance.new("BevelMesh") end, "Unable to create an Instance of type \"BevelMesh\"") end)
end
do
    local ok, o = pcall(Instance.new, "BillboardGui")
    T("class.new.BillboardGui", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BillboardGui") end)
    T("class.name.BillboardGui", function() return EQ(o.Name, "BillboardGui") end)
    T("class.tostring.BillboardGui", function() return EQ(tostring(o), "BillboardGui") end)
    T("class.parent.BillboardGui", function() return EQ(o.Parent, nil) end)
    T("class.isa.BillboardGui.BillboardGui", function() return EQ(o:IsA("BillboardGui"), true) end)
    T("class.isa.BillboardGui.LayerCollector", function() return EQ(o:IsA("LayerCollector"), true) end)
    T("class.isa.BillboardGui.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.BillboardGui.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.BillboardGui.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BillboardGui", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BinaryStringValue")
    T("class.new.BinaryStringValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BinaryStringValue") end)
    T("class.name.BinaryStringValue", function() return EQ(o.Name, "BinaryStringValue") end)
    T("class.tostring.BinaryStringValue", function() return EQ(tostring(o), "BinaryStringValue") end)
    T("class.parent.BinaryStringValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.BinaryStringValue.BinaryStringValue", function() return EQ(o:IsA("BinaryStringValue"), true) end)
    T("class.isa.BinaryStringValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.BinaryStringValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BinaryStringValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    local ok, o = pcall(Instance.new, "BindableEvent")
    T("class.new.BindableEvent", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BindableEvent") end)
    T("class.name.BindableEvent", function() return EQ(o.Name, "BindableEvent") end)
    T("class.tostring.BindableEvent", function() return EQ(tostring(o), "BindableEvent") end)
    T("class.parent.BindableEvent", function() return EQ(o.Parent, nil) end)
    T("class.isa.BindableEvent.BindableEvent", function() return EQ(o:IsA("BindableEvent"), true) end)
    T("class.isa.BindableEvent.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BindableEvent", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BindableFunction")
    T("class.new.BindableFunction", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BindableFunction") end)
    T("class.name.BindableFunction", function() return EQ(o.Name, "BindableFunction") end)
    T("class.tostring.BindableFunction", function() return EQ(tostring(o), "BindableFunction") end)
    T("class.parent.BindableFunction", function() return EQ(o.Parent, nil) end)
    T("class.isa.BindableFunction.BindableFunction", function() return EQ(o:IsA("BindableFunction"), true) end)
    T("class.isa.BindableFunction.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BindableFunction", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BlockMesh")
    T("class.new.BlockMesh", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BlockMesh") end)
    T("class.name.BlockMesh", function() return EQ(o.Name, "BlockMesh") end)
    T("class.tostring.BlockMesh", function() return EQ(tostring(o), "BlockMesh") end)
    T("class.parent.BlockMesh", function() return EQ(o.Parent, nil) end)
    T("class.isa.BlockMesh.BlockMesh", function() return EQ(o:IsA("BlockMesh"), true) end)
    T("class.isa.BlockMesh.BevelMesh", function() return EQ(o:IsA("BevelMesh"), true) end)
    T("class.isa.BlockMesh.DataModelMesh", function() return EQ(o:IsA("DataModelMesh"), true) end)
    T("class.isa.BlockMesh.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BlockMesh", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BloomEffect")
    T("class.new.BloomEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BloomEffect") end)
    T("class.name.BloomEffect", function() return EQ(o.Name, "BloomEffect") end)
    T("class.tostring.BloomEffect", function() return EQ(tostring(o), "BloomEffect") end)
    T("class.parent.BloomEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.BloomEffect.BloomEffect", function() return EQ(o:IsA("BloomEffect"), true) end)
    T("class.isa.BloomEffect.PostEffect", function() return EQ(o:IsA("PostEffect"), true) end)
    T("class.isa.BloomEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BloomEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BlurEffect")
    T("class.new.BlurEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BlurEffect") end)
    T("class.name.BlurEffect", function() return EQ(o.Name, "BlurEffect") end)
    T("class.tostring.BlurEffect", function() return EQ(tostring(o), "BlurEffect") end)
    T("class.parent.BlurEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.BlurEffect.BlurEffect", function() return EQ(o:IsA("BlurEffect"), true) end)
    T("class.isa.BlurEffect.PostEffect", function() return EQ(o:IsA("PostEffect"), true) end)
    T("class.isa.BlurEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BlurEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BodyAngularVelocity")
    T("class.new.BodyAngularVelocity", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BodyAngularVelocity") end)
    T("class.name.BodyAngularVelocity", function() return EQ(o.Name, "BodyAngularVelocity") end)
    T("class.tostring.BodyAngularVelocity", function() return EQ(tostring(o), "BodyAngularVelocity") end)
    T("class.parent.BodyAngularVelocity", function() return EQ(o.Parent, nil) end)
    T("class.isa.BodyAngularVelocity.BodyAngularVelocity", function() return EQ(o:IsA("BodyAngularVelocity"), true) end)
    T("class.isa.BodyAngularVelocity.BodyMover", function() return EQ(o:IsA("BodyMover"), true) end)
    T("class.isa.BodyAngularVelocity.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BodyAngularVelocity", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BodyColors")
    T("class.new.BodyColors", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BodyColors") end)
    T("class.name.BodyColors", function() return EQ(o.Name, "BodyColors") end)
    T("class.tostring.BodyColors", function() return EQ(tostring(o), "BodyColors") end)
    T("class.parent.BodyColors", function() return EQ(o.Parent, nil) end)
    T("class.isa.BodyColors.BodyColors", function() return EQ(o:IsA("BodyColors"), true) end)
    T("class.isa.BodyColors.CharacterAppearance", function() return EQ(o:IsA("CharacterAppearance"), true) end)
    T("class.isa.BodyColors.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BodyColors", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BodyForce")
    T("class.new.BodyForce", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BodyForce") end)
    T("class.name.BodyForce", function() return EQ(o.Name, "BodyForce") end)
    T("class.tostring.BodyForce", function() return EQ(tostring(o), "BodyForce") end)
    T("class.parent.BodyForce", function() return EQ(o.Parent, nil) end)
    T("class.isa.BodyForce.BodyForce", function() return EQ(o:IsA("BodyForce"), true) end)
    T("class.isa.BodyForce.BodyMover", function() return EQ(o:IsA("BodyMover"), true) end)
    T("class.isa.BodyForce.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BodyForce", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BodyGyro")
    T("class.new.BodyGyro", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BodyGyro") end)
    T("class.name.BodyGyro", function() return EQ(o.Name, "BodyGyro") end)
    T("class.tostring.BodyGyro", function() return EQ(tostring(o), "BodyGyro") end)
    T("class.parent.BodyGyro", function() return EQ(o.Parent, nil) end)
    T("class.isa.BodyGyro.BodyGyro", function() return EQ(o:IsA("BodyGyro"), true) end)
    T("class.isa.BodyGyro.BodyMover", function() return EQ(o:IsA("BodyMover"), true) end)
    T("class.isa.BodyGyro.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BodyGyro", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.BodyMover", function() return ERR(function() return Instance.new("BodyMover") end, "Unable to create an Instance of type \"BodyMover\"") end)
end
do
    local ok, o = pcall(Instance.new, "BodyPartDescription")
    T("class.new.BodyPartDescription", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BodyPartDescription") end)
    T("class.name.BodyPartDescription", function() return EQ(o.Name, "BodyPartDescription") end)
    T("class.tostring.BodyPartDescription", function() return EQ(tostring(o), "BodyPartDescription") end)
    T("class.parent.BodyPartDescription", function() return EQ(o.Parent, nil) end)
    T("class.isa.BodyPartDescription.BodyPartDescription", function() return EQ(o:IsA("BodyPartDescription"), true) end)
    T("class.isa.BodyPartDescription.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BodyPartDescription", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BodyPosition")
    T("class.new.BodyPosition", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BodyPosition") end)
    T("class.name.BodyPosition", function() return EQ(o.Name, "BodyPosition") end)
    T("class.tostring.BodyPosition", function() return EQ(tostring(o), "BodyPosition") end)
    T("class.parent.BodyPosition", function() return EQ(o.Parent, nil) end)
    T("class.isa.BodyPosition.BodyPosition", function() return EQ(o:IsA("BodyPosition"), true) end)
    T("class.isa.BodyPosition.BodyMover", function() return EQ(o:IsA("BodyMover"), true) end)
    T("class.isa.BodyPosition.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BodyPosition", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BodyThrust")
    T("class.new.BodyThrust", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BodyThrust") end)
    T("class.name.BodyThrust", function() return EQ(o.Name, "BodyThrust") end)
    T("class.tostring.BodyThrust", function() return EQ(tostring(o), "BodyThrust") end)
    T("class.parent.BodyThrust", function() return EQ(o.Parent, nil) end)
    T("class.isa.BodyThrust.BodyThrust", function() return EQ(o:IsA("BodyThrust"), true) end)
    T("class.isa.BodyThrust.BodyMover", function() return EQ(o:IsA("BodyMover"), true) end)
    T("class.isa.BodyThrust.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BodyThrust", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BodyVelocity")
    T("class.new.BodyVelocity", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BodyVelocity") end)
    T("class.name.BodyVelocity", function() return EQ(o.Name, "BodyVelocity") end)
    T("class.tostring.BodyVelocity", function() return EQ(tostring(o), "BodyVelocity") end)
    T("class.parent.BodyVelocity", function() return EQ(o.Parent, nil) end)
    T("class.isa.BodyVelocity.BodyVelocity", function() return EQ(o:IsA("BodyVelocity"), true) end)
    T("class.isa.BodyVelocity.BodyMover", function() return EQ(o:IsA("BodyMover"), true) end)
    T("class.isa.BodyVelocity.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BodyVelocity", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Bone")
    T("class.new.Bone", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Bone") end)
    T("class.name.Bone", function() return EQ(o.Name, "Bone") end)
    T("class.tostring.Bone", function() return EQ(tostring(o), "Bone") end)
    T("class.parent.Bone", function() return EQ(o.Parent, nil) end)
    T("class.isa.Bone.Bone", function() return EQ(o:IsA("Bone"), true) end)
    T("class.isa.Bone.Attachment", function() return EQ(o:IsA("Attachment"), true) end)
    T("class.isa.Bone.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Bone", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BoolValue")
    T("class.new.BoolValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BoolValue") end)
    T("class.name.BoolValue", function() return EQ(o.Name, "BoolValue") end)
    T("class.tostring.BoolValue", function() return EQ(tostring(o), "BoolValue") end)
    T("class.parent.BoolValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.BoolValue.BoolValue", function() return EQ(o:IsA("BoolValue"), true) end)
    T("class.isa.BoolValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.BoolValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BoolValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    local ok, o = pcall(Instance.new, "BoxHandleAdornment")
    T("class.new.BoxHandleAdornment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BoxHandleAdornment") end)
    T("class.name.BoxHandleAdornment", function() return EQ(o.Name, "BoxHandleAdornment") end)
    T("class.tostring.BoxHandleAdornment", function() return EQ(tostring(o), "BoxHandleAdornment") end)
    T("class.parent.BoxHandleAdornment", function() return EQ(o.Parent, nil) end)
    T("class.isa.BoxHandleAdornment.BoxHandleAdornment", function() return EQ(o:IsA("BoxHandleAdornment"), true) end)
    T("class.isa.BoxHandleAdornment.HandleAdornment", function() return EQ(o:IsA("HandleAdornment"), true) end)
    T("class.isa.BoxHandleAdornment.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.BoxHandleAdornment.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.BoxHandleAdornment.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.BoxHandleAdornment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BoxHandleAdornment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BrickColorValue")
    T("class.new.BrickColorValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BrickColorValue") end)
    T("class.name.BrickColorValue", function() return EQ(o.Name, "BrickColorValue") end)
    T("class.tostring.BrickColorValue", function() return EQ(tostring(o), "BrickColorValue") end)
    T("class.parent.BrickColorValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.BrickColorValue.BrickColorValue", function() return EQ(o:IsA("BrickColorValue"), true) end)
    T("class.isa.BrickColorValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.BrickColorValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BrickColorValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    T("class.notcreatable.BubbleChatConfiguration", function() return ERR(function() return Instance.new("BubbleChatConfiguration") end, "Unable to create an Instance of type \"BubbleChatConfiguration\"") end)
end
do
    local ok, o = pcall(Instance.new, "BubbleChatMessageProperties")
    T("class.new.BubbleChatMessageProperties", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BubbleChatMessageProperties") end)
    T("class.name.BubbleChatMessageProperties", function() return EQ(o.Name, "BubbleChatMessageProperties") end)
    T("class.tostring.BubbleChatMessageProperties", function() return EQ(tostring(o), "BubbleChatMessageProperties") end)
    T("class.parent.BubbleChatMessageProperties", function() return EQ(o.Parent, nil) end)
    T("class.isa.BubbleChatMessageProperties.BubbleChatMessageProperties", function() return EQ(o:IsA("BubbleChatMessageProperties"), true) end)
    T("class.isa.BubbleChatMessageProperties.TextChatMessageProperties", function() return EQ(o:IsA("TextChatMessageProperties"), true) end)
    T("class.isa.BubbleChatMessageProperties.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BubbleChatMessageProperties", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "BuoyancySensor")
    T("class.new.BuoyancySensor", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "BuoyancySensor") end)
    T("class.name.BuoyancySensor", function() return EQ(o.Name, "BuoyancySensor") end)
    T("class.tostring.BuoyancySensor", function() return EQ(tostring(o), "BuoyancySensor") end)
    T("class.parent.BuoyancySensor", function() return EQ(o.Parent, nil) end)
    T("class.isa.BuoyancySensor.BuoyancySensor", function() return EQ(o:IsA("BuoyancySensor"), true) end)
    T("class.isa.BuoyancySensor.SensorBase", function() return EQ(o:IsA("SensorBase"), true) end)
    T("class.isa.BuoyancySensor.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.BuoyancySensor", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "CFrameValue")
    T("class.new.CFrameValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CFrameValue") end)
    T("class.name.CFrameValue", function() return EQ(o.Name, "CFrameValue") end)
    T("class.tostring.CFrameValue", function() return EQ(tostring(o), "CFrameValue") end)
    T("class.parent.CFrameValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.CFrameValue.CFrameValue", function() return EQ(o:IsA("CFrameValue"), true) end)
    T("class.isa.CFrameValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.CFrameValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CFrameValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    local ok, o = pcall(Instance.new, "Camera")
    T("class.new.Camera", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Camera") end)
    T("class.name.Camera", function() return EQ(o.Name, "Camera") end)
    T("class.tostring.Camera", function() return EQ(tostring(o), "Camera") end)
    T("class.parent.Camera", function() return EQ(o.Parent, nil) end)
    T("class.isa.Camera.Camera", function() return EQ(o:IsA("Camera"), true) end)
    T("class.isa.Camera.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.Camera.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Camera", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "CanvasGroup")
    T("class.new.CanvasGroup", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CanvasGroup") end)
    T("class.name.CanvasGroup", function() return EQ(o.Name, "CanvasGroup") end)
    T("class.tostring.CanvasGroup", function() return EQ(tostring(o), "CanvasGroup") end)
    T("class.parent.CanvasGroup", function() return EQ(o.Parent, nil) end)
    T("class.isa.CanvasGroup.CanvasGroup", function() return EQ(o:IsA("CanvasGroup"), true) end)
    T("class.isa.CanvasGroup.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.CanvasGroup.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.CanvasGroup.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.CanvasGroup.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CanvasGroup", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.Capture", function() return ERR(function() return Instance.new("Capture") end, "Unable to create an Instance of type \"Capture\"") end)
end
do
    T("class.notcreatable.CapturesPages", function() return ERR(function() return Instance.new("CapturesPages") end, "Unable to create an Instance of type \"CapturesPages\"") end)
end
do
    T("class.notcreatable.CapturesViewConfiguration", function() return ERR(function() return Instance.new("CapturesViewConfiguration") end, "Unable to create an Instance of type \"CapturesViewConfiguration\"") end)
end
do
    T("class.notcreatable.CatalogPages", function() return ERR(function() return Instance.new("CatalogPages") end, "Unable to create an Instance of type \"CatalogPages\"") end)
end
do
    T("class.notcreatable.ChannelSelectorSoundEffect", function() return ERR(function() return Instance.new("ChannelSelectorSoundEffect") end, "Unable to create an Instance of type \"ChannelSelectorSoundEffect\"") end)
end
do
    T("class.notcreatable.ChannelTabsConfiguration", function() return ERR(function() return Instance.new("ChannelTabsConfiguration") end, "Unable to create an Instance of type \"ChannelTabsConfiguration\"") end)
end
do
    T("class.notcreatable.CharacterAppearance", function() return ERR(function() return Instance.new("CharacterAppearance") end, "Unable to create an Instance of type \"CharacterAppearance\"") end)
end
do
    local ok, o = pcall(Instance.new, "CharacterMesh")
    T("class.new.CharacterMesh", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CharacterMesh") end)
    T("class.name.CharacterMesh", function() return EQ(o.Name, "CharacterMesh") end)
    T("class.tostring.CharacterMesh", function() return EQ(tostring(o), "CharacterMesh") end)
    T("class.parent.CharacterMesh", function() return EQ(o.Parent, nil) end)
    T("class.isa.CharacterMesh.CharacterMesh", function() return EQ(o:IsA("CharacterMesh"), true) end)
    T("class.isa.CharacterMesh.CharacterAppearance", function() return EQ(o:IsA("CharacterAppearance"), true) end)
    T("class.isa.CharacterMesh.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CharacterMesh", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ChatInputBarConfiguration", function() return ERR(function() return Instance.new("ChatInputBarConfiguration") end, "Unable to create an Instance of type \"ChatInputBarConfiguration\"") end)
end
do
    T("class.notcreatable.ChatWindowConfiguration", function() return ERR(function() return Instance.new("ChatWindowConfiguration") end, "Unable to create an Instance of type \"ChatWindowConfiguration\"") end)
end
do
    T("class.notcreatable.ChatWindowMessageProperties", function() return ERR(function() return Instance.new("ChatWindowMessageProperties") end, "Unable to create an Instance of type \"ChatWindowMessageProperties\"") end)
end
do
    local ok, o = pcall(Instance.new, "ChorusSoundEffect")
    T("class.new.ChorusSoundEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ChorusSoundEffect") end)
    T("class.name.ChorusSoundEffect", function() return EQ(o.Name, "ChorusSoundEffect") end)
    T("class.tostring.ChorusSoundEffect", function() return EQ(tostring(o), "ChorusSoundEffect") end)
    T("class.parent.ChorusSoundEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.ChorusSoundEffect.ChorusSoundEffect", function() return EQ(o:IsA("ChorusSoundEffect"), true) end)
    T("class.isa.ChorusSoundEffect.SoundEffect", function() return EQ(o:IsA("SoundEffect"), true) end)
    T("class.isa.ChorusSoundEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ChorusSoundEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ClickDetector")
    T("class.new.ClickDetector", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ClickDetector") end)
    T("class.name.ClickDetector", function() return EQ(o.Name, "ClickDetector") end)
    T("class.tostring.ClickDetector", function() return EQ(tostring(o), "ClickDetector") end)
    T("class.parent.ClickDetector", function() return EQ(o.Parent, nil) end)
    T("class.isa.ClickDetector.ClickDetector", function() return EQ(o:IsA("ClickDetector"), true) end)
    T("class.isa.ClickDetector.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ClickDetector", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ClientReplicator", function() return ERR(function() return Instance.new("ClientReplicator") end, "Unable to create an Instance of type \"ClientReplicator\"") end)
end
do
    local ok, o = pcall(Instance.new, "ClimbController")
    T("class.new.ClimbController", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ClimbController") end)
    T("class.name.ClimbController", function() return EQ(o.Name, "ClimbController") end)
    T("class.tostring.ClimbController", function() return EQ(tostring(o), "ClimbController") end)
    T("class.parent.ClimbController", function() return EQ(o.Parent, nil) end)
    T("class.isa.ClimbController.ClimbController", function() return EQ(o:IsA("ClimbController"), true) end)
    T("class.isa.ClimbController.ControllerBase", function() return EQ(o:IsA("ControllerBase"), true) end)
    T("class.isa.ClimbController.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ClimbController", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.Clothing", function() return ERR(function() return Instance.new("Clothing") end, "Unable to create an Instance of type \"Clothing\"") end)
end
do
    T("class.notcreatable.CloudLocalizationTable", function() return ERR(function() return Instance.new("CloudLocalizationTable") end, "Unable to create an Instance of type \"CloudLocalizationTable\"") end)
end
do
    local ok, o = pcall(Instance.new, "Clouds")
    T("class.new.Clouds", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Clouds") end)
    T("class.name.Clouds", function() return EQ(o.Name, "Clouds") end)
    T("class.tostring.Clouds", function() return EQ(tostring(o), "Clouds") end)
    T("class.parent.Clouds", function() return EQ(o.Parent, nil) end)
    T("class.isa.Clouds.Clouds", function() return EQ(o:IsA("Clouds"), true) end)
    T("class.isa.Clouds.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Clouds", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.Collaborator", function() return ERR(function() return Instance.new("Collaborator") end, "Unable to create an Instance of type \"Collaborator\"") end)
end
do
    local ok, o = pcall(Instance.new, "Color3Value")
    T("class.new.Color3Value", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Color3Value") end)
    T("class.name.Color3Value", function() return EQ(o.Name, "Color3Value") end)
    T("class.tostring.Color3Value", function() return EQ(tostring(o), "Color3Value") end)
    T("class.parent.Color3Value", function() return EQ(o.Parent, nil) end)
    T("class.isa.Color3Value.Color3Value", function() return EQ(o:IsA("Color3Value"), true) end)
    T("class.isa.Color3Value.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.Color3Value.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Color3Value", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    local ok, o = pcall(Instance.new, "ColorCorrectionEffect")
    T("class.new.ColorCorrectionEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ColorCorrectionEffect") end)
    T("class.name.ColorCorrectionEffect", function() return EQ(o.Name, "ColorCorrectionEffect") end)
    T("class.tostring.ColorCorrectionEffect", function() return EQ(tostring(o), "ColorCorrectionEffect") end)
    T("class.parent.ColorCorrectionEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.ColorCorrectionEffect.ColorCorrectionEffect", function() return EQ(o:IsA("ColorCorrectionEffect"), true) end)
    T("class.isa.ColorCorrectionEffect.PostEffect", function() return EQ(o:IsA("PostEffect"), true) end)
    T("class.isa.ColorCorrectionEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ColorCorrectionEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "CompressorSoundEffect")
    T("class.new.CompressorSoundEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CompressorSoundEffect") end)
    T("class.name.CompressorSoundEffect", function() return EQ(o.Name, "CompressorSoundEffect") end)
    T("class.tostring.CompressorSoundEffect", function() return EQ(tostring(o), "CompressorSoundEffect") end)
    T("class.parent.CompressorSoundEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.CompressorSoundEffect.CompressorSoundEffect", function() return EQ(o:IsA("CompressorSoundEffect"), true) end)
    T("class.isa.CompressorSoundEffect.SoundEffect", function() return EQ(o:IsA("SoundEffect"), true) end)
    T("class.isa.CompressorSoundEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CompressorSoundEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ConeHandleAdornment")
    T("class.new.ConeHandleAdornment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ConeHandleAdornment") end)
    T("class.name.ConeHandleAdornment", function() return EQ(o.Name, "ConeHandleAdornment") end)
    T("class.tostring.ConeHandleAdornment", function() return EQ(tostring(o), "ConeHandleAdornment") end)
    T("class.parent.ConeHandleAdornment", function() return EQ(o.Parent, nil) end)
    T("class.isa.ConeHandleAdornment.ConeHandleAdornment", function() return EQ(o:IsA("ConeHandleAdornment"), true) end)
    T("class.isa.ConeHandleAdornment.HandleAdornment", function() return EQ(o:IsA("HandleAdornment"), true) end)
    T("class.isa.ConeHandleAdornment.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.ConeHandleAdornment.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.ConeHandleAdornment.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.ConeHandleAdornment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ConeHandleAdornment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ConfigSnapshot", function() return ERR(function() return Instance.new("ConfigSnapshot") end, "Unable to create an Instance of type \"ConfigSnapshot\"") end)
end
do
    local ok, o = pcall(Instance.new, "Configuration")
    T("class.new.Configuration", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Configuration") end)
    T("class.name.Configuration", function() return EQ(o.Name, "Configuration") end)
    T("class.tostring.Configuration", function() return EQ(tostring(o), "Configuration") end)
    T("class.parent.Configuration", function() return EQ(o.Parent, nil) end)
    T("class.isa.Configuration.Configuration", function() return EQ(o:IsA("Configuration"), true) end)
    T("class.isa.Configuration.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Configuration", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.Constraint", function() return ERR(function() return Instance.new("Constraint") end, "Unable to create an Instance of type \"Constraint\"") end)
end
do
    T("class.notcreatable.Controller", function() return ERR(function() return Instance.new("Controller") end, "Unable to create an Instance of type \"Controller\"") end)
end
do
    T("class.notcreatable.ControllerBase", function() return ERR(function() return Instance.new("ControllerBase") end, "Unable to create an Instance of type \"ControllerBase\"") end)
end
do
    local ok, o = pcall(Instance.new, "ControllerManager")
    T("class.new.ControllerManager", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ControllerManager") end)
    T("class.name.ControllerManager", function() return EQ(o.Name, "ControllerManager") end)
    T("class.tostring.ControllerManager", function() return EQ(tostring(o), "ControllerManager") end)
    T("class.parent.ControllerManager", function() return EQ(o.Parent, nil) end)
    T("class.isa.ControllerManager.ControllerManager", function() return EQ(o:IsA("ControllerManager"), true) end)
    T("class.isa.ControllerManager.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ControllerManager", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ControllerPartSensor")
    T("class.new.ControllerPartSensor", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ControllerPartSensor") end)
    T("class.name.ControllerPartSensor", function() return EQ(o.Name, "ControllerPartSensor") end)
    T("class.tostring.ControllerPartSensor", function() return EQ(tostring(o), "ControllerPartSensor") end)
    T("class.parent.ControllerPartSensor", function() return EQ(o.Parent, nil) end)
    T("class.isa.ControllerPartSensor.ControllerPartSensor", function() return EQ(o:IsA("ControllerPartSensor"), true) end)
    T("class.isa.ControllerPartSensor.ControllerSensor", function() return EQ(o:IsA("ControllerSensor"), true) end)
    T("class.isa.ControllerPartSensor.SensorBase", function() return EQ(o:IsA("SensorBase"), true) end)
    T("class.isa.ControllerPartSensor.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ControllerPartSensor", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ControllerSensor", function() return ERR(function() return Instance.new("ControllerSensor") end, "Unable to create an Instance of type \"ControllerSensor\"") end)
end
do
    T("class.notcreatable.CoreScript", function() return ERR(function() return Instance.new("CoreScript") end, "Unable to create an Instance of type \"CoreScript\"") end)
end
do
    local ok, o = pcall(Instance.new, "CornerWedgePart")
    T("class.new.CornerWedgePart", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CornerWedgePart") end)
    T("class.name.CornerWedgePart", function() return EQ(o.Name, "CornerWedgePart") end)
    T("class.tostring.CornerWedgePart", function() return EQ(tostring(o), "CornerWedgePart") end)
    T("class.parent.CornerWedgePart", function() return EQ(o.Parent, nil) end)
    T("class.isa.CornerWedgePart.CornerWedgePart", function() return EQ(o:IsA("CornerWedgePart"), true) end)
    T("class.isa.CornerWedgePart.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.CornerWedgePart.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.CornerWedgePart.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CornerWedgePart", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "CurveAnimation")
    T("class.new.CurveAnimation", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CurveAnimation") end)
    T("class.name.CurveAnimation", function() return EQ(o.Name, "CurveAnimation") end)
    T("class.tostring.CurveAnimation", function() return EQ(tostring(o), "CurveAnimation") end)
    T("class.parent.CurveAnimation", function() return EQ(o.Parent, nil) end)
    T("class.isa.CurveAnimation.CurveAnimation", function() return EQ(o:IsA("CurveAnimation"), true) end)
    T("class.isa.CurveAnimation.AnimationClip", function() return EQ(o:IsA("AnimationClip"), true) end)
    T("class.isa.CurveAnimation.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CurveAnimation", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "CustomEvent")
    T("class.new.CustomEvent", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CustomEvent") end)
    T("class.name.CustomEvent", function() return EQ(o.Name, "CustomEvent") end)
    T("class.tostring.CustomEvent", function() return EQ(tostring(o), "CustomEvent") end)
    T("class.parent.CustomEvent", function() return EQ(o.Parent, nil) end)
    T("class.isa.CustomEvent.CustomEvent", function() return EQ(o:IsA("CustomEvent"), true) end)
    T("class.isa.CustomEvent.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CustomEvent", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "CustomEventReceiver")
    T("class.new.CustomEventReceiver", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CustomEventReceiver") end)
    T("class.name.CustomEventReceiver", function() return EQ(o.Name, "CustomEventReceiver") end)
    T("class.tostring.CustomEventReceiver", function() return EQ(tostring(o), "CustomEventReceiver") end)
    T("class.parent.CustomEventReceiver", function() return EQ(o.Parent, nil) end)
    T("class.isa.CustomEventReceiver.CustomEventReceiver", function() return EQ(o:IsA("CustomEventReceiver"), true) end)
    T("class.isa.CustomEventReceiver.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CustomEventReceiver", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.CustomSoundEffect", function() return ERR(function() return Instance.new("CustomSoundEffect") end, "Unable to create an Instance of type \"CustomSoundEffect\"") end)
end
do
    local ok, o = pcall(Instance.new, "CylinderHandleAdornment")
    T("class.new.CylinderHandleAdornment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CylinderHandleAdornment") end)
    T("class.name.CylinderHandleAdornment", function() return EQ(o.Name, "CylinderHandleAdornment") end)
    T("class.tostring.CylinderHandleAdornment", function() return EQ(tostring(o), "CylinderHandleAdornment") end)
    T("class.parent.CylinderHandleAdornment", function() return EQ(o.Parent, nil) end)
    T("class.isa.CylinderHandleAdornment.CylinderHandleAdornment", function() return EQ(o:IsA("CylinderHandleAdornment"), true) end)
    T("class.isa.CylinderHandleAdornment.HandleAdornment", function() return EQ(o:IsA("HandleAdornment"), true) end)
    T("class.isa.CylinderHandleAdornment.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.CylinderHandleAdornment.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.CylinderHandleAdornment.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.CylinderHandleAdornment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CylinderHandleAdornment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "CylinderMesh")
    T("class.new.CylinderMesh", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CylinderMesh") end)
    T("class.name.CylinderMesh", function() return EQ(o.Name, "CylinderMesh") end)
    T("class.tostring.CylinderMesh", function() return EQ(tostring(o), "CylinderMesh") end)
    T("class.parent.CylinderMesh", function() return EQ(o.Parent, nil) end)
    T("class.isa.CylinderMesh.CylinderMesh", function() return EQ(o:IsA("CylinderMesh"), true) end)
    T("class.isa.CylinderMesh.BevelMesh", function() return EQ(o:IsA("BevelMesh"), true) end)
    T("class.isa.CylinderMesh.DataModelMesh", function() return EQ(o:IsA("DataModelMesh"), true) end)
    T("class.isa.CylinderMesh.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CylinderMesh", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "CylindricalConstraint")
    T("class.new.CylindricalConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "CylindricalConstraint") end)
    T("class.name.CylindricalConstraint", function() return EQ(o.Name, "CylindricalConstraint") end)
    T("class.tostring.CylindricalConstraint", function() return EQ(tostring(o), "CylindricalConstraint") end)
    T("class.parent.CylindricalConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.CylindricalConstraint.CylindricalConstraint", function() return EQ(o:IsA("CylindricalConstraint"), true) end)
    T("class.isa.CylindricalConstraint.SlidingBallConstraint", function() return EQ(o:IsA("SlidingBallConstraint"), true) end)
    T("class.isa.CylindricalConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.CylindricalConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.CylindricalConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.DataModel", function() return ERR(function() return Instance.new("DataModel") end, "Unable to create an Instance of type \"DataModel\"") end)
end
do
    T("class.notcreatable.DataModelDiff", function() return ERR(function() return Instance.new("DataModelDiff") end, "Unable to create an Instance of type \"DataModelDiff\"") end)
end
do
    T("class.notcreatable.DataModelMesh", function() return ERR(function() return Instance.new("DataModelMesh") end, "Unable to create an Instance of type \"DataModelMesh\"") end)
end
do
    T("class.notcreatable.DataModelSession", function() return ERR(function() return Instance.new("DataModelSession") end, "Unable to create an Instance of type \"DataModelSession\"") end)
end
do
    T("class.notcreatable.DataStore", function() return ERR(function() return Instance.new("DataStore") end, "Unable to create an Instance of type \"DataStore\"") end)
end
do
    local ok, o = pcall(Instance.new, "DataStoreGetOptions")
    T("class.new.DataStoreGetOptions", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DataStoreGetOptions") end)
    T("class.name.DataStoreGetOptions", function() return EQ(o.Name, "DataStoreGetOptions") end)
    T("class.tostring.DataStoreGetOptions", function() return EQ(tostring(o), "DataStoreGetOptions") end)
    T("class.parent.DataStoreGetOptions", function() return EQ(o.Parent, nil) end)
    T("class.isa.DataStoreGetOptions.DataStoreGetOptions", function() return EQ(o:IsA("DataStoreGetOptions"), true) end)
    T("class.isa.DataStoreGetOptions.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DataStoreGetOptions", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "DataStoreIncrementOptions")
    T("class.new.DataStoreIncrementOptions", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DataStoreIncrementOptions") end)
    T("class.name.DataStoreIncrementOptions", function() return EQ(o.Name, "DataStoreIncrementOptions") end)
    T("class.tostring.DataStoreIncrementOptions", function() return EQ(tostring(o), "DataStoreIncrementOptions") end)
    T("class.parent.DataStoreIncrementOptions", function() return EQ(o.Parent, nil) end)
    T("class.isa.DataStoreIncrementOptions.DataStoreIncrementOptions", function() return EQ(o:IsA("DataStoreIncrementOptions"), true) end)
    T("class.isa.DataStoreIncrementOptions.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DataStoreIncrementOptions", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.DataStoreInfo", function() return ERR(function() return Instance.new("DataStoreInfo") end, "Unable to create an Instance of type \"DataStoreInfo\"") end)
end
do
    T("class.notcreatable.DataStoreKey", function() return ERR(function() return Instance.new("DataStoreKey") end, "Unable to create an Instance of type \"DataStoreKey\"") end)
end
do
    T("class.notcreatable.DataStoreKeyInfo", function() return ERR(function() return Instance.new("DataStoreKeyInfo") end, "Unable to create an Instance of type \"DataStoreKeyInfo\"") end)
end
do
    T("class.notcreatable.DataStoreKeyPages", function() return ERR(function() return Instance.new("DataStoreKeyPages") end, "Unable to create an Instance of type \"DataStoreKeyPages\"") end)
end
do
    T("class.notcreatable.DataStoreListingPages", function() return ERR(function() return Instance.new("DataStoreListingPages") end, "Unable to create an Instance of type \"DataStoreListingPages\"") end)
end
do
    T("class.notcreatable.DataStoreObjectVersionInfo", function() return ERR(function() return Instance.new("DataStoreObjectVersionInfo") end, "Unable to create an Instance of type \"DataStoreObjectVersionInfo\"") end)
end
do
    local ok, o = pcall(Instance.new, "DataStoreOptions")
    T("class.new.DataStoreOptions", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DataStoreOptions") end)
    T("class.name.DataStoreOptions", function() return EQ(o.Name, "DataStoreOptions") end)
    T("class.tostring.DataStoreOptions", function() return EQ(tostring(o), "DataStoreOptions") end)
    T("class.parent.DataStoreOptions", function() return EQ(o.Parent, nil) end)
    T("class.isa.DataStoreOptions.DataStoreOptions", function() return EQ(o:IsA("DataStoreOptions"), true) end)
    T("class.isa.DataStoreOptions.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DataStoreOptions", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.DataStorePages", function() return ERR(function() return Instance.new("DataStorePages") end, "Unable to create an Instance of type \"DataStorePages\"") end)
end
do
    local ok, o = pcall(Instance.new, "DataStoreSetOptions")
    T("class.new.DataStoreSetOptions", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DataStoreSetOptions") end)
    T("class.name.DataStoreSetOptions", function() return EQ(o.Name, "DataStoreSetOptions") end)
    T("class.tostring.DataStoreSetOptions", function() return EQ(tostring(o), "DataStoreSetOptions") end)
    T("class.parent.DataStoreSetOptions", function() return EQ(o.Parent, nil) end)
    T("class.isa.DataStoreSetOptions.DataStoreSetOptions", function() return EQ(o:IsA("DataStoreSetOptions"), true) end)
    T("class.isa.DataStoreSetOptions.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DataStoreSetOptions", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.DataStoreVersionPages", function() return ERR(function() return Instance.new("DataStoreVersionPages") end, "Unable to create an Instance of type \"DataStoreVersionPages\"") end)
end
do
    T("class.notcreatable.DebuggerBreakpoint", function() return ERR(function() return Instance.new("DebuggerBreakpoint") end, "Unable to create an Instance of type \"DebuggerBreakpoint\"") end)
end
do
    T("class.notcreatable.DebuggerConnection", function() return ERR(function() return Instance.new("DebuggerConnection") end, "Unable to create an Instance of type \"DebuggerConnection\"") end)
end
do
    T("class.notcreatable.DebuggerLuaResponse", function() return ERR(function() return Instance.new("DebuggerLuaResponse") end, "Unable to create an Instance of type \"DebuggerLuaResponse\"") end)
end
do
    T("class.notcreatable.DebuggerVariable", function() return ERR(function() return Instance.new("DebuggerVariable") end, "Unable to create an Instance of type \"DebuggerVariable\"") end)
end
do
    local ok, o = pcall(Instance.new, "Decal")
    T("class.new.Decal", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Decal") end)
    T("class.name.Decal", function() return EQ(o.Name, "Decal") end)
    T("class.tostring.Decal", function() return EQ(tostring(o), "Decal") end)
    T("class.parent.Decal", function() return EQ(o.Parent, nil) end)
    T("class.isa.Decal.Decal", function() return EQ(o:IsA("Decal"), true) end)
    T("class.isa.Decal.FaceInstance", function() return EQ(o:IsA("FaceInstance"), true) end)
    T("class.isa.Decal.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Decal", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "DepthOfFieldEffect")
    T("class.new.DepthOfFieldEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DepthOfFieldEffect") end)
    T("class.name.DepthOfFieldEffect", function() return EQ(o.Name, "DepthOfFieldEffect") end)
    T("class.tostring.DepthOfFieldEffect", function() return EQ(tostring(o), "DepthOfFieldEffect") end)
    T("class.parent.DepthOfFieldEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.DepthOfFieldEffect.DepthOfFieldEffect", function() return EQ(o:IsA("DepthOfFieldEffect"), true) end)
    T("class.isa.DepthOfFieldEffect.PostEffect", function() return EQ(o:IsA("PostEffect"), true) end)
    T("class.isa.DepthOfFieldEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DepthOfFieldEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Dialog")
    T("class.new.Dialog", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Dialog") end)
    T("class.name.Dialog", function() return EQ(o.Name, "Dialog") end)
    T("class.tostring.Dialog", function() return EQ(tostring(o), "Dialog") end)
    T("class.parent.Dialog", function() return EQ(o.Parent, nil) end)
    T("class.isa.Dialog.Dialog", function() return EQ(o:IsA("Dialog"), true) end)
    T("class.isa.Dialog.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Dialog", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "DialogChoice")
    T("class.new.DialogChoice", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DialogChoice") end)
    T("class.name.DialogChoice", function() return EQ(o.Name, "DialogChoice") end)
    T("class.tostring.DialogChoice", function() return EQ(tostring(o), "DialogChoice") end)
    T("class.parent.DialogChoice", function() return EQ(o.Parent, nil) end)
    T("class.isa.DialogChoice.DialogChoice", function() return EQ(o:IsA("DialogChoice"), true) end)
    T("class.isa.DialogChoice.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DialogChoice", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "DigitsRigDescription")
    T("class.new.DigitsRigDescription", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DigitsRigDescription") end)
    T("class.name.DigitsRigDescription", function() return EQ(o.Name, "DigitsRigDescription") end)
    T("class.tostring.DigitsRigDescription", function() return EQ(tostring(o), "DigitsRigDescription") end)
    T("class.parent.DigitsRigDescription", function() return EQ(o.Parent, nil) end)
    T("class.isa.DigitsRigDescription.DigitsRigDescription", function() return EQ(o:IsA("DigitsRigDescription"), true) end)
    T("class.isa.DigitsRigDescription.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DigitsRigDescription", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.DisplayWakeLock", function() return ERR(function() return Instance.new("DisplayWakeLock") end, "Unable to create an Instance of type \"DisplayWakeLock\"") end)
end
do
    local ok, o = pcall(Instance.new, "DistortionSoundEffect")
    T("class.new.DistortionSoundEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DistortionSoundEffect") end)
    T("class.name.DistortionSoundEffect", function() return EQ(o.Name, "DistortionSoundEffect") end)
    T("class.tostring.DistortionSoundEffect", function() return EQ(tostring(o), "DistortionSoundEffect") end)
    T("class.parent.DistortionSoundEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.DistortionSoundEffect.DistortionSoundEffect", function() return EQ(o:IsA("DistortionSoundEffect"), true) end)
    T("class.isa.DistortionSoundEffect.SoundEffect", function() return EQ(o:IsA("SoundEffect"), true) end)
    T("class.isa.DistortionSoundEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DistortionSoundEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.DockWidgetPluginGui", function() return ERR(function() return Instance.new("DockWidgetPluginGui") end, "Unable to create an Instance of type \"DockWidgetPluginGui\"") end)
end
do
    local ok, o = pcall(Instance.new, "DoubleConstrainedValue")
    T("class.new.DoubleConstrainedValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DoubleConstrainedValue") end)
    T("class.name.DoubleConstrainedValue", function() return EQ(o.Name, "DoubleConstrainedValue") end)
    T("class.tostring.DoubleConstrainedValue", function() return EQ(tostring(o), "DoubleConstrainedValue") end)
    T("class.parent.DoubleConstrainedValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.DoubleConstrainedValue.DoubleConstrainedValue", function() return EQ(o:IsA("DoubleConstrainedValue"), true) end)
    T("class.isa.DoubleConstrainedValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.DoubleConstrainedValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DoubleConstrainedValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    local ok, o = pcall(Instance.new, "DragDetector")
    T("class.new.DragDetector", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "DragDetector") end)
    T("class.name.DragDetector", function() return EQ(o.Name, "DragDetector") end)
    T("class.tostring.DragDetector", function() return EQ(tostring(o), "DragDetector") end)
    T("class.parent.DragDetector", function() return EQ(o.Parent, nil) end)
    T("class.isa.DragDetector.DragDetector", function() return EQ(o:IsA("DragDetector"), true) end)
    T("class.isa.DragDetector.ClickDetector", function() return EQ(o:IsA("ClickDetector"), true) end)
    T("class.isa.DragDetector.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.DragDetector", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.DynamicRotate", function() return ERR(function() return Instance.new("DynamicRotate") end, "Unable to create an Instance of type \"DynamicRotate\"") end)
end
do
    local ok, o = pcall(Instance.new, "EchoSoundEffect")
    T("class.new.EchoSoundEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "EchoSoundEffect") end)
    T("class.name.EchoSoundEffect", function() return EQ(o.Name, "EchoSoundEffect") end)
    T("class.tostring.EchoSoundEffect", function() return EQ(tostring(o), "EchoSoundEffect") end)
    T("class.parent.EchoSoundEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.EchoSoundEffect.EchoSoundEffect", function() return EQ(o:IsA("EchoSoundEffect"), true) end)
    T("class.isa.EchoSoundEffect.SoundEffect", function() return EQ(o:IsA("SoundEffect"), true) end)
    T("class.isa.EchoSoundEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.EchoSoundEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.EditableImage", function() return ERR(function() return Instance.new("EditableImage") end, "Unable to create an Instance of type \"EditableImage\"") end)
end
do
    T("class.notcreatable.EditableMesh", function() return ERR(function() return Instance.new("EditableMesh") end, "Unable to create an Instance of type \"EditableMesh\"") end)
end
do
    local ok, o = pcall(Instance.new, "EqualizerSoundEffect")
    T("class.new.EqualizerSoundEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "EqualizerSoundEffect") end)
    T("class.name.EqualizerSoundEffect", function() return EQ(o.Name, "EqualizerSoundEffect") end)
    T("class.tostring.EqualizerSoundEffect", function() return EQ(tostring(o), "EqualizerSoundEffect") end)
    T("class.parent.EqualizerSoundEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.EqualizerSoundEffect.EqualizerSoundEffect", function() return EQ(o:IsA("EqualizerSoundEffect"), true) end)
    T("class.isa.EqualizerSoundEffect.SoundEffect", function() return EQ(o:IsA("SoundEffect"), true) end)
    T("class.isa.EqualizerSoundEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.EqualizerSoundEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "EulerRotationCurve")
    T("class.new.EulerRotationCurve", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "EulerRotationCurve") end)
    T("class.name.EulerRotationCurve", function() return EQ(o.Name, "EulerRotationCurve") end)
    T("class.tostring.EulerRotationCurve", function() return EQ(tostring(o), "EulerRotationCurve") end)
    T("class.parent.EulerRotationCurve", function() return EQ(o.Parent, nil) end)
    T("class.isa.EulerRotationCurve.EulerRotationCurve", function() return EQ(o:IsA("EulerRotationCurve"), true) end)
    T("class.isa.EulerRotationCurve.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.EulerRotationCurve", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ExecutedRemoteCommand", function() return ERR(function() return Instance.new("ExecutedRemoteCommand") end, "Unable to create an Instance of type \"ExecutedRemoteCommand\"") end)
end
do
    local ok, o = pcall(Instance.new, "ExperienceInviteOptions")
    T("class.new.ExperienceInviteOptions", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ExperienceInviteOptions") end)
    T("class.name.ExperienceInviteOptions", function() return EQ(o.Name, "ExperienceInviteOptions") end)
    T("class.tostring.ExperienceInviteOptions", function() return EQ(tostring(o), "ExperienceInviteOptions") end)
    T("class.parent.ExperienceInviteOptions", function() return EQ(o.Parent, nil) end)
    T("class.isa.ExperienceInviteOptions.ExperienceInviteOptions", function() return EQ(o:IsA("ExperienceInviteOptions"), true) end)
    T("class.isa.ExperienceInviteOptions.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ExperienceInviteOptions", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ExplorerFilterAutocompleter", function() return ERR(function() return Instance.new("ExplorerFilterAutocompleter") end, "Unable to create an Instance of type \"ExplorerFilterAutocompleter\"") end)
end
do
    local ok, o = pcall(Instance.new, "Explosion")
    T("class.new.Explosion", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Explosion") end)
    T("class.name.Explosion", function() return EQ(o.Name, "Explosion") end)
    T("class.tostring.Explosion", function() return EQ(tostring(o), "Explosion") end)
    T("class.parent.Explosion", function() return EQ(o.Parent, nil) end)
    T("class.isa.Explosion.Explosion", function() return EQ(o:IsA("Explosion"), true) end)
    T("class.isa.Explosion.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Explosion", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "FaceControls")
    T("class.new.FaceControls", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "FaceControls") end)
    T("class.name.FaceControls", function() return EQ(o.Name, "FaceControls") end)
    T("class.tostring.FaceControls", function() return EQ(tostring(o), "FaceControls") end)
    T("class.parent.FaceControls", function() return EQ(o.Parent, nil) end)
    T("class.isa.FaceControls.FaceControls", function() return EQ(o:IsA("FaceControls"), true) end)
    T("class.isa.FaceControls.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.FaceControls", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.FaceInstance", function() return ERR(function() return Instance.new("FaceInstance") end, "Unable to create an Instance of type \"FaceInstance\"") end)
end
do
    T("class.notcreatable.FacialAnimationStreamingServiceStats", function() return ERR(function() return Instance.new("FacialAnimationStreamingServiceStats") end, "Unable to create an Instance of type \"FacialAnimationStreamingServiceStats\"") end)
end
do
    T("class.notcreatable.FacialAnimationStreamingSubsessionStats", function() return ERR(function() return Instance.new("FacialAnimationStreamingSubsessionStats") end, "Unable to create an Instance of type \"FacialAnimationStreamingSubsessionStats\"") end)
end
do
    T("class.notcreatable.FacsImportData", function() return ERR(function() return Instance.new("FacsImportData") end, "Unable to create an Instance of type \"FacsImportData\"") end)
end
do
    T("class.notcreatable.Feature", function() return ERR(function() return Instance.new("Feature") end, "Unable to create an Instance of type \"Feature\"") end)
end
do
    T("class.notcreatable.FeatureMatchingSession", function() return ERR(function() return Instance.new("FeatureMatchingSession") end, "Unable to create an Instance of type \"FeatureMatchingSession\"") end)
end
do
    T("class.notcreatable.File", function() return ERR(function() return Instance.new("File") end, "Unable to create an Instance of type \"File\"") end)
end
do
    local ok, o = pcall(Instance.new, "FileMesh")
    T("class.new.FileMesh", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "FileMesh") end)
    T("class.name.FileMesh", function() return EQ(o.Name, "FileMesh") end)
    T("class.tostring.FileMesh", function() return EQ(tostring(o), "FileMesh") end)
    T("class.parent.FileMesh", function() return EQ(o.Parent, nil) end)
    T("class.isa.FileMesh.FileMesh", function() return EQ(o:IsA("FileMesh"), true) end)
    T("class.isa.FileMesh.DataModelMesh", function() return EQ(o:IsA("DataModelMesh"), true) end)
    T("class.isa.FileMesh.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.FileMesh", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Fire")
    T("class.new.Fire", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Fire") end)
    T("class.name.Fire", function() return EQ(o.Name, "Fire") end)
    T("class.tostring.Fire", function() return EQ(tostring(o), "Fire") end)
    T("class.parent.Fire", function() return EQ(o.Parent, nil) end)
    T("class.isa.Fire.Fire", function() return EQ(o:IsA("Fire"), true) end)
    T("class.isa.Fire.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Fire", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Flag")
    T("class.new.Flag", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Flag") end)
    T("class.name.Flag", function() return EQ(o.Name, "Flag") end)
    T("class.tostring.Flag", function() return EQ(tostring(o), "Flag") end)
    T("class.parent.Flag", function() return EQ(o.Parent, nil) end)
    T("class.isa.Flag.Flag", function() return EQ(o:IsA("Flag"), true) end)
    T("class.isa.Flag.Tool", function() return EQ(o:IsA("Tool"), true) end)
    T("class.isa.Flag.BackpackItem", function() return EQ(o:IsA("BackpackItem"), true) end)
    T("class.isa.Flag.Model", function() return EQ(o:IsA("Model"), true) end)
    T("class.isa.Flag.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.Flag.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Flag", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "FlagStand")
    T("class.new.FlagStand", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "FlagStand") end)
    T("class.name.FlagStand", function() return EQ(o.Name, "FlagStand") end)
    T("class.tostring.FlagStand", function() return EQ(tostring(o), "FlagStand") end)
    T("class.parent.FlagStand", function() return EQ(o.Parent, nil) end)
    T("class.isa.FlagStand.FlagStand", function() return EQ(o:IsA("FlagStand"), true) end)
    T("class.isa.FlagStand.Part", function() return EQ(o:IsA("Part"), true) end)
    T("class.isa.FlagStand.FormFactorPart", function() return EQ(o:IsA("FormFactorPart"), true) end)
    T("class.isa.FlagStand.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.FlagStand.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.FlagStand.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.FlagStand", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "FlangeSoundEffect")
    T("class.new.FlangeSoundEffect", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "FlangeSoundEffect") end)
    T("class.name.FlangeSoundEffect", function() return EQ(o.Name, "FlangeSoundEffect") end)
    T("class.tostring.FlangeSoundEffect", function() return EQ(tostring(o), "FlangeSoundEffect") end)
    T("class.parent.FlangeSoundEffect", function() return EQ(o.Parent, nil) end)
    T("class.isa.FlangeSoundEffect.FlangeSoundEffect", function() return EQ(o:IsA("FlangeSoundEffect"), true) end)
    T("class.isa.FlangeSoundEffect.SoundEffect", function() return EQ(o:IsA("SoundEffect"), true) end)
    T("class.isa.FlangeSoundEffect.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.FlangeSoundEffect", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "FloatCurve")
    T("class.new.FloatCurve", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "FloatCurve") end)
    T("class.name.FloatCurve", function() return EQ(o.Name, "FloatCurve") end)
    T("class.tostring.FloatCurve", function() return EQ(tostring(o), "FloatCurve") end)
    T("class.parent.FloatCurve", function() return EQ(o.Parent, nil) end)
    T("class.isa.FloatCurve.FloatCurve", function() return EQ(o:IsA("FloatCurve"), true) end)
    T("class.isa.FloatCurve.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.FloatCurve", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "FloorWire")
    T("class.new.FloorWire", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "FloorWire") end)
    T("class.name.FloorWire", function() return EQ(o.Name, "FloorWire") end)
    T("class.tostring.FloorWire", function() return EQ(tostring(o), "FloorWire") end)
    T("class.parent.FloorWire", function() return EQ(o.Parent, nil) end)
    T("class.isa.FloorWire.FloorWire", function() return EQ(o:IsA("FloorWire"), true) end)
    T("class.isa.FloorWire.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.FloorWire.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.FloorWire.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.FloorWire", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "FluidForceSensor")
    T("class.new.FluidForceSensor", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "FluidForceSensor") end)
    T("class.name.FluidForceSensor", function() return EQ(o.Name, "FluidForceSensor") end)
    T("class.tostring.FluidForceSensor", function() return EQ(tostring(o), "FluidForceSensor") end)
    T("class.parent.FluidForceSensor", function() return EQ(o.Parent, nil) end)
    T("class.isa.FluidForceSensor.FluidForceSensor", function() return EQ(o:IsA("FluidForceSensor"), true) end)
    T("class.isa.FluidForceSensor.SensorBase", function() return EQ(o:IsA("SensorBase"), true) end)
    T("class.isa.FluidForceSensor.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.FluidForceSensor", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Folder")
    T("class.new.Folder", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Folder") end)
    T("class.name.Folder", function() return EQ(o.Name, "Folder") end)
    T("class.tostring.Folder", function() return EQ(tostring(o), "Folder") end)
    T("class.parent.Folder", function() return EQ(o.Parent, nil) end)
    T("class.isa.Folder.Folder", function() return EQ(o:IsA("Folder"), true) end)
    T("class.isa.Folder.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Folder", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ForceField")
    T("class.new.ForceField", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ForceField") end)
    T("class.name.ForceField", function() return EQ(o.Name, "ForceField") end)
    T("class.tostring.ForceField", function() return EQ(tostring(o), "ForceField") end)
    T("class.parent.ForceField", function() return EQ(o.Parent, nil) end)
    T("class.isa.ForceField.ForceField", function() return EQ(o:IsA("ForceField"), true) end)
    T("class.isa.ForceField.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ForceField", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.FormFactorPart", function() return ERR(function() return Instance.new("FormFactorPart") end, "Unable to create an Instance of type \"FormFactorPart\"") end)
end
do
    local ok, o = pcall(Instance.new, "Frame")
    T("class.new.Frame", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Frame") end)
    T("class.name.Frame", function() return EQ(o.Name, "Frame") end)
    T("class.tostring.Frame", function() return EQ(tostring(o), "Frame") end)
    T("class.parent.Frame", function() return EQ(o.Parent, nil) end)
    T("class.isa.Frame.Frame", function() return EQ(o:IsA("Frame"), true) end)
    T("class.isa.Frame.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.Frame.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.Frame.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.Frame.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Frame", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.FriendPages", function() return ERR(function() return Instance.new("FriendPages") end, "Unable to create an Instance of type \"FriendPages\"") end)
end
do
    T("class.notcreatable.FriendsCallingInstance", function() return ERR(function() return Instance.new("FriendsCallingInstance") end, "Unable to create an Instance of type \"FriendsCallingInstance\"") end)
end
do
    T("class.notcreatable.FriendsCallingParticipant", function() return ERR(function() return Instance.new("FriendsCallingParticipant") end, "Unable to create an Instance of type \"FriendsCallingParticipant\"") end)
end
do
    T("class.notcreatable.GenericSettings", function() return ERR(function() return Instance.new("GenericSettings") end, "Unable to create an Instance of type \"GenericSettings\"") end)
end
do
    local ok, o = pcall(Instance.new, "GetTextBoundsParams")
    T("class.new.GetTextBoundsParams", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "GetTextBoundsParams") end)
    T("class.name.GetTextBoundsParams", function() return EQ(o.Name, "GetTextBoundsParams") end)
    T("class.tostring.GetTextBoundsParams", function() return EQ(tostring(o), "GetTextBoundsParams") end)
    T("class.parent.GetTextBoundsParams", function() return EQ(o.Parent, nil) end)
    T("class.isa.GetTextBoundsParams.GetTextBoundsParams", function() return EQ(o:IsA("GetTextBoundsParams"), true) end)
    T("class.isa.GetTextBoundsParams.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.GetTextBoundsParams", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.GlobalDataStore", function() return ERR(function() return Instance.new("GlobalDataStore") end, "Unable to create an Instance of type \"GlobalDataStore\"") end)
end
do
    T("class.notcreatable.GlobalSettings", function() return ERR(function() return Instance.new("GlobalSettings") end, "Unable to create an Instance of type \"GlobalSettings\"") end)
end
do
    local ok, o = pcall(Instance.new, "Glue")
    T("class.new.Glue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Glue") end)
    T("class.name.Glue", function() return EQ(o.Name, "Glue") end)
    T("class.tostring.Glue", function() return EQ(tostring(o), "Glue") end)
    T("class.parent.Glue", function() return EQ(o.Parent, nil) end)
    T("class.isa.Glue.Glue", function() return EQ(o:IsA("Glue"), true) end)
    T("class.isa.Glue.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.Glue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Glue", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "GroundController")
    T("class.new.GroundController", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "GroundController") end)
    T("class.name.GroundController", function() return EQ(o.Name, "GroundController") end)
    T("class.tostring.GroundController", function() return EQ(tostring(o), "GroundController") end)
    T("class.parent.GroundController", function() return EQ(o.Parent, nil) end)
    T("class.isa.GroundController.GroundController", function() return EQ(o:IsA("GroundController"), true) end)
    T("class.isa.GroundController.ControllerBase", function() return EQ(o:IsA("ControllerBase"), true) end)
    T("class.isa.GroundController.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.GroundController", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.GroupImportData", function() return ERR(function() return Instance.new("GroupImportData") end, "Unable to create an Instance of type \"GroupImportData\"") end)
end
do
    T("class.notcreatable.GuiBase", function() return ERR(function() return Instance.new("GuiBase") end, "Unable to create an Instance of type \"GuiBase\"") end)
end
do
    T("class.notcreatable.GuiBase2d", function() return ERR(function() return Instance.new("GuiBase2d") end, "Unable to create an Instance of type \"GuiBase2d\"") end)
end
do
    T("class.notcreatable.GuiBase3d", function() return ERR(function() return Instance.new("GuiBase3d") end, "Unable to create an Instance of type \"GuiBase3d\"") end)
end
do
    T("class.notcreatable.GuiButton", function() return ERR(function() return Instance.new("GuiButton") end, "Unable to create an Instance of type \"GuiButton\"") end)
end
do
    T("class.notcreatable.GuiLabel", function() return ERR(function() return Instance.new("GuiLabel") end, "Unable to create an Instance of type \"GuiLabel\"") end)
end
do
    local ok, o = pcall(Instance.new, "GuiMain")
    T("class.new.GuiMain", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "GuiMain") end)
    T("class.name.GuiMain", function() return EQ(o.Name, "GuiMain") end)
    T("class.tostring.GuiMain", function() return EQ(tostring(o), "GuiMain") end)
    T("class.parent.GuiMain", function() return EQ(o.Parent, nil) end)
    T("class.isa.GuiMain.GuiMain", function() return EQ(o:IsA("GuiMain"), true) end)
    T("class.isa.GuiMain.ScreenGui", function() return EQ(o:IsA("ScreenGui"), true) end)
    T("class.isa.GuiMain.LayerCollector", function() return EQ(o:IsA("LayerCollector"), true) end)
    T("class.isa.GuiMain.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.GuiMain.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.GuiMain.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.GuiMain", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.GuiObject", function() return ERR(function() return Instance.new("GuiObject") end, "Unable to create an Instance of type \"GuiObject\"") end)
end
do
    T("class.notcreatable.HandleAdornment", function() return ERR(function() return Instance.new("HandleAdornment") end, "Unable to create an Instance of type \"HandleAdornment\"") end)
end
do
    local ok, o = pcall(Instance.new, "Handles")
    T("class.new.Handles", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Handles") end)
    T("class.name.Handles", function() return EQ(o.Name, "Handles") end)
    T("class.tostring.Handles", function() return EQ(tostring(o), "Handles") end)
    T("class.parent.Handles", function() return EQ(o.Parent, nil) end)
    T("class.isa.Handles.Handles", function() return EQ(o:IsA("Handles"), true) end)
    T("class.isa.Handles.HandlesBase", function() return EQ(o:IsA("HandlesBase"), true) end)
    T("class.isa.Handles.PartAdornment", function() return EQ(o:IsA("PartAdornment"), true) end)
    T("class.isa.Handles.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.Handles.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.Handles.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Handles", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.HandlesBase", function() return ERR(function() return Instance.new("HandlesBase") end, "Unable to create an Instance of type \"HandlesBase\"") end)
end
do
    local ok, o = pcall(Instance.new, "Hat")
    T("class.new.Hat", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Hat") end)
    T("class.name.Hat", function() return EQ(o.Name, "Hat") end)
    T("class.tostring.Hat", function() return EQ(tostring(o), "Hat") end)
    T("class.parent.Hat", function() return EQ(o.Parent, nil) end)
    T("class.isa.Hat.Hat", function() return EQ(o:IsA("Hat"), true) end)
    T("class.isa.Hat.Accoutrement", function() return EQ(o:IsA("Accoutrement"), true) end)
    T("class.isa.Hat.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Hat", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Highlight")
    T("class.new.Highlight", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Highlight") end)
    T("class.name.Highlight", function() return EQ(o.Name, "Highlight") end)
    T("class.tostring.Highlight", function() return EQ(tostring(o), "Highlight") end)
    T("class.parent.Highlight", function() return EQ(o.Parent, nil) end)
    T("class.isa.Highlight.Highlight", function() return EQ(o:IsA("Highlight"), true) end)
    T("class.isa.Highlight.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Highlight", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "HingeConstraint")
    T("class.new.HingeConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "HingeConstraint") end)
    T("class.name.HingeConstraint", function() return EQ(o.Name, "HingeConstraint") end)
    T("class.tostring.HingeConstraint", function() return EQ(tostring(o), "HingeConstraint") end)
    T("class.parent.HingeConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.HingeConstraint.HingeConstraint", function() return EQ(o:IsA("HingeConstraint"), true) end)
    T("class.isa.HingeConstraint.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.HingeConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.HingeConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Hint")
    T("class.new.Hint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Hint") end)
    T("class.name.Hint", function() return EQ(o.Name, "Hint") end)
    T("class.tostring.Hint", function() return EQ(tostring(o), "Hint") end)
    T("class.parent.Hint", function() return EQ(o.Parent, nil) end)
    T("class.isa.Hint.Hint", function() return EQ(o:IsA("Hint"), true) end)
    T("class.isa.Hint.Message", function() return EQ(o:IsA("Message"), true) end)
    T("class.isa.Hint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Hint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Hole")
    T("class.new.Hole", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Hole") end)
    T("class.name.Hole", function() return EQ(o.Name, "Hole") end)
    T("class.tostring.Hole", function() return EQ(tostring(o), "Hole") end)
    T("class.parent.Hole", function() return EQ(o.Parent, nil) end)
    T("class.isa.Hole.Hole", function() return EQ(o:IsA("Hole"), true) end)
    T("class.isa.Hole.Feature", function() return EQ(o:IsA("Feature"), true) end)
    T("class.isa.Hole.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Hole", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "HopperBin")
    T("class.new.HopperBin", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "HopperBin") end)
    T("class.name.HopperBin", function() return EQ(o.Name, "HopperBin") end)
    T("class.tostring.HopperBin", function() return EQ(tostring(o), "HopperBin") end)
    T("class.parent.HopperBin", function() return EQ(o.Parent, nil) end)
    T("class.isa.HopperBin.HopperBin", function() return EQ(o:IsA("HopperBin"), true) end)
    T("class.isa.HopperBin.BackpackItem", function() return EQ(o:IsA("BackpackItem"), true) end)
    T("class.isa.HopperBin.Model", function() return EQ(o:IsA("Model"), true) end)
    T("class.isa.HopperBin.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.HopperBin.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.HopperBin", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.HttpRequest", function() return ERR(function() return Instance.new("HttpRequest") end, "Unable to create an Instance of type \"HttpRequest\"") end)
end
do
    local ok, o = pcall(Instance.new, "Humanoid")
    T("class.new.Humanoid", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Humanoid") end)
    T("class.name.Humanoid", function() return EQ(o.Name, "Humanoid") end)
    T("class.tostring.Humanoid", function() return EQ(tostring(o), "Humanoid") end)
    T("class.parent.Humanoid", function() return EQ(o.Parent, nil) end)
    T("class.isa.Humanoid.Humanoid", function() return EQ(o:IsA("Humanoid"), true) end)
    T("class.isa.Humanoid.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Humanoid", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "HumanoidDescription")
    T("class.new.HumanoidDescription", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "HumanoidDescription") end)
    T("class.name.HumanoidDescription", function() return EQ(o.Name, "HumanoidDescription") end)
    T("class.tostring.HumanoidDescription", function() return EQ(tostring(o), "HumanoidDescription") end)
    T("class.parent.HumanoidDescription", function() return EQ(o.Parent, nil) end)
    T("class.isa.HumanoidDescription.HumanoidDescription", function() return EQ(o:IsA("HumanoidDescription"), true) end)
    T("class.isa.HumanoidDescription.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.HumanoidDescription", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "HumanoidRigDescription")
    T("class.new.HumanoidRigDescription", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "HumanoidRigDescription") end)
    T("class.name.HumanoidRigDescription", function() return EQ(o.Name, "HumanoidRigDescription") end)
    T("class.tostring.HumanoidRigDescription", function() return EQ(tostring(o), "HumanoidRigDescription") end)
    T("class.parent.HumanoidRigDescription", function() return EQ(o.Parent, nil) end)
    T("class.isa.HumanoidRigDescription.HumanoidRigDescription", function() return EQ(o:IsA("HumanoidRigDescription"), true) end)
    T("class.isa.HumanoidRigDescription.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.HumanoidRigDescription", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "IKControl")
    T("class.new.IKControl", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "IKControl") end)
    T("class.name.IKControl", function() return EQ(o.Name, "IKControl") end)
    T("class.tostring.IKControl", function() return EQ(tostring(o), "IKControl") end)
    T("class.parent.IKControl", function() return EQ(o.Parent, nil) end)
    T("class.isa.IKControl.IKControl", function() return EQ(o:IsA("IKControl"), true) end)
    T("class.isa.IKControl.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.IKControl", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ImageButton")
    T("class.new.ImageButton", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ImageButton") end)
    T("class.name.ImageButton", function() return EQ(o.Name, "ImageButton") end)
    T("class.tostring.ImageButton", function() return EQ(tostring(o), "ImageButton") end)
    T("class.parent.ImageButton", function() return EQ(o.Parent, nil) end)
    T("class.isa.ImageButton.ImageButton", function() return EQ(o:IsA("ImageButton"), true) end)
    T("class.isa.ImageButton.GuiButton", function() return EQ(o:IsA("GuiButton"), true) end)
    T("class.isa.ImageButton.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.ImageButton.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.ImageButton.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.ImageButton.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ImageButton", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ImageHandleAdornment")
    T("class.new.ImageHandleAdornment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ImageHandleAdornment") end)
    T("class.name.ImageHandleAdornment", function() return EQ(o.Name, "ImageHandleAdornment") end)
    T("class.tostring.ImageHandleAdornment", function() return EQ(tostring(o), "ImageHandleAdornment") end)
    T("class.parent.ImageHandleAdornment", function() return EQ(o.Parent, nil) end)
    T("class.isa.ImageHandleAdornment.ImageHandleAdornment", function() return EQ(o:IsA("ImageHandleAdornment"), true) end)
    T("class.isa.ImageHandleAdornment.HandleAdornment", function() return EQ(o:IsA("HandleAdornment"), true) end)
    T("class.isa.ImageHandleAdornment.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.ImageHandleAdornment.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.ImageHandleAdornment.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.ImageHandleAdornment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ImageHandleAdornment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ImageLabel")
    T("class.new.ImageLabel", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ImageLabel") end)
    T("class.name.ImageLabel", function() return EQ(o.Name, "ImageLabel") end)
    T("class.tostring.ImageLabel", function() return EQ(tostring(o), "ImageLabel") end)
    T("class.parent.ImageLabel", function() return EQ(o.Parent, nil) end)
    T("class.isa.ImageLabel.ImageLabel", function() return EQ(o:IsA("ImageLabel"), true) end)
    T("class.isa.ImageLabel.GuiLabel", function() return EQ(o:IsA("GuiLabel"), true) end)
    T("class.isa.ImageLabel.GuiObject", function() return EQ(o:IsA("GuiObject"), true) end)
    T("class.isa.ImageLabel.GuiBase2d", function() return EQ(o:IsA("GuiBase2d"), true) end)
    T("class.isa.ImageLabel.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.ImageLabel.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ImageLabel", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ImportSession", function() return ERR(function() return Instance.new("ImportSession") end, "Unable to create an Instance of type \"ImportSession\"") end)
end
do
    local ok, o = pcall(Instance.new, "InputAction")
    T("class.new.InputAction", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "InputAction") end)
    T("class.name.InputAction", function() return EQ(o.Name, "InputAction") end)
    T("class.tostring.InputAction", function() return EQ(tostring(o), "InputAction") end)
    T("class.parent.InputAction", function() return EQ(o.Parent, nil) end)
    T("class.isa.InputAction.InputAction", function() return EQ(o:IsA("InputAction"), true) end)
    T("class.isa.InputAction.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.InputAction", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "InputBinding")
    T("class.new.InputBinding", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "InputBinding") end)
    T("class.name.InputBinding", function() return EQ(o.Name, "InputBinding") end)
    T("class.tostring.InputBinding", function() return EQ(tostring(o), "InputBinding") end)
    T("class.parent.InputBinding", function() return EQ(o.Parent, nil) end)
    T("class.isa.InputBinding.InputBinding", function() return EQ(o:IsA("InputBinding"), true) end)
    T("class.isa.InputBinding.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.InputBinding", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "InputContext")
    T("class.new.InputContext", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "InputContext") end)
    T("class.name.InputContext", function() return EQ(o.Name, "InputContext") end)
    T("class.tostring.InputContext", function() return EQ(tostring(o), "InputContext") end)
    T("class.parent.InputContext", function() return EQ(o.Parent, nil) end)
    T("class.isa.InputContext.InputContext", function() return EQ(o:IsA("InputContext"), true) end)
    T("class.isa.InputContext.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.InputContext", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.InputObject", function() return ERR(function() return Instance.new("InputObject") end, "Unable to create an Instance of type \"InputObject\"") end)
end
do
    T("class.notcreatable.Instance", function() return ERR(function() return Instance.new("Instance") end, "Unable to create an Instance of type \"Instance\"") end)
end
do
    T("class.notcreatable.InstanceAdornment", function() return ERR(function() return Instance.new("InstanceAdornment") end, "Unable to create an Instance of type \"InstanceAdornment\"") end)
end
do
    local ok, o = pcall(Instance.new, "IntConstrainedValue")
    T("class.new.IntConstrainedValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "IntConstrainedValue") end)
    T("class.name.IntConstrainedValue", function() return EQ(o.Name, "IntConstrainedValue") end)
    T("class.tostring.IntConstrainedValue", function() return EQ(tostring(o), "IntConstrainedValue") end)
    T("class.parent.IntConstrainedValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.IntConstrainedValue.IntConstrainedValue", function() return EQ(o:IsA("IntConstrainedValue"), true) end)
    T("class.isa.IntConstrainedValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.IntConstrainedValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.IntConstrainedValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    local ok, o = pcall(Instance.new, "IntValue")
    T("class.new.IntValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "IntValue") end)
    T("class.name.IntValue", function() return EQ(o.Name, "IntValue") end)
    T("class.tostring.IntValue", function() return EQ(tostring(o), "IntValue") end)
    T("class.parent.IntValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.IntValue.IntValue", function() return EQ(o:IsA("IntValue"), true) end)
    T("class.isa.IntValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.IntValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.IntValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    local ok, o = pcall(Instance.new, "IntersectOperation")
    T("class.new.IntersectOperation", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "IntersectOperation") end)
    T("class.name.IntersectOperation", function() return EQ(o.Name, "IntersectOperation") end)
    T("class.tostring.IntersectOperation", function() return EQ(tostring(o), "IntersectOperation") end)
    T("class.parent.IntersectOperation", function() return EQ(o.Parent, nil) end)
    T("class.isa.IntersectOperation.IntersectOperation", function() return EQ(o:IsA("IntersectOperation"), true) end)
    T("class.isa.IntersectOperation.PartOperation", function() return EQ(o:IsA("PartOperation"), true) end)
    T("class.isa.IntersectOperation.TriangleMeshPart", function() return EQ(o:IsA("TriangleMeshPart"), true) end)
    T("class.isa.IntersectOperation.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.IntersectOperation.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.IntersectOperation.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.IntersectOperation", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.InventoryPages", function() return ERR(function() return Instance.new("InventoryPages") end, "Unable to create an Instance of type \"InventoryPages\"") end)
end
do
    T("class.notcreatable.JointImportData", function() return ERR(function() return Instance.new("JointImportData") end, "Unable to create an Instance of type \"JointImportData\"") end)
end
do
    T("class.notcreatable.JointInstance", function() return ERR(function() return Instance.new("JointInstance") end, "Unable to create an Instance of type \"JointInstance\"") end)
end
do
    local ok, o = pcall(Instance.new, "Keyframe")
    T("class.new.Keyframe", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Keyframe") end)
    T("class.name.Keyframe", function() return EQ(o.Name, "Keyframe") end)
    T("class.tostring.Keyframe", function() return EQ(tostring(o), "Keyframe") end)
    T("class.parent.Keyframe", function() return EQ(o.Parent, nil) end)
    T("class.isa.Keyframe.Keyframe", function() return EQ(o:IsA("Keyframe"), true) end)
    T("class.isa.Keyframe.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Keyframe", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "KeyframeMarker")
    T("class.new.KeyframeMarker", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "KeyframeMarker") end)
    T("class.name.KeyframeMarker", function() return EQ(o.Name, "KeyframeMarker") end)
    T("class.tostring.KeyframeMarker", function() return EQ(tostring(o), "KeyframeMarker") end)
    T("class.parent.KeyframeMarker", function() return EQ(o.Parent, nil) end)
    T("class.isa.KeyframeMarker.KeyframeMarker", function() return EQ(o:IsA("KeyframeMarker"), true) end)
    T("class.isa.KeyframeMarker.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.KeyframeMarker", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "KeyframeSequence")
    T("class.new.KeyframeSequence", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "KeyframeSequence") end)
    T("class.name.KeyframeSequence", function() return EQ(o.Name, "KeyframeSequence") end)
    T("class.tostring.KeyframeSequence", function() return EQ(tostring(o), "KeyframeSequence") end)
    T("class.parent.KeyframeSequence", function() return EQ(o.Parent, nil) end)
    T("class.isa.KeyframeSequence.KeyframeSequence", function() return EQ(o:IsA("KeyframeSequence"), true) end)
    T("class.isa.KeyframeSequence.AnimationClip", function() return EQ(o:IsA("AnimationClip"), true) end)
    T("class.isa.KeyframeSequence.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.KeyframeSequence", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.LayerCollector", function() return ERR(function() return Instance.new("LayerCollector") end, "Unable to create an Instance of type \"LayerCollector\"") end)
end
do
    T("class.notcreatable.Light", function() return ERR(function() return Instance.new("Light") end, "Unable to create an Instance of type \"Light\"") end)
end
do
    local ok, o = pcall(Instance.new, "LineForce")
    T("class.new.LineForce", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "LineForce") end)
    T("class.name.LineForce", function() return EQ(o.Name, "LineForce") end)
    T("class.tostring.LineForce", function() return EQ(tostring(o), "LineForce") end)
    T("class.parent.LineForce", function() return EQ(o.Parent, nil) end)
    T("class.isa.LineForce.LineForce", function() return EQ(o:IsA("LineForce"), true) end)
    T("class.isa.LineForce.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.LineForce.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.LineForce", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "LineHandleAdornment")
    T("class.new.LineHandleAdornment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "LineHandleAdornment") end)
    T("class.name.LineHandleAdornment", function() return EQ(o.Name, "LineHandleAdornment") end)
    T("class.tostring.LineHandleAdornment", function() return EQ(tostring(o), "LineHandleAdornment") end)
    T("class.parent.LineHandleAdornment", function() return EQ(o.Parent, nil) end)
    T("class.isa.LineHandleAdornment.LineHandleAdornment", function() return EQ(o:IsA("LineHandleAdornment"), true) end)
    T("class.isa.LineHandleAdornment.HandleAdornment", function() return EQ(o:IsA("HandleAdornment"), true) end)
    T("class.isa.LineHandleAdornment.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.LineHandleAdornment.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.LineHandleAdornment.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.LineHandleAdornment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.LineHandleAdornment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "LinearVelocity")
    T("class.new.LinearVelocity", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "LinearVelocity") end)
    T("class.name.LinearVelocity", function() return EQ(o.Name, "LinearVelocity") end)
    T("class.tostring.LinearVelocity", function() return EQ(tostring(o), "LinearVelocity") end)
    T("class.parent.LinearVelocity", function() return EQ(o.Parent, nil) end)
    T("class.isa.LinearVelocity.LinearVelocity", function() return EQ(o:IsA("LinearVelocity"), true) end)
    T("class.isa.LinearVelocity.Constraint", function() return EQ(o:IsA("Constraint"), true) end)
    T("class.isa.LinearVelocity.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.LinearVelocity", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.LocalDebuggerConnection", function() return ERR(function() return Instance.new("LocalDebuggerConnection") end, "Unable to create an Instance of type \"LocalDebuggerConnection\"") end)
end
do
    local ok, o = pcall(Instance.new, "LocalScript")
    T("class.new.LocalScript", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "LocalScript") end)
    T("class.name.LocalScript", function() return EQ(o.Name, "LocalScript") end)
    T("class.tostring.LocalScript", function() return EQ(tostring(o), "LocalScript") end)
    T("class.parent.LocalScript", function() return EQ(o.Parent, nil) end)
    T("class.isa.LocalScript.LocalScript", function() return EQ(o:IsA("LocalScript"), true) end)
    T("class.isa.LocalScript.Script", function() return EQ(o:IsA("Script"), true) end)
    T("class.isa.LocalScript.BaseScript", function() return EQ(o:IsA("BaseScript"), true) end)
    T("class.isa.LocalScript.LuaSourceContainer", function() return EQ(o:IsA("LuaSourceContainer"), true) end)
    T("class.isa.LocalScript.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.LocalScript", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "LocalizationTable")
    T("class.new.LocalizationTable", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "LocalizationTable") end)
    T("class.name.LocalizationTable", function() return EQ(o.Name, "LocalizationTable") end)
    T("class.tostring.LocalizationTable", function() return EQ(tostring(o), "LocalizationTable") end)
    T("class.parent.LocalizationTable", function() return EQ(o.Parent, nil) end)
    T("class.isa.LocalizationTable.LocalizationTable", function() return EQ(o:IsA("LocalizationTable"), true) end)
    T("class.isa.LocalizationTable.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.LocalizationTable", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.LodDataEntity", function() return ERR(function() return Instance.new("LodDataEntity") end, "Unable to create an Instance of type \"LodDataEntity\"") end)
end
do
    T("class.notcreatable.Logger", function() return ERR(function() return Instance.new("Logger") end, "Unable to create an Instance of type \"Logger\"") end)
end
do
    T("class.notcreatable.LuaSourceContainer", function() return ERR(function() return Instance.new("LuaSourceContainer") end, "Unable to create an Instance of type \"LuaSourceContainer\"") end)
end
do
    T("class.notcreatable.LuauExpression", function() return ERR(function() return Instance.new("LuauExpression") end, "Unable to create an Instance of type \"LuauExpression\"") end)
end
do
    T("class.notcreatable.MLSession", function() return ERR(function() return Instance.new("MLSession") end, "Unable to create an Instance of type \"MLSession\"") end)
end
do
    local ok, o = pcall(Instance.new, "MakeupDescription")
    T("class.new.MakeupDescription", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "MakeupDescription") end)
    T("class.name.MakeupDescription", function() return EQ(o.Name, "MakeupDescription") end)
    T("class.tostring.MakeupDescription", function() return EQ(tostring(o), "MakeupDescription") end)
    T("class.parent.MakeupDescription", function() return EQ(o.Parent, nil) end)
    T("class.isa.MakeupDescription.MakeupDescription", function() return EQ(o:IsA("MakeupDescription"), true) end)
    T("class.isa.MakeupDescription.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.MakeupDescription", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ManualGlue")
    T("class.new.ManualGlue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ManualGlue") end)
    T("class.name.ManualGlue", function() return EQ(o.Name, "ManualGlue") end)
    T("class.tostring.ManualGlue", function() return EQ(tostring(o), "ManualGlue") end)
    T("class.parent.ManualGlue", function() return EQ(o.Parent, nil) end)
    T("class.isa.ManualGlue.ManualGlue", function() return EQ(o:IsA("ManualGlue"), true) end)
    T("class.isa.ManualGlue.ManualSurfaceJointInstance", function() return EQ(o:IsA("ManualSurfaceJointInstance"), true) end)
    T("class.isa.ManualGlue.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.ManualGlue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ManualGlue", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ManualSurfaceJointInstance", function() return ERR(function() return Instance.new("ManualSurfaceJointInstance") end, "Unable to create an Instance of type \"ManualSurfaceJointInstance\"") end)
end
do
    local ok, o = pcall(Instance.new, "ManualWeld")
    T("class.new.ManualWeld", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ManualWeld") end)
    T("class.name.ManualWeld", function() return EQ(o.Name, "ManualWeld") end)
    T("class.tostring.ManualWeld", function() return EQ(tostring(o), "ManualWeld") end)
    T("class.parent.ManualWeld", function() return EQ(o.Parent, nil) end)
    T("class.isa.ManualWeld.ManualWeld", function() return EQ(o:IsA("ManualWeld"), true) end)
    T("class.isa.ManualWeld.ManualSurfaceJointInstance", function() return EQ(o:IsA("ManualSurfaceJointInstance"), true) end)
    T("class.isa.ManualWeld.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.ManualWeld.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ManualWeld", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "MarkerCurve")
    T("class.new.MarkerCurve", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "MarkerCurve") end)
    T("class.name.MarkerCurve", function() return EQ(o.Name, "MarkerCurve") end)
    T("class.tostring.MarkerCurve", function() return EQ(tostring(o), "MarkerCurve") end)
    T("class.parent.MarkerCurve", function() return EQ(o.Parent, nil) end)
    T("class.isa.MarkerCurve.MarkerCurve", function() return EQ(o:IsA("MarkerCurve"), true) end)
    T("class.isa.MarkerCurve.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.MarkerCurve", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.MaterialImportData", function() return ERR(function() return Instance.new("MaterialImportData") end, "Unable to create an Instance of type \"MaterialImportData\"") end)
end
do
    local ok, o = pcall(Instance.new, "MaterialVariant")
    T("class.new.MaterialVariant", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "MaterialVariant") end)
    T("class.name.MaterialVariant", function() return EQ(o.Name, "MaterialVariant") end)
    T("class.tostring.MaterialVariant", function() return EQ(tostring(o), "MaterialVariant") end)
    T("class.parent.MaterialVariant", function() return EQ(o.Parent, nil) end)
    T("class.isa.MaterialVariant.MaterialVariant", function() return EQ(o:IsA("MaterialVariant"), true) end)
    T("class.isa.MaterialVariant.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.MaterialVariant", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.MemStorageConnection", function() return ERR(function() return Instance.new("MemStorageConnection") end, "Unable to create an Instance of type \"MemStorageConnection\"") end)
end
do
    T("class.notcreatable.MemoryStoreDistributedCounter", function() return ERR(function() return Instance.new("MemoryStoreDistributedCounter") end, "Unable to create an Instance of type \"MemoryStoreDistributedCounter\"") end)
end
do
    T("class.notcreatable.MemoryStoreHashMap", function() return ERR(function() return Instance.new("MemoryStoreHashMap") end, "Unable to create an Instance of type \"MemoryStoreHashMap\"") end)
end
do
    T("class.notcreatable.MemoryStoreHashMapPages", function() return ERR(function() return Instance.new("MemoryStoreHashMapPages") end, "Unable to create an Instance of type \"MemoryStoreHashMapPages\"") end)
end
do
    T("class.notcreatable.MemoryStoreQueue", function() return ERR(function() return Instance.new("MemoryStoreQueue") end, "Unable to create an Instance of type \"MemoryStoreQueue\"") end)
end
do
    T("class.notcreatable.MemoryStoreSortedMap", function() return ERR(function() return Instance.new("MemoryStoreSortedMap") end, "Unable to create an Instance of type \"MemoryStoreSortedMap\"") end)
end
do
    T("class.notcreatable.MeshImportData", function() return ERR(function() return Instance.new("MeshImportData") end, "Unable to create an Instance of type \"MeshImportData\"") end)
end
do
    local ok, o = pcall(Instance.new, "MeshPart")
    T("class.new.MeshPart", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "MeshPart") end)
    T("class.name.MeshPart", function() return EQ(o.Name, "MeshPart") end)
    T("class.tostring.MeshPart", function() return EQ(tostring(o), "MeshPart") end)
    T("class.parent.MeshPart", function() return EQ(o.Parent, nil) end)
    T("class.isa.MeshPart.MeshPart", function() return EQ(o:IsA("MeshPart"), true) end)
    T("class.isa.MeshPart.TriangleMeshPart", function() return EQ(o:IsA("TriangleMeshPart"), true) end)
    T("class.isa.MeshPart.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.MeshPart.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.MeshPart.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.MeshPart", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Message")
    T("class.new.Message", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Message") end)
    T("class.name.Message", function() return EQ(o.Name, "Message") end)
    T("class.tostring.Message", function() return EQ(tostring(o), "Message") end)
    T("class.parent.Message", function() return EQ(o.Parent, nil) end)
    T("class.isa.Message.Message", function() return EQ(o:IsA("Message"), true) end)
    T("class.isa.Message.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Message", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.MessageBusConnection", function() return ERR(function() return Instance.new("MessageBusConnection") end, "Unable to create an Instance of type \"MessageBusConnection\"") end)
end
do
    T("class.notcreatable.MetaBreakpoint", function() return ERR(function() return Instance.new("MetaBreakpoint") end, "Unable to create an Instance of type \"MetaBreakpoint\"") end)
end
do
    T("class.notcreatable.MetaBreakpointContext", function() return ERR(function() return Instance.new("MetaBreakpointContext") end, "Unable to create an Instance of type \"MetaBreakpointContext\"") end)
end
do
    local ok, o = pcall(Instance.new, "Model")
    T("class.new.Model", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Model") end)
    T("class.name.Model", function() return EQ(o.Name, "Model") end)
    T("class.tostring.Model", function() return EQ(tostring(o), "Model") end)
    T("class.parent.Model", function() return EQ(o.Parent, nil) end)
    T("class.isa.Model.Model", function() return EQ(o:IsA("Model"), true) end)
    T("class.isa.Model.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.Model.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Model", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ModuleScript")
    T("class.new.ModuleScript", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ModuleScript") end)
    T("class.name.ModuleScript", function() return EQ(o.Name, "ModuleScript") end)
    T("class.tostring.ModuleScript", function() return EQ(tostring(o), "ModuleScript") end)
    T("class.parent.ModuleScript", function() return EQ(o.Parent, nil) end)
    T("class.isa.ModuleScript.ModuleScript", function() return EQ(o:IsA("ModuleScript"), true) end)
    T("class.isa.ModuleScript.LuaSourceContainer", function() return EQ(o:IsA("LuaSourceContainer"), true) end)
    T("class.isa.ModuleScript.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ModuleScript", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Motor")
    T("class.new.Motor", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Motor") end)
    T("class.name.Motor", function() return EQ(o.Name, "Motor") end)
    T("class.tostring.Motor", function() return EQ(tostring(o), "Motor") end)
    T("class.parent.Motor", function() return EQ(o.Parent, nil) end)
    T("class.isa.Motor.Motor", function() return EQ(o:IsA("Motor"), true) end)
    T("class.isa.Motor.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.Motor.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Motor", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Motor6D")
    T("class.new.Motor6D", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Motor6D") end)
    T("class.name.Motor6D", function() return EQ(o.Name, "Motor6D") end)
    T("class.tostring.Motor6D", function() return EQ(tostring(o), "Motor6D") end)
    T("class.parent.Motor6D", function() return EQ(o.Parent, nil) end)
    T("class.isa.Motor6D.Motor6D", function() return EQ(o:IsA("Motor6D"), true) end)
    T("class.isa.Motor6D.Motor", function() return EQ(o:IsA("Motor"), true) end)
    T("class.isa.Motor6D.JointInstance", function() return EQ(o:IsA("JointInstance"), true) end)
    T("class.isa.Motor6D.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Motor6D", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.Mouse", function() return ERR(function() return Instance.new("Mouse") end, "Unable to create an Instance of type \"Mouse\"") end)
end
do
    T("class.notcreatable.MultipleDocumentInterfaceInstance", function() return ERR(function() return Instance.new("MultipleDocumentInterfaceInstance") end, "Unable to create an Instance of type \"MultipleDocumentInterfaceInstance\"") end)
end
do
    local ok, o = pcall(Instance.new, "NegateOperation")
    T("class.new.NegateOperation", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "NegateOperation") end)
    T("class.name.NegateOperation", function() return EQ(o.Name, "NegateOperation") end)
    T("class.tostring.NegateOperation", function() return EQ(tostring(o), "NegateOperation") end)
    T("class.parent.NegateOperation", function() return EQ(o.Parent, nil) end)
    T("class.isa.NegateOperation.NegateOperation", function() return EQ(o:IsA("NegateOperation"), true) end)
    T("class.isa.NegateOperation.PartOperation", function() return EQ(o:IsA("PartOperation"), true) end)
    T("class.isa.NegateOperation.TriangleMeshPart", function() return EQ(o:IsA("TriangleMeshPart"), true) end)
    T("class.isa.NegateOperation.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.NegateOperation.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.NegateOperation.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.NegateOperation", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.NetworkMarker", function() return ERR(function() return Instance.new("NetworkMarker") end, "Unable to create an Instance of type \"NetworkMarker\"") end)
end
do
    T("class.notcreatable.NetworkPeer", function() return ERR(function() return Instance.new("NetworkPeer") end, "Unable to create an Instance of type \"NetworkPeer\"") end)
end
do
    T("class.notcreatable.NetworkReplicator", function() return ERR(function() return Instance.new("NetworkReplicator") end, "Unable to create an Instance of type \"NetworkReplicator\"") end)
end
do
    local ok, o = pcall(Instance.new, "NoCollisionConstraint")
    T("class.new.NoCollisionConstraint", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "NoCollisionConstraint") end)
    T("class.name.NoCollisionConstraint", function() return EQ(o.Name, "NoCollisionConstraint") end)
    T("class.tostring.NoCollisionConstraint", function() return EQ(tostring(o), "NoCollisionConstraint") end)
    T("class.parent.NoCollisionConstraint", function() return EQ(o.Parent, nil) end)
    T("class.isa.NoCollisionConstraint.NoCollisionConstraint", function() return EQ(o:IsA("NoCollisionConstraint"), true) end)
    T("class.isa.NoCollisionConstraint.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.NoCollisionConstraint", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "NumberPose")
    T("class.new.NumberPose", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "NumberPose") end)
    T("class.name.NumberPose", function() return EQ(o.Name, "NumberPose") end)
    T("class.tostring.NumberPose", function() return EQ(tostring(o), "NumberPose") end)
    T("class.parent.NumberPose", function() return EQ(o.Parent, nil) end)
    T("class.isa.NumberPose.NumberPose", function() return EQ(o:IsA("NumberPose"), true) end)
    T("class.isa.NumberPose.PoseBase", function() return EQ(o:IsA("PoseBase"), true) end)
    T("class.isa.NumberPose.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.NumberPose", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "NumberValue")
    T("class.new.NumberValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "NumberValue") end)
    T("class.name.NumberValue", function() return EQ(o.Name, "NumberValue") end)
    T("class.tostring.NumberValue", function() return EQ(tostring(o), "NumberValue") end)
    T("class.parent.NumberValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.NumberValue.NumberValue", function() return EQ(o:IsA("NumberValue"), true) end)
    T("class.isa.NumberValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.NumberValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.NumberValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    T("class.notcreatable.Object", function() return ERR(function() return Instance.new("Object") end, "Unable to create an Instance of type \"Object\"") end)
end
do
    local ok, o = pcall(Instance.new, "ObjectValue")
    T("class.new.ObjectValue", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ObjectValue") end)
    T("class.name.ObjectValue", function() return EQ(o.Name, "ObjectValue") end)
    T("class.tostring.ObjectValue", function() return EQ(tostring(o), "ObjectValue") end)
    T("class.parent.ObjectValue", function() return EQ(o.Parent, nil) end)
    T("class.isa.ObjectValue.ObjectValue", function() return EQ(o:IsA("ObjectValue"), true) end)
    T("class.isa.ObjectValue.ValueBase", function() return EQ(o:IsA("ValueBase"), true) end)
    T("class.isa.ObjectValue.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ObjectValue", function() return EQ(o:IsA("ValueBase") == (true), true) end)
end
do
    T("class.notcreatable.OpenCloudApiV1", function() return ERR(function() return Instance.new("OpenCloudApiV1") end, "Unable to create an Instance of type \"OpenCloudApiV1\"") end)
end
do
    T("class.notcreatable.OrderedDataStore", function() return ERR(function() return Instance.new("OrderedDataStore") end, "Unable to create an Instance of type \"OrderedDataStore\"") end)
end
do
    T("class.notcreatable.OutfitPages", function() return ERR(function() return Instance.new("OutfitPages") end, "Unable to create an Instance of type \"OutfitPages\"") end)
end
do
    T("class.notcreatable.OutputLink", function() return ERR(function() return Instance.new("OutputLink") end, "Unable to create an Instance of type \"OutputLink\"") end)
end
do
    T("class.notcreatable.PVAdornment", function() return ERR(function() return Instance.new("PVAdornment") end, "Unable to create an Instance of type \"PVAdornment\"") end)
end
do
    T("class.notcreatable.PVInstance", function() return ERR(function() return Instance.new("PVInstance") end, "Unable to create an Instance of type \"PVInstance\"") end)
end
do
    T("class.notcreatable.PackageLink", function() return ERR(function() return Instance.new("PackageLink") end, "Unable to create an Instance of type \"PackageLink\"") end)
end
do
    T("class.notcreatable.Pages", function() return ERR(function() return Instance.new("Pages") end, "Unable to create an Instance of type \"Pages\"") end)
end
do
    local ok, o = pcall(Instance.new, "Pants")
    T("class.new.Pants", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Pants") end)
    T("class.name.Pants", function() return EQ(o.Name, "Pants") end)
    T("class.tostring.Pants", function() return EQ(tostring(o), "Pants") end)
    T("class.parent.Pants", function() return EQ(o.Parent, nil) end)
    T("class.isa.Pants.Pants", function() return EQ(o:IsA("Pants"), true) end)
    T("class.isa.Pants.Clothing", function() return EQ(o:IsA("Clothing"), true) end)
    T("class.isa.Pants.CharacterAppearance", function() return EQ(o:IsA("CharacterAppearance"), true) end)
    T("class.isa.Pants.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Pants", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "ParabolaAdornment")
    T("class.new.ParabolaAdornment", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ParabolaAdornment") end)
    T("class.name.ParabolaAdornment", function() return EQ(o.Name, "ParabolaAdornment") end)
    T("class.tostring.ParabolaAdornment", function() return EQ(tostring(o), "ParabolaAdornment") end)
    T("class.parent.ParabolaAdornment", function() return EQ(o.Parent, nil) end)
    T("class.isa.ParabolaAdornment.ParabolaAdornment", function() return EQ(o:IsA("ParabolaAdornment"), true) end)
    T("class.isa.ParabolaAdornment.PVAdornment", function() return EQ(o:IsA("PVAdornment"), true) end)
    T("class.isa.ParabolaAdornment.GuiBase3d", function() return EQ(o:IsA("GuiBase3d"), true) end)
    T("class.isa.ParabolaAdornment.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.ParabolaAdornment.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ParabolaAdornment", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    local ok, o = pcall(Instance.new, "Part")
    T("class.new.Part", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Part") end)
    T("class.name.Part", function() return EQ(o.Name, "Part") end)
    T("class.tostring.Part", function() return EQ(tostring(o), "Part") end)
    T("class.parent.Part", function() return EQ(o.Parent, nil) end)
    T("class.isa.Part.Part", function() return EQ(o:IsA("Part"), true) end)
    T("class.isa.Part.FormFactorPart", function() return EQ(o:IsA("FormFactorPart"), true) end)
    T("class.isa.Part.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.Part.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.Part.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Part", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.PartAdornment", function() return ERR(function() return Instance.new("PartAdornment") end, "Unable to create an Instance of type \"PartAdornment\"") end)
end
do
    local ok, o = pcall(Instance.new, "PartOperation")
    T("class.new.PartOperation", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "PartOperation") end)
    T("class.name.PartOperation", function() return EQ(o.Name, "PartOperation") end)
    T("class.tostring.PartOperation", function() return EQ(tostring(o), "PartOperation") end)
    T("class.parent.PartOperation", function() return EQ(o.Parent, nil) end)
    T("class.isa.PartOperation.PartOperation", function() return EQ(o:IsA("PartOperation"), true) end)
    T("class.isa.PartOperation.TriangleMeshPart", function() return EQ(o:IsA("TriangleMeshPart"), true) end)
    T("class.isa.PartOperation.BasePart", function() return EQ(o:IsA("BasePart"), true) end)
    T("class.isa.PartOperation.PVInstance", function() return EQ(o:IsA("PVInstance"), true) end)
    T("class.isa.PartOperation.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.PartOperation", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.ParticipantHandle", function() return ERR(function() return Instance.new("ParticipantHandle") end, "Unable to create an Instance of type \"ParticipantHandle\"") end)
end
do
    local ok, o = pcall(Instance.new, "ParticleEmitter")
    T("class.new.ParticleEmitter", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "ParticleEmitter") end)
    T("class.name.ParticleEmitter", function() return EQ(o.Name, "ParticleEmitter") end)
    T("class.tostring.ParticleEmitter", function() return EQ(tostring(o), "ParticleEmitter") end)
    T("class.parent.ParticleEmitter", function() return EQ(o.Parent, nil) end)
    T("class.isa.ParticleEmitter.ParticleEmitter", function() return EQ(o:IsA("ParticleEmitter"), true) end)
    T("class.isa.ParticleEmitter.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.ParticleEmitter", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
do
    T("class.notcreatable.PatchMapping", function() return ERR(function() return Instance.new("PatchMapping") end, "Unable to create an Instance of type \"PatchMapping\"") end)
end
do
    T("class.notcreatable.Path", function() return ERR(function() return Instance.new("Path") end, "Unable to create an Instance of type \"Path\"") end)
end
do
    local ok, o = pcall(Instance.new, "Path2D")
    T("class.new.Path2D", function() A(EQ(ok, true)); A(TY(o, "Instance")); return EQ(o.ClassName, "Path2D") end)
    T("class.name.Path2D", function() return EQ(o.Name, "Path2D") end)
    T("class.tostring.Path2D", function() return EQ(tostring(o), "Path2D") end)
    T("class.parent.Path2D", function() return EQ(o.Parent, nil) end)
    T("class.isa.Path2D.Path2D", function() return EQ(o:IsA("Path2D"), true) end)
    T("class.isa.Path2D.GuiBase", function() return EQ(o:IsA("GuiBase"), true) end)
    T("class.isa.Path2D.Instance", function() return EQ(o:IsA("Instance"), true) end)
    T("class.isa_not.Path2D", function() return EQ(o:IsA("ValueBase") == (false), true) end)
end
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
