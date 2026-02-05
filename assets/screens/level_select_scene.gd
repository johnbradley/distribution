extends Node2D


func _ready() -> void:
    %Back.pressed.connect(_on_back_pressed)
    for i in range(1, 8):
        var button: Button = get_node("%%%s" % ["Level%d" % i])
        button.pressed.connect(_on_level_pressed.bind(i))
        button.disabled = false # i > GameManager.unlocked_level
        var level_data = LevelData.read_level_data(i)
        if level_data:
            var parts: Array[String] = ["Level %d" % i]
            parts.append(level_data["description"])
            parts.append("%ds downtime" % int(level_data["downtime_limit"]))
            parts.append("max %d lost" % int(level_data["max_boxes_lost"]))
            if GameManager.best_scores.has(i):
                parts.append("best: %d lost" % GameManager.best_scores[i])
            button.text = "  ·  ".join(parts)
    %Level1.grab_focus()


func _on_level_pressed(level: int) -> void:
    GameManager.current_level = level
    GameManager.show_game_scene()


func _on_back_pressed() -> void:
    GameManager.show_start_scene()
