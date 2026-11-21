extends Node

signal loop_started(loop_index: int)
signal loop_ended
signal progress_changed(progress: float)

const LOOP_DURATION_MINUTES := 37.0
const TEST_LOOP_MINUTES := 5.0
const USE_TEST_DURATION := true

var elapsed := 0.0
var running := false

func loop_duration_seconds() -> float:
	var minutes := TEST_LOOP_MINUTES if USE_TEST_DURATION else LOOP_DURATION_MINUTES
	return minutes * 60.0

func progress() -> float:
	return clampf(elapsed / loop_duration_seconds(), 0.0, 1.0)

func remaining_seconds() -> float:
	return maxf(0.0, loop_duration_seconds() - elapsed)

func start_loop() -> void:
	elapsed = 0.0
	running = true
	GameState.loop_count += 1
	loop_started.emit(GameState.loop_count)
	progress_changed.emit(0.0)

func _process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	progress_changed.emit(progress())
	if elapsed >= loop_duration_seconds():
		_end_loop()

func _end_loop() -> void:
	running = false
	loop_ended.emit()
	WorldState.restore_snapshot()
	if GameState.player != null:
		GameState.player.reset_to_spawn()
	start_loop()
