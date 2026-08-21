extends MeshInstance3D

# One camp-journal note. Same question as journal/journal.h.
# World mesh on the path high tide hides. Not a HUD, Label3D, or toast.

const QUESTION := "Was the path always there?"


func _ready() -> void:
	var letters := get_node_or_null("Letters") as MeshInstance3D
	if letters == null or not (letters.mesh is TextMesh):
		push_error("Note: Letters TextMesh missing")
		return
	(letters.mesh as TextMesh).text = QUESTION
