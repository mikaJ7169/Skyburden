extends "res://scripts/npc.gd"

var _mats := {}

func _ready() -> void:
	npc_name = "Ben"
	prompt = "Parler à Ben"
	dialogue_file = "res://data/dialogues/ben.json"
	super._ready()
	timeline = [{"t": 0.0, "pos": global_position}]

func _part(size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var key := color.to_html()
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		m.roughness = 1.0
		m.albedo_color = color
		_mats[key] = m
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = _mats[key]
	mi.position = pos
	add_child(mi)
	return mi

func _build_visual() -> void:
	var skin := Color(0.72, 0.58, 0.48)
	var coat := Color(0.30, 0.28, 0.26)
	var trousers := Color(0.22, 0.21, 0.20)
	var boots := Color(0.12, 0.11, 0.10)
	var beard := Color(0.62, 0.62, 0.64)
	var cap_color := Color(0.25, 0.24, 0.23)
	var scarf := Color(0.45, 0.44, 0.42)
	var dark := Color(0.08, 0.08, 0.08)
	_part(Vector3(0.16, 0.75, 0.16), Vector3(-0.11, 0.375, 0), trousers)
	_part(Vector3(0.16, 0.75, 0.16), Vector3(0.11, 0.375, 0), trousers)
	_part(Vector3(0.18, 0.12, 0.24), Vector3(-0.11, 0.06, 0), boots)
	_part(Vector3(0.18, 0.12, 0.24), Vector3(0.11, 0.06, 0), boots)
	_body = _part(Vector3(0.52, 0.85, 0.3), Vector3(0, 1.17, 0), coat)
	_part(Vector3(0.12, 0.65, 0.12), Vector3(-0.33, 1.1, 0), coat)
	_part(Vector3(0.12, 0.65, 0.12), Vector3(0.33, 1.1, 0), coat)
	_part(Vector3(0.1, 0.1, 0.1), Vector3(-0.33, 0.72, 0), skin)
	_part(Vector3(0.1, 0.1, 0.1), Vector3(0.33, 0.72, 0), skin)
	_part(Vector3(0.4, 0.12, 0.34), Vector3(0, 1.52, 0), scarf)
	_part(Vector3(0.34, 0.36, 0.3), Vector3(0, 1.85, 0), skin)
	_part(Vector3(0.05, 0.05, 0.03), Vector3(-0.08, 1.9, 0.16), dark)
	_part(Vector3(0.05, 0.05, 0.03), Vector3(0.08, 1.9, 0.16), dark)
	_part(Vector3(0.06, 0.1, 0.05), Vector3(0, 1.82, 0.17), skin)
	_part(Vector3(0.3, 0.16, 0.12), Vector3(0, 1.72, 0.14), beard)
	_part(Vector3(0.38, 0.1, 0.38), Vector3(0, 2.06, 0), cap_color)
	_part(Vector3(0.3, 0.04, 0.2), Vector3(0, 2.03, 0.24), cap_color)
	var label := Label3D.new()
	label.text = npc_name
	label.position = Vector3(0, 2.45, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.004
	label.modulate = Color(0.9, 0.9, 0.85)
	label.outline_size = 8
	label.outline_modulate = Color(0, 0, 0, 0.9)
	add_child(label)
