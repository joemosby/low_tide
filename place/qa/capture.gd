extends SceneTree

# One-shot: instantiate cove.tscn, wait for a drawn player-camera frame,
# write docs/cove.png. Unused by qa.sh. Leaves Water at TideHigh.

const DEST := "res://../docs/cove.png"
const EPS := 0.05


func _initialize() -> void:
	var packed: PackedScene = load("res://cove.tscn") as PackedScene
	if packed == null:
		push_error("cove capture: missing res://cove.tscn")
		quit(1)
		return
	root.size = Vector2i(1280, 720)
	var cove: Node = packed.instantiate()
	root.add_child(cove)
	call_deferred("_capture", cove)


func _capture(cove: Node) -> void:
	var camera := cove.get_node_or_null("Player/Camera3D") as Camera3D
	if camera == null:
		push_error("cove capture: Player/Camera3D missing")
		quit(1)
		return
	camera.make_current()

	var water := cove.get_node_or_null("Water") as AnimatableBody3D
	var high := cove.get_node_or_null("TideHigh") as Marker3D
	if water == null or high == null:
		push_error("cove capture: Water/TideHigh missing")
		quit(1)
		return
	# Scene default is high. Do not wait for Clock's 18s drop.
	if water.global_position.distance_to(high.global_position) > EPS:
		push_error("cove capture: Water is not at TideHigh")
		quit(1)
		return

	# At least one drawn frame from the player camera.
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	await process_frame

	var tex := root.get_texture()
	if tex == null:
		push_error("cove capture: viewport texture is null")
		quit(1)
		return
	var img := tex.get_image()
	if img == null:
		push_error("cove capture: viewport image is null")
		quit(1)
		return
	if img.get_width() < 64 or img.get_height() < 64:
		push_error("cove capture: image too small (%dx%d)" % [img.get_width(), img.get_height()])
		quit(1)
		return
	if _is_blank(img):
		push_error("cove capture: image is black/empty; renderer did not draw the shelf")
		quit(1)
		return

	var dest := ProjectSettings.globalize_path(DEST)
	var err := img.save_png(dest)
	if err != OK:
		push_error("cove capture: save_png failed (%s)" % err)
		quit(1)
		return
	print("cove capture: wrote %s (%dx%d)" % [dest, img.get_width(), img.get_height()])
	quit(0)


func _is_blank(img: Image) -> bool:
	# Grid sample. All near-black or all one color is not the greybox cove.
	var w := img.get_width()
	var h := img.get_height()
	var seen := {}
	var lit := 0
	for iy in range(8):
		for ix in range(8):
			var c := img.get_pixel(int((ix + 0.5) * w / 8.0), int((iy + 0.5) * h / 8.0))
			var key := "%d,%d,%d" % [int(c.r * 16.0), int(c.g * 16.0), int(c.b * 16.0)]
			seen[key] = true
			if c.r + c.g + c.b > 0.12:
				lit += 1
	return lit < 8 or seen.size() < 4
