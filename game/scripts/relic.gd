extends "res://scripts/interactable.gd"

const PROMPTS := {
	"radio": "Ramasser la radio morte",
	"livre": "Ramasser le livre (crime selon l'Église)",
	"conserve": "Ramasser la conserve",
}

@export var kind := "radio"

func _ready() -> void:
	add_to_group("world_state")
	prompt = PROMPTS.get(kind, "Ramasser")
	flag = "relique_" + kind
	_build_visual()

func _build_visual() -> void:
	var mat := StandardMaterial3D.new()
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.roughness = 1.0
	var mi := MeshInstance3D.new()
	if kind == "radio":
		mat.albedo_color = Color(0.25, 0.25, 0.28)
		var bm := BoxMesh.new()
		bm.size = Vector3(0.5, 0.3, 0.35)
		mi.mesh = bm
		var ant := BoxMesh.new()
		ant.size = Vector3(0.03, 0.5, 0.03)
		var ami := MeshInstance3D.new()
		ami.mesh = ant
		ami.material_override = mat
		ami.position = Vector3(0.18, 0.55, 0)
		add_child(ami)
	elif kind == "livre":
		mat.albedo_color = Color(0.85, 0.82, 0.72)
		var bm := BoxMesh.new()
		bm.size = Vector3(0.3, 0.08, 0.22)
		mi.mesh = bm
	else:
		mat.albedo_color = Color(0.6, 0.55, 0.45)
		var cm := CylinderMesh.new()
		cm.top_radius = 0.09
		cm.bottom_radius = 0.09
		cm.height = 0.2
		mi.mesh = cm
	mi.material_override = mat
	mi.position = Vector3(0, 0.2, 0)
	add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.6, 0.6, 0.6)
	col.shape = shape
	col.position = Vector3(0, 0.3, 0)
	add_child(col)
