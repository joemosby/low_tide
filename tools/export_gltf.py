# Blender --background only. Invoked by tools/export-gltf.sh.
# Host Blender is a known leak, like host Godot. Do not import bpy
# outside Blender.
import os
import sys

import bpy


def _args_after_dash():
    if "--" not in sys.argv:
        return []
    return sys.argv[sys.argv.index("--") + 1 :]


def _prepare_fixture():
    for obj in list(bpy.data.objects):
        if obj.type != "MESH":
            bpy.data.objects.remove(obj, do_unlink=True)
    mesh = next((o for o in bpy.data.objects if o.type == "MESH"), None)
    if mesh is None:
        bpy.ops.mesh.primitive_cube_add()
        mesh = bpy.context.active_object
    mesh.name = "QaImport"


def _export(path):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    if os.path.exists(path):
        os.remove(path)
    # 4.5+ dropped GLTF_EMBEDDED. Separate .gltf + .bin is the
    # official text path. Do not bake a .blend or the editor.
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLTF_SEPARATE",
        export_cameras=False,
        export_lights=False,
    )
    if not os.path.isfile(path) or os.path.getsize(path) < 32:
        raise SystemExit("export_gltf: missing or empty " + path)


def main():
    args = _args_after_dash()
    fixture = False
    if args and args[0] == "--fixture":
        fixture = True
        args = args[1:]
    if len(args) != 1:
        raise SystemExit(
            "export_gltf: usage: blender --background "
            "[in.blend] --python export_gltf.py -- "
            "[--fixture] out.gltf"
        )
    out = os.path.abspath(args[0])
    if fixture:
        _prepare_fixture()
    _export(out)
    print("export_gltf: " + out)


if __name__ == "__main__":
    main()
