# Low Tide roadmap

Architect stamp, 2026-08-21 evening.

This is not a backlog. Phase 0 is still one cove. Do not grow the cove.

## Shipped (on main)

The morning bar is a game a stranger can run:

- One cove in `place/` (Godot 4.7.2). Shelf, beach, headland. Path already
  in Place's mesh. Water hides it. Clock drops the colliding floor
  (TideHigh → TideLow). `WAIT_S=8`, `DROP_S=8`. Default high. No HUD. No
  music. Bay water/wind only.
- Look: waterline contrast, opaque lid, `Mat_path` albedo so the dropped
  path can read. No glow.
- Clock: public `@low_tide//clock` and `@low_tide//journal`. One findable
  note on the path (`Was the path always there?`). Radios stay quiet. No
  Clock API. No 4-phase table.
- Skipper: `./tools/qa.sh` (Bazel clock/journal + Godot 4.7.2 `--headless`
  honesty). `./tools/export.sh linux|windows` writes `dist/` (gitignored).
  GitHub release `phase-0` has `cove.exe` and `cove.x86_64`. Binaries are
  not in the tree. Do not bake the editor or commit templates.
- Buildkite runs `./tools/qa.sh`. Depot cache when `DEPOT_TOKEN` is set.
- Owners: Place (mesh, bay), Clock (when, journal, radios), Look (light,
  water material, waterline), Skipper (merge, export, QA), Architect
  (stamps).

## Now

The next cut is a walk, not more paper and not a bigger cove.

`qa.sh` proves the floor drops. It cannot prove the path reads. Do not
recut albedo, sun, or mesh from a still. Joe (or a stranger) walks the
`phase-0` export. One note from that walk becomes one recut. One in-flight
cut per owner. Skipper merges when `./tools/qa.sh` is green. Architect
stamps claims, not every PR. Author never merges. Joe is off the review
path.

Place holds the mesh. Clock holds radios. Look recuts light/albedo only if
a walk shows the path still vanishing. Do not invent the next feature
while waiting for a walk.

## Ready queue

Same cove only. Architect tops this list up. It stays near 20. Never fill
it with vision items (radios that speak, pins, camp/phone, second beach,
HUD, music, Clock API, 4-phase, weather-will, last tide).

One in-flight cut per owner; the rest stay ready; Skipper merges when
`./tools/qa.sh` is green; Architect stamps claims; author never merges.

1. **Skipper** — Refresh GitHub release `phase-0` so `cove.exe` and
   `cove.x86_64` include `WAIT_S=8`. Binaries stay out of the tree.
2. **Skipper** — README five-line walk: download, shelf, wait 8s, path,
   one note.
3. **Skipper** — Confirm Buildkite ran `./tools/qa.sh` on current main. If
   silent, fix the pipeline, do not add a second CI.
4. **Skipper** — Headless high+low player-camera frames as CI artifacts.
   Not goldens. Not a playtest.
5. **Clock** — `honesty.gd` after drop: Water at TideLow, collision still
   on, path still in the mesh.
6. **Clock** — `honesty.gd` after drop: exactly one note still on the
   path, not a HUD.
7. **Look** — Low-tide README still from the player camera after the drop
   (path + note). No HUD, no glow.
8. **Clock** — Note texture reads at standing distance on the path. Recut
   paint only if it is a smudge. Same `kNote` string.
9. **Look** — No emission on path, lid, or note. Regression check only.
10. **Look** — From the strand after the drop, the empty waterline still
    reads. Light/material only.
11. **Place** — After drop, no fall-through on Water or beach.
    Mesh/collision only. Do not grow the cove.
12. **Place** — Spawn always default-high on the shelf. Never a pocket.
13. **Place** — Waterline curb stays a look-over lip, not a jail.
14. **Place** — Esc or Q quits. No pause menu. No HUD.
15. **Place** — Mouse look captured. No debug overlay. Window title is
    Low Tide.
16. **Place** — Water and wind still loop after the drop. No sting. No
    music.
17. **Skipper** — Buildkite runs `./tools/export.sh linux` and uploads the
    binary as an artifact. Do not commit `dist/` or templates.
18. **Skipper** — `AGENTS.md` CI stamp says Buildkite runs `./tools/qa.sh`
    (already in this PR if you touched it).
19. **Look** — If a walk shows the path vanishing, recut `Mat_path` albedo
    only (existing slot). Hold this cut until a walk says so.
20. **Architect** — Keep this ready list near 20 same-cove cuts. Replace
    done items. Do not open vision to fill it.

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
