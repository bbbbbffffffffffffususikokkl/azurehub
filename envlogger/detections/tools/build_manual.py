#!/usr/bin/env python3
"""Wrap the hand-written detection sources (manual/*.luau) with the harness.

manual/<name>.luau  ->  suites/manual_<name>.luau
The sources only contain T(...) checks (plus local helpers); the harness supplies T, EQ, NEAR,
NEARV, TY, ERR, OK and A.  The static T( count is recorded in suites/manifest_manual.json and
is used as the failure count if a suite dies before reporting.
"""
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


def main():
    harness = open(os.path.join(ROOT, "harness.luau"), encoding="utf-8").read()
    src_dir = os.path.join(ROOT, "manual")
    out_dir = os.path.join(ROOT, "suites")
    os.makedirs(out_dir, exist_ok=True)
    for f in os.listdir(out_dir):
        if f.startswith("manual_") and f.endswith(".luau"):
            os.remove(os.path.join(out_dir, f))
    manifest = {}
    for f in sorted(os.listdir(src_dir)):
        if not f.endswith(".luau"):
            continue
        name = "manual_" + f[:-5]
        body = open(os.path.join(src_dir, f), encoding="utf-8").read()
        text = (harness.replace("%SUITE%", name) + "\n" + body.rstrip() + "\n"
                + '__print("@@E|" .. __suite .. "|" .. __total .. "|" .. __pass .. "|" .. __fail)\n')
        with open(os.path.join(out_dir, name + ".luau"), "w", encoding="utf-8") as fh:
            fh.write(text)
        manifest[name] = len(re.findall(r"\bT\(", body))
    json.dump(manifest, open(os.path.join(out_dir, "manifest_manual.json"), "w"), indent=1)
    for k, v in manifest.items():
        print(f"{k}: {v} static checks")


if __name__ == "__main__":
    main()
