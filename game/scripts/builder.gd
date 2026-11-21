extends RefCounted

static func _scaled_material(material: Material, k: float) -> Material:
	var m := material.duplicate() as BaseMaterial3D
	m.uv1_scale = Vector3(k, k, k)
	return m

static func _tile_scale(max_dim: float, tile: float) -> float:
	var k := max_dim / tile
	return maxf(roundf(k * 4.0) / 4.0, 0.25)

static func box(
	parent: Node, pos: Vector3, size: Vector3, material: Material, rot := Vector3.ZERO, tile := 4.0
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation = rot
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	if tile > 0.0:
		mi.material_override = _scaled_material(material, _tile_scale(maxf(size.x, size.y, size.z), tile))
	else:
		mi.material_override = material
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	parent.add_child(body)
	return body

static func cylinder(
	parent: Node, pos: Vector3, radius: float, height: float,
	material: Material, rot := Vector3.ZERO, tile := 4.0
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation = rot
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = radius
	cm.bottom_radius = radius
	cm.height = height
	mi.mesh = cm
	if tile > 0.0:
		mi.material_override = _scaled_material(material, _tile_scale(maxf(radius * 2.0, height), tile))
	else:
		mi.material_override = material
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	col.shape = shape
	body.add_child(col)
	parent.add_child(body)
	return body
