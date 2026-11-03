#!/usr/bin/env python3
"""Generate API-derived detection suites for envlogger.

Ground truth comes from two machine-generated sources, never from memory:
  * Roblox Full-API-Dump.json (Roblox-Client-Tracker, same client build the logger reports),
    which is authoritative for classes, members, security, tags, enums, and the defaults of
    members declared on creatable classes;
  * rbx-dom's reflection database (rbx_reflection_database crate), whose defaults are read
    from instances created with Instance.new and include inherited members.  Both sources
    agree on >99% of the ~1,500 defaults they share; members where they disagree are skipped.

Usage: gen_api_checks.py [--dump Full-API-Dump.json] [--rbxdb database.msgpack] [--out suites/]
Missing inputs are downloaded into detections/.cache/.
"""
import argparse
import json
import math
import os
import re
import struct
import sys
import tarfile
import urllib.request
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
CACHE = os.path.join(ROOT, ".cache")
DUMP_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Full-API-Dump.json"
VERSION_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/version.txt"
RBXDB_CRATE = "https://static.crates.io/crates/rbx_reflection_database/rbx_reflection_database-3.0.1+roblox-741.crate"

CHECKS_PER_FILE = 1500

# Creatable per the dump, but Studio/plugin/internal-only or with engine side effects; a live
# client (and therefore a detection) cannot rely on Instance.new succeeding for these.
EXCLUDE_CREATE = set("""
Player PluginAction PluginCapabilities Breakpoint DebuggerWatch AdvancedDragger Dragger
StandalonePluginScripts StudioAttachment StudioCallout InternalSyncItem ExplorerFilter RenderingTest
FunctionalTest AuroraScript PartOperationAsset HiddenSurfaceRemovalAsset CustomLog TextChannelWindow
VisualizationMode VisualizationModeCategory StateMachineDefinition StateMachineTransitionDefinition
AnimationNodeDefinition AnimationGraphDefinition AnimationValueNodeDefinition AnimationValueOutputDefinition
OperationGraph RTAnimationTracker TrackerStreamAnimation RealtimeMedia TextGenerator AnimationRigData
ProceduralModel GeneratedFolder RelativeGui Annotation WorkspaceAnnotation TextDocument MotorFeature
FeatureMatchingTable InputActionLabel ViewportCamera SelectionPartLasso SelectionPointLasso FlyweightService
CSGDictionaryService NonReplicatedCSGDictionaryService HeightmapImporterService MemoryStoreService
ProximityPromptService TestService VirtualInputManager AudioSpeechToText AudioTextToSpeech AudioRecorder
AudioSearchParams AvatarAbilityRules AvatarAccessoryRules AvatarAnimationRules AvatarBodyRules
AvatarClothingRules AvatarCollisionRules AvatarRules ControlState VehicleController HumanoidController
SkateboardController CompositeValueCurve ValueCurve Vector3Curve StyleQuery Path3D ParticleEmitter2D
UIShadow ColorGradingEffect AudioWindSynthesizer WrapTextureTransfer UIBlur Noise HapticEffect
""".split())
for _n in ["ReflectionMetadata", "ReflectionMetadataCallbacks", "ReflectionMetadataClasses",
           "ReflectionMetadataEnums", "ReflectionMetadataEvents", "ReflectionMetadataFunctions",
           "ReflectionMetadataClass", "ReflectionMetadataEnum", "ReflectionMetadataEnumItem",
           "ReflectionMetadataMember", "ReflectionMetadataProperties", "ReflectionMetadataYieldFunctions"]:
    EXCLUDE_CREATE.add(_n)

# Common classes first: inherited members are checked on these before anything exotic.
POPULAR = """Part MeshPart Model Folder Frame TextLabel TextButton ImageLabel ImageButton ScreenGui
Script LocalScript ModuleScript RemoteEvent RemoteFunction BindableEvent BindableFunction Sound Humanoid
Tool Camera Attachment Weld WeldConstraint Motor6D ParticleEmitter PointLight SpotLight SurfaceLight Decal
Texture StringValue IntValue BoolValue NumberValue ObjectValue CFrameValue Vector3Value Color3Value
ProximityPrompt ClickDetector Highlight UICorner UIStroke UIListLayout UIGridLayout UIPadding UIScale
UIGradient BillboardGui SurfaceGui ScrollingFrame TextBox ViewportFrame CanvasGroup Beam Trail Fire Smoke
Sparkles Explosion SpawnLocation Seat VehicleSeat WedgePart CornerWedgePart TrussPart UnionOperation
Accessory Shirt Pants ShirtGraphic BodyColors Animation AnimationController Animator Configuration
SelectionBox BoxHandleAdornment SphereHandleAdornment Sky Atmosphere BloomEffect BlurEffect
ColorCorrectionEffect SunRaysEffect DepthOfFieldEffect AlignPosition AlignOrientation LinearVelocity
AngularVelocity VectorForce HingeConstraint RopeConstraint SpringConstraint BallSocketConstraint
BodyVelocity BodyPosition BodyGyro BodyForce Team SoundGroup Path2D""".split()
POP_RANK = {n: i for i, n in enumerate(POPULAR)}

