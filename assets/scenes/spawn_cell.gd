extends Sprite2D

var location: Vector2i

@onready var color_indicator:Sprite2D = $ColorIndicator
const ARROW_BLUE_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_blue.png")
const ARROW_RED_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_red.png")
const ARROW_YELLOW_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_yellow.png")

func start(color: GridData.CellColor):
    match color:
        GridData.CellColor.BLUE:
            color_indicator.texture = ARROW_BLUE_TEXTURE
        GridData.CellColor.RED:
            color_indicator.texture = ARROW_RED_TEXTURE
        GridData.CellColor.YELLOW:
            color_indicator.texture = ARROW_YELLOW_TEXTURE
