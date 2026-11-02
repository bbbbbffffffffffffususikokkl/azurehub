#!/usr/bin/env python3
"""Regenerate the data blocks that envlogger embeds from Roblox's own API data.

Rewrites, in place, the regions of the logger delimited by
    -- [v1.7 GENERATED:<name> BEGIN] ... -- [v1.7 GENERATED:<name> END]
inserting them at fixed anchors on first run:
  * enum-sync     exact enum/item/value set of the API dump + LegacyNames aliases
  * defaults      Instance.new() property defaults (dump + rbx-dom), compact rows
  * materials     per-material PhysicalProperties (Creator Hub table)

Usage: gen_logger_patch.py [--logger ../envlogger_v1.7.lua]
"""
import argparse
import json
import math
import os
import re
import sys
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import gen_api_checks as G  # noqa: E402
import gen_docs_checks as D  # noqa: E402


def num(x):
    if isinstance(x, bool):
        return "1" if x else "0"
    if isinstance(x, int):
        return str(x)
    if math.isinf(x):
        return "inf" if x > 0 else "-inf"
    if math.isnan(x):
        return "nan"
    r = repr(float(x))
    return r[:-2] if r.endswith(".0") else r


def spec_for(exp):
    """Encode an expectation as a DEFAULTS literal (kinds understood by dumpDefault)."""
    kind, p = exp
    if kind == "bool":
        return "b" + ("1" if p else "0")
    if kind in ("int", "num"):
        return "n" + num(p)
    if kind == "str":
        if "|" in p or "\n" in p or ";" in p or "]]" in p:
            return None
        return "s" + p
    if kind == "enum":
        return "@EN:%s.%s" % p
    if kind == "nil":
        return "@NIL"
    if kind == "vec":
        tn, comps = p
        tag = {"Vector3": "V3", "Vector2": "V2", "Color3": "C3"}[tn]
        return "@%s:%s" % (tag, ",".join(num(c) for c in comps))
    if kind == "udim2":
        return "@U2:" + ",".join(num(c) for c in p)
    if kind == "udim":
        return "@U1:" + ",".join(num(c) for c in p)
    if kind == "cframe":
        return "@CF:" + ",".join(num(c) for c in p)
    if kind == "nrange":
        return "@NR:" + ",".join(num(c) for c in p)
    if kind == "rect":
        return "@RC:" + ",".join(num(c) for c in p)
    if kind == "brick":
        return "@BC:%d" % p
    if kind == "nseq":
        return "@NS:" + ",".join(num(c) for kp in p for c in kp)
    if kind == "cseq":
        return "@CS:" + ",".join(num(c) for kp in p for c in kp)
    if kind == "font":
        fam, weight, style = p
        if ";" in fam or "|" in fam:
            return None
        return "@FN:%s;%s;%s" % (fam, weight, style)
    if kind == "faces":
        return "@FA:%d" % p
    if kind == "axes":
        return "@AX:%d" % p
    if kind == "content_none":
        return "@CN:"
    if kind == "ray":
        return "@RY:" + ",".join(num(c) for c in p)
    return None


def expected_default(api, cn, decl, m):
    """Same derivation the generated checks use."""
    pn, vt = m["Name"], m["ValueType"]
    exp = None
    if decl == cn:
        exp = G.expected_from_dump(api, m, vt["Name"], vt["Category"], m.get("Default"))
    rv = api.rbx_default(cn, pn)
    rexp = G.expected_from_rbx(api, vt["Name"], vt["Category"], rv) if rv is not None else None
    if exp is not None and rexp is not None and exp[0] == rexp[0] and exp[0] in ("bool", "int", "str", "enum") and exp[1] != rexp[1]:
        return None
    if exp is None:
        exp = rexp
    if vt["Category"] == "Class" and exp is None and pn not in G.VOLATILE_PROPS:
        exp = ("nil", None)
    return exp


def existing_default_rows(src):
    rows = {}
    for block in re.findall(r"robloxApi\.DEFAULTS = (?:robloxApi\.DEFAULTS \.\. )?\[\[\n(.*?)\]\]", src, re.S):
        for line in block.splitlines():
            parts = line.split("|", 2)
            if len(parts) == 3:
                rows[(parts[0], parts[1])] = parts[2]
    return rows


def gen_defaults(api, src):
    existing = existing_default_rows(src)
    rows = {}
    for decl in api.classes:
        for m in api.members(decl, "Property"):
            if not G.readable(m):
                continue
            pn = m["Name"]
            if pn in G.VOLATILE_PROPS or pn in ("Name", "ClassName", "Parent"):
                continue
            # every creatable descendant, including the ones the checks leave out
            conc = [c for c in api.descendants(decl)
                    if "NotCreatable" not in api.tags(c) and "Service" not in api.tags(c)]
            specs = {}
            for c in conc:
                exp = expected_default(api, c, decl, m)
                if exp is None:
                    continue
                s = spec_for(exp)
                if s is not None:
                    specs[c] = s
            if not specs:
                continue
            majority = Counter(specs.values()).most_common(1)[0][0]
            rows[(decl, pn)] = majority
            for c, s in specs.items():
                if s != majority or (c, pn) in existing:
                    rows[(c, pn)] = s
    return rows


