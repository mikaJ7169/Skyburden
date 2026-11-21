extends StaticBody3D

const Tex := preload("res://scripts/textures.gd")

@export var width := 1.8
@export var glass := false
@export var hinge_right := false

var prompt := "Ouvrir la porte"
var _pivot: Node3D
var _closed := true
var _busy := false

func _ready() -> void:
	add_to_group("world_state")
	var mat := StandardMaterial3D.new()
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.roughness = 1.0
	if glass:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(0.62, 0.7, 0.74, 0.35)
	else:
		mat.albedo_color = Color(0.85, 0.8, 0.7)
		mat.albedo_texture = Tex.make_wood()
	_pivot = Node3D.new()
	var hinge_x := width / 2.0 if hinge_right else -width / 2.0
	_pivot.position = Vector3(hinge_x, 0, 0)
	add_child(_pivot)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(width, 2.6, 0.08)
	mi.mesh = bm
	mi.material_override = mat
	mi.position = Vector3(-hinge_x, 1.3, 0)
	_pivot.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(width, 2.6, 0.08)
	col.shape = shape
	col.position = Vector3(-hinge_x, 1.3, 0)
	_pivot.add_child(col)
	if not glass:
		var handle := MeshInstance3D.new()
		var hb := BoxMesh.new()
		hb.size = Vector3(0.06, 0.06, 0.3)
		handle.mesh = hb
		handle.material_override = mat
		var hx := -hinge_x + (0.15 if hinge_right else -0.15)
		handle.position = Vector3(hx, 1.2, 0.08)
		_pivot.add_child(handle)

func interact() -> void:
	if _busy:
		return
	_busy = true
	_closed = not _closed
	prompt = "Fermer la porte" if not _closed else "Ouvrir la porte"
	var target := 0.0
	if not _closed:
		target = 1.5 if hinge_right else -1.5
	var tween := create_tween()
	tween.tween_property(_pivot, "rotation:y", target, 0.6).set_trans(Tween.TRANS_SINE)
	await tween.finished
	_busy = false

func on_loop_reset() -> void:
	_closed = true
	prompt = "Ouvrir la porte"
	if _pivot != null:
		_pivot.rotation.y = 0.0