# Properties whose value on a fresh instance depends on the running engine (rendering, physics,
# text shaping, clocks, asset loading) -- type-checked only, never value-checked.
VOLATILE_PROPS = set("""
AbsolutePosition AbsoluteSize AbsoluteRotation AbsoluteCanvasSize AbsoluteWindowSize AbsoluteContentSize
AbsoluteCellSize AbsoluteCellCount TextBounds TextFits ContentText LocalizedText GuiState Mass AssemblyMass
AssemblyCenterOfMass AssemblyRootPart ExtentsCFrame ExtentsSize CurrentDistance CurrentAngle CurrentPosition
CurrentLength TimeLength IsLoaded IsPlaying PlaybackLoudness TimePosition Resolution ContentImageSize
ImageContent ViewportSize NearPlaneZ PeakLevel RmsLevel CurrentPage IsReady UniqueId HistoryId
SourceAssetId Capabilities Sandboxed SimulationRadius ReceiveAge ResizeableFaces ResizeIncrement
RobloxLocked MeshSize InitialSize TriangleCount RenderFidelity CollisionFidelity Status
""".split())

# ValueType names whose typeof() equals the type name.
SAME_TYPEOF = set("""Vector3 Vector2 CFrame Color3 BrickColor UDim UDim2 Rect NumberRange NumberSequence
ColorSequence Font Faces Axes Ray Region3int16 Vector3int16 Vector2int16 TweenInfo DateTime Content
SecurityCapabilities Path2DControlPoint PhysicalProperties""".split())
TYPEOF_ALIAS = {"ContentId": "string", "ProtectedString": "string"}


def fetch(url, path):
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        print("downloading", url, file=sys.stderr)
        urllib.request.urlretrieve(url, path)
    return path


def load_rbxdb(path):
    import msgpack  # pip install msgpack
    if path.endswith(".crate"):
        with tarfile.open(path) as tf:
            member = next(m for m in tf.getmembers() if m.name.endswith("/database.msgpack"))
            raw = tf.extractfile(member).read()
    else:
        raw = open(path, "rb").read()
    return msgpack.unpackb(raw, raw=False, strict_map_key=False)


def f32(x):
    if x is None or isinstance(x, bool):
        return x
    if math.isinf(x) or math.isnan(x):
        return x
    return struct.unpack("f", struct.pack("f", x))[0]


def lstr(s):
    out = ['"']
    for ch in s.encode("utf-8"):
        c = chr(ch)
        if c == '"':
            out.append('\\"')
        elif c == "\\":
            out.append("\\\\")
        elif c == "\n":
            out.append("\\n")
        elif c == "\r":
            out.append("\\r")
        elif c == "\t":
            out.append("\\t")
        elif ch < 32 or ch == 127:
            out.append("\\%03d" % ch)
        else:
            out.append(c if ch < 128 else None)
            if ch >= 128:
                out[-1] = "\\%03d" % ch
    out.append('"')
    return "".join(out)


def lnum(x):
    if isinstance(x, bool):
        return "true" if x else "false"
    if isinstance(x, int):
        return str(x)
    if math.isnan(x):
        return "(0/0)"
    if math.isinf(x):
        return "math.huge" if x > 0 else "-math.huge"
    r = repr(float(x))
    if r.endswith(".0"):
        r = r[:-2]
    return r


def ident_ok(name):
    return re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", name) is not None


def idx(obj, name):
    return f"{obj}.{name}" if ident_ok(name) else f"{obj}[{lstr(name)}]"


class Api:
    def __init__(self, dump, rbx):
        self.version = None
        self.classes = {c["Name"]: c for c in dump["Classes"]}
        self.enums = {e["Name"]: e for e in dump["Enums"]}
        self.enum_vals = {e["Name"]: {it["Name"]: it["Value"] for it in e["Items"]} for e in dump["Enums"]}
        self.enum_by_val = {e["Name"]: {it["Value"]: it["Name"] for it in e["Items"]} for e in dump["Enums"]}
        self.rbx_classes = rbx[1]
        self.children = defaultdict(list)
        for n, c in self.classes.items():
            sup = c.get("Superclass")
            if sup and sup in self.classes:
                self.children[sup].append(n)

    def tags(self, cn):
        return [t for t in (self.classes[cn].get("Tags") or []) if isinstance(t, str)]

    def chain(self, cn):
        out = []
        while cn and cn in self.classes:
            out.append(cn)
            cn = self.classes[cn].get("Superclass")
            if cn == "<<<ROOT>>>":
                break
        return out

    def is_creatable(self, cn):
        t = self.tags(cn)
        return "NotCreatable" not in t and "Service" not in t and cn not in EXCLUDE_CREATE

    def descendants(self, cn):
        out, stack = [], [cn]
        while stack:
            x = stack.pop()
            out.append(x)
            stack.extend(self.children.get(x, []))
        return out

    def concrete(self, cn):
        return sorted((x for x in self.descendants(cn) if self.is_creatable(x)),
                      key=lambda n: (POP_RANK.get(n, 10_000), n))

    def members(self, cn, kind):
        for m in self.classes[cn]["Members"]:
            if m["MemberType"] == kind:
                yield m

    def rbx_default(self, cn, pn):
        """Default of property pn on a concrete class cn per rbx-dom, following alias properties."""
        rc = self.rbx_classes.get(cn)
        if rc is None:
            return None
        defaults = rc[4] or {}
        if pn in defaults and defaults[pn] is not None:
            return defaults[pn]
        # alias (e.g. deprecated lower-case names) -> canonical default
        for c in self.chain(cn):
            rcc = self.rbx_classes.get(c)
            if rcc is None:
                continue
            pd = (rcc[3] or {}).get(pn)
            if pd is None:
                continue
            kind = pd[4]
            if isinstance(kind, dict) and "Alias" in kind:
                alias = kind["Alias"]
                target = alias[0] if isinstance(alias, list) else alias.get("AliasFor") if isinstance(alias, dict) else None
                if isinstance(target, list):
                    target = target[0]
                if isinstance(target, str) and target in defaults and defaults[target] is not None:
                    return defaults[target]
            break
        return None


