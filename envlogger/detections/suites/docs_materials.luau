-- envlogger detection harness (prepended to every suite by tools/build_suites.py)
-- Every check is isolated in pcall: a check passes only when its function returns exactly `true`.
-- Result protocol (one print per line, parsed by tools/run_detections.py):
--   @@B|<suite>                         suite started
--   @@F|<check id>|<detail>             a failed check
--   @@E|<suite>|<total>|<pass>|<fail>   suite finished
-- The suites are plain Luau, so they can also be pasted into a real executor to confirm the
-- expectations against a live Roblox client.
local __suite = "docs_materials"
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
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Asphalt)
    T("physprops.Asphalt.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Asphalt.Density", function() return NEAR(pp.Density, 2.36, 1e-6) end)
    T("physprops.Asphalt.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.Asphalt.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Asphalt.Friction", function() return NEAR(pp.Friction, 0.8, 1e-6) end)
    T("physprops.Asphalt.FrictionWeight", function() return NEAR(pp.FrictionWeight, 0.3, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Basalt)
    T("physprops.Basalt.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Basalt.Density", function() return NEAR(pp.Density, 2.691, 1e-6) end)
    T("physprops.Basalt.Elasticity", function() return NEAR(pp.Elasticity, 0.15, 1e-6) end)
    T("physprops.Basalt.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Basalt.Friction", function() return NEAR(pp.Friction, 0.7, 1e-6) end)
    T("physprops.Basalt.FrictionWeight", function() return NEAR(pp.FrictionWeight, 0.3, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Brick)
    T("physprops.Brick.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Brick.Density", function() return NEAR(pp.Density, 1.922, 1e-6) end)
    T("physprops.Brick.Elasticity", function() return NEAR(pp.Elasticity, 0.15, 1e-6) end)
    T("physprops.Brick.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Brick.Friction", function() return NEAR(pp.Friction, 0.8, 1e-6) end)
    T("physprops.Brick.FrictionWeight", function() return NEAR(pp.FrictionWeight, 0.3, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Cardboard)
    T("physprops.Cardboard.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Cardboard.Density", function() return NEAR(pp.Density, 0.7, 1e-6) end)
    T("physprops.Cardboard.Elasticity", function() return NEAR(pp.Elasticity, 0.05, 1e-6) end)
    T("physprops.Cardboard.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 2.0, 1e-6) end)
    T("physprops.Cardboard.Friction", function() return NEAR(pp.Friction, 0.5, 1e-6) end)
    T("physprops.Cardboard.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Carpet)
    T("physprops.Carpet.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Carpet.Density", function() return NEAR(pp.Density, 1.1, 1e-6) end)
    T("physprops.Carpet.Elasticity", function() return NEAR(pp.Elasticity, 0.25, 1e-6) end)
    T("physprops.Carpet.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 2.0, 1e-6) end)
    T("physprops.Carpet.Friction", function() return NEAR(pp.Friction, 0.4, 1e-6) end)
    T("physprops.Carpet.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.CeramicTiles)
    T("physprops.CeramicTiles.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.CeramicTiles.Density", function() return NEAR(pp.Density, 2.4, 1e-6) end)
    T("physprops.CeramicTiles.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.CeramicTiles.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.CeramicTiles.Friction", function() return NEAR(pp.Friction, 0.51, 1e-6) end)
    T("physprops.CeramicTiles.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.ClayRoofTiles)
    T("physprops.ClayRoofTiles.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.ClayRoofTiles.Density", function() return NEAR(pp.Density, 2.0, 1e-6) end)
    T("physprops.ClayRoofTiles.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.ClayRoofTiles.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.ClayRoofTiles.Friction", function() return NEAR(pp.Friction, 0.51, 1e-6) end)
    T("physprops.ClayRoofTiles.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Cobblestone)
    T("physprops.Cobblestone.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Cobblestone.Density", function() return NEAR(pp.Density, 2.691, 1e-6) end)
    T("physprops.Cobblestone.Elasticity", function() return NEAR(pp.Elasticity, 0.17, 1e-6) end)
    T("physprops.Cobblestone.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Cobblestone.Friction", function() return NEAR(pp.Friction, 0.5, 1e-6) end)
    T("physprops.Cobblestone.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Concrete)
    T("physprops.Concrete.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Concrete.Density", function() return NEAR(pp.Density, 2.403, 1e-6) end)
    T("physprops.Concrete.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.Concrete.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Concrete.Friction", function() return NEAR(pp.Friction, 0.7, 1e-6) end)
    T("physprops.Concrete.FrictionWeight", function() return NEAR(pp.FrictionWeight, 0.3, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.CorrodedMetal)
    T("physprops.CorrodedMetal.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.CorrodedMetal.Density", function() return NEAR(pp.Density, 7.85, 1e-6) end)
    T("physprops.CorrodedMetal.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.CorrodedMetal.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.CorrodedMetal.Friction", function() return NEAR(pp.Friction, 0.7, 1e-6) end)
    T("physprops.CorrodedMetal.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.CrackedLava)
    T("physprops.CrackedLava.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.CrackedLava.Density", function() return NEAR(pp.Density, 2.691, 1e-6) end)
    T("physprops.CrackedLava.Elasticity", function() return NEAR(pp.Elasticity, 0.15, 1e-6) end)
    T("physprops.CrackedLava.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.CrackedLava.Friction", function() return NEAR(pp.Friction, 0.65, 1e-6) end)
    T("physprops.CrackedLava.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.DiamondPlate)
    T("physprops.DiamondPlate.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.DiamondPlate.Density", function() return NEAR(pp.Density, 7.85, 1e-6) end)
    T("physprops.DiamondPlate.Elasticity", function() return NEAR(pp.Elasticity, 0.25, 1e-6) end)
    T("physprops.DiamondPlate.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.DiamondPlate.Friction", function() return NEAR(pp.Friction, 0.35, 1e-6) end)
    T("physprops.DiamondPlate.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Fabric)
    T("physprops.Fabric.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Fabric.Density", function() return NEAR(pp.Density, 0.7, 1e-6) end)
    T("physprops.Fabric.Elasticity", function() return NEAR(pp.Elasticity, 0.05, 1e-6) end)
    T("physprops.Fabric.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Fabric.Friction", function() return NEAR(pp.Friction, 0.35, 1e-6) end)
    T("physprops.Fabric.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Foil)
    T("physprops.Foil.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Foil.Density", function() return NEAR(pp.Density, 2.7, 1e-6) end)
    T("physprops.Foil.Elasticity", function() return NEAR(pp.Elasticity, 0.25, 1e-6) end)
    T("physprops.Foil.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Foil.Friction", function() return NEAR(pp.Friction, 0.4, 1e-6) end)
    T("physprops.Foil.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.ForceField)
    T("physprops.ForceField.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.ForceField.Density", function() return NEAR(pp.Density, 2.403, 1e-6) end)
    T("physprops.ForceField.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.ForceField.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.ForceField.Friction", function() return NEAR(pp.Friction, 0.25, 1e-6) end)
    T("physprops.ForceField.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Glacier)
    T("physprops.Glacier.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Glacier.Density", function() return NEAR(pp.Density, 0.919, 1e-6) end)
    T("physprops.Glacier.Elasticity", function() return NEAR(pp.Elasticity, 0.15, 1e-6) end)
    T("physprops.Glacier.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Glacier.Friction", function() return NEAR(pp.Friction, 0.05, 1e-6) end)
    T("physprops.Glacier.FrictionWeight", function() return NEAR(pp.FrictionWeight, 2.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Glass)
    T("physprops.Glass.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Glass.Density", function() return NEAR(pp.Density, 2.403, 1e-6) end)
    T("physprops.Glass.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.Glass.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Glass.Friction", function() return NEAR(pp.Friction, 0.25, 1e-6) end)
    T("physprops.Glass.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Granite)
    T("physprops.Granite.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Granite.Density", function() return NEAR(pp.Density, 2.691, 1e-6) end)
    T("physprops.Granite.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.Granite.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Granite.Friction", function() return NEAR(pp.Friction, 0.4, 1e-6) end)
    T("physprops.Granite.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Grass)
    T("physprops.Grass.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Grass.Density", function() return NEAR(pp.Density, 0.9, 1e-6) end)
    T("physprops.Grass.Elasticity", function() return NEAR(pp.Elasticity, 0.1, 1e-6) end)
    T("physprops.Grass.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.5, 1e-6) end)
    T("physprops.Grass.Friction", function() return NEAR(pp.Friction, 0.4, 1e-6) end)
    T("physprops.Grass.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Ground)
    T("physprops.Ground.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Ground.Density", function() return NEAR(pp.Density, 0.9, 1e-6) end)
    T("physprops.Ground.Elasticity", function() return NEAR(pp.Elasticity, 0.1, 1e-6) end)
    T("physprops.Ground.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Ground.Friction", function() return NEAR(pp.Friction, 0.45, 1e-6) end)
    T("physprops.Ground.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Ice)
    T("physprops.Ice.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Ice.Density", function() return NEAR(pp.Density, 0.919, 1e-6) end)
    T("physprops.Ice.Elasticity", function() return NEAR(pp.Elasticity, 0.15, 1e-6) end)
    T("physprops.Ice.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Ice.Friction", function() return NEAR(pp.Friction, 0.02, 1e-6) end)
    T("physprops.Ice.FrictionWeight", function() return NEAR(pp.FrictionWeight, 3.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.LeafyGrass)
    T("physprops.LeafyGrass.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.LeafyGrass.Density", function() return NEAR(pp.Density, 0.9, 1e-6) end)
    T("physprops.LeafyGrass.Elasticity", function() return NEAR(pp.Elasticity, 0.1, 1e-6) end)
    T("physprops.LeafyGrass.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 2.0, 1e-6) end)
    T("physprops.LeafyGrass.Friction", function() return NEAR(pp.Friction, 0.4, 1e-6) end)
    T("physprops.LeafyGrass.FrictionWeight", function() return NEAR(pp.FrictionWeight, 2.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Leather)
    T("physprops.Leather.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Leather.Density", function() return NEAR(pp.Density, 0.86, 1e-6) end)
    T("physprops.Leather.Elasticity", function() return NEAR(pp.Elasticity, 0.25, 1e-6) end)
    T("physprops.Leather.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Leather.Friction", function() return NEAR(pp.Friction, 0.35, 1e-6) end)
    T("physprops.Leather.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Limestone)
    T("physprops.Limestone.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Limestone.Density", function() return NEAR(pp.Density, 2.691, 1e-6) end)
    T("physprops.Limestone.Elasticity", function() return NEAR(pp.Elasticity, 0.15, 1e-6) end)
    T("physprops.Limestone.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Limestone.Friction", function() return NEAR(pp.Friction, 0.5, 1e-6) end)
    T("physprops.Limestone.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Marble)
    T("physprops.Marble.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Marble.Density", function() return NEAR(pp.Density, 2.563, 1e-6) end)
    T("physprops.Marble.Elasticity", function() return NEAR(pp.Elasticity, 0.17, 1e-6) end)
    T("physprops.Marble.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Marble.Friction", function() return NEAR(pp.Friction, 0.2, 1e-6) end)
    T("physprops.Marble.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Metal)
    T("physprops.Metal.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Metal.Density", function() return NEAR(pp.Density, 7.85, 1e-6) end)
    T("physprops.Metal.Elasticity", function() return NEAR(pp.Elasticity, 0.25, 1e-6) end)
    T("physprops.Metal.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Metal.Friction", function() return NEAR(pp.Friction, 0.4, 1e-6) end)
    T("physprops.Metal.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Mud)
    T("physprops.Mud.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Mud.Density", function() return NEAR(pp.Density, 0.9, 1e-6) end)
    T("physprops.Mud.Elasticity", function() return NEAR(pp.Elasticity, 0.07, 1e-6) end)
    T("physprops.Mud.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 4.0, 1e-6) end)
    T("physprops.Mud.Friction", function() return NEAR(pp.Friction, 0.3, 1e-6) end)
    T("physprops.Mud.FrictionWeight", function() return NEAR(pp.FrictionWeight, 3.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Neon)
    T("physprops.Neon.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Neon.Density", function() return NEAR(pp.Density, 0.7, 1e-6) end)
    T("physprops.Neon.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.Neon.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Neon.Friction", function() return NEAR(pp.Friction, 0.3, 1e-6) end)
    T("physprops.Neon.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Pavement)
    T("physprops.Pavement.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Pavement.Density", function() return NEAR(pp.Density, 2.691, 1e-6) end)
    T("physprops.Pavement.Elasticity", function() return NEAR(pp.Elasticity, 0.17, 1e-6) end)
    T("physprops.Pavement.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Pavement.Friction", function() return NEAR(pp.Friction, 0.5, 1e-6) end)
    T("physprops.Pavement.FrictionWeight", function() return NEAR(pp.FrictionWeight, 0.3, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Pebble)
    T("physprops.Pebble.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Pebble.Density", function() return NEAR(pp.Density, 2.403, 1e-6) end)
    T("physprops.Pebble.Elasticity", function() return NEAR(pp.Elasticity, 0.17, 1e-6) end)
    T("physprops.Pebble.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.5, 1e-6) end)
    T("physprops.Pebble.Friction", function() return NEAR(pp.Friction, 0.4, 1e-6) end)
    T("physprops.Pebble.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Plaster)
    T("physprops.Plaster.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Plaster.Density", function() return NEAR(pp.Density, 0.75, 1e-6) end)
    T("physprops.Plaster.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.Plaster.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Plaster.Friction", function() return NEAR(pp.Friction, 0.6, 1e-6) end)
    T("physprops.Plaster.FrictionWeight", function() return NEAR(pp.FrictionWeight, 0.3, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Plastic)
    T("physprops.Plastic.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Plastic.Density", function() return NEAR(pp.Density, 0.7, 1e-6) end)
    T("physprops.Plastic.Elasticity", function() return NEAR(pp.Elasticity, 0.5, 1e-6) end)
    T("physprops.Plastic.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Plastic.Friction", function() return NEAR(pp.Friction, 0.3, 1e-6) end)
    T("physprops.Plastic.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Rock)
    T("physprops.Rock.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Rock.Density", function() return NEAR(pp.Density, 2.691, 1e-6) end)
    T("physprops.Rock.Elasticity", function() return NEAR(pp.Elasticity, 0.17, 1e-6) end)
    T("physprops.Rock.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Rock.Friction", function() return NEAR(pp.Friction, 0.5, 1e-6) end)
    T("physprops.Rock.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.RoofShingles)
    T("physprops.RoofShingles.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.RoofShingles.Density", function() return NEAR(pp.Density, 2.36, 1e-6) end)
    T("physprops.RoofShingles.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.RoofShingles.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.RoofShingles.Friction", function() return NEAR(pp.Friction, 0.8, 1e-6) end)
    T("physprops.RoofShingles.FrictionWeight", function() return NEAR(pp.FrictionWeight, 0.3, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Rubber)
    T("physprops.Rubber.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Rubber.Density", function() return NEAR(pp.Density, 1.3, 1e-6) end)
    T("physprops.Rubber.Elasticity", function() return NEAR(pp.Elasticity, 0.95, 1e-6) end)
    T("physprops.Rubber.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 2.0, 1e-6) end)
    T("physprops.Rubber.Friction", function() return NEAR(pp.Friction, 1.5, 1e-6) end)
    T("physprops.Rubber.FrictionWeight", function() return NEAR(pp.FrictionWeight, 3.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Salt)
    T("physprops.Salt.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Salt.Density", function() return NEAR(pp.Density, 2.165, 1e-6) end)
    T("physprops.Salt.Elasticity", function() return NEAR(pp.Elasticity, 0.05, 1e-6) end)
    T("physprops.Salt.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Salt.Friction", function() return NEAR(pp.Friction, 0.5, 1e-6) end)
    T("physprops.Salt.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Sand)
    T("physprops.Sand.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Sand.Density", function() return NEAR(pp.Density, 1.602, 1e-6) end)
    T("physprops.Sand.Elasticity", function() return NEAR(pp.Elasticity, 0.05, 1e-6) end)
    T("physprops.Sand.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 2.5, 1e-6) end)
    T("physprops.Sand.Friction", function() return NEAR(pp.Friction, 0.5, 1e-6) end)
    T("physprops.Sand.FrictionWeight", function() return NEAR(pp.FrictionWeight, 5.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Sandstone)
    T("physprops.Sandstone.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Sandstone.Density", function() return NEAR(pp.Density, 2.691, 1e-6) end)
    T("physprops.Sandstone.Elasticity", function() return NEAR(pp.Elasticity, 0.15, 1e-6) end)
    T("physprops.Sandstone.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Sandstone.Friction", function() return NEAR(pp.Friction, 0.5, 1e-6) end)
    T("physprops.Sandstone.FrictionWeight", function() return NEAR(pp.FrictionWeight, 5.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.SmoothPlastic)
    T("physprops.SmoothPlastic.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.SmoothPlastic.Density", function() return NEAR(pp.Density, 0.7, 1e-6) end)
    T("physprops.SmoothPlastic.Elasticity", function() return NEAR(pp.Elasticity, 0.5, 1e-6) end)
    T("physprops.SmoothPlastic.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.SmoothPlastic.Friction", function() return NEAR(pp.Friction, 0.2, 1e-6) end)
    T("physprops.SmoothPlastic.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Slate)
    T("physprops.Slate.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Slate.Density", function() return NEAR(pp.Density, 2.691, 1e-6) end)
    T("physprops.Slate.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.Slate.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Slate.Friction", function() return NEAR(pp.Friction, 0.4, 1e-6) end)
    T("physprops.Slate.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Snow)
    T("physprops.Snow.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Snow.Density", function() return NEAR(pp.Density, 0.9, 1e-6) end)
    T("physprops.Snow.Elasticity", function() return NEAR(pp.Elasticity, 0.03, 1e-6) end)
    T("physprops.Snow.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 4.0, 1e-6) end)
    T("physprops.Snow.Friction", function() return NEAR(pp.Friction, 0.3, 1e-6) end)
    T("physprops.Snow.FrictionWeight", function() return NEAR(pp.FrictionWeight, 3.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.Wood)
    T("physprops.Wood.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.Wood.Density", function() return NEAR(pp.Density, 0.35, 1e-6) end)
    T("physprops.Wood.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.Wood.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.Wood.Friction", function() return NEAR(pp.Friction, 0.48, 1e-6) end)
    T("physprops.Wood.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
do
    local ok, pp = pcall(PhysicalProperties.new, Enum.Material.WoodPlanks)
    T("physprops.WoodPlanks.ok", function() A(EQ(ok, true)); return TY(pp, "PhysicalProperties") end)
    T("physprops.WoodPlanks.Density", function() return NEAR(pp.Density, 0.35, 1e-6) end)
    T("physprops.WoodPlanks.Elasticity", function() return NEAR(pp.Elasticity, 0.2, 1e-6) end)
    T("physprops.WoodPlanks.ElasticityWeight", function() return NEAR(pp.ElasticityWeight, 1.0, 1e-6) end)
    T("physprops.WoodPlanks.Friction", function() return NEAR(pp.Friction, 0.48, 1e-6) end)
    T("physprops.WoodPlanks.FrictionWeight", function() return NEAR(pp.FrictionWeight, 1.0, 1e-6) end)
end
__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)
