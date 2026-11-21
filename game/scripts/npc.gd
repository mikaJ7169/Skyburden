extends StaticBody3D

@export var npc_name := "PNJ"
@export var dialogue_file := ""
@export var body_color := Color(0.55, 0.54, 0.52)

var timeline: Array = []
var _loop_t := 0.0

func _ready() -> void:
	add_to_group("world_state")
	_build_visual()
	if dialogue_file == "":
		dialogue_file = "res://data/dialogues/%s.json" % npc_name.to_lower()

func _build_visual() -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = body_color
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.32
	capsule.height = 1.6
	var body := MeshInstance3D.new()
	body.mesh = capsule
	body.material_override = mat
	body.position = Vector3(0, 0.85, 0)
	add_child(body)
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.2
	head_mesh.height = 0.4
	var head := MeshInstance3D.new()
	head.mesh = head_mesh
	head.material_override = mat
	head.position = Vector3(0, 1.75, 0)
	add_child(head)

func _process(_delta: float) -> void:
	_loop_t = LoopManager.elapsed
	_apply_timeline()

func _apply_timeline() -> void:
	for step in timeline:
		if _loop_t >= step["t"]:
			global_position = step["pos"]

func on_loop_reset() -> void:
	_loop_t = 0.0

func interact() -> void:
	if GameState.ui == null or GameState.ui.dialogue_active:
		return
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