def nums(s):
    out = []
    for tok in re.findall(r"-?INF|-?inf|NAN|nan|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?", s):
        t = tok.lower()
        if t in ("inf", "-inf"):
            out.append(math.inf if t == "inf" else -math.inf)
        elif t == "nan":
            out.append(math.nan)
        else:
            out.append(float(tok))
    return out


def expected_from_dump(api, member, vtn, vcat, dv):
    """Turn an API-dump Default string into ('kind', payload) or None when not representable."""
    if dv is None or dv.startswith("__api_dump"):
        return None
    if vcat == "Primitive":
        if vtn == "bool":
            return ("bool", dv == "true")
        if vtn in ("int", "int64"):
            try:
                return ("int", int(dv))
            except ValueError:
                return None
        if vtn in ("float", "double"):
            v = nums(dv)
            return ("num", f32(v[0]) if vtn == "float" else v[0]) if len(v) == 1 else None
        if vtn == "string":
            return ("str", dv)
        return None
    if vcat == "Enum":
        if dv in api.enum_vals.get(vtn, {}):
            return ("enum", (vtn, dv))
        return None
    if vcat == "DataType":
        if vtn in ("ContentId",):
            return ("str", dv)
        n = nums(dv)
        if vtn in ("Vector3", "Vector2", "Color3") and len(n) == (2 if vtn == "Vector2" else 3):
            return ("vec", (vtn, [f32(x) for x in n]))
        if vtn == "UDim2" and len(n) == 4:
            return ("udim2", [f32(n[0]), int(n[1]), f32(n[2]), int(n[3])])
        if vtn == "UDim" and len(n) == 2:
            return ("udim", [f32(n[0]), int(n[1])])
        if vtn == "CFrame" and len(n) == 12:
            return ("cframe", [f32(x) for x in n])
        if vtn == "NumberRange" and len(n) == 2:
            return ("nrange", [f32(x) for x in n])
        if vtn == "Rect" and len(n) == 4:
            return ("rect", [f32(x) for x in n])
    return None


def expected_from_rbx(api, vtn, vcat, value):
    (vt, val), = value.items()
    if vt == "Bool":
        return ("bool", bool(val))
    if vt in ("Int32", "Int64"):
        return ("int", int(val))
    if vt == "Float32":
        return ("num", f32(val))
    if vt == "Float64":
        return ("num", float(val))
    if vt in ("String", "ContentId"):
        return ("str", val)
    if vt == "Enum":
        if vcat == "Enum" and val in api.enum_by_val.get(vtn, {}):
            return ("enum", (vtn, api.enum_by_val[vtn][val]))
        return None
    if vt in ("Vector3", "Vector2"):
        return ("vec", (vt, [f32(x) for x in val]))
    if vt == "Color3":
        return ("vec", ("Color3", [f32(x) for x in val]))
    if vt == "Color3uint8":
        return ("vec", ("Color3", [f32(x / 255) for x in val]))
    if vt == "UDim2":
        return ("udim2", [f32(val[0][0]), int(val[0][1]), f32(val[1][0]), int(val[1][1])])
    if vt == "UDim":
        return ("udim", [f32(val[0]), int(val[1])])
    if vt == "CFrame":
        p, rot = val
        flat = list(p) + [rot[0][0], rot[0][1], rot[0][2], rot[1][0], rot[1][1], rot[1][2], rot[2][0], rot[2][1], rot[2][2]]
        return ("cframe", [f32(x) for x in flat])
    if vt == "NumberRange":
        return ("nrange", [f32(x) for x in val])
    if vt == "Rect":
        return ("rect", [f32(val[0][0]), f32(val[0][1]), f32(val[1][0]), f32(val[1][1])])
    if vt == "BrickColor":
        return ("brick", int(val))
    if vt == "NumberSequence":
        kps = val[0] if val and isinstance(val[0], list) and val[0] and isinstance(val[0][0], list) else val
        return ("nseq", [[f32(a) for a in kp] for kp in kps])
    if vt == "ColorSequence":
        kps = val[0] if val and isinstance(val[0], list) and val[0] and isinstance(val[0][0], list) else val
        return ("cseq", [[f32(kp[0])] + [f32(x) for x in kp[1]] for kp in kps])
    if vt == "Font":
        fam, weight, style = val[0], val[1], val[2]
        if weight in api.enum_vals.get("FontWeight", {}) and style in api.enum_vals.get("FontStyle", {}):
            return ("font", (fam, weight, style))
        return None
    if vt == "PhysicalProperties" and val == "Default":
        return ("nil", None)
    if vt == "Content" and val == "None":
        return ("content_none", None)
    if vt == "Faces":
        return ("faces", int(val))
    if vt == "Axes":
        return ("axes", int(val))
    if vt == "Ray":
        return ("ray", [f32(x) for x in val[0]] + [f32(x) for x in val[1]])
    return None


