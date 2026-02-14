extends HBoxContainer

@onready var level: Label = %Level

func _ready() -> void:
    level.text = "{0} ".format([str(GameManager.current_level)])
