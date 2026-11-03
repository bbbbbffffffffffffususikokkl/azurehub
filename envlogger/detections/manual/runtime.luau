-- Roblox runtime environment: globals, scheduler, services, cross-object consistency.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- globals
local globalTypes = {
    game = "Instance", workspace = "Instance", Workspace = "Instance", Game = "Instance", Enum = "Enums",
    Instance = "table", Vector3 = "table", CFrame = "table", task = "table", shared = "table", _G = "table",
    wait = "function", delay = "function", spawn = "function", tick = "function", time = "function",
    elapsedTime = "function", version = "function", settings = "function", UserSettings = "function",
    stats = "function", require = "function", warn = "function", typeof = "function", printidentity = "function",
    Wait = "function", Delay = "function", Spawn = "function", Version = "function", ElapsedTime = "function",
    utf8 = "table", buffer = "table", bit32 = "table", debug = "table", coroutine = "table", Random = "table",
    DateTime = "table", SharedTable = "table", TweenInfo = "table", Ray = "table", Region3 = "table",
    UDim2 = "table", Color3 = "table", BrickColor = "table", NumberSequence = "table", Font = "table",
}
for name, ty in pairs(globalTypes) do
    T("global.type." .. name, function() return TY(getfenv(0)[name], ty) end)
end
T("global.plugin_nil", function() return EQ(plugin, nil) end)
T("global.game_alias", function() return EQ(Game, game) end)
T("global.workspace_alias", function() A(EQ(Workspace, workspace)); return EQ(game.Workspace, workspace) end)
T("global.workspace_service", function() return EQ(game:GetService("Workspace"), workspace) end)
T("global.shared_not_G", function() return EQ(rawequal(shared, _G), false) end)
T("global.G_not_env", function() return EQ(rawequal(_G, getfenv(0)), false) end)
T("global.version_format", function() return EQ(version():match("^%d+%.%d+%.%d+%.%d+$") ~= nil, true) end)
T("global.version_alias", function() return EQ(Version(), version()) end)
T("global.stats_service", function() return EQ(stats(), game:GetService("Stats")) end)
T("global.settings_class", function() return EQ(settings().ClassName, "GlobalSettings") end)
T("global.usersettings_class", function() return EQ(UserSettings().ClassName, "UserSettings") end)
T("global.usersettings_gamesettings", function() return EQ(UserSettings():GetService("UserGameSettings").ClassName, "UserGameSettings") end)
T("global.typeof_frozen_string", function() return EQ(table.isfrozen(string), true) end)
T("global.require_bad", function() return ERR(function() return require("not a module") end) end)
T("global.require_part", function() return ERR(function() return require(Instance.new("Part")) end) end)

-- clocks
T("time.tick_close_to_os_time", function() return EQ(math.abs(tick() - os.time()) < 5, true) end)
T("time.tick_fraction", function() return EQ(type(tick()), "number") end)
T("time.time_nonneg", function() return EQ(time() >= 0, true) end)
T("time.elapsed_nonneg", function() return EQ(elapsedTime() >= 0, true) end)
T("time.os_clock_advances", function() local a = os.clock(); task.wait(0.05); return EQ(os.clock() - a >= 0.04, true) end)
T("time.server_time_now", function() return EQ(math.abs(workspace:GetServerTimeNow() - os.time()) < 60, true) end)
T("time.datetime_now", function() return EQ(math.abs(DateTime.now().UnixTimestamp - os.time()) < 5, true) end)