def emit_value_check(expr, exp):
    """Luau boolean-returning expression (as check body) comparing `expr` against an expectation."""
    kind, p = exp
    if kind == "bool":
        return f"return EQ({expr}, {lnum(p)})"
    if kind == "int":
        return f"return EQ({expr}, {p})"
    if kind == "num":
        if isinstance(p, float) and math.isnan(p):
            return f"local v = {expr}; return v ~= v"
        if isinstance(p, float) and math.isinf(p):
            return f"return EQ({expr}, {lnum(p)})"
        return f"return NEAR({expr}, {lnum(p)})"
    if kind == "str":
        return f"return EQ({expr}, {lstr(p)})"
    if kind == "enum":
        en, item = p
        return f"return EQ({expr}, Enum.{en}[{lstr(item)}])" if not ident_ok(item) else f"return EQ({expr}, Enum.{en}.{item})"
    if kind == "nil":
        return f"return EQ({expr}, nil)"
    if kind == "vec":
        tn, comps = p
        names = {"Vector3": ("X", "Y", "Z"), "Vector2": ("X", "Y"), "Color3": ("R", "G", "B")}[tn]
        got = ", ".join(f"v.{c}" for c in names)
        exp_ = ", ".join(lnum(x) for x in comps)
        eps = "1e-5" if tn == "Color3" else "1e-6"
        return f'local v = {expr}; A(TY(v, "{tn}")); return NEARV({{{got}}}, {{{exp_}}}, {eps})'
    if kind == "udim2":
        exp_ = ", ".join(lnum(x) for x in p)
        return f'local v = {expr}; A(TY(v, "UDim2")); return NEARV({{v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset}}, {{{exp_}}})'
    if kind == "udim":
        exp_ = ", ".join(lnum(x) for x in p)
        return f'local v = {expr}; A(TY(v, "UDim")); return NEARV({{v.Scale, v.Offset}}, {{{exp_}}})'
    if kind == "cframe":
        exp_ = ", ".join(lnum(x) for x in p)
        return f'local v = {expr}; A(TY(v, "CFrame")); return NEARV({{v:GetComponents()}}, {{{exp_}}}, 1e-5)'
    if kind == "nrange":
        exp_ = ", ".join(lnum(x) for x in p)
        return f'local v = {expr}; A(TY(v, "NumberRange")); return NEARV({{v.Min, v.Max}}, {{{exp_}}})'
    if kind == "rect":
        exp_ = ", ".join(lnum(x) for x in p)
        return f'local v = {expr}; A(TY(v, "Rect")); return NEARV({{v.Min.X, v.Min.Y, v.Max.X, v.Max.Y}}, {{{exp_}}})'
    if kind == "brick":
        return f'local v = {expr}; A(TY(v, "BrickColor")); return EQ(v.Number, {p})'
    if kind == "nseq":
        flat = ", ".join(lnum(x) for kp in p for x in kp)
        return (f'local v = {expr}; A(TY(v, "NumberSequence")); local k = v.Keypoints; A(EQ(#k, {len(p)})); '
                f'local t = {{}}; for _, kp in ipairs(k) do t[#t + 1] = kp.Time; t[#t + 1] = kp.Value; t[#t + 1] = kp.Envelope end; '
                f'return NEARV(t, {{{flat}}}, 1e-5)')
    if kind == "cseq":
        flat = ", ".join(lnum(x) for kp in p for x in kp)
        return (f'local v = {expr}; A(TY(v, "ColorSequence")); local k = v.Keypoints; A(EQ(#k, {len(p)})); '
                f'local t = {{}}; for _, kp in ipairs(k) do t[#t + 1] = kp.Time; t[#t + 1] = kp.Value.R; t[#t + 1] = kp.Value.G; t[#t + 1] = kp.Value.B end; '
                f'return NEARV(t, {{{flat}}}, 1e-5)')
    if kind == "font":
        fam, weight, style = p
        return (f'local v = {expr}; A(TY(v, "Font")); A(EQ(v.Family, {lstr(fam)})); '
                f'A(EQ(v.Weight, Enum.FontWeight.{weight})); return EQ(v.Style, Enum.FontStyle.{style})')
    if kind == "content_none":
        return f'local v = {expr}; A(TY(v, "Content")); return EQ(v.SourceType, Enum.ContentSourceType.None)'
    if kind == "faces":
        names = ["Right", "Top", "Back", "Left", "Bottom", "Front"]
        exp_ = ", ".join("true" if p & (1 << i) else "false" for i in range(6))
        got = ", ".join(f"v.{n}" for n in names)
        return f'local v = {expr}; A(TY(v, "Faces")); local g, e = {{{got}}}, {{{exp_}}}; for i = 1, 6 do A(EQ(g[i], e[i])) end; return true'
    if kind == "axes":
        exp_ = ", ".join("true" if p & (1 << i) else "false" for i in range(3))
        return f'local v = {expr}; A(TY(v, "Axes")); local g, e = {{v.X, v.Y, v.Z}}, {{{exp_}}}; for i = 1, 3 do A(EQ(g[i], e[i])) end; return true'
    if kind == "ray":
        exp_ = ", ".join(lnum(x) for x in p)
        return f'local v = {expr}; A(TY(v, "Ray")); return NEARV({{v.Origin.X, v.Origin.Y, v.Origin.Z, v.Direction.X, v.Direction.Y, v.Direction.Z}}, {{{exp_}}})'
    raise ValueError(kind)


