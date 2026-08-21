extends SceneTree

# Place owns the real cove assertions when the mesh lands.
# Invoked without a scene: skip, not a fake pass.

func _initialize() -> void:
	if get_current_scene() == null:
		print("cove honesty: scene is not on main; skip")
		quit(0)
		return
	push_error("cove honesty: stub cannot assert; Place owns the checks")
	quit(1)
