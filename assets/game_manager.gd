extends Node

enum GameState {
    PLAYING,
    PAUSED,
    GAME_OVER
}

var _game_state: GameState = GameState.PLAYING
signal game_state_changed(game_state: GameState)

func show_start_scene() -> void:
    get_tree().change_scene_to_file("res://assets/scenes/start_scene.tscn")

func show_game_scene() -> void:
    _game_state = GameState.PLAYING
    get_tree().change_scene_to_file("res://assets/scenes/game_scene.tscn")

func exit_game() -> void:
    get_tree().quit()

func is_game_paused() -> bool:
    return _game_state == GameState.PAUSED

func pause_game() -> void:
    _game_state = GameState.PAUSED
    game_state_changed.emit(_game_state)

func resume_game() -> void:
    _game_state = GameState.PLAYING
    game_state_changed.emit(_game_state)

func set_game_over() -> void:
    _game_state = GameState.GAME_OVER
    game_state_changed.emit(_game_state)