class Suite:
    def __init__(self, name):
        self.name = name
        self.blocks = []   # list of (setup_lines, [check lines])
        self.count = 0

    def block(self, setup, checks):
        if checks:
            self.blocks.append((setup, checks))
            self.count += len(checks)


def T(cid, body):
    return f"T({lstr(cid)}, function() {body} end)"


def write_suites(prefix, blocks_iter, outdir, manifest, harness):
    """Split blocks into files of ~CHECKS_PER_FILE checks."""
    files, cur, n = [], [], 0
    for setup, checks in blocks_iter:
        if n and n + len(checks) > CHECKS_PER_FILE:
            files.append(cur)
            cur, n = [], 0
        cur.append((setup, checks))
        n += len(checks)
    if cur:
        files.append(cur)
    for i, blocks in enumerate(files, 1):
        name = f"{prefix}_{i:02d}" if len(files) > 1 else prefix
        total = sum(len(c) for _, c in blocks)
        lines = [harness.replace("%SUITE%", name)]
        for setup, checks in blocks:
            lines.append("do")
            lines.extend("    " + s for s in setup)
            lines.extend("    " + c for c in checks)
            lines.append("end")
        lines.append('__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)')
        path = os.path.join(outdir, name + ".luau")
        with open(path, "w", encoding="utf-8") as fh:
            fh.write("\n".join(lines) + "\n")
        manifest[name] = total


def gen_classes(api):
    blocks = []
    for cn in sorted(api.classes):
        tags = api.tags(cn)
        checks = []
        if api.is_creatable(cn):
            setup = [f"local ok, o = pcall(Instance.new, {lstr(cn)})"]
            checks.append(T(f"class.new.{cn}", f"A(EQ(ok, true)); A(TY(o, \"Instance\")); return EQ(o.ClassName, {lstr(cn)})"))
            checks.append(T(f"class.name.{cn}", f"return EQ(o.Name, {lstr(cn)})"))
            checks.append(T(f"class.tostring.{cn}", f"return EQ(tostring(o), {lstr(cn)})"))
            checks.append(T(f"class.parent.{cn}", "return EQ(o.Parent, nil)"))
            for anc in api.chain(cn):
                if anc == "Object":
                    continue
                checks.append(T(f"class.isa.{cn}.{anc}", f"return EQ(o:IsA({lstr(anc)}), true)"))
            # a sibling branch the class does not derive from
            checks.append(T(f"class.isa_not.{cn}", "return EQ(o:IsA(\"ValueBase\") == (" +
                            ("true" if "ValueBase" in api.chain(cn) else "false") + "), true)"))
            blocks.append((setup, checks))
        elif "Service" not in tags and cn not in EXCLUDE_CREATE:
            checks.append(T(f"class.notcreatable.{cn}",
                            f"return ERR(function() return Instance.new({lstr(cn)}) end, {lstr('Unable to create an Instance of type \"' + cn + '\"')})"))
            blocks.append(([], checks))
    # names that are not classes at all
    bogus = ["Partt", "NotAClass", "instance", "part", "Players2", "LuaSourceContainerX", "", "Vector3", "Enum"]
    checks = [T(f"class.bogus.{b or 'empty'}", f"return ERR(function() return Instance.new({lstr(b)}) end, {lstr('Unable to create an Instance of type \"' + b + '\"')})") for b in bogus]
    blocks.append(([], checks))
    return blocks


def prop_targets(api, decl, pname, kind_filter=None):
    """Concrete classes on which an inherited property is checked: up to 3 popular ones plus the
    declaring class itself when creatable."""
    conc = api.concrete(decl)
    if not conc:
        return []
    picks = conc[:3]
    if decl in conc and decl not in picks:
        picks.append(decl)
    return picks


def readable(m):
    tags = m.get("Tags") or []
    sec = m.get("Security")
    rsec = sec.get("Read") if isinstance(sec, dict) else sec
    return "NotScriptable" not in tags and rsec == "None"


