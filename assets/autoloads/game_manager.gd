extends Node

enum GameState {
    PLAYING,
    PAUSED,
    WIN,
    LOST
}

var current_level: int = 1
var unlocked_level: int = 1
var best_scores: Dictionary = {}
var seen_how_to_play: bool = false
var music_enabled: bool = true
var sfx_enabled: bool = true

var _game_state: GameState = GameState.PLAYING
signal game_state_changed(game_state: GameState)

signal game_clock_running_changed(running: bool)

const SAVE_PATH := "user://save_data.cfg"

func _ready() -> void:
    load_progress()
    apply_audio_settings()

func save_progress() -> void:
    var config := ConfigFile.new()
    config.set_value("progress", "unlocked_level", unlocked_level)
    config.set_value("progress", "seen_how_to_play", seen_how_to_play)
    config.set_value("audio", "music_enabled", music_enabled)
    config.set_value("audio", "sfx_enabled", sfx_enabled)
    for level in best_scores:
        config.set_value("best_scores", "level_%d" % level, best_scores[level])
    config.save(SAVE_PATH)

func load_progress() -> void:
    var config := ConfigFile.new()
    if config.load(SAVE_PATH) == OK:
        unlocked_level = config.get_value("progress", "unlocked_level", 1)
        seen_how_to_play = config.get_value("progress", "seen_how_to_play", false)
        music_enabled = config.get_value("audio", "music_enabled", true)
        sfx_enabled = config.get_value("audio", "sfx_enabled", true)
        if config.has_section("best_scores"):
            for key in config.get_section_keys("best_scores"):
                var level := int(key.trim_prefix("level_"))
                best_scores[level] = config.get_value("best_scores", key)

func reset_progress() -> void:
    current_level = 1
    unlocked_level = 1
    best_scores = {}
    seen_how_to_play = false
    music_enabled = true
    sfx_enabled = true
    save_progress()
    apply_audio_settings()

func apply_audio_settings() -> void:
    var music_bus := AudioServer.get_bus_index("Music")
    var sfx_bus := AudioServer.get_bus_index("SFX")
    if music_bus != -1:
        AudioServer.set_bus_mute(music_bus, not music_enabled)
    if sfx_bus != -1:
        AudioServer.set_bus_mute(sfx_bus, not sfx_enabled)

func show_settings_scene() -> void:
    get_tree().change_scene_to_file("res://assets/screens/settings_scene.tscn")

func show_credits_scene() -> void:
    get_tree().change_scene_to_file("res://assets/screens/credits_scene.tscn")

func show_start_scene() -> void:
    get_tree().change_scene_to_file("res://assets/screens/start_scene.tscn")

func show_instructions_scene() -> void:
    seen_how_to_play = true
    save_progress()
    get_tree().change_scene_to_file("res://assets/screens/instructions_scene.tscn")

func show_level_select_scene() -> void:
    get_tree().change_scene_to_file("res://assets/screens/level_select_scene.tscn")

func show_game_scene() -> void:
    _game_state = GameState.PLAYING
    get_tree().change_scene_to_file("res://assets/game/game_scene.tscn")

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
        game_clock_running_changed.emit(false)

func resume_game() -> void:
    _game_state = GameState.PLAYING
    game_state_changed.emit(_game_state)
    game_clock_running_changed.emit(true)

func game_won() -> void:
    _game_state = GameState.WIN
    var completed_level := current_level
    var lost := GridData.lost_boxes
    if not best_scores.has(completed_level) or lost < best_scores[completed_level]:
        best_scores[completed_level] = lost
    current_level += 1
    unlocked_level = max(unlocked_level, current_level)
    save_progress()
    game_state_changed.emit(_game_state)

func game_lost() -> void:
    _game_state = GameState.LOST
    game_state_changed.emit(_game_state)

func show_win_game_scene() -> void:
    get_tree().change_scene_to_file("res://assets/screens/win_game_scene.tscn")
