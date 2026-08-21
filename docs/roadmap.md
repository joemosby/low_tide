# Low Tide roadmap

Architect stamp, 2026-08-20.

This is not a backlog. Phase 0 is one cove. The next cut is a playable cove, not more paper.

## Now (Phase 0)

One cove. Walk, look, wait. Water falls. A path that is already in Place's mesh appears. One camp-journal note that is nonsense until you have seen the path. Radios stay quiet. No HUD. No music in the cove.

Tide is a door: two phases, high and low, a moving floor, not a shader. Three planes: shelf, beach, headland. First fail recovers to a beach that has changed. Journal stores questions, not conclusions. Knowledge is the only progression. The map can lie.

### On main

- Bzlmod skeleton (`low_tide`). Public `@low_tide//clock` and `@low_tide//journal` only.
- Practices fold in `AGENTS.md`.
- Thin Buildkite on `//clock` and `//journal`. Bazel 9 exit 4 means no test targets yet, not tested-green.
- README Phase 0 stamp.

### This week

- **Place:** one walkable cove mesh in `place/` (shelf, beach, headland). Path already in the mesh. Water hides it. No glow, no spawn. Do not grow the cove.
- **Clock:** drop the tide (high/low). One journal note. Radios quiet. Recut header stubs to `#pragma once`. No Clock API. No 4-phase table.
- **Skipper:** one path to main. Author never merges unless Joe waives a landing.
- **Architect:** stamps claims. Does not write the cove.

### Repo loop (many agents)

Two loops, never one. Place iterates in the host Godot 4 editor and never waits on Bazel. Clock and journal use `bazelisk test //clock/... //journal/...`.

Depot remote cache is `https://cache.depot.dev` when `DEPOT_TOKEN` is set (Buildkite and a Cursor cloud environment named `low_tide`). Token is a Runtime Secret. Never commit it. Never put a literal token in workspace `.bazelrc`. Workspace `.bazelrc` stays token-free. When the token is present, write `$HOME/.bazelrc` (or pass the flags on the command line) with:

```
build --remote_cache=https://cache.depot.dev
build --remote_header=authorization=$DEPOT_TOKEN
```

Do not write hermetic. No RBE this week. No `rules_godot`. No Next.js. Do not bake Godot into the cloud image. Committed `MODULE.bazel.lock` is sacred: one agent updates it, others do not regenerate it.

## Held until the cove is a game

Phone/camp/walk split, pins, sleep-as-save, friend channels, Clock API (`flow_policy` and friends), 4-phase table, bell, 8–12 facts, music in the cove, radios that speak, HUD.

## Later (not a date)

If that hour is fun in Discord with 2–4 friends, the archipelago can grow. Not before. Day-30 stranger gate is a quality bar, not this week's ticket.

The long-term vision lives in `docs/vision.md`. It is not a backlog. Do not build it until a stranger can finish this cove.

## Out

Combat, quest markers, lore dump, MMO, Outer Wilds-full, Spine, isolcpus.
