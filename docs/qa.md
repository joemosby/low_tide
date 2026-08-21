# QA

Cloud agents are done when `./tools/qa.sh` is green. That is the
definition of done.

Two loops:

1. `bazelisk test //clock/... //journal/...` — C++ honesty. Bazel 9
   exit 4 (no tests) is success until Clock adds tests. Real failures
   stay non-zero.
2. Godot 4 **headless** — cove honesty when a Godot project exists.
   Official binary: Godot 4.7.2-stable Linux x86_64 from
   https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable
   (`Godot_v4.7.2-stable_linux.x86_64.zip`). Run with `--headless
   --audio-driver Dummy --quit-after`. Not the editor GUI.

If `place/` has no `project.godot` yet, cove QA prints that the scene
is not on main and exits 0 (skip, not a fake pass). Once Place lands a
project, cove QA fails closed on water-as-body, path-in-mesh, high tide
blocked, low tide walkable, and no HUD / overlay / jump.

No GdUnit4. No xvfb. No screenshot goldens.

Human playtest (curiosity vs "nice cove") stays human. It is not this
script.
