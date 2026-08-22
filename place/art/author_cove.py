# Blender --background only. Builds the four cove planes to the current
# CSG extents, then saves place/art/cove.blend. Host Blender is a known
# leak. Do not import bpy outside Blender. Clock does not spawn geo.
#
#   blender --background --python place/art/author_cove.py
#   ./tools/export-gltf.sh place/art/cove.blend place/art/cove.gltf
#   godot --headless --path place --script res://art/extract_meshes.gd
import math
import sys
from pathlib import Path

import bpy
from mathutils import Euler


# Godot CSG extents (Y-up). Blender is Z-up; glTF export converts back.
SHELF_DECK_LOC = (0.0, 1.0, 10.0)
SHELF_DECK_SIZE = (16.0, 2.0, 8.0)
CURB_LOC = (0.0, 2.05, 6.175)
CURB_SIZE = (16.0, 0.1, 0.35)
BEACH_LOC = (0.0, -0.2, -2.0)
BEACH_SIZE = (16.0, 0.4, 16.0)
RAMP_LOC = (0.0, 0.859332, 3.060378)
RAMP_SIZE = (3.0, 0.4, 6.293648)
RAMP_GODOT_RX = math.atan2(0.301892, 0.953342)
STRAND_LOC = (0.0, 0.0, -5.0)
STRAND_SIZE = (3.0, 0.2, 10.0)
HEAD_BACK_LOC = (0.0, 5.0, -12.5)
HEAD_BACK_SIZE = (18.0, 10.0, 3.0)
HEAD_WEST_LOC = (-9.0, 3.5, -2.0)
HEAD_EAST_LOC = (9.0, 3.5, -2.0)
HEAD_ARM_SIZE = (2.0, 7.0, 16.0)

# Existing Look albedo only. No emission. No wet-band. No second beach.
MAT_SHELF = (0.5, 0.42, 0.3)
MAT_BEACH = (0.62, 0.52, 0.36)
MAT_HEAD = (0.36, 0.32, 0.28)
MAT_PATH = (0.11, 0.095, 0.08)


def _script_path():
    for arg in sys.argv:
        if arg.endswith("author_cove.py"):
            return Path(arg).resolve()
    raise SystemExit("author_cove: script path not on argv")


def _godot_to_blender(loc):
    # Blender +Y becomes glTF -Z. Negate Godot Z so the export lands
    # on the same Y-up translation as the CSG nodes.
    return (loc[0], -loc[2], loc[1])


def _godot_size_to_blender(size):
    return (size[0], size[2], size[1])


def _make_mat(name, color):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (color[0], color[1], color[2], 1.0)
    bsdf.inputs["Roughness"].default_value = 0.9
    emit = bsdf.inputs.get("Emission Strength")
    if emit is not None:
        emit.default_value = 0.0
    return mat


def _empty(name, parent):
    obj = bpy.data.objects.new(name, None)
    obj.empty_display_type = "PLAIN_AXES"
    bpy.context.scene.collection.objects.link(obj)
    if parent is not None:
        obj.parent = parent
    obj.location = (0.0, 0.0, 0.0)
    return obj


def _box(name, parent, godot_loc, godot_size, mat, godot_rx=0.0):
    sx, sy, sz = _godot_size_to_blender(godot_size)
    hx, hy, hz = sx * 0.5, sy * 0.5, sz * 0.5
    verts = (
        (-hx, -hy, -hz),
        (hx, -hy, -hz),
        (hx, hy, -hz),
        (-hx, hy, -hz),
        (-hx, -hy, hz),
        (hx, -hy, hz),
        (hx, hy, hz),
        (-hx, hy, hz),
    )
    faces = (
        (0, 1, 2, 3),
        (4, 7, 6, 5),
        (0, 4, 5, 1),
        (1, 5, 6, 2),
        (2, 6, 7, 3),
        (3, 7, 4, 0),
    )
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    if parent is not None:
        obj.parent = parent
    obj.location = _godot_to_blender(godot_loc)
    obj.rotation_euler = Euler((godot_rx, 0.0, 0.0), "XYZ")
    if mat is not None:
        mesh.materials.append(mat)
    return obj


def main():
    art_dir = _script_path().parent
    blend_path = art_dir / "cove.blend"

    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.name = "Cove"

    mat_shelf = _make_mat("Mat_shelf", MAT_SHELF)
    mat_beach = _make_mat("Mat_beach", MAT_BEACH)
    mat_head = _make_mat("Mat_headland", MAT_HEAD)
    mat_path = _make_mat("Mat_path", MAT_PATH)

    # Scene name is Cove. No extra root empty — Godot wraps the four
    # planes as children of the imported scene root.
    shelf = _empty("Shelf", None)
    _box("Deck", shelf, SHELF_DECK_LOC, SHELF_DECK_SIZE, mat_shelf)
    _box("WaterlineCurb", shelf, CURB_LOC, CURB_SIZE, mat_shelf)
    _box("Beach", None, BEACH_LOC, BEACH_SIZE, mat_beach)
    path = _empty("Path", None)
    _box("Ramp", path, RAMP_LOC, RAMP_SIZE, mat_path, RAMP_GODOT_RX)
    _box("Strand", path, STRAND_LOC, STRAND_SIZE, mat_path)
    head = _empty("Headland", None)
    _box("Back", head, HEAD_BACK_LOC, HEAD_BACK_SIZE, mat_head)
    _box("West", head, HEAD_WEST_LOC, HEAD_ARM_SIZE, mat_head)
    _box("East", head, HEAD_EAST_LOC, HEAD_ARM_SIZE, mat_head)

    bpy.ops.wm.save_as_mainfile(filepath=str(blend_path))
    print("author_cove: " + str(blend_path))


if __name__ == "__main__":
    main()