def typeof_for(api, m, default_exp):
    vt = m["ValueType"]
    cat, name = vt["Category"], vt["Name"]
    if cat == "Primitive":
        return {"bool": "boolean", "int": "number", "int64": "number", "float": "number",
                "double": "number", "string": "string"}.get(name)
    if cat == "Enum":
        return "EnumItem" if name in api.enums else None
    if cat == "DataType":
        if name in TYPEOF_ALIAS:
            return TYPEOF_ALIAS[name]
        if name == "PhysicalProperties":
            return "nil" if default_exp and default_exp[0] == "nil" else None
        if name in SAME_TYPEOF:
            return name
        return None
    if cat == "Class":
        return "nil" if default_exp and default_exp[0] == "nil" else None
    return None


def gen_properties(api):
    """Yields (type_blocks, default_blocks) per concrete class."""
    per_class = defaultdict(list)   # concrete class -> list of (decl, member)
    for decl in api.classes:
        for m in api.members(decl, "Property"):
            if not readable(m):
                continue
            targets = api.concrete(decl)
            if not targets:
                continue
            if api.is_creatable(decl):
                chosen = set(targets[:3]) | {decl}
            else:
                chosen = set(targets[:3])
            # every subclass whose default differs from the majority is checked too
            vals = {}
            for t in targets:
                rv = api.rbx_default(t, m["Name"])
                vals[t] = json.dumps(rv, sort_keys=True, default=str) if rv is not None else None
            common = Counter(v for v in vals.values() if v is not None).most_common(1)
            if common:
                for t, v in vals.items():
                    if v is not None and v != common[0][0]:
                        chosen.add(t)
            for t in chosen:
                per_class[t].append((decl, m))
    type_blocks, def_blocks = [], []
    for cn in sorted(per_class, key=lambda n: (POP_RANK.get(n, 10_000), n)):
        setup = [f"local o = Instance.new({lstr(cn)})"]
        tchecks, dchecks = [], []
        for decl, m in sorted(per_class[cn], key=lambda x: x[1]["Name"]):
            pn = m["Name"]
            vt = m["ValueType"]
            tags = m.get("Tags") or []
            # expected default: dump value for members declared on this class, else rbx-dom
            exp = None
            if decl == cn:
                exp = expected_from_dump(api, m, vt["Name"], vt["Category"], m.get("Default"))
            rv = api.rbx_default(cn, pn)
            rexp = expected_from_rbx(api, vt["Name"], vt["Category"], rv) if rv is not None else None
            if exp is not None and rexp is not None and exp[0] == rexp[0] and exp[0] in ("bool", "int", "str", "enum") and exp[1] != rexp[1]:
                exp = None  # sources disagree -> unknowable here
                rexp = None
            if exp is None:
                exp = rexp
            if vt["Category"] == "Class" and exp is None and pn not in VOLATILE_PROPS:
                # object references of a freshly created, unparented instance are unset
                exp = ("nil", None)
            if pn == "Name":
                exp = ("str", cn)
            elif pn == "Parent":
                exp = ("nil", None)
            elif pn == "ClassName":
                exp = ("str", cn)
            ty = typeof_for(api, m, exp)
            access = idx("o", pn)
            if ty is not None:
                body = f'return TY({access}, "{ty}")'
                if ty == "EnumItem":
                    body = f'local v = {access}; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.{vt["Name"]})'
                tchecks.append(T(f"prop.type.{cn}.{pn}", body))
            value_checkable = pn == "ClassName" or (pn not in VOLATILE_PROPS and "ReadOnly" not in tags)
            if exp is not None and value_checkable:
                try:
                    dchecks.append(T(f"prop.default.{cn}.{pn}", emit_value_check(access, exp)))
                except ValueError:
                    pass
        if tchecks:
            type_blocks.append((setup, tchecks))
        if dchecks:
            def_blocks.append((setup, dchecks))
    return type_blocks, def_blocks


def member_targets(api, decl):
    conc = api.concrete(decl)
    if not conc:
        return []
    n = 8 if decl == "Instance" else 2
    picks = conc[:n]
    if decl in conc and decl not in picks:
        picks.append(decl)
    return picks


def gen_members(api):
    per_class = defaultdict(list)
    for decl in api.classes:
        targets = member_targets(api, decl)
        if not targets:
            continue
        for kind in ("Function", "Event", "Callback"):
            for m in api.members(decl, kind):
                tags = m.get("Tags") or []
                sec = m.get("Security")
                if "NotScriptable" in tags or (sec not in (None, "None")):
                    continue
                for t in targets:
                    per_class[t].append((decl, m))
    blocks = []
    for cn in sorted(per_class, key=lambda n: (POP_RANK.get(n, 10_000), n)):
        setup = [f"local o = Instance.new({lstr(cn)})"]
        checks = []
        for decl, m in sorted(per_class[cn], key=lambda x: (x[1]["MemberType"], x[1]["Name"])):
            name = m["Name"]
            access = idx("o", name)
            if m["MemberType"] == "Function":
                checks.append(T(f"member.method.{cn}.{name}", f'return TY({access}, "function")'))
            elif m["MemberType"] == "Event":
                if "Deprecated" in (m.get("Tags") or []):
                    # which descriptor name a deprecated alias reports in tostring() is not documented
                    checks.append(T(f"member.event.{cn}.{name}", f'return TY({access}, "RBXScriptSignal")'))
                else:
                    checks.append(T(f"member.event.{cn}.{name}",
                                    f'local s = {access}; A(TY(s, "RBXScriptSignal")); return EQ(tostring(s), {lstr("Signal " + name)})'))
            elif m["MemberType"] == "Callback":
                msg = f"{name} is a callback member of {cn}; you can only set the callback value, get is not available"
                checks.append(T(f"member.callback.{cn}.{name}",
                                f"return ERR(function() return {access} end, {lstr(msg)})"))
        checks.append(T(f"member.invalid.{cn}",
                        f"return ERR(function() return o.NotARealMember_zq end, {lstr('NotARealMember_zq is not a valid member of ' + cn + ' \"' + cn + '\"')})"))
        blocks.append((setup, checks))
    return blocks


