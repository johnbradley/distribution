extends Node

enum GameState {
    PLAYING,
    PAUSED,
    WIN,
    LOST
}

var current_level: int = 1

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
    if _game_state == GameState.PLAYING:
        _game_state = GameState.PAUSED
        game_state_changed.emit(_game_state)
        game_clock_state_changed.emit(false)

func resume_game() -> void:
    _game_state = GameState.PLAYING
    game_state_changed.emit(_game_state)
    game_clock_state_changed.emit(true)

func game_won() -> void:
    _game_state = GameState.WIN
    current_level += 1
    game_state_changed.emit(_game_state)

func game_lost() -> void:
    _game_state = GameState.LOST
    game_state_changed.emit(_game_state)

func showWinGameScene() -> void:
    get_tree().change_scene_to_file("res://assets/scenes/win_game_scene.tscn")
