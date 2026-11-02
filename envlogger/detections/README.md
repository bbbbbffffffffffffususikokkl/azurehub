# envlogger detection suite (v1.7)

22,975 checks that compare the logger's emulated environment with a real Roblox client
(build `0.745.0.7451137`). Each check is a self-contained `T("id", function() ... end)`; a check
passes only when it returns `true`. Every suite is plain Luau, so it can also be pasted into a
real executor to confirm the expectations against a live client.

## Where the expectations come from

Expectations are never typed from memory:

| Source | Used for |
|---|---|
| Roblox `Full-API-Dump.json` (Roblox-Client-Tracker, same build the logger reports) | classes, creatability, IsA chains, members, security, read-only tags, enums + `LegacyNames`, own-class defaults |
| rbx-dom reflection database (`rbx_reflection_database` 3.0.1, roblox-741) | `Instance.new` defaults of inherited members (agrees with the dump on >99% of ~1,500 shared defaults; disagreements are skipped) |
| Creator Hub reference (Roblox/creator-docs) | BrickColor table (208 colours), per-material PhysicalProperties (43 rows), Path2D, HttpService, attribute types |
| Plain Lune (same Luau VM, no logger) | every check in `manual/luau.luau` is validated against the real VM first |
| DevForum-quoted engine errors | `Unable to assign property X. Property is read only`, callback-read error, `X member of Vector2 is read-only and cannot be assigned to` |

Where a source is silent or contradictory (for example the exact wording of a few errors, or
whether `BrickColor.new(Color3)` searches beyond the 128-colour palette), the check asserts only
what is known (that it errors, or the palette case) instead of guessing.

## Layout

```
harness.luau            T / EQ / NEAR / NEARV / TY / ERR / OK / A helpers, @@ result protocol
manual/*.luau           hand-written suites (Path2D, datatypes, Luau, instances, runtime, UNC)
suites/*.luau           runnable suites (generated + manual wrapped with the harness)
tools/gen_api_checks.py   API-dump + rbx-dom generator          (19,153 checks)
tools/gen_docs_checks.py  Creator Hub tables generator          (1,553 checks)
tools/build_manual.py     wraps manual/ into suites/            (2,269 checks)
tools/gen_logger_patch.py regenerates the logger's enum / defaults / material data blocks
tools/run_detections.py   parallel runner
```

## Running

```sh
export LUNE=/path/to/lune            # tested with Lune 0.10.4 and 0.11.1
python3 tools/run_detections.py                    # all suites
python3 tools/run_detections.py --mode both        # also the logger's "obfuscated input" path
python3 tools/run_detections.py -k manual_path2d   # one suite
python3 tools/run_detections.py --logger ../envlogger_v1.6.lua --json out.json
python3 tools/run_detections.py --require-vm       # with the patched lune-fork runtime
```

Regenerating after a Roblox update: delete `.cache/`, then run `gen_api_checks.py`,
`gen_docs_checks.py`, `build_manual.py` and `gen_logger_patch.py` (the last one rewrites the
`[v1.7 GENERATED:*]` blocks inside the logger).

## Results (stock Lune 0.10.4)

| Area | Checks | v1.6 fails | v1.7 fails |
|---|---:|---:|---:|
| Classes (creatable / not creatable / IsA / Name / tostring) | 2,541 | 0 | 0 |
| Enums (types, items, values, tostring, FromName/FromValue, legacy aliases, counts) | 9,487 | 103 | 0 |
| Property types | 2,384 | 13 | 0 |
| Property defaults (`Instance.new`) | 2,056 | 174 | 0 |
| Members (methods, events, callbacks, invalid member) | 1,320 | 6 | 0 |
| Read-only properties | 152 | 0 | 0 |
| Services (GetService, FindService, typed members) | 1,213 | 1 | 0 |
| BrickColor table | 1,295 | 0 | 0 |
| Material PhysicalProperties | 258 | 53 | 0 |
| Datatypes (Vector3/2, CFrame, Color3, UDim2, sequences, Font, DateTime, Random, Enum, signals, ...) | 869 | 10 | 0 |
| Luau language + standard library | 638 | 7 | 0 |
| Path2D + Path2DControlPoint | 133 | 62 | 0 |
| Instances (hierarchy, lifetime, coercion, attributes, tags, change signals) | 149 | 4 | 0 |
| Runtime (globals, scheduler, RunService, players, HttpService, TweenService, Lighting) | 263 | 8 | 0 |
| Executor / UNC | 217 | 36 | 0 (+14 VM-only, below) |
| **Total** | **22,975** | **477** | **0** |

