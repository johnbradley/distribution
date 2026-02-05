extends Sprite2D

const CellColor = GridData.CellColor
const Direction = GridData.Direction

@onready var color_indicator:Sprite2D = $ColorIndicator
const ARROW_BLUE_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_blue.png")
const ARROW_RED_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_red.png")
const ARROW_YELLOW_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_yellow.png")

var location: Vector2i

func _ready() -> void:
    GridData.sink_changed.connect(on_sink_changed)

func on_sink_changed(cell: GridData.GridCell) -> void:
    if cell.location == location:
        match cell.cell_color:
            CellColor.BLUE:
                color_indicator.texture = ARROW_BLUE_TEXTURE
            CellColor.RED:
                color_indicator.texture = ARROW_RED_TEXTURE
            CellColor.YELLOW:
                color_indicator.texture = ARROW_YELLOW_TEXTURE
            CellColor.NONE:
                color_indicator.texture = null
        match cell.direction:
            Direction.UP:
                color_indicator.rotation_degrees = 90
            Direction.RIGHT:
                color_indicator.rotation_degrees = 180
            Direction.DOWN:
                color_indicator.rotation_degrees = 270
            Direction.LEFT:
                color_indicator.rotation_degrees = 0
