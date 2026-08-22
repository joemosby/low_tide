extends SceneTree

# Place-owned cove honesty. Godot 4.7.2 --headless only.
# No GdUnit4. No xvfb. Clock still owns the drop.

const WATER_HALF_HEIGHT := 1.4
const EPS := 0.05
const DECK_Y := 2.0
const CURB_Z := 6.4
const SHELF_BACK_Z := 14.0
const SHELF_HALF_X := 7.0


func _initialize() -> void:
	var packed: PackedScene = load("res://cove.tscn") as PackedScene
	if packed == null:
		push_error("cove honesty: missing res://cove.tscn")
		quit(1)
		return
	var cove: Node = packed.instantiate()
	var failed := PackedStringArray()
	# Authored transform, before player._ready can snap. A pocket scene must fail
	# even if _ready later pins feet to the shelf.
	_assert_spawn(cove, "authored spawn", failed)
	root.add_child(cove)
	call_deferred("_assert_cove", cove, failed)


func _assert_cove(cove: Node, failed: PackedStringArray) -> void:
	var water := cove.get_node_or_null("Water") as AnimatableBody3D
	var path := cove.get_node_or_null("Path") as Node3D
	var shelf := cove.get_node_or_null("Shelf") as Node3D
	var beach := cove.get_node_or_null("Beach") as Node3D
	var headland := cove.get_node_or_null("Headland") as Node3D
	var tide_high := cove.get_node_or_null("TideHigh") as Marker3D
	var tide_low := cove.get_node_or_null("TideLow") as Marker3D
	var player := cove.get_node_or_null("Player") as CharacterBody3D
	var note := cove.get_node_or_null("Note") as MeshInstance3D

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
	if note == null:
		failed.append("one findable note missing")

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

	# Runtime after player._ready pin. Shelf + TideHigh. Never a pocket.
	_assert_spawn(cove, "ready spawn", failed)

	if _has_csg(cove):
		failed.append("CSG landforms still in the cove")
	var scene_src := FileAccess.get_file_as_string("res://cove.tscn")
	if scene_src.find("res://art/Deck.tres") < 0 or scene_src.find("res://art/Strand.tres") < 0:
		failed.append("cove does not use the authored glTF meshes")
	if not FileAccess.file_exists("res://art/cove.gltf"):
		failed.append("authored place/art/cove.gltf missing")
	if not FileAccess.file_exists("res://art/cove.bin"):
		failed.append("authored place/art/cove.bin missing")
	var deck := cove.get_node_or_null("Shelf/Deck") as MeshInstance3D
	if deck == null or deck.mesh == null:
		failed.append("Shelf/Deck is not an authored mesh")
	var beach_mesh := cove.get_node_or_null("Beach") as MeshInstance3D
	if beach_mesh == null or beach_mesh.mesh == null:
		failed.append("Beach is not an authored mesh")
	var strand := cove.get_node_or_null("Path/Strand") as MeshInstance3D
	if strand == null or strand.mesh == null:
		failed.append("Path/Strand is not an authored mesh")
	if _has_overlay(cove):
		failed.append("HUD / overlay / sign present")
	if str(ProjectSettings.get_setting("application/config/name")) != "Low Tide":
		failed.append("window title is not Low Tide")
	_assert_curb(cove, failed)
	_assert_no_emission(cove, note, failed)
	var world := cove.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world and world.environment and world.environment.glow_enabled:
		failed.append("glow is on")

	var question := _journal_k_note()
	if question.is_empty():
		failed.append("journal/journal.h kNote unreadable")
	if _count_named(cove, "Note") != 1:
		failed.append("need exactly one journal note")
	if note and note.get("QUESTION") != question:
		failed.append("note is not the journal question")
	if note:
		var mat := note.get_surface_override_material(0) as StandardMaterial3D
		if mat == null or mat.albedo_texture == null:
			failed.append("note has no painted question")
		elif mat.uv1_scale.y < 0.0:
			failed.append("note UV is flipped upside down")
		var nbasis := note.global_transform.basis
		# Walk is from the shelf (+Z). Local +Y is text up. Face the walk.
		if nbasis.y.y < 0.7:
			failed.append("note is upside down")
		if nbasis.z.z < 0.5:
			failed.append("note faces the wrong way")
	if not FileAccess.file_exists("res://note.png"):
		failed.append("note texture missing")
	if note and path:
		if _note_off_path(note, path):
			failed.append("note is not on or beside the path")
		if note.global_position.z > 6.4 or note.global_position.y >= 1.5:
			failed.append("note is a sign at spawn")
	if note and tide_high:
		var water_high_top := tide_high.global_position.y + WATER_HALF_HEIGHT
		if note.global_position.y >= water_high_top:
			failed.append("note is above the high-tide water")
	if note and tide_low and _note_under_low(note, tide_low):
		failed.append("note stays under the low-tide water")

	var src := FileAccess.get_file_as_string("res://player.gd")
	if src.is_empty():
		failed.append("player.gd missing")
	else:
		if src.find("KEY_SPACE") != -1 or src.find("\"jump\"") != -1 or src.find("ui_accept") != -1:
			failed.append("jump is present")
		if src.find("SHELF_SPAWN") < 0 or src.find("global_position = SHELF_SPAWN") < 0:
			failed.append("player.gd does not pin _ready spawn to the shelf")
		if src.find("MOUSE_MODE_CAPTURED") < 0:
			failed.append("mouse look is not captured")
		if src.find("WINDOW_MODE_MAXIMIZED") < 0:
			failed.append("player.gd does not open maximized")

	var proj := FileAccess.get_file_as_string("res://project.godot")
	if proj.find("viewport_width=1920") < 0 or proj.find("viewport_height=1080") < 0:
		failed.append("window default is still the tiny 1152x648")
	if proj.find("window/size/mode=2") < 0:
		failed.append("project.godot is not maximized")

	# Physics: high water occupies the path; low water does not.
	await physics_frame
	await physics_frame
	var space: PhysicsDirectSpaceState3D = cove.get_world_3d().direct_space_state
	if space == null:
		failed.append("no physics space")
	else:
		if water and not _point_hits(space, Vector3(0.0, 0.8, -4.0), water):
			failed.append("high tide does not collide on the path")
		if water and not _point_hits(space, Vector3(0.0, 1.2, 2.0), water):
			failed.append("high tide does not block the inlet")
		if tide_low and water:
			# Snap only. Do not wait WAIT_S+DROP_S — qa.sh --quit-after 15
			# would kill a 16s Clock wait. Clock still owns the drop.
			water.global_position = tide_low.global_position
			await physics_frame
			await physics_frame
			if _point_hits(space, Vector3(0.0, 0.05, -4.0), water):
				failed.append("low-tide water still covers the path")
			if not _point_hits_any(space, Vector3(0.0, 0.05, -4.0)):
				failed.append("path is not walkable after the floor drops")
			if water.global_position.distance_to(tide_low.global_position) > EPS:
				failed.append("water is not at TideLow after drop")
			var collision := water.get_node_or_null("Collision") as CollisionShape3D
			if collision == null or collision.disabled:
				failed.append("Water collision off after drop")
			if _count_named(cove, "Note") != 1:
				failed.append("need exactly one journal note after drop")
			var note_after := cove.get_node_or_null("Note") as MeshInstance3D
			if note_after == null:
				failed.append("note gone after drop")
			else:
				if path and _note_off_path(note_after, path):
					failed.append("note is not on or beside the path after drop")
				if _note_under_low(note_after, tide_low):
					failed.append("note stays under the low-tide water")
				var after_basis := note_after.global_transform.basis
				if after_basis.y.y < 0.7:
					failed.append("note is upside down after drop")
				if after_basis.z.z < 0.5:
					failed.append("note faces the wrong way after drop")

	if not failed.is_empty():
		for line in failed:
			push_error("cove honesty: " + line)
		quit(1)
		return
	print("cove honesty: water collides; path is in the mesh; default high; shelf spawn; one note; no HUD; no jump")
	print("cove honesty: after drop: TideLow; collision on; one note still on the path; faces the walk")
	print("cove honesty: title Low Tide; curb is a lip; no emission; maximized")
	quit(0)


