extends SceneTree

# Place-owned drop-floor honesty. Sibling to qa/honesty.gd.
# Stand on Water at high. Wait Clock's WAIT_S + DROP_S. Still on a floor.
# Esc/Q quit lives in player.gd. No HUD. Do not recut Clock.

const WATER_HALF_HEIGHT := 1.4
const WAIT_S := 8.0
const DROP_S := 8.0
const SETTLE_S := 1.0
const DEATH_Y := -8.0


func _initialize() -> void:
	var packed: PackedScene = load("res://cove.tscn") as PackedScene
	if packed == null:
		push_error("cove drop floor: missing res://cove.tscn")
		quit(1)
		return
	var cove: Node = packed.instantiate()
	root.add_child(cove)
	call_deferred("_assert_drop", cove)


func _assert_drop(cove: Node) -> void:
	var failed := PackedStringArray()
	_assert_quit(failed)

	var water := cove.get_node_or_null("Water") as AnimatableBody3D
	var player := cove.get_node_or_null("Player") as CharacterBody3D
	var tide_high := cove.get_node_or_null("TideHigh") as Marker3D
	if water == null or player == null or tide_high == null:
		failed.append("Water, Player, and TideHigh required")
		_fail(failed)
		return

	var water_top := tide_high.global_position.y + WATER_HALF_HEIGHT
	# Inlet, on the colliding tide lid. Not the shelf.
	player.global_position = Vector3(0.0, water_top + 0.02, 2.0)
	player.velocity = Vector3.ZERO
	await create_timer(0.35).timeout
	if not player.is_on_floor() or player.global_position.y < 1.0:
		failed.append("player is not standing on Water at high")

	var min_y := player.global_position.y
	var elapsed := 0.0
	while elapsed < WAIT_S + DROP_S + SETTLE_S:
		await create_timer(0.25).timeout
		elapsed += 0.25
		min_y = minf(min_y, player.global_position.y)
		if not is_finite(player.global_position.y) or player.global_position.y < DEATH_Y:
			failed.append("fell through after the drop (y=%s)" % player.global_position.y)
			break

	if is_finite(player.global_position.y) and player.global_position.y >= DEATH_Y:
		if not player.is_on_floor():
			failed.append("not on a floor after WAIT_S + DROP_S")
		else:
			var floor_path := _floor_path(player)
			if not (
				floor_path.ends_with("/Water")
				or floor_path.contains("/Path/")
				or floor_path.contains("/Beach")
				or floor_path.contains("/Shelf/")
			):
				failed.append("landed on unexpected collider: " + floor_path)

	_assert_bay_still_loops(cove, failed)

	if not failed.is_empty():
		_fail(failed)
		return
	print(
		"cove drop floor: rode Water; still on a floor (y=%.3f, min_y=%.3f); Esc/Q quit; no HUD; bay loops"
		% [player.global_position.y, min_y]
	)
	quit(0)


func _assert_quit(failed: PackedStringArray) -> void:
	var src := FileAccess.get_file_as_string("res://player.gd")
	if src.is_empty():
		failed.append("player.gd missing")
		return
	if src.find("get_tree().quit()") < 0:
		failed.append("player.gd does not quit")
	if src.find("ui_cancel") < 0 or src.find("MOUSE_MODE_VISIBLE") >= 0:
		failed.append("ui_cancel still uncaptures instead of quitting")
	if src.find("KEY_Q") < 0:
		failed.append("Q does not quit")
	if src.find("Label") >= 0 or src.find("CanvasLayer") >= 0 or src.find("toast") >= 0:
		failed.append("quit added a HUD")


func _assert_bay_still_loops(cove: Node, failed: PackedStringArray) -> void:
	var water := cove.get_node_or_null("BayWater") as AudioStreamPlayer
	var wind := cove.get_node_or_null("BayWind") as AudioStreamPlayer
	if water == null or not water.autoplay:
		failed.append("bay water does not autoplay")
	if wind == null or not wind.autoplay:
		failed.append("bay wind does not autoplay")
	if not _wav_loops("res://audio/bay_water.wav.import"):
		failed.append("bay water is not looping")
	if not _wav_loops("res://audio/bay_wind.wav.import"):
		failed.append("bay wind is not looping")
	# .godot/imported is not in the tree. If the stream loaded, it must
	# still be playing after WAIT_S + DROP_S.
	if water and water.stream != null and not water.playing:
		failed.append("bay water is silent after the drop")
	if wind and wind.stream != null and not wind.playing:
		failed.append("bay wind is silent after the drop")
	for child in cove.get_children():
		if child is AudioStreamPlayer:
			if child.name != "BayWater" and child.name != "BayWind":
				failed.append("music or sting present: " + child.name)


func _wav_loops(import_res: String) -> bool:
	var src := FileAccess.get_file_as_string(import_res)
	return src.find("edit/loop_mode=2") >= 0


func _floor_path(player: CharacterBody3D) -> String:
	var col := player.get_last_slide_collision()
	if col == null:
		return ""
	var collider := col.get_collider() as Node
	if collider == null:
		return ""
	return str(collider.get_path())


func _fail(failed: PackedStringArray) -> void:
	for line in failed:
		push_error("cove drop floor: " + line)
	quit(1)
