extends SceneTree

# One-shot after ./tools/export-gltf.sh. Writes ArrayMesh .tres from
# the authored glTF so cove.tscn can reference meshes without the
# editor importer. Host Godot is a known leak. Clock does not spawn geo.
#
#   godot --headless --path place --script res://art/extract_meshes.gd


func _initialize() -> void:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_file("res://art/cove.gltf", state)
	if err != OK:
		push_error("extract: Godot could not import res://art/cove.gltf")
		quit(1)
		return
	var land: Node = doc.generate_scene(state)
	if land == null:
		push_error("extract: generate_scene failed")
		quit(1)
		return
	var saved := 0
	saved += _save_meshes(land)
	print("extract: wrote %s meshes" % saved)
	land.free()
	quit(0 if saved >= 8 else 1)


func _save_meshes(n: Node) -> int:
	var count := 0
	if n is MeshInstance3D:
		var mesh: Mesh = (n as MeshInstance3D).mesh
		if mesh:
			var path := "res://art/%s.tres" % n.name
			mesh.resource_name = n.name
			var save_err := ResourceSaver.save(mesh, path)
			if save_err != OK:
				push_error("extract: save failed " + path)
			else:
				print("extract: " + path)
				count += 1
	for child in n.get_children():
		count += _save_meshes(child)
	return count
