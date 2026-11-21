extends Node

var flags := {}

func set_flag(flag_name: StringName, value := true) -> void:
	flags[flag_name] = value

func has_flag(flag_name: StringName) -> bool:
	return bool(flags.get(flag_name, false))

func clear() -> void:
	flags.clear()
