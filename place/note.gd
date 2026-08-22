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
	# Quad faces the shelf walk. Local +Y is text up. Do not flip V:
	# a V-flip plus a sky-lean made the line upside down from the path.
	mat.roughness = 0.96
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	set_surface_override_material(0, mat)