func _assert_spawn(cove: Node, label: String, failed: PackedStringArray) -> void:
	var player := cove.get_node_or_null("Player") as CharacterBody3D
	var water := cove.get_node_or_null("Water") as AnimatableBody3D
	var tide_high := cove.get_node_or_null("TideHigh") as Marker3D
	var tide_low := cove.get_node_or_null("TideLow") as Marker3D
	if player == null:
		failed.append("%s: Player missing" % label)
		return
	var pos := player.position if player.get_parent() == null or not player.is_inside_tree() else player.global_position
	var basis := player.basis if player.get_parent() == null or not player.is_inside_tree() else player.global_transform.basis
	if pos.z < -10.0:
		failed.append("%s is a pocket behind Headland" % label)
	elif pos.y < 1.0 and absf(pos.z + 2.0) < 8.0:
		failed.append("%s is on the Beach" % label)
	elif pos.z < CURB_Z and pos.y < 1.5:
		failed.append("%s is on the Path" % label)
	elif pos.z < CURB_Z:
		failed.append("%s is past the curb/door" % label)
	elif pos.y + 0.1 < DECK_Y or pos.y > DECK_Y + 0.25:
		failed.append("%s y is not on the shelf deck" % label)
	elif pos.z > SHELF_BACK_Z:
		failed.append("%s is off the shelf" % label)
	elif absf(pos.x) > SHELF_HALF_X:
		failed.append("%s is a headland pocket" % label)
	if basis.z.z < 0.85:
		failed.append("%s is not looking at the waterline" % label)
	if water and tide_high and water.position.distance_to(tide_high.position) > EPS:
		failed.append("%s: Water is not at TideHigh" % label)
	if water and tide_low and water.position.distance_to(tide_low.position) <= EPS:
		failed.append("%s: water already low" % label)


