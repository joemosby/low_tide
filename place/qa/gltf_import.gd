extends SceneTree

# Skipper-owned glTF import honesty. Godot 4.7.2 --headless only.
# Loads the file via GLTFDocument. Does not spawn into the running
# cove. Clock does not spawn geo. No GdUnit4. No xvfb.


func _initialize() -> void:
	var path := "res://art/qa_import.gltf"
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		path = args[0]
	if not FileAccess.file_exists(path):
		push_error("gltf import: missing " + path)
		quit(1)
		return
	# Runtime glTF import. Headless load() has no PackedScene
	# loader for .gltf; GLTFDocument is the official path.
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_file(path, state)
	if err != OK:
		push_error("gltf import: Godot could not import " + path)
		quit(1)
		return
	var node: Node = doc.generate_scene(state)
	if node == null:
		push_error("gltf import: generate_scene failed " + path)
		quit(1)
		return
	if not _has_mesh(node):
		push_error("gltf import: no mesh in " + path)
		quit(1)
		return
	print("gltf import: " + path + " loads")
	node.free()
	quit(0)


func _has_mesh(n: Node) -> bool:
	if n is MeshInstance3D or n is GeometryInstance3D:
		return true
	var cls := n.get_class()
	if cls.find("Mesh") >= 0:
		return true
	for child in n.get_children():
		if _has_mesh(child):
			return true
	return false