-- task library
T("task.wait_returns_elapsed", function() local dt = task.wait(); return EQ(type(dt) == "number" and dt > 0, true) end)
T("task.wait_duration", function() local dt = task.wait(0.1); return EQ(dt >= 0.1, true) end)
T("task.spawn_immediate", function() local ran = false; task.spawn(function() ran = true end); return EQ(ran, true) end)
T("task.spawn_returns_thread", function() return TY(task.spawn(function() end), "thread") end)
T("task.spawn_args", function() local got; task.spawn(function(a, b) got = a + b end, 2, 3); return EQ(got, 5) end)
T("task.spawn_thread", function()
    local co = coroutine.create(function(x) return x end)
    task.spawn(co, 1)
    return EQ(coroutine.status(co), "dead")
end)
T("task.defer_later", function()
    local ran = false; task.defer(function() ran = true end)
    local before = ran; task.wait()
    return EQ(before == false and ran == true, true)
end)
T("task.delay_later", function()
    local ran = false; task.delay(0.05, function() ran = true end)
    local before = ran; task.wait(0.15)
    return EQ(before == false and ran == true, true)
end)
T("task.cancel", function()
    local ran = false; local th = task.delay(0.05, function() ran = true end)
    task.cancel(th); task.wait(0.15)
    return EQ(ran, false)
end)
T("task.cancel_status", function()
    local th = task.delay(1, function() end); task.cancel(th); return EQ(coroutine.status(th), "dead")
end)
T("task.wait_in_spawn", function()
    local steps = {}
    task.spawn(function() steps[#steps + 1] = "a"; task.wait(); steps[#steps + 1] = "c" end)
    steps[#steps + 1] = "b"; task.wait(); task.wait()
    return EQ(table.concat(steps), "abc")
end)
T("task.spawn_error_isolated", function()
    task.spawn(function() error("isolated") end)
    return true
end)
T("task.desynchronize_outside_actor", function() return ERR(function() task.desynchronize() end) end)
T("task.bad_arg", function() return ERR(function() task.spawn(42) end) end)
T("task.frozen", function() return EQ(table.isfrozen(task), true) end)
T("legacy.wait_two_values", function() local a, b = wait(); return EQ(type(a) == "number" and type(b) == "number", true) end)
T("legacy.wait_duration", function() local a = wait(0.05); return EQ(a >= 0.05, true) end)
T("legacy.spawn_deferred", function()
    local ran = false; spawn(function() ran = true end)
    local before = ran; wait(0.1)
    return EQ(before == false and ran == true, true)
end)
T("legacy.delay", function() local ran = false; delay(0, function() ran = true end); wait(0.1); return EQ(ran, true) end)

-- RunService
T("runservice.is_client", function() return EQ(RunService:IsClient(), true) end)
T("runservice.is_server", function() return EQ(RunService:IsServer(), false) end)
T("runservice.is_studio", function() return EQ(RunService:IsStudio(), false) end)
T("runservice.heartbeat_wait", function() local dt = RunService.Heartbeat:Wait(); return EQ(type(dt) == "number" and dt > 0, true) end)
T("runservice.renderstepped_wait", function() local dt = RunService.RenderStepped:Wait(); return EQ(type(dt) == "number" and dt > 0, true) end)
T("runservice.stepped_wait", function() local t, dt = RunService.Stepped:Wait(); return EQ(type(t) == "number" and type(dt) == "number", true) end)
T("runservice.heartbeat_connect", function()
    local n = 0
    local c = RunService.Heartbeat:Connect(function() n += 1 end)
    task.wait(0.1); c:Disconnect()
    return EQ(n >= 1, true)
end)
T("runservice.bind_render", function()
    local n = 0
    RunService:BindToRenderStep("detect_zq", 1, function() n += 1 end)
    task.wait(0.1); RunService:UnbindFromRenderStep("detect_zq")
    return EQ(n >= 1, true)
end)

-- local player consistency
local lp = Players.LocalPlayer
T("player.local_exists", function() A(TY(lp, "Instance")); return EQ(lp.ClassName, "Player") end)
T("player.parent", function() return EQ(lp.Parent, Players) end)
T("player.userid", function() return EQ(type(lp.UserId) == "number" and lp.UserId > 0 and lp.UserId % 1 == 0, true) end)
T("player.name_string", function() return EQ(type(lp.Name) == "string" and #lp.Name >= 3, true) end)
T("player.displayname_string", function() return TY(lp.DisplayName, "string") end)
T("player.in_getplayers", function()
    for _, p in ipairs(Players:GetPlayers()) do if p == lp then return true end end
    return false, "LocalPlayer missing from GetPlayers()"
end)
T("player.by_userid", function() return EQ(Players:GetPlayerByUserId(lp.UserId), lp) end)
T("player.find_by_name", function() return EQ(Players:FindFirstChild(lp.Name), lp) end)
T("player.service_isa", function() return EQ(lp:IsA("Player"), true) end)
T("player.full_name", function() return EQ(lp:GetFullName(), "Players." .. lp.Name) end)
T("player.tostring", function() return EQ(tostring(lp), lp.Name) end)
T("player.mouse", function() local m = lp:GetMouse(); A(TY(m, "Instance")); return EQ(m:IsA("Mouse"), true) end)
T("player.playergui", function() local g = lp:FindFirstChildOfClass("PlayerGui"); A(TY(g, "Instance")); return EQ(g.ClassName, "PlayerGui") end)
T("player.backpack", function() local b = lp:FindFirstChildOfClass("Backpack"); return EQ(b and b.ClassName, "Backpack") end)
T("player.account_age", function() return EQ(type(lp.AccountAge) == "number" and lp.AccountAge >= 0, true) end)
T("player.userid_readonly", function() return ERR(function() lp.UserId = 1 end) end)
T("player.max_players", function() return EQ(type(Players.MaxPlayers) == "number" and Players.MaxPlayers >= 1, true) end)
T("player.character_model", function()
    local c = lp.Character
    if c == nil then return true end
    A(EQ(c.ClassName, "Model")); return EQ(Players:GetPlayerFromCharacter(c), lp)
end)
T("game.is_loaded", function() return EQ(game:IsLoaded(), true) end)
T("game.place_id", function() return EQ(type(game.PlaceId) == "number" and game.PlaceId % 1 == 0, true) end)
T("game.job_id", function() return TY(game.JobId, "string") end)
T("game.creator_type", function() local t = game.CreatorType; return EQ(t == Enum.CreatorType.User or t == Enum.CreatorType.Group, true) end)

-- HttpService
T("http.json_encode_array", function() return EQ(HttpService:JSONEncode({1, 2, 3}), "[1,2,3]") end)
T("http.json_encode_empty", function() return EQ(HttpService:JSONEncode({}), "[]") end)
T("http.json_encode_object", function() return EQ(HttpService:JSONEncode({a = 1}), '{"a":1}') end)
T("http.json_encode_string", function() return EQ(HttpService:JSONEncode({"x\"y"}), '["x\\"y"]') end)
T("http.json_encode_bool", function() return EQ(HttpService:JSONEncode({true, false}), "[true,false]") end)
T("http.json_encode_nested", function() return EQ(HttpService:JSONEncode({a = {1}}), '{"a":[1]}') end)
T("http.json_encode_array_priority", function() return EQ(HttpService:JSONEncode({1, 2, x = 3}), "[1,2]") end)
T("http.json_encode_cycle", function() local t = {}; t[1] = t; return ERR(function() return HttpService:JSONEncode(t) end) end)
T("http.json_encode_function", function() return ERR(function() return HttpService:JSONEncode({print}) end) end)
T("http.json_decode_object", function() local t = HttpService:JSONDecode('{"a":[1,2,{"b":true}]}'); return EQ(t.a[3].b, true) end)
T("http.json_decode_number", function() return EQ(HttpService:JSONDecode("[1.5]")[1], 1.5) end)
T("http.json_decode_null", function() local t = HttpService:JSONDecode('{"a":null,"b":1}'); return EQ(t.a == nil and t.b == 1, true) end)
T("http.json_decode_bad", function() return ERR(function() return HttpService:JSONDecode("{bad json") end) end)
T("http.json_roundtrip", function()
    local src = {name = "x", list = {1, 2, 3}, flag = false}
    local back = HttpService:JSONDecode(HttpService:JSONEncode(src))
    return EQ(back.name == "x" and #back.list == 3 and back.flag == false, true)
end)
T("http.guid_braces", function()
    local g = HttpService:GenerateGUID()
    return EQ(#g == 38 and g:sub(1, 1) == "{" and g:sub(-1) == "}", true)
end)
T("http.guid_plain", function() return EQ(#HttpService:GenerateGUID(false), 36) end)
T("http.guid_v4", function()
    local g = HttpService:GenerateGUID(false)
    return EQ(g:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-4%x%x%x%-[89abAB]%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil, true)
end)
T("http.guid_unique", function() return EQ(HttpService:GenerateGUID() ~= HttpService:GenerateGUID(), true) end)
T("http.urlencode_doc_example", function()
    return EQ(HttpService:UrlEncode("https://www.roblox.com/discover#/"), "https%3A%2F%2Fwww%2Eroblox%2Ecom%2Fdiscover%23%2F")
end)
T("http.urlencode_space", function() return EQ(HttpService:UrlEncode("a b"), "a%20b") end)
T("http.urlencode_utf8", function() return EQ(HttpService:UrlEncode("é"), "%C3%A9") end)
T("http.urlencode_alnum", function() return EQ(HttpService:UrlEncode("abcXYZ019"), "abcXYZ019") end)

-- TweenService easing (standard polynomial / sine / circular curves)
local function easeIn(style, t)
    if style == "Linear" then return t
    elseif style == "Quad" then return t ^ 2
    elseif style == "Cubic" then return t ^ 3
    elseif style == "Quart" then return t ^ 4
    elseif style == "Quint" then return t ^ 5
    elseif style == "Sine" then return 1 - math.cos(t * math.pi / 2)
    elseif style == "Circular" then return 1 - math.sqrt(1 - t * t) end
end
local function ease(style, dir, t)
    if dir == "In" then return easeIn(style, t) end
    if dir == "Out" then return 1 - easeIn(style, 1 - t) end
    if t < 0.5 then return easeIn(style, 2 * t) / 2 end
    return 1 - easeIn(style, 2 - 2 * t) / 2
end
for _, style in ipairs({"Linear", "Quad", "Cubic", "Quart", "Quint", "Sine", "Circular"}) do
    for _, dir in ipairs({"In", "Out", "InOut"}) do
        for _, t in ipairs({0, 0.25, 0.5, 0.75, 1}) do
            T(("tween.getvalue.%s.%s.%s"):format(style, dir, t), function()
                return NEAR(TweenService:GetValue(t, Enum.EasingStyle[style], Enum.EasingDirection[dir]), ease(style, dir, t), 1e-5)
            end)
        end
    end
end
T("tween.create_type", function()
    local tw = TweenService:Create(Instance.new("Part"), TweenInfo.new(0.1), {Transparency = 1})
    A(TY(tw, "Instance")); return EQ(tw.ClassName, "Tween")
end)
T("tween.initial_state", function()
    local tw = TweenService:Create(Instance.new("Part"), TweenInfo.new(0.1), {Transparency = 1})
    return EQ(tw.PlaybackState, Enum.PlaybackState.Begin)
end)
T("tween.completes", function()
    local p = Instance.new("Part")
    local tw = TweenService:Create(p, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Transparency = 1})
    tw:Play(); task.wait(0.3)
    A(EQ(tw.PlaybackState, Enum.PlaybackState.Completed)); return EQ(p.Transparency, 1)
end)
T("tween.completed_event", function()
    local tw = TweenService:Create(Instance.new("Part"), TweenInfo.new(0.05), {Transparency = 1})
    local state
    tw.Completed:Connect(function(s) state = s end)
    tw:Play(); task.wait(0.3)
    return EQ(state, Enum.PlaybackState.Completed)
end)
T("tween.bad_property", function()
    return ERR(function() TweenService:Create(Instance.new("Part"), TweenInfo.new(1), {NotAProperty_zq = 1}) end)
end)
T("tween.bad_value_type", function()
    return ERR(function() TweenService:Create(Instance.new("Part"), TweenInfo.new(1), {Transparency = "x"}) end)
end)

-- Lighting time consistency
T("lighting.clock_to_timeofday", function()
    local L = game:GetService("Lighting"); local old = L.ClockTime
    L.ClockTime = 6.5
    local s = L.TimeOfDay
    L.ClockTime = old
    return EQ(s, "06:30:00")
end)
T("lighting.timeofday_to_clock", function()
    local L = game:GetService("Lighting"); local old = L.TimeOfDay
    L.TimeOfDay = "13:15:00"
    local c = L.ClockTime
    L.TimeOfDay = old
    return NEAR(c, 13.25, 1e-5)
end)
T("lighting.minutes_after_midnight", function()
    local L = game:GetService("Lighting")
    return NEAR(L:GetMinutesAfterMidnight(), L.ClockTime * 60, 1e-3)
end)

-- input / gui state on a fresh client
local UIS = game:GetService("UserInputService")
T("uis.key_not_down", function() return EQ(UIS:IsKeyDown(Enum.KeyCode.Q), false) end)
T("uis.keys_pressed", function() return TY(UIS:GetKeysPressed(), "table") end)
T("uis.mouse_location", function() return TY(UIS:GetMouseLocation(), "Vector2") end)
T("uis.focused_textbox", function() return EQ(UIS:GetFocusedTextBox(), nil) end)
T("uis.flags", function() return EQ(type(UIS.TouchEnabled) == "boolean" and type(UIS.KeyboardEnabled) == "boolean", true) end)

-- Debris / CollectionService / misc services
T("debris.additem", function()
    local p = Instance.new("Part"); p.Parent = workspace
    game:GetService("Debris"):AddItem(p, 0.05)
    task.wait(0.3)
    return EQ(p.Parent, nil)
end)
T("textservice.size", function()
    local v = game:GetService("TextService"):GetTextSize("Hello", 14, Enum.Font.SourceSans, Vector2.new(1000, 1000))
    A(TY(v, "Vector2")); return EQ(v.X > 0 and v.Y > 0, true)
end)
T("localization.locale", function() return TY(game:GetService("LocalizationService").RobloxLocaleId, "string") end)
T("workspace.raycast_empty", function()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {}
    return EQ(workspace:Raycast(Vector3.new(0, 1e6, 0), Vector3.new(0, 10, 0), params), nil)
end)
T("workspace.raycast_hit", function()
    local p = Instance.new("Part"); p.Anchored = true; p.Size = Vector3.new(10, 1, 10); p.Position = Vector3.new(0, 5000, 0); p.Parent = workspace
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Include; params.FilterDescendantsInstances = {p}
    local r = workspace:Raycast(Vector3.new(0, 5010, 0), Vector3.new(0, -20, 0), params)
    p:Destroy()
    A(TY(r, "RaycastResult")); A(EQ(r.Instance, p)); return NEAR(r.Position.Y, 5000.5, 1e-3)
end)
