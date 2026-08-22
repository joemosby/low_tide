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
   When Godot is present, glTF import is fail-closed:
   `place/art/qa_import.gltf` must load. A missing or dirty import
   fails. This does not instance the mesh. CSG stays.
3. Blender **`--background`** — `./tools/export-gltf.sh --qa` writes a
   fixture glTF under `place/art/`. Skip honestly when Blender is
   missing (same as export templates). Fail closed when Blender is
   present and the export is dirty. Host Blender is a known leak.
   Standalone `./tools/export-gltf.sh` (no `--qa`) fails closed if
   Blender is missing, with a one-line install message.

If `place/` has no `project.godot` yet, cove QA prints that the scene
is not on main and exits 0 (skip, not a fake pass). Once Place lands a
project, cove QA fails closed on water-as-body, path-in-mesh, high tide
blocked, low tide walkable, no HUD / overlay / jump, and a loadable
glTF import.

No GdUnit4. No xvfb. No screenshot goldens.

Human playtest (curiosity vs "nice cove") stays human. It is not this
script.
