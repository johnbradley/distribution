extends Sprite2D

const CellColor = GridCell.CellColor
const Direction = GridCell.Direction

@onready var color_indicator:Sprite2D = $ColorIndicator
const ARROW_BLUE_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_blue.png")
const ARROW_RED_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_red.png")
const ARROW_YELLOW_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_yellow.png")

var location: Vector2i
var tween: Tween

func _ready() -> void:
    GridData.sink_changed.connect(on_sink_changed)
    GameManager.game_clock_state_changed.connect(game_clock_state_changed)

func on_sink_changed(cell: GridCell) -> void:
    if cell.location == location:
        var schedule_reset = false
        match cell.cell_color:
            CellColor.BLUE:
                color_indicator.texture = ARROW_BLUE_TEXTURE
                schedule_reset = true
            CellColor.RED:
                color_indicator.texture = ARROW_RED_TEXTURE
                schedule_reset = true
            CellColor.YELLOW:
                color_indicator.texture = ARROW_YELLOW_TEXTURE
                schedule_reset = true
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
        if schedule_reset:
            tween = get_tree().create_tween()
            tween.tween_interval(cell.lifespan)
            tween.tween_callback(reset_sink) 

func game_clock_state_changed(running):
    if tween:
        if running:
            tween.play()
        else:
            tween.pause()

func reset_sink() -> void:
    GridData.reset_sink(location)
