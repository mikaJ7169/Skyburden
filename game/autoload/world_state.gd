extends Node

const SNAPSHOT_GROUP := "world_state"

var _snapshot := {}

func take_snapshot() -> void:
	_snapshot.clear()
	for node in get_tree().get_nodes_in_group(SNAPSHOT_GROUP):
		if node is Node3D:
			var n := node as Node3D
			_snapshot[node.get_path()] = {
				"position": n.global_position,
				"rotation": n.global_rotation,
				"scale": n.scale,
				"visible": n.visible,
			}

func restore_snapshot() -> void:
	for node in get_tree().get_nodes_in_group(SNAPSHOT_GROUP):
		var path := node.get_path()
		if _snapshot.has(path) and node is Node3D:
			var n := node as Node3D
			var s: Dictionary = _snapshot[path]
			n.global_position = s["position"]
			n.global_rotation = s["rotation"]
			n.scale = s["scale"]
			n.visible = s["visible"]
		if node.has_method("on_loop_reset"):
			node.call("on_loop_reset")
