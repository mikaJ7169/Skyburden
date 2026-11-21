extends "res://scripts/npc.gd"

func _ready() -> void:
	npc_name = "Ben"
	prompt = "Parler à Ben"
	dialogue_file = "res://data/dialogues/ben.json"
	body_color = Color(0.48, 0.46, 0.42)
	super._ready()
	timeline = [{"t": 0.0, "pos": global_position}]

func interact() -> void:
	if GameState.ui == null or GameState.ui.dialogue_active:
		return
	var data := _load_dialogue()
	if data.is_empty():
		return
	var lines: Array
	if MemoryStore.has_flag(&"ben_rencontre"):
		lines = data.get("repeat", []) + [data.get("farewell", "")]
	else:
		lines = data.get("default", [])
	MemoryStore.set_flag(&"ben_rencontre")
	await GameState.ui.play_dialogue(String(data.get("name", "Ben")), lines)
