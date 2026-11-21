extends Node3D

const PLAYER_SCENE := "res://scenes/player.tscn"
const SOUS_SOL_SCENE := "res://scenes/zones/sous_sol.tscn"
const CENDREVAL_SCENE := "res://scenes/zones/cendreval.tscn"
const BEN_SCENE := "res://scenes/npc/ben.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const SKY_MANAGER_SCRIPT := "res://scripts/sky_manager.gd"

const PLAYER_SPAWN := Vector3(0.0, -7.5, 9.0)
const BEN_POSITION := Vector3(0.0, 0.0, -6.0)

var _env: Environment
var _sky_mat: ProceduralSkyMaterial

func _ready() -> void:
	_build_environment()
	_build_light()
	var sous_sol: Node3D = load(SOUS_SOL_SCENE).instantiate()
	add_child(sous_sol)
	var cendreval: Node3D = load(CENDREVAL_SCENE).instantiate()
	add_child(cendreval)
	var ben: Node3D = load(BEN_SCENE).instantiate()
	ben.global_position = BEN_POSITION
	add_child(ben)
	var player: CharacterBody3D = load(PLAYER_SCENE).instantiate()
	player.global_position = PLAYER_SPAWN
	add_child(player)
	var hud: CanvasLayer = load(HUD_SCENE).instantiate()
	add_child(hud)
	var sky_manager: Node = load(SKY_MANAGER_SCRIPT).new()
	add_child(sky_manager)
	sky_manager.setup(_env, _sky_mat)
	WorldState.take_snapshot()
	LoopManager.start_loop()

func _build_environment() -> void:
	_sky_mat = ProceduralSkyMaterial.new()
	_sky_mat.sky_top_color = Color(0.52, 0.56, 0.62)
	_sky_mat.sky_horizon_color = Color(0.66, 0.68, 0.70)
	_sky_mat.ground_bottom_color = Color(0.10, 0.10, 0.12)
	_sky_mat.ground_horizon_color = Color(0.30, 0.30, 0.32)
	var sky := Sky.new()
	sky.sky_material = _sky_mat
	_env = Environment.new()
	_env.background_mode = Environment.BG_SKY
	_env.sky = sky
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_env.ambient_light_color = Color(0.55, 0.56, 0.60)
	_env.ambient_light_energy = 0.45
	_env.fog_enabled = true
	_env.fog_light_color = Color(0.66, 0.68, 0.70)
	_env.fog_density = 0.045
	_env.fog_sky_affect = 1.0
	_env.glow_enabled = false
	var we := WorldEnvironment.new()
	we.environment = _env
	add_child(we)

func _build_light() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation = Vector3(-0.9, -0.6, 0.0)
	sun.light_energy = 0.8
	sun.shadow_enabled = false
	add_child(sun)