def render_defaults(rows):
    lines, cur = [], []
    for (c, p), s in sorted(rows.items()):
        cur.append("%s|%s|%s" % (c, p, s))
        if len(cur) == 40:
            lines.append(";".join(cur))
            cur = []
    if cur:
        lines.append(";".join(cur))
    body = "\n".join(lines)
    return ("-- Instance.new() property defaults of the %s dump (own-class defaults) and rbx-dom's\n"
            "-- reflection database (inherited defaults), derived by detections/tools/gen_logger_patch.py.\n"
            "-- Rows are Class|Property|literal separated by ';'; they override the older tables above.\n"
            "robloxApi.DEFAULTS_V17 = [[\n%s\n]]\n" % (api_version(), body))


def gen_enum_sync(api):
    lines = []
    for en in sorted(api.enums):
        e = api.enums[en]
        items = ",".join("%s:%d" % (it["Name"], it["Value"]) for it in e["Items"])
        legacy = ",".join("%s>%s" % (ln, it["Name"]) for it in e["Items"] for ln in (it.get("LegacyNames") or []))
        lines.append("%s=%s%s" % (en, items, ("|" + legacy) if legacy else ""))
    data = "\n".join(lines)
    return """-- Exact enum set of the %s dump: replaces every older layer above, drops items the engine
-- no longer has, and records LegacyNames aliases (Enum.Axis.Left == Enum.Axis.X). Generated by
-- detections/tools/gen_logger_patch.py.
do
    local ENUMS = [[
%s
]]
    local seen, legacy = {}, {}
    for row in ENUMS:gmatch("[^\\n]+") do
        local en, items, aliases = row:match("^([^=]+)=([^|]*)|?(.*)$")
        seen[en] = true
        local ks = knownEnumItems[en]; if not ks then ks = {}; knownEnumItems[en] = ks end
        local vs = enumItemValues[en]; if not vs then vs = {}; enumItemValues[en] = vs end
        for k in pairsFunction(ks) do ks[k] = nil end
        for k in pairsFunction(vs) do vs[k] = nil end
        for it, v in items:gmatch("([%%w_ ]+):(-?%%d+)") do ks[it] = 1; vs[it] = tonumber(v) end
        if aliases ~= "" then
            local map = {}
            for old, new in aliases:gmatch("([^,>]+)>([^,]+)") do map[old] = new end
            legacy[en] = map
        end
        local d = robloxApi.enumdefault[en]
        if d ~= nil and ks[d] == nil then
            robloxApi.enumdefault[en] = (legacy[en] and legacy[en][d]) or nil
        end
    end
    for en in pairsFunction(knownEnumItems) do
        if not seen[en] then knownEnumItems[en] = nil; enumItemValues[en] = nil; robloxApi.enumdefault[en] = nil end
    end
    robloxApi.enumLegacy = legacy
end
""" % (api_version(), data)


def gen_materials():
    mats = D.materials()
    body = ",\n".join("    %s={%s,%s,%s,%s,%s}" % (m["name"], num(m["density"]), num(m["friction"]), num(m["elasticity"]),
                                                   num(m["frictionWeight"]), num(m["elasticityWeight"])) for m in mats)
    return "local _materialPhysTable = {\n%s,\n}\n" % body


_VERSION = [None]


def api_version():
    return _VERSION[0] or "Roblox"


def replace_block(src, name, text, anchor_re, before=True):
    begin = "-- [v1.7 GENERATED:%s BEGIN]" % name
    end = "-- [v1.7 GENERATED:%s END]" % name
    block = "%s\n%s%s\n" % (begin, text, end)
    if begin in src:
        i = src.index(begin)
        j = src.index(end, i) + len(end) + 1
        return src[:i] + block + src[j:]
    m = re.search(anchor_re, src, re.M)
    if not m:
        sys.exit("anchor not found for " + name)
    pos = m.start() if before else m.end()
    return src[:pos] + block + src[pos:]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--logger", default=os.path.join(os.path.dirname(ROOT), "envlogger_v1.7.lua"))
    args = ap.parse_args()
    dump = json.load(open(os.path.join(ROOT, ".cache", "Full-API-Dump.json"), encoding="utf-8"))
    vpath = os.path.join(ROOT, ".cache", "version.txt")
    _VERSION[0] = open(vpath).read().strip() if os.path.exists(vpath) else None
    api = G.Api(dump, G.load_rbxdb(os.path.join(ROOT, ".cache", "rbx_reflection_database.crate")))
    D.fetch_all()
    src = open(args.logger, encoding="utf-8").read()
    src = replace_block(src, "enum-sync", gen_enum_sync(api), r"^local function setupEnumMeta\(e\)")
    rows = gen_defaults(api, src)
    src = replace_block(src, "defaults", render_defaults(rows), r"^robloxApi\.dumpDefault = function\(className, key\)")
    # material table: swap the literal in place (keeps the existing local)
    mat = gen_materials()
    if "-- [v1.7 GENERATED:materials BEGIN]" in src:
        src = replace_block(src, "materials", mat, None)
    else:
        m = re.search(r"^local _materialPhysTable = \{.*?^\}\n", src, re.S | re.M)
        if not m:
            sys.exit("material table not found")
        block = "-- [v1.7 GENERATED:materials BEGIN]\n%s-- [v1.7 GENERATED:materials END]\n" % mat
        src = src[:m.start()] + block + src[m.end():]
    open(args.logger, "w", encoding="utf-8").write(src)
    print("enum-sync: %d enums; defaults: %d rows; materials: %d" % (len(api.enums), len(rows), len(D.materials())))


if __name__ == "__main__":
    main()
