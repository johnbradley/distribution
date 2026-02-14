extends GutTest

var game_manager: Node


func before_each() -> void:
    game_manager = load("res://assets/autoloads/game_manager.gd").new()
    add_child_autofree(game_manager)


func test_initial_state_is_playing() -> void:
    assert_true(game_manager.is_game_playing())
    assert_false(game_manager.is_game_paused())


func test_initial_level_is_1() -> void:
    assert_eq(game_manager.current_level, 1)


func test_pause_game_changes_state() -> void:
    game_manager.pause_game()
    assert_true(game_manager.is_game_paused())
    assert_false(game_manager.is_game_playing())


func test_pause_game_emits_signals() -> void:
    watch_signals(game_manager)
    game_manager.pause_game()
    assert_signal_emitted(game_manager, "game_state_changed")
    assert_signal_emitted(game_manager, "game_clock_running_changed")


func test_pause_emits_clock_false() -> void:
    var clock_value := []
    game_manager.game_clock_running_changed.connect(func(running): clock_value.append(running))
    game_manager.pause_game()
    assert_eq(clock_value, [false])


func test_pause_only_works_when_playing() -> void:
    game_manager.pause_game()
    assert_true(game_manager.is_game_paused())
    watch_signals(game_manager)
    # Pausing again while already paused should do nothing
    game_manager.pause_game()
    assert_signal_not_emitted(game_manager, "game_state_changed")
    assert_true(game_manager.is_game_paused())


func test_resume_game_changes_state() -> void:
    game_manager.pause_game()
    game_manager.resume_game()
    assert_true(game_manager.is_game_playing())
    assert_false(game_manager.is_game_paused())


func test_resume_game_emits_signals() -> void:
    game_manager.pause_game()
    watch_signals(game_manager)
    game_manager.resume_game()
    assert_signal_emitted(game_manager, "game_state_changed")
    assert_signal_emitted(game_manager, "game_clock_running_changed")


func test_resume_emits_clock_true() -> void:
    game_manager.pause_game()
    var clock_value := []
    game_manager.game_clock_running_changed.connect(func(running): clock_value.append(running))
    game_manager.resume_game()
    assert_eq(clock_value, [true])


func test_game_won_changes_state() -> void:
    game_manager.game_won()
    assert_false(game_manager.is_game_playing())
    assert_false(game_manager.is_game_paused())


func test_game_won_increments_level() -> void:
    assert_eq(game_manager.current_level, 1)
    game_manager.game_won()
    assert_eq(game_manager.current_level, 2)
    game_manager.game_won()
    assert_eq(game_manager.current_level, 3)


func test_game_won_emits_signal() -> void:
    watch_signals(game_manager)
    game_manager.game_won()
    assert_signal_emitted(game_manager, "game_state_changed")


func test_game_lost_changes_state() -> void:
    game_manager.game_lost()
    assert_false(game_manager.is_game_playing())
    assert_false(game_manager.is_game_paused())


func test_game_lost_emits_signal() -> void:
    watch_signals(game_manager)
    game_manager.game_lost()
    assert_signal_emitted(game_manager, "game_state_changed")


func test_game_lost_does_not_change_level() -> void:
    assert_eq(game_manager.current_level, 1)
    game_manager.game_lost()
    assert_eq(game_manager.current_level, 1)


func test_pause_does_nothing_after_game_won() -> void:
    game_manager.game_won()
    watch_signals(game_manager)
    game_manager.pause_game()
    assert_signal_not_emitted(game_manager, "game_state_changed")


func test_pause_does_nothing_after_game_lost() -> void:
    game_manager.game_lost()
    watch_signals(game_manager)
    game_manager.pause_game()
    assert_signal_not_emitted(game_manager, "game_state_changed")
