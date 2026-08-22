# Low Tide roadmap

Architect stamp, 2026-08-22.

This is not a backlog. Phase 0 is still one cove. Do not grow the cove.

## Shipped (on main)

The morning bar is a game a stranger can run:

- One cove in `place/` (Godot 4.7.2). Shelf, beach, headland. Path already
  in Place's mesh. Water hides it. Clock drops the colliding floor
  (TideHigh → TideLow). `WAIT_S=8`, `DROP_S=8`. Default high. No HUD. No
  music. Bay water/wind only.
- Look: waterline contrast, opaque lid, `Mat_path` albedo so the dropped
  path can read. No glow. Beach look pass (#33) is on main.
- Clock: public `@low_tide//clock` and `@low_tide//journal`. One findable
  note on the path (`Was the path always there?`). Radios stay quiet. No
  Clock API. No 4-phase table.
- Skipper: `./tools/qa.sh` (Bazel clock/journal + Godot 4.7.2 `--headless`
  honesty). `./tools/export.sh linux|windows` writes `dist/` (gitignored).
  GitHub release `phase-0` has `cove.exe` and `cove.x86_64`. Binaries are
  not in the tree. Do not bake the editor or commit templates.
- Buildkite runs `./tools/qa.sh`. Depot cache when `DEPOT_TOKEN` is set.
- Joe walked 2026-08-22. Did not name a path-vanishing. Window title is
  Low Tide. Curb is a look-over lip. Bay loops after the drop. No
  emission. Mac walks in host Godot 4.7.2 (`place/`); no macOS binary.
- Owners: Place (mesh, bay), Clock (when, journal, radios), Look (light,
  water material, waterline), Skipper (merge, export, QA), Architect
  (stamps).

## Now

Joe walked. Do not recut albedo, sun, or mesh from a still. `Mat_path`
stays held until a walk names the path vanishing.

Remaining cuts are same-cove leftovers. One in-flight cut per owner.
Skipper merges when `./tools/qa.sh` is green. Architect stamps claims,
not every PR. Author never merges. Joe is off the review path.

Do not invent the next feature. Do not grow the cove.

## Ready queue

Same cove only. Architect tops this list up. It stays near 20. Never fill
it with vision items (radios that speak, pins, camp/phone, second beach,
HUD, music, Clock API, 4-phase, weather-will, last tide).

One in-flight cut per owner; the rest stay ready; Skipper merges when
`./tools/qa.sh` is green; Architect stamps claims; author never merges.

1. **Skipper** — Headless high+low player-camera frames as CI artifacts.
   Not goldens. Not a playtest.
2. **Skipper** — Buildkite runs `./tools/export.sh linux` and uploads the
   binary as an artifact. Do not commit `dist/` or templates.
3. **Skipper** — Refresh GitHub release `phase-0` so `cove.exe` and
   `cove.x86_64` include window title Low Tide. Binaries stay out of
   the tree.
4. **Skipper** — Buildkite agent has Godot 4.7.2 so cove honesty cannot
   skip. If silent, fix the pipeline. Do not add a second CI.
5. **Skipper** — Buildkite agent has 4.7.2 Linux templates so
   `export.sh --qa` fails closed instead of skip. Do not commit
   templates.
6. **Skipper** — Windows export stays a sibling path. Do not gate Linux
   QA on Windows templates.
7. **Look** — If a walk shows the path vanishing, recut `Mat_path` albedo
   only (existing slot). Hold until a walk says so.
8. **Look** — From the strand after the drop, the empty waterline still
   reads. Light/material only. Walk did not name this. `#30` closed.
   Hold unless a later walk says so.
9. **Look** — README stills stay player-camera. Recut only if a walk
   shows a lie. No glow.
10. **Look** — No emission on path, lid, or note. Honesty landed. Do
    not recut materials from a still.
11. **Place** — Do not grow the mesh so the waterline "reads from the
    strand." Curb stays a look-over lip.
12. **Place** — Spawn stays the shelf at TideHigh. Never a pocket.
13. **Place** — Esc/Q quits. No pause menu. No HUD.
14. **Clock** — Radios stay quiet. No Clock API. No 4-phase table.
15. **Clock** — Same `kNote` string. One note on the path. Does not
    grade.
16. **Skipper** — Do not bake the editor or commit `dist/`.
17. **Skipper** — `docs/dev-practices.md` CI line is `./tools/qa.sh`
    (already in this PR if you touched it).
18. **Architect** — Day-30 stranger gate stays a quality bar, not a
    ticket. Vision stays closed.
19. **Architect** — Keep this ready list near 20 same-cove cuts.
    Replace done items. Do not open vision to fill it.
20. **Architect** — Do not invent the next feature while the leftover
    Skipper cuts are still in-flight.

## Repo loop

Two loops, never one. Place/Look iterate in the host Godot 4.7.2 editor
and never wait on Bazel. Clock/journal use bazelisk. Depot remote cache
`https://cache.depot.dev` when `DEPOT_TOKEN` is set. Never commit the
token. No hermetic claim. No RBE. No `rules_godot`. No Next.js. Do not
bake Godot. `MODULE.bazel.lock` is sacred.

When the token is present, write `$HOME/.bazelrc` (or pass the flags on
the command line) with:

```
build --remote_cache=https://cache.depot.dev
build --remote_header=authorization=$DEPOT_TOKEN
```

Workspace `.bazelrc` stays token-free. One agent updates
`MODULE.bazel.lock`; others do not regenerate it.

## Held until a stranger can finish this cove without a lecture

Phone/camp/walk split, pins, sleep-as-save, friend channels, Clock API
(`flow_policy` and friends), 4-phase table, bell, 8–12 facts, music in
the cove, radios that speak, HUD.

Vision in `docs/vision.md` stays closed. Day-30 stranger gate is a
quality bar, not a ticket.

## Later (not a date)

If that hour is fun in Discord with 2–4 friends, the archipelago can
grow. Not before.

## Out

Combat, quest markers, lore dump, MMO, Outer Wilds-full, Spine, isolcpus.
