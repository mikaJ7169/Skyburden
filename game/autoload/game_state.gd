extends Node

var loop_count := 0
var player: CharacterBody3D = null
var ui: CanvasLayer = null

func register_player(p: CharacterBody3D) -> void:
	player = p

func register_ui(u: CanvasLayer) -> void:
	ui = u
