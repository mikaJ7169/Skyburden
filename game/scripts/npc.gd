extends StaticBody3D

@export var npc_name := "PNJ"
@export var dialogue_file := ""
@export var body_color := Color(0.55, 0.54, 0.52)

var prompt := "Parler"
var timeline: Array = []
var _loop_t := 0.0
var _body: MeshInstance3D
var _head: MeshInstance3D

func _ready() -> void:
	add_to_group("world_state")
	_build_visual()
	if dialogue_file == "":
		dialogue_file = "res://data/dialogues/%s.json" % npc_name.to_lower()

func _build_visual() -> void:
	var mat := StandardMaterial3D.new()
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.roughness = 1.0
	mat.albedo_color = body_color
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.32
	capsule.height = 1.6
	_body = MeshInstance3D.new()
	_body.mesh = capsule
	_body.material_override = mat
	_body.position = Vector3(0, 0.85, 0)
	add_child(_body)
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.2
	head_mesh.height = 0.4
	_head = MeshInstance3D.new()
	_head.mesh = head_mesh
	_head.material_override = mat
	_head.position = Vector3(0, 1.75, 0)
	add_child(_head)
	var label := Label3D.new()
	label.text = npc_name
	label.position = Vector3(0, 2.3, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.004
	label.modulate = Color(0.9, 0.9, 0.85)
	label.outline_size = 8
	label.outline_modulate = Color(0, 0, 0, 0.9)
	add_child(label)

func _process(_delta: float) -> void:
	_loop_t = LoopManager.elapsed
	_apply_timeline()

func _apply_timeline() -> void:
	for step in timeline:
		if _loop_t >= step["t"]:
			global_position = step["pos"]

func _react() -> void:
	if _body == null:
		return
	var tween := create_tween()
	tween.tween_property(_body, "scale:y", 1.08, 0.15)
	tween.tween_property(_body, "scale:y", 1.0, 0.3)

func on_loop_reset() -> void:
	_loop_t = 0.0

func interact() -> void:
	if GameState.ui == null or GameState.ui.dialogue_active:
		return
	_react()
	var data := _load_dialogue()
	if data.is_empty():
		return
	await GameState.ui.play_dialogue(String(data.get("name", npc_name)), data.get("default", []))

func _load_dialogue() -> Dictionary:
	if not FileAccess.file_exists(dialogue_file):
		return {}
	var f := FileAccess.open(dialogue_file, FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if parsed is Dictionary else {}