def gen_readonly(api):
    blocks = []
    for cn in sorted(api.classes, key=lambda n: (POP_RANK.get(n, 10_000), n)):
        if not api.is_creatable(cn):
            continue
        checks = []
        seen = set()
        for anc in api.chain(cn):
            for m in api.members(anc, "Property"):
                tags = m.get("Tags") or []
                if m["Name"] in seen or "ReadOnly" not in tags or not readable(m):
                    continue
                seen.add(m["Name"])
                # inherited read-only members are only exercised on a few concrete classes
                if anc != cn and cn not in member_targets(api, anc):
                    continue
                pn = m["Name"]
                access = idx("o", pn)
                if pn == "ClassName" or "Deprecated" in tags:
                    # the write must fail; the exact wording for these two shapes is not documented
                    checks.append(T(f"readonly.{cn}.{pn}", f"return ERR(function() {access} = {access} end)"))
                else:
                    checks.append(T(f"readonly.{cn}.{pn}",
                                    f"return ERR(function() {access} = {access} end, {lstr('Unable to assign property ' + pn + '. Property is read only')})"))
        if checks:
            blocks.append(([f"local o = Instance.new({lstr(cn)})"], checks))
    return blocks


CLIENT_SERVICES = """Players Workspace Lighting ReplicatedStorage ReplicatedFirst StarterGui StarterPack StarterPlayer
Teams SoundService Chat LocalizationService RunService UserInputService ContextActionService TweenService
HttpService MarketplaceService TeleportService CollectionService Debris PathfindingService PhysicsService
TextService GuiService GroupService BadgeService InsertService ContentProvider SocialService PolicyService
VRService HapticService TextChatService VoiceChatService AvatarEditorService AssetService
KeyframeSequenceProvider LogService Stats CoreGui ServerStorage ServerScriptService DataStoreService
MaterialService ScriptContext UserService AnalyticsService ChangeHistoryService Selection CaptureService
AdService AnimationClipProvider ExperienceNotificationService MessagingService NetworkClient GamepadService
ControllerService TextBoxService""".split()


def gen_services(api):
    blocks = []
    for sn in CLIENT_SERVICES:
        if sn not in api.classes or "Service" not in api.tags(sn):
            continue
        setup = [f"local ok, s = pcall(function() return game:GetService({lstr(sn)}) end)"]
        checks = [
            T(f"service.get.{sn}", f'A(EQ(ok, true)); A(TY(s, "Instance")); return EQ(s.ClassName, {lstr(sn)})'),
            T(f"service.identity.{sn}", f"return EQ(game:GetService({lstr(sn)}), s)"),
            T(f"service.find.{sn}", f"return EQ(game:FindService({lstr(sn)}), s)"),
            T(f"service.notcreatable.{sn}", f"return ERR(function() return Instance.new({lstr(sn)}) end)"),
        ]
        for anc in api.chain(sn):
            if anc != "Object":
                checks.append(T(f"service.isa.{sn}.{anc}", f"return EQ(s:IsA({lstr(anc)}), true)"))
        seen = set()
        for anc in api.chain(sn):
            for m in api.classes[anc]["Members"]:
                name, kind, tags = m["Name"], m["MemberType"], m.get("Tags") or []
                if name in seen or "NotScriptable" in tags:
                    continue
                seen.add(name)
                access = idx("s", name)
                # Instance-level members are covered by the creatable-class suites
                if anc in ("Instance", "Object") and sn != "Workspace":
                    continue
                if kind == "Property" and readable(m):
                    ty = typeof_for(api, m, None)
                    if ty is None or ty == "nil":
                        continue
                    if ty == "EnumItem":
                        checks.append(T(f"service.prop.{sn}.{name}", f'local v = {access}; A(TY(v, "EnumItem")); return EQ(v.EnumType, Enum.{m["ValueType"]["Name"]})'))
                    else:
                        checks.append(T(f"service.prop.{sn}.{name}", f'return TY({access}, "{ty}")'))
                elif kind == "Function" and m.get("Security") in (None, "None"):
                    checks.append(T(f"service.method.{sn}.{name}", f'return TY({access}, "function")'))
                elif kind == "Event" and m.get("Security") in (None, "None"):
                    if "Deprecated" in tags:
                        checks.append(T(f"service.event.{sn}.{name}", f'return TY({access}, "RBXScriptSignal")'))
                    else:
                        checks.append(T(f"service.event.{sn}.{name}",
                                        f'local e = {access}; A(TY(e, "RBXScriptSignal")); return EQ(tostring(e), {lstr("Signal " + name)})'))
        blocks.append((setup, checks))
    # the DataModel itself
    checks = [T("service.datamodel.class", 'A(TY(game, "Instance")); return EQ(game.ClassName, "DataModel")'),
              T("service.datamodel.workspace", "return EQ(game:GetService(\"Workspace\"), workspace)"),
              T("service.bogus.getservice", 'return ERR(function() return game:GetService("NotAService_zq") end)'),
              T("service.bogus.findservice", 'return EQ(game:FindService("NotAService_zq"), nil)')]
    for anc in api.chain("DataModel"):
        if anc in ("Instance", "Object"):
            continue
        for m in api.classes[anc]["Members"]:
            name, kind, tags = m["Name"], m["MemberType"], m.get("Tags") or []
            if "NotScriptable" in tags:
                continue
            access = idx("game", name)
            if kind == "Function" and m.get("Security") in (None, "None"):
                checks.append(T(f"service.method.DataModel.{name}", f'return TY({access}, "function")'))
            elif kind == "Event" and m.get("Security") in (None, "None") and "Deprecated" not in tags:
                checks.append(T(f"service.event.DataModel.{name}",
                                f'local e = {access}; A(TY(e, "RBXScriptSignal")); return EQ(tostring(e), {lstr("Signal " + name)})'))
    blocks.append(([], checks))
    return blocks


