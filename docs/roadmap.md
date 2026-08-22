# Low Tide roadmap

Architect stamp, 2026-08-21. Authored art on the same cove.

This is not a backlog. Phase 0 is still one cove. Do not grow the cove.
No new verbs, no dog, no second beach, no HUD. The tide door stays the
game.

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

Authored art on the same cove. Skipper's first piece is the Blender
`--background` glTF path into `place/art/`. Do not replace CSG in that
cut. Do not recut Look materials. Do not move the note. Clock does not
spawn geo.

After the path exists, Place swaps the mesh. Look puts materials on the
new geo. Clock keeps the one note on the path.

Joe walked. Do not recut albedo, sun, or mesh from a still. `Mat_path`
stays held until a walk names the path vanishing.

One in-flight cut per owner. Skipper merges when `./tools/qa.sh` is
green. Architect stamps claims, not every PR. Author never merges. Joe
is off the review path.

Do not invent the next feature. Do not grow the cove.

## Ready queue

Same-cove art cuts only. Architect tops this list up. It stays near 20.
Never fill it with vision items (radios that speak, pins, camp/phone,
second beach, HUD, music, Clock API, 4-phase, weather-will, last tide).

One in-flight cut per owner; the rest stay ready; Skipper merges when
`./tools/qa.sh` is green; Architect stamps claims; author never merges.

1. **Place** — Swap CSG for the Blender glTF in `place/art/` via
   Skipper's export path. Same cove. Do not grow. Do not move the note.
2. **Look** — Materials on the new geo only. Existing slots (`Mat_path`,
   lid, water). No glow. No HUD. Do not recut from a still.
3. **Clock** — After the mesh swap, the one note is still on the path.
   Same `kNote`. Clock does not spawn geo.
4. **Skipper** — Leftover: `./tools/export-gltf.sh` + `qa.sh` fail-closed
   on a dirty glTF import. Host Blender is a leak. Skip honestly if
   Blender is missing (same as export templates).
5. **Place** — After the authored mesh lands, no fall-through on Water
   or beach. Collision only. Same cove.
6. **Place** — Spawn still default-high on the shelf after the mesh
   swap. Never a pocket.
7. **Place** — Waterline curb stays a look-over lip on the new mesh,
   not a jail.
8. **Place** — Path still already in the mesh; water still hides it.
   Do not paint a glow. Do not grow the cove.
9. **Look** — Waterline contrast still reads from the strand after the
   drop on the new geo. Light/material only.
10. **Look** — No emission on path, lid, or note after the geo swap.
    Regression only. Do not recut materials from a still.
11. **Look** — Opaque lid still sits on the new water. No glow.
12. **Clock** — `honesty.gd` after a mesh swap: exactly one note still
    on the path, not a HUD.
13. **Clock** — After swap: Water at TideLow, collision still on, path
    still in the mesh. Radios stay quiet. No Clock API.
14. **Skipper** — Buildkite still runs `./tools/qa.sh` only. Agent
    Godot 4.7.2 / Linux templates leftover so honesty and
    `export.sh --qa` cannot skip. Do not add a second CI.
15. **Skipper** — `./tools/export.sh linux|windows` still writes
    `dist/` (gitignored). Do not bake the editor. Windows stays a
    sibling path.
16. **Skipper** — Refresh GitHub release `phase-0` so `cove.exe` and
    `cove.x86_64` include window title Low Tide. Binaries stay out of
    the tree.
17. **Look** — If a walk shows the path vanishing on the new geo, recut
    `Mat_path` albedo only (existing slot). Hold until a walk says so.
18. **Place** — Esc or Q still quits. Mouse look captured. Window title
    is Low Tide. No pause menu. No HUD.
19. **Place** — Water and wind still loop after the drop. No sting. No
    music. Same cove. Mac walks in host Godot; no macOS binary.
20. **Architect** — Keep this ready list near 20 same-cove art cuts.
    Replace done items. Do not open vision to fill it.

## Repo loop

Two loops, never one. Place/Look iterate in the host Godot 4.7.2 editor
and never wait on Bazel. Host Blender `--background` writes glTF into
`place/art/`; do not commit Blender. Clock/journal use bazelisk. Depot
remote cache `https://cache.depot.dev` when `DEPOT_TOKEN` is set. Never
commit the token. No hermetic claim. No RBE. No `rules_godot`. No
Next.js. Do not bake Godot. `MODULE.bazel.lock` is sacred.

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