`--mode both` (plain + obfuscated-input path): 45,950 runs, 45,922 pass, 0 fail, 28 VM-only.

### VM-only checks (14)

`unc.vm.*` — `debug.getconstant(s)`, `setconstant`, `getupvalue(s)`, `setupvalue`, `getproto(s)`,
`getstack`, `setstack`, in-place `hookfunction` (Lua and C closures), `getgc(true)` table walks and
un-freezing with `setreadonly`. These need VM access that stock Luau does not expose; the logger
takes it from the patched Lune runtime (`_G.lvm`, lune-fork). They are reported separately on a
stock Lune and should be run with `--require-vm` on the patched runtime (not available here, so
not verified).

## What changed in the logger (v1.6 -> v1.7)

- **API data synced to 0.745**: exact enum set with `LegacyNames` aliases (`Enum.RaycastFilterType.Blacklist`
  is `Exclude`, `Enum.KeyCode.Unknown` is `None`, removed items gone); generated `Instance.new`
  defaults for every creatable class incl. inherited members (typed literals for Vector/Color/UDim/
  CFrame/NumberRange/sequences/BrickColor/Font/Faces/Axes/Content; object references are `nil`
  instead of fabricated parts); documented material physical properties.
- **Path2D** implemented: control-point storage, 1-based Get/Insert/Remove/Update, Set, max 100,
  cubic-Bezier position/tangent queries in parameter and arc-length space, Closed loops,
  GetLength/GetBoundingRect, `ControlPointChanged`, Thickness clamp [0, 100]; `Path2DControlPoint`
  fields are UDim2 and constructor arguments are validated.
- **Behaviour**: callback members raise on read; `tostring(number)` uses Luau's shortest
  round-trip form (v1.6 used Lua 5.1's `%.14g`, e.g. `0.33333333333333`); `typeof` ignores `__type`
  on tables; `debug.traceback({})` and `collectgarbage("collect")` raise; `tostring(connection)`,
  `tostring(Enum)`; read-only EnumItems; `Random:Clone` keeps state; BindableEvent copies tables;
  `Vector3.zero.Unit` is NaN; current datatype assignment error; `Color3.toHSV`; enum properties
  accept names/values; nil rejected for non-reference properties; `stats()`; `require` argument
  checks; `task.desynchronize` outside an Actor; legacy `spawn`/`delay` run on `wait()`;
  `HttpService:UrlEncode` per the docs; `Instance.Capabilities`.
- **Executor functions**: real `crypt.hash` digests (md5/sha1/sha2/sha3), base64 `generatebytes`,
  IV-dependent `encrypt`/`decrypt` round trip, workspace-relative `listfiles`, `loadfile`/`dofile`,
  `messagebox`, `cache.*`, `getconnections` (all UNC fields, working Disable/Enable), `firesignal`,
  `getcallbackvalue`, hidden/scriptable properties, `getnilinstances`, raw metatables and
  `hookmetamethod` on the script's own (locked) tables, Drawing kinds + ZIndex.
- **Security**: `game:HttpGet` no longer fetches loopback / private / link-local / CGNAT / metadata
  addresses (any IPv4 spelling, IPv6, `localhost`, `*.internal`) or non-http(s) schemes, and the
  https->http downgrade is gone. Hostnames that *resolve* to private addresses can't be detected
  from Luau, so run the dumper with egress limited to the public internet. The RVC now indexes
  the whole logger (it stopped at line 30,000 and the file is longer than that).

## Known limits

- `crypt.encrypt` is a reversible keyed cipher with an IV, not byte-exact AES.
- Live `HttpGet` could not be exercised here (this sandbox's TLS proxy is not trusted by Lune's
  HTTP client; v1.6 behaves the same); the guard itself was unit-tested.
- The repo's `loader.lua` still stops at `service cannot be assigned to` — unchanged from v1.6.
