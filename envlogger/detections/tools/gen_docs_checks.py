#!/usr/bin/env python3
"""Generate detection suites from Roblox's official reference data (Roblox/creator-docs).

  * BrickColor colour table (datatypes/BrickColor.yaml): number <-> name, RGB, palette index,
    nearest-colour construction.
  * Material physical properties table (parts/materials.md): PhysicalProperties.new(material).

Inputs are fetched into detections/.cache/docs/ when missing.
"""
import json
import os
import re
import sys
import urllib.request
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DOCS = os.path.join(ROOT, ".cache", "docs")
SOURCES = {
    "BrickColor.yaml": "https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/datatypes/BrickColor.yaml",
    "materials.md": "https://create.roblox.com/docs/en-us/parts/materials.md",
}
sys.path.insert(0, HERE)
from gen_api_checks import lstr, write_suites, T  # noqa: E402


def fetch_all():
    os.makedirs(DOCS, exist_ok=True)
    for name, url in SOURCES.items():
        path = os.path.join(DOCS, name)
        if not os.path.exists(path):
            print("downloading", url, file=sys.stderr)
            urllib.request.urlretrieve(url, path)


def brickcolors():
    s = open(os.path.join(DOCS, "BrickColor.yaml"), encoding="utf-8").read()
    rows = re.findall(r"<tr>\s*<td><ColorSwatch[^>]*/></td>\s*<td>([^<]*)</td>\s*<td><code>(\d+)</code></td>\s*"
                      r"<td>(?:<code>(\d+)</code>)?</td>\s*<td><code>(\d+), (\d+), (\d+)</code></td>", s)
    out = []
    for name, num, pal, r, g, b in rows:
        out.append({"name": name.strip(), "number": int(num), "palette": int(pal) if pal else None,
                    "rgb": (int(r), int(g), int(b))})
    if len(out) < 200:
        sys.exit("BrickColor table parse failed: %d rows" % len(out))
    return out


def materials():
    s = open(os.path.join(DOCS, "materials.md"), encoding="utf-8").read()
    head = s.index("| Material | Density | Elasticity | ElasticityWeight | Friction | FrictionWeight |")
    out = []
    for line in s[head:].splitlines()[2:]:
        if not line.startswith("|"):
            break
        cells = [c.strip().strip("`") for c in line.strip("|").split("|")]
        # first cell is `Enum.Material.X\|X` -> split produced an extra cell
        name = cells[0].split(".")[-1].rstrip("\\")
        nums = [float(c) for c in cells[2:7]]
        out.append({"name": name, "density": nums[0], "elasticity": nums[1], "elasticityWeight": nums[2],
                    "friction": nums[3], "frictionWeight": nums[4]})
    if len(out) < 40:
        sys.exit("materials table parse failed: %d rows" % len(out))
    return out


def gen_brickcolor_blocks(colors):
    name_count = Counter(c["name"] for c in colors)
    rgb_count = Counter(c["rgb"] for c in colors)
    blocks = []
    for c in colors:
        n, name, (r, g, b) = c["number"], c["name"], c["rgb"]
        checks = [
            T(f"brickcolor.number_to_name.{n}", f"return EQ(BrickColor.new({n}).Name, {lstr(name)})"),
            T(f"brickcolor.tostring.{n}", f"return EQ(tostring(BrickColor.new({n})), {lstr(name)})"),
            T(f"brickcolor.rgb.{n}", f"local c = BrickColor.new({n}).Color; return NEARV({{c.R, c.G, c.B}}, {{{r}/255, {g}/255, {b}/255}}, 1e-6)"),
            T(f"brickcolor.number_field.{n}", f"return EQ(BrickColor.new({n}).Number, {n})"),
        ]
        if name_count[name] == 1:
            checks.append(T(f"brickcolor.name_to_number.{n}", f"return EQ(BrickColor.new({lstr(name)}).Number, {n})"))
        # nearest-colour matching is only asserted for palette colours: whether the engine also
        # considers the 80 non-palette colours is not documented
        if rgb_count[(r, g, b)] == 1 and c["palette"] is not None:
            checks.append(T(f"brickcolor.nearest_self.{n}", f"return EQ(BrickColor.new(Color3.fromRGB({r}, {g}, {b})).Number, {n})"))
        if c["palette"] is not None:
            checks.append(T(f"brickcolor.palette.{c['palette']}", f"return EQ(BrickColor.palette({c['palette']}).Number, {n})"))
        blocks.append(([], checks))
    extra = [
        T("brickcolor.palette_out_of_range", "return ERR(function() return BrickColor.palette(128) end)"),
        T("brickcolor.palette_negative", "return ERR(function() return BrickColor.palette(-1) end)"),
        T("brickcolor.unknown_number", "return EQ(BrickColor.new(987654).Name, \"Medium stone grey\")"),
        T("brickcolor.unknown_name", "return EQ(BrickColor.new(\"No such colour zq\").Name, \"Medium stone grey\")"),
        T("brickcolor.random_type", "return TY(BrickColor.random(), \"BrickColor\")"),
        T("brickcolor.random_in_palette", """local palette = {}
        for i = 0, 127 do palette[BrickColor.palette(i).Number] = true end
        for _ = 1, 50 do local b = BrickColor.random(); if not palette[b.Number] then return false, "not in palette: " .. b.Number end end
        return true"""),
        T("brickcolor.count_palette_unique", """local seen, n = {}, 0
        for i = 0, 127 do local num = BrickColor.palette(i).Number; if not seen[num] then seen[num] = true; n += 1 end end
        return EQ(n, 128)"""),
    ]
    blocks.append(([], extra))
    return blocks


def gen_material_blocks(mats):
    blocks = []
    for m in mats:
        name = m["name"]
        setup = [f"local ok, pp = pcall(PhysicalProperties.new, Enum.Material.{name})"]
        checks = [T(f"physprops.{name}.ok", 'A(EQ(ok, true)); return TY(pp, "PhysicalProperties")')]
        for field, key in (("Density", "density"), ("Elasticity", "elasticity"), ("ElasticityWeight", "elasticityWeight"),
                           ("Friction", "friction"), ("FrictionWeight", "frictionWeight")):
            checks.append(T(f"physprops.{name}.{field}", f"return NEAR(pp.{field}, {m[key]!r}, 1e-6)"))
        blocks.append((setup, checks))
    return blocks


def main():
    fetch_all()
    harness = open(os.path.join(ROOT, "harness.luau"), encoding="utf-8").read()
    out = os.path.join(ROOT, "suites")
    for f in os.listdir(out):
        if f.startswith("docs_") and f.endswith(".luau"):
            os.remove(os.path.join(out, f))
    manifest = {}
    write_suites("docs_brickcolor", gen_brickcolor_blocks(brickcolors()), out, manifest, harness)
    write_suites("docs_materials", gen_material_blocks(materials()), out, manifest, harness)
    json.dump(dict(sorted(manifest.items())), open(os.path.join(out, "manifest_docs.json"), "w"), indent=1)
    print(f"{sum(manifest.values())} docs checks in {len(manifest)} suites")
    for k, v in sorted(manifest.items()):
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()
