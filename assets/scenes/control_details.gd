extends VBoxContainer

const BRIEF_FONT_SIZE: int = 40

@onready var controlsLabel: Label = %ControlsLabel
@onready var space: Label = %Space
@onready var wasd: Label = %WASD
@onready var ijkl: Label = %IJKL

@export var brief: bool

func _ready() -> void:
    if brief:
        controlsLabel.add_theme_font_size_override("font_size", BRIEF_FONT_SIZE)
        space.text = "Pause/Resume"
        space.add_theme_font_size_override("font_size", BRIEF_FONT_SIZE)
        wasd.text = "Select cell"
        wasd.add_theme_font_size_override("font_size", BRIEF_FONT_SIZE)
        ijkl.text = "Rotate cell"
        ijkl.add_theme_font_size_override("font_size", BRIEF_FONT_SIZE)
