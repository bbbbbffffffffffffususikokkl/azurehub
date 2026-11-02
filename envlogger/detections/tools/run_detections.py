#!/usr/bin/env python3
"""Run envlogger detection suites through the logger and report pass/fail.

Each suite is executed as the analysed script:  lune run <logger> <suite> <dump>.
The harness prints @@B / @@F / @@E markers; the logger records those print() calls in the
dump, which is parsed here.  A suite without its @@E marker (crash, timeout, logger abort)
counts every one of its checks as failed.

  run_detections.py                       # all suites, plain mode
  run_detections.py --mode both           # also run a packed (single-line) copy, which drives
                                          # the logger's "obfuscated input" code path
  run_detections.py -k api_enums -k manual_path2d
  run_detections.py --logger ../envlogger_v1.6.lua --json results.json
"""
import argparse
import concurrent.futures as cf
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEFAULT_LOGGER = os.path.join(os.path.dirname(ROOT), "envlogger_v1.7.lua")
PRINT_RE = re.compile(r'^\s*print\((".*")\)\s*$')


def lua_unescape(lit):
    """Decode one double-quoted Lua string literal as written by the logger's serializer."""
    assert lit[0] == '"' and lit[-1] == '"'
    s, out, i = lit[1:-1], bytearray(), 0
    simple = {"n": 10, "t": 9, "r": 13, "a": 7, "b": 8, "f": 12, "v": 11, "\\": 92, '"': 34, "'": 39, "\n": 10}
    while i < len(s):
        c = s[i]
        if c != "\\":
            out += c.encode("utf-8")
            i += 1
            continue
        i += 1
        c = s[i] if i < len(s) else ""
        if c in simple:
            out.append(simple[c])
            i += 1
        elif c == "x":
            out.append(int(s[i + 1:i + 3], 16))
            i += 3
        elif c == "u":
            j = s.index("}", i)
            out += chr(int(s[i + 2:j], 16)).encode("utf-8")
            i = j + 1
        elif c == "z":
            i += 1
            while i < len(s) and s[i] in " \t\r\n":
                i += 1
        elif c.isdigit():
            j = i
            while j < len(s) and j < i + 3 and s[j].isdigit():
                j += 1
            out.append(int(s[i:j]) & 255)
            i = j
        else:
            out += ("\\" + c).encode("utf-8")
            i += 1
    return out.decode("utf-8", "replace")


def strip_comments(src):
    """Remove Lua comments (line and long) while respecting strings, for packing."""
    out, i, n = [], 0, len(src)

    def long_bracket(at):
        m = re.match(r"\[(=*)\[", src[at:])
        return m.group(1) if m else None

    while i < n:
        c = src[i]
        if src.startswith("--", i):
            lvl = long_bracket(i + 2)
            if lvl is not None:
                end = src.find("]" + lvl + "]", i)
                i = n if end < 0 else end + len(lvl) + 2
            else:
                j = src.find("\n", i)
                i = n if j < 0 else j
            continue
        if c in "\"'":
            j = i + 1
            while j < n and src[j] != c:
                j += 2 if src[j] == "\\" else 1
            out.append(src[i:j + 1])
            i = j + 1
            continue
        if c == "[":
            lvl = long_bracket(i)
            if lvl is not None:
                end = src.find("]" + lvl + "]", i)
                end = n if end < 0 else end + len(lvl) + 2
                out.append(src[i:end])
                i = end
                continue
        out.append(c)
        i += 1
    return "".join(out)


def pack(src):
    """One-line copy of a suite: average line length > 250 trips the logger's obfuscation heuristic."""
    body = strip_comments(src)
    return " ".join(line.strip() for line in body.splitlines() if line.strip()) + "\n"


def find_lune(explicit):
    for cand in [explicit, os.environ.get("LUNE"), shutil.which("lune")]:
        if cand and os.path.exists(cand):
            return cand
    sys.exit("lune not found: pass --lune or set LUNE")


