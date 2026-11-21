extends "res://scripts/interactable.gd"

func _ready() -> void:
	add_to_group("world_state")
	prompt = "Ramasser la lampe à huile"
	flag = "lampe_huile"
	_build_visual()

func _build_visual() -> void:
	var flame := StandardMaterial3D.new()
	flame.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame.albedo_color = Color(0.9, 0.7, 0.35)
	flame.emission_enabled = true
	flame.emission = Color(1.0, 0.65, 0.25)
	flame.emission_energy_multiplier = 2.5
	var flame_mesh := BoxMesh.new()
	flame_mesh.size = Vector3(0.18, 0.26, 0.18)
	var flame_mi := MeshInstance3D.new()
	flame_mi.mesh = flame_mesh
	flame_mi.material_override = flame
	flame_mi.position = Vector3(0, 0.3, 0)
	add_child(flame_mi)
	var glass := StandardMaterial3D.new()
	glass.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glass.albedo_color = Color(0.75, 0.72, 0.6, 0.55)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(0.3, 0.4, 0.3)
	var body := MeshInstance3D.new()
	body.mesh = body_mesh
	body.material_override = glass
	body.position = Vector3(0, 0.2, 0)
	add_child(body)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.45, 0.5, 0.45)
	col.shape = shape
	col.position = Vector3(0, 0.25, 0)
	add_child(col)

func _on_picked() -> void:
	if GameState.player != null:
		GameState.player.enable_lamp()
