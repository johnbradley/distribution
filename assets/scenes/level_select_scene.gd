extends Node2D


func _ready() -> void:
    %Back.pressed.connect(_on_back_pressed)
    for i in range(1, 8):
        var button: Button = get_node("%%%s" % ["Level%d" % i])
        button.pressed.connect(_on_level_pressed.bind(i))
        button.disabled = i > GameManager.unlocked_level
        if GameManager.best_scores.has(i):
            button.text += "  ·  Best: %d lost" % GameManager.best_scores[i]
    %Level1.grab_focus()


func _on_level_pressed(level: int) -> void:
    GameManager.current_level = level
    GameManager.show_game_scene()


func _on_back_pressed() -> void:
    GameManager.show_start_scene()