func _journal_k_note() -> String:
	var header := ProjectSettings.globalize_path("res://").path_join("../journal/journal.h")
	var src := FileAccess.get_file_as_string(header)
	var marker := "kNote = \""
	var start := src.find(marker)
	if start < 0:
		return ""
	start += marker.length()
	var stop := src.find("\"", start)
	if stop < 0:
		return ""
	return src.substr(start, stop - start)


func _note_off_path(note: Node3D, path: Node3D) -> bool:
	var strand := path.get_node_or_null("Strand") as Node3D
	return strand != null and note.global_position.distance_to(strand.global_position) > 6.0


func _note_under_low(note: Node3D, tide_low: Node3D) -> bool:
	return note.global_position.y <= tide_low.global_position.y + WATER_HALF_HEIGHT


func _count_named(n: Node, want: String) -> int:
	var count := 1 if n.name == want else 0
	for child in n.get_children():
		count += _count_named(child, want)
	return count


func _assert_curb(cove: Node, failed: PackedStringArray) -> void:
	var curb := cove.get_node_or_null("Shelf/WaterlineCurb") as MeshInstance3D
	if curb == null:
		failed.append("WaterlineCurb missing")
		return
	if curb.mesh == null:
		failed.append("WaterlineCurb has no mesh")
		return
	if curb.mesh.get_aabb().size.y > 0.2:
		failed.append("WaterlineCurb is taller than a look-over lip")
	for child in curb.get_children():
		if child is CollisionShape3D or child is StaticBody3D:
			failed.append("WaterlineCurb has collision")
			break


func _assert_no_emission(cove: Node, note: MeshInstance3D, failed: PackedStringArray) -> void:
	var path := cove.get_node_or_null("Path") as Node3D
	if path:
		for child in path.get_children():
			if child is MeshInstance3D:
				var mesh_i := child as MeshInstance3D
				var mat := mesh_i.material_override as StandardMaterial3D
				if mat == null:
					mat = mesh_i.get_surface_override_material(0) as StandardMaterial3D
				if mat == null:
					mat = mesh_i.get_active_material(0) as StandardMaterial3D
				if mat and mat.emission_enabled:
					failed.append("path emission is on")
					break
	var lid := cove.get_node_or_null("Water/Mesh/Lid") as MeshInstance3D
	if lid:
		var lid_mat := lid.get_surface_override_material(0) as StandardMaterial3D
		if lid_mat and lid_mat.emission_enabled:
			failed.append("lid emission is on")
	if note:
		var note_mat := note.get_surface_override_material(0) as StandardMaterial3D
		if note_mat and note_mat.emission_enabled:
			failed.append("note emission is on")


func _has_overlay(n: Node) -> bool:
	if n is Control or n is CanvasLayer or n is Label3D:
		return true
	for child in n.get_children():
		if _has_overlay(child):
			return true
	return false


func _has_csg(n: Node) -> bool:
	if n is CSGShape3D or n is CSGPrimitive3D:
		return true
	for child in n.get_children():
		if _has_csg(child):
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
