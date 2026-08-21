extends Node

# Clock owns when the colliding tide floor drops.
# Place owns the mesh. No Clock API. Radios stay quiet.

const WAIT_S := 8.0
const DROP_S := 8.0


func _ready() -> void:
	var cove := get_parent()
	var water := cove.get_node_or_null("Water") as AnimatableBody3D
	var high := cove.get_node_or_null("TideHigh") as Marker3D
	var low := cove.get_node_or_null("TideLow") as Marker3D
	if water == null or high == null or low == null:
		push_error("Clock: Water/TideHigh/TideLow missing; Place owns the mesh")
		return
	# Honesty asserts default high within a few physics frames. Do not drop yet.
	water.global_position = high.global_position
	_wait_then_fall(water, high.global_position, low.global_position)


func _wait_then_fall(water: AnimatableBody3D, from: Vector3, to: Vector3) -> void:
	# Walk the shelf. Look at the waterline. Then the floor falls.
	await get_tree().create_timer(WAIT_S).timeout
	# Collision stays on. AnimatableBody3D moves with the physics step.
	var drop := create_tween()
	drop.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	drop.tween_property(water, "global_position", to, DROP_S).from(from)
