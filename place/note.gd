extends MeshInstance3D

# One camp-journal note. Same question as journal/journal.h.
# Painted on this mesh at ready. Not a HUD, Label3D, or toast.
# Image.load from the project file — no Godot import, no .godot bake.

const QUESTION := "Was the path always there?"


func _ready() -> void:
	var img := Image.new()
	var path := ProjectSettings.globalize_path("res://note.png")
	if img.load(path) != OK:
		push_error("Note: res://note.png missing")
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = ImageTexture.create_from_image(img)
	# Quad +Y leans toward the shelf. Flip V so the line reads
	# from the path, not from the headland.
	mat.uv1_scale = Vector3(1.0, -1.0, 1.0)
	mat.uv1_offset = Vector3(0.0, 1.0, 0.0)
	mat.roughness = 0.96
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	set_surface_override_material(0, mat)
