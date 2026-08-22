# Agent notes

This file is the source of truth. Stamps are requirements, not
suggestions. Workflow notes live in `docs/dev-practices.md`.

This workspace is not fully hermetic.

The compiler is a Bazel-fetched LLVM. Native links still use the host
sysroot. Do not write "hermetic" as a claim.

The host Godot editor is a known leak.

Author never merges. Joe (joemosby) is off the review path. Architect
stamps claims.

---

## Live stamps

- **Bazel:** not fully hermetic. Fetched LLVM for this repo only. Host
  sysroot. Do not write hermetic. Host Godot editor is a known leak.
  (Architect)
- **Bzlmod:** Bzlmod only. Module name `low_tide`. No `WORKSPACE`.
  bazelisk + `.bazelversion` + committed `MODULE.bazel.lock`. (Architect)
- **Bzlmod consumer:** portable as a third-party Bzlmod module. Public
  surface is `@low_tide//clock` and `@low_tide//journal` only. Consumer
  brings the toolchain. (Architect)
- **place/:** Godot 4.7.2 assets, not a public Bazel dep. No `rules_godot`.
  Host editor is Place's loop. (Architect)
- **C++ headers:** `#pragma once`. Modern compilers only. Clock owns the
  clock/journal stubs; do not rewrite them in a docs change. (Architect)
- **C++ format:** Allman + 80 columns, enforced by clang-format in
  qa.sh. (Architect)
- **Review:** Author never merges. Joe (joemosby) is off the review path.
  Architect stamps claims. (Architect)
- **Repos:** Cloud agents open GitHub PRs. Origin may mirror them. GitHub
  remains source of truth. Do not create a second Origin-native repo.
  (Architect)
- **CI:** Buildkite runs `./tools/qa.sh` (Bazel + Godot honesty). Depot
  is remote cache `https://cache.depot.dev`. Token is a secret, never
  committed. Do not put a literal Depot token in `.bazelrc`. (Architect)
- **Vercel:** Vercel is not the game. Do not grow a Next.js app. A static
  export later is fine. (Architect)
- **Phase 0:** one cove only. Not Spine. Engine is Godot 4. Walk, wait,
  water falls, path already in the mesh, one journal note. Radios quiet.
  No music in the cove. Tide is a moving floor, two phases (high/low), no
  HUD. The cove is playable (release phase-0). Joe walked. One recut
  from that walk. Not more paper. Do not grow the cove.
  (Architect)
- **Out:** combat, quest markers, lore dump, MMO, Outer Wilds-full,
  phone/camp/walk split, pins, isolcpus, Spine runtime. (Architect)
- **Roadmap:** `docs/roadmap.md`. Phase 0 only. The cove is playable
  (release phase-0). Joe walked. One recut from that walk. Not more
  paper. Architect keeps a ~20 same-cove ready queue in
  `docs/roadmap.md`.
  (Architect)
- **Vision:** `docs/vision.md`. Later only. Not a backlog. Do not build it until a stranger can finish the cove. (Architect)
- **Agent loop:** Place in host Godot 4.7.2, never Bazel. Clock/journal via bazelisk + Depot when `DEPOT_TOKEN` is set. Token is a secret. No literal token in workspace `.bazelrc`. No RBE this week. (Architect)
- **QA:** Cloud agents are done when `./tools/qa.sh` is green. Bazel for clock/journal. Godot 4.7.2 `--headless` for cove honesty. No GdUnit4, no xvfb, no screenshot goldens. (Architect)
- **Godot:** 4.7.2. `place/` requires that version. Cloud honesty is
  Godot 4.7.2 `--headless` (not xvfb, not GdUnit4, not a stranger
  playtest). Headless binary only. Do not bake the editor into the repo.
  Do not add GdUnit4. (Architect)
- **Tide door:** Default high. First drop is readable from the
  waterline. Teach the door before it punishes. No pocket that locks
  before the door is seen. Clock lowers the water. Place does not
  write the drop, a timer, a keybind, or a Clock API. (Architect)

---

## Cursor Cloud specific instructions

Run `./tools/qa.sh` after a change. If `DEPOT_TOKEN` is set, write
`$HOME/.bazelrc` with:

```
build --remote_cache=https://cache.depot.dev
build --remote_header=authorization=$DEPOT_TOKEN
```

before bazelisk. Never commit the token. Workspace `.bazelrc` stays
token-free.

The first `bazelisk test` fetches the LLVM 19.1.7 toolchain and can take
a few minutes with no output. That is not a hang. Later runs hit the
action cache and finish in under a second.
