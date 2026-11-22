extends StaticBody3D

signal picked_up

@export var prompt := "Ramasser"
@export var flag := ""

var taken := false

func interact() -> void:
	if taken:
		return
	taken = true
	if flag != "":
		MemoryStore.set_flag(StringName(flag))
	_on_picked()
	picked_up.emit()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 0.7, 0.4)
	tween.tween_property(self, "rotation:y", rotation.y + TAU, 0.5)
	tween.tween_property(self, "scale", Vector3.ONE * 0.01, 0.45).set_delay(0.1)
	await tween.finished
	visible = false

func _on_picked() -> void:
	pass

func on_loop_reset() -> void:
	taken = false
