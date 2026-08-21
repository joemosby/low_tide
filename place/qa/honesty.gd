extends SceneTree

<<<<<<< HEAD
# Place owns the real cove assertions when the mesh lands.
# Invoked without a scene: skip, not a fake pass.

func _initialize() -> void:
	if get_current_scene() == null:
		print("cove honesty: scene is not on main; skip")
		quit(0)
		return
	push_error("cove honesty: stub cannot assert; Place owns the checks")
	quit(1)
=======
# Place-owned cove honesty. Godot 4.7.2 --headless only.
# No GdUnit4. No xvfb. Clock still owns the drop.

const WATER_HALF_HEIGHT := 1.4
const EPS := 0.05


func _initialize() -> void:
	var packed: PackedScene = load("res://cove.tscn") as PackedScene
	if packed == null:
		push_error("cove honesty: missing res://cove.tscn")
		quit(1)
		return
	var cove: Node = packed.instantiate()
	root.add_child(cove)
	call_deferred("_assert_cove", cove)


func _assert_cove(cove: Node) -> void:
	var failed := PackedStringArray()

	var water := cove.get_node_or_null("Water") as AnimatableBody3D
	var path := cove.get_node_or_null("Path") as Node3D
	var shelf := cove.get_node_or_null("Shelf") as Node3D
	var beach := cove.get_node_or_null("Beach") as Node3D
	var headland := cove.get_node_or_null("Headland") as Node3D
	var tide_high := cove.get_node_or_null("TideHigh") as Marker3D
	var tide_low := cove.get_node_or_null("TideLow") as Marker3D
	var player := cove.get_node_or_null("Player") as CharacterBody3D

	if water == null:
		failed.append("Water must be an AnimatableBody3D")
	if path == null:
		failed.append("Path must exist in the mesh")
	if shelf == null:
		failed.append("Shelf plane missing")
	if beach == null:
		failed.append("Beach plane missing")
	if headland == null:
		failed.append("Headland plane missing")
	if tide_high == null or tide_low == null:
		failed.append("TideHigh and TideLow markers required")
	if player == null:
		failed.append("Player missing")

	if water:
		var collision := water.get_node_or_null("Collision") as CollisionShape3D
		if collision == null or collision.shape == null or collision.disabled:
			failed.append("water is visual-only; door is decoration")
		if water.collision_layer == 0:
			failed.append("Water collision_layer is empty")

	if tide_high and tide_low:
		if tide_low.global_position.y >= tide_high.global_position.y - 1.0:
			failed.append("first drop is not readable from the waterline")
		if water and water.global_position.distance_to(tide_high.global_position) > EPS:
			failed.append("default state is not high tide")

	if water and path:
		var water_high_top := tide_high.global_position.y + WATER_HALF_HEIGHT if tide_high else water.global_position.y + WATER_HALF_HEIGHT
		for child in path.get_children():
			if child is Node3D and (child as Node3D).global_position.y >= water_high_top:
				failed.append("path is not under the high-tide water")

	if player and shelf:
		if player.global_position.y + 0.1 < 2.0:
			failed.append("player is not on the shelf at high tide")
		if player.global_position.z < 6.4:
			failed.append("player starts past the door")

	if _has_overlay(cove):
		failed.append("HUD / overlay / sign present")

	var src := FileAccess.get_file_as_string("res://player.gd")
	if src.is_empty():
		failed.append("player.gd missing")
	else:
		if src.find("KEY_SPACE") != -1 or src.find("\"jump\"") != -1 or src.find("ui_accept") != -1:
			failed.append("jump is present")

	# Physics: high water occupies the path; low water does not.
	await physics_frame
	await physics_frame
	var space := cove.get_world_3d().direct_space_state
	if space == null:
		failed.append("no physics space")
	else:
		if water and not _point_hits(space, Vector3(0.0, 0.8, -4.0), water):
			failed.append("high tide does not collide on the path")
		if water and not _point_hits(space, Vector3(0.0, 1.2, 2.0), water):
			failed.append("high tide does not block the inlet")
		if tide_low and water:
			water.global_position = tide_low.global_position
			await physics_frame
			await physics_frame
			if _point_hits(space, Vector3(0.0, 0.05, -4.0), water):
				failed.append("low-tide water still covers the path")
			if not _point_hits_any(space, Vector3(0.0, 0.05, -4.0)):
				failed.append("path is not walkable after the floor drops")

	if not failed.is_empty():
		for line in failed:
			push_error("cove honesty: " + line)
		quit(1)
		return
	print("cove honesty: water collides; path is in the mesh; default high; no HUD; no jump")
	quit(0)


func _has_overlay(n: Node) -> bool:
	if n is Control or n is CanvasLayer or n is Label3D:
		return true
	for child in n.get_children():
		if _has_overlay(child):
			return true
	return false


func _point_hits(space: PhysicsDirectSpaceState3D, point: Vector3, body: PhysicsBody3D) -> bool:
	for hit in _point_hits_raw(space, point):
		if hit.get("collider") == body:
			return true
	return false


func _point_hits_any(space: PhysicsDirectSpaceState3D, point: Vector3) -> bool:
	return not _point_hits_raw(space, point).is_empty()


func _point_hits_raw(space: PhysicsDirectSpaceState3D, point: Vector3) -> Array[Dictionary]:
	var params := PhysicsPointQueryParameters3D.new()
	params.position = point
	params.collide_with_bodies = true
	params.collide_with_areas = false
	return space.intersect_point(params, 16)
>>>>>>> 4a15de7 (Add Phase 0 Godot 4.7.2 cove under place/)
