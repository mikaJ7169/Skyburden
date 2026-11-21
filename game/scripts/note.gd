extends StaticBody3D

@export var note_file := ""

var prompt := "Lire"

func _ready() -> void:
	var paper := StandardMaterial3D.new()
	paper.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	paper.roughness = 1.0
	paper.albedo_color = Color(0.85, 0.82, 0.72)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.24, 0.02, 0.32)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = paper
	mi.position = Vector3(0, 0.02, 0)
	add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.4, 0.2, 0.45)
	col.shape = shape
	col.position = Vector3(0, 0.1, 0)
	add_child(col)

func interact() -> void:
	if GameState.ui == null or GameState.ui.input_blocked():
		return
	if GameState.menu_open or GameState.inventory_open:
		return
	var data := _load_note()
	if data.is_empty():
		return
	await GameState.ui.show_note(String(data.get("title", "Note")), String(data.get("text", "")))

func _load_note() -> Dictionary:
	if not FileAccess.file_exists(note_file):
		return {}
	var f := FileAccess.open(note_file, FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if parsed is Dictionary else {}