def run_suite(lune, logger, suite_path, mode, timeout, keep_dir):
    name = os.path.splitext(os.path.basename(suite_path))[0]
    work = tempfile.mkdtemp(prefix="envdet_")
    try:
        src = open(suite_path, encoding="utf-8").read()
        inp = os.path.join(work, name + (".packed" if mode == "packed" else "") + ".luau")
        with open(inp, "w", encoding="utf-8") as fh:
            fh.write(pack(src) if mode == "packed" else src)
        dump = os.path.join(work, "dump_" + name + ".lua")
        t0 = time.time()
        try:
            proc = subprocess.run([lune, "run", logger, inp, dump], cwd=work, capture_output=True,
                                  text=True, timeout=timeout)
            rc, stdout, stderr = proc.returncode, proc.stdout, proc.stderr
        except subprocess.TimeoutExpired as ex:
            rc, stdout, stderr = "timeout", (ex.stdout or b"").decode("utf-8", "replace") if isinstance(ex.stdout, bytes) else (ex.stdout or ""), ""
        elapsed = time.time() - t0
        fails, began, ended = [], False, None
        text = open(dump, encoding="utf-8", errors="replace").read() if os.path.exists(dump) else ""
        for line in text.splitlines():
            m = PRINT_RE.match(line)
            if not m:
                continue
            try:
                msg = lua_unescape(m.group(1))
            except Exception:
                continue
            if msg.startswith("@@B|"):
                began = True
            elif msg.startswith("@@F|"):
                _, cid, detail = (msg.split("|", 2) + [""])[:3]
                fails.append((cid, detail))
            elif msg.startswith("@@E|"):
                parts = msg.split("|")
                ended = tuple(int(x) for x in parts[2:5])
        if keep_dir:
            os.makedirs(keep_dir, exist_ok=True)
            shutil.copy(dump, os.path.join(keep_dir, f"{name}.{mode}.dump.lua")) if os.path.exists(dump) else None
            with open(os.path.join(keep_dir, f"{name}.{mode}.stdout.txt"), "w") as fh:
                fh.write(f"rc={rc}\n--- stdout ---\n{stdout}\n--- stderr ---\n{stderr}\n")
        return {"suite": name, "mode": mode, "rc": rc, "elapsed": round(elapsed, 2), "began": began,
                "ended": ended, "fails": fails, "stdout_tail": (stdout or "")[-1500:], "stderr_tail": (stderr or "")[-1500:]}
    finally:
        shutil.rmtree(work, ignore_errors=True)


def category(cid):
    parts = cid.split(".")
    return ".".join(parts[:2]) if len(parts) > 1 else parts[0]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--logger", default=DEFAULT_LOGGER)
    ap.add_argument("--lune")
    ap.add_argument("--suites", nargs="*", default=[os.path.join(ROOT, "suites"), os.path.join(ROOT, "manual")])
    ap.add_argument("-k", "--filter", action="append", default=[])
    ap.add_argument("--mode", choices=["plain", "packed", "both"], default="plain")
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 2)
    ap.add_argument("--timeout", type=int, default=180)
    ap.add_argument("--json", help="write full results here")
    ap.add_argument("--keep", help="keep dumps/stdout of every run in this directory")
    ap.add_argument("--show", type=int, default=40, help="failures to print per suite")
    args = ap.parse_args()
    lune = find_lune(args.lune)
    logger = os.path.abspath(args.logger)
    files = []
    for d in args.suites:
        if os.path.isfile(d):
            files.append(d)
            continue
        for f in sorted(os.listdir(d)):
            if f.endswith(".luau") and (not args.filter or any(k in f for k in args.filter)):
                files.append(os.path.join(d, f))
    counts = {}
    for d in args.suites:
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.startswith("manifest") and f.endswith(".json"):
                    counts.update(json.load(open(os.path.join(d, f))))
    modes = ["plain", "packed"] if args.mode == "both" else [args.mode]
    jobs = [(f, m) for f in files for m in modes]
    results = []
    with cf.ThreadPoolExecutor(max_workers=args.jobs) as ex:
        futs = {ex.submit(run_suite, lune, logger, f, m, args.timeout, args.keep): (f, m) for f, m in jobs}
        for fut in cf.as_completed(futs):
            results.append(fut.result())
    results.sort(key=lambda r: (r["suite"], r["mode"]))
    grand = Counter()
    by_cat = defaultdict(Counter)
    print(f"logger: {logger}")
    print(f"{'suite':34} {'mode':7} {'total':>6} {'pass':>6} {'fail':>6} {'time':>7}")
    for r in results:
        if r["ended"]:
            total, passed, failed = r["ended"]
            status = ""
        else:
            total = counts.get(r["suite"], len(r["fails"]) or 1)
            passed, failed = 0, total
            status = f"  DID NOT FINISH (rc={r['rc']})"
        grand["total"] += total
        grand["pass"] += passed
        grand["fail"] += failed
        for cid, _ in r["fails"]:
            by_cat[category(cid)]["fail"] += 1
        print(f"{r['suite']:34} {r['mode']:7} {total:6d} {passed:6d} {failed:6d} {r['elapsed']:6.1f}s{status}")
    print(f"{'TOTAL':34} {'':7} {grand['total']:6d} {grand['pass']:6d} {grand['fail']:6d}")
    if by_cat:
        print("\nfailures by category:")
        for cat, c in sorted(by_cat.items(), key=lambda x: -x[1]["fail"]):
            print(f"  {cat:40} {c['fail']}")
    for r in results:
        if not r["ended"]:
            print(f"\n== {r['suite']} [{r['mode']}] did not finish; stdout tail:\n{r['stdout_tail']}\n{r['stderr_tail']}")
        if r["fails"] and args.show:
            print(f"\n== {r['suite']} [{r['mode']}] failures ({len(r['fails'])}):")
            for cid, detail in r["fails"][:args.show]:
                print(f"  {cid}: {detail[:300]}")
    if args.json:
        json.dump({"logger": logger, "totals": grand, "results": results}, open(args.json, "w"), indent=1)
    sys.exit(0 if grand["fail"] == 0 else 1)


if __name__ == "__main__":
    main()
