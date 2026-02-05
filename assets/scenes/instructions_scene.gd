extends Node

@onready var details: Label = $VBoxContainer/Details

var instructions = """
Operate your factory floor with maximum efficency.
• Ensure you do not lose any boxes.
• Minimize downtime.
• Press the [SPACE] key will start and end downtime.
• Press the [A] [W] [S] and [D] keys to select a tile.
• Press the [J] [I] [K] and [L] keys change tile orientation.


"""

func _ready() -> void:
    details.text = instructions



func _on_button_pressed() -> void:
    GameManager.show_game_scene()