def gen_enums(api):
    blocks = []
    for en in sorted(api.enums):
        e = api.enums[en]
        checks = []
        checks.append(T(f"enum.type.{en}", f"return TY(Enum.{en}, \"Enum\")"))
        checks.append(T(f"enum.tostring.{en}", f"return EQ(tostring(Enum.{en}), {lstr(en)})"))
        items = e["Items"]
        if not any(it.get("Tags") for it in items):
            checks.append(T(f"enum.count.{en}", f"return EQ(#Enum.{en}:GetEnumItems(), {len(items)})"))
        for it in items:
            iname, val = it["Name"], it["Value"]
            ref = f"Enum.{en}.{iname}" if ident_ok(iname) else f"Enum.{en}[{lstr(iname)}]"
            checks.append(T(f"enum.item.{en}.{iname}",
                            f'local i = {ref}; A(TY(i, "EnumItem")); A(EQ(i.Name, {lstr(iname)})); A(EQ(i.Value, {val})); return EQ(i.EnumType, Enum.{en})'))
            checks.append(T(f"enum.itemstr.{en}.{iname}",
                            f"local i = {ref}; A(EQ(tostring(i), {lstr('Enum.' + en + '.' + iname)})); "
                            f"A(EQ(Enum.{en}:FromValue({val}), i)); return EQ(Enum.{en}:FromName({lstr(iname)}), i)"))
            for legacy in it.get("LegacyNames") or []:
                checks.append(T(f"enum.legacy.{en}.{legacy}", f"return EQ(Enum.{en}[{lstr(legacy)}], {ref})"))
        blocks.append(([], checks))
    return blocks


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dump", default=os.path.join(CACHE, "Full-API-Dump.json"))
    ap.add_argument("--rbxdb", default=os.path.join(CACHE, "rbx_reflection_database.crate"))
    ap.add_argument("--out", default=os.path.join(ROOT, "suites"))
    args = ap.parse_args()
    if args.dump == os.path.join(CACHE, "Full-API-Dump.json"):
        fetch(DUMP_URL, args.dump)
        fetch(VERSION_URL, os.path.join(CACHE, "version.txt"))
    if args.rbxdb == os.path.join(CACHE, "rbx_reflection_database.crate"):
        fetch(RBXDB_CRATE, args.rbxdb)
    dump = json.load(open(args.dump, encoding="utf-8"))
    api = Api(dump, load_rbxdb(args.rbxdb))
    harness = open(os.path.join(ROOT, "harness.luau"), encoding="utf-8").read()
    os.makedirs(args.out, exist_ok=True)
    for f in os.listdir(args.out):
        if f.startswith("api_") and f.endswith(".luau"):
            os.remove(os.path.join(args.out, f))
    manifest = {}
    write_suites("api_classes", gen_classes(api), args.out, manifest, harness)
    tb, db = gen_properties(api)
    write_suites("api_prop_types", tb, args.out, manifest, harness)
    write_suites("api_prop_defaults", db, args.out, manifest, harness)
    write_suites("api_members", gen_members(api), args.out, manifest, harness)
    write_suites("api_readonly", gen_readonly(api), args.out, manifest, harness)
    write_suites("api_services", gen_services(api), args.out, manifest, harness)
    write_suites("api_enums", gen_enums(api), args.out, manifest, harness)
    mpath = os.path.join(args.out, "manifest_api.json")
    json.dump(dict(sorted(manifest.items())), open(mpath, "w"), indent=1)
    print(f"{sum(manifest.values())} API checks in {len(manifest)} suites -> {args.out}")
    for k, v in sorted(manifest.items()):
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()
