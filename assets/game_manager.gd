extends Node

enum GameState {
    PLAYING,
    PAUSED,
    GAME_OVER
}

var _game_state: GameState = GameState.PLAYING
signal game_state_changed(game_state: GameState)

signal game_clock_state_changed(running: bool)

func show_start_scene() -> void:
    get_tree().change_scene_to_file("res://assets/scenes/start_scene.tscn")

func show_instructions_scene() -> void:
    _game_state = GameState.PLAYING
    get_tree().change_scene_to_file("res://assets/scenes/instructions_scene.tscn")

func show_game_scene() -> void:
    _game_state = GameState.PLAYING
    get_tree().change_scene_to_file("res://assets/scenes/game_scene.tscn")

func exit_game() -> void:
    get_tree().quit()

func is_game_paused() -> bool:
    return _game_state == GameState.PAUSED

func is_game_playing() -> bool:
    return _game_state == GameState.PLAYING

func pause_game() -> void:
    _game_state = GameState.PAUSED
    game_state_changed.emit(_game_state)
    game_clock_state_changed.emit(false)

func resume_game() -> void:
    _game_state = GameState.PLAYING
    game_state_changed.emit(_game_state)
    game_clock_state_changed.emit(true)

func set_game_over() -> void:
    _game_state = GameState.GAME_OVER
    game_state_changed.emit(_game_state)


