extends Node2D

const CellColor = GridCell.CellColor
const CellType = GridCell.CellType
const Direction = GridCell.Direction
const SinkType = GridCell.SinkType

const CORNER_CELL_SCENE: PackedScene = preload("res://assets/cells/corner_cell.tscn")
const EDGE_CELL_SCENE: PackedScene = preload("res://assets/cells/edge_cell.tscn")
const CONVEYOR_CELL_SCENE: PackedScene = preload("res://assets/cells/conveyor_cell.tscn")
@onready var level_scheduler: LevelScheduler = %LevelScheduler
@onready var music: AudioStreamPlayer = %Music
@export var music_volume_db: float = -10.0

var background_rect : Rect2
const background_color: Color = Color.BLACK
const background_border_width1: float = 12.0
const background_border_width2: float = 4.0
const background_border_color1: Color = Color("#555555")
const background_border_color2: Color = Color("#777777")

func _ready() -> void:
    # Setup for rendering black background
    const pixel_dimension = GameConstants.GRID_SIZE * GameConstants.CELL_SIZE + GameConstants.CELL_OFFSET
    background_rect = Rect2(0, 0, pixel_dimension, pixel_dimension)

    GridData.reset()
    _add_cell_sprites()

    music.volume_db = music_volume_db
    music.play()

    var level_exists = level_scheduler.play_level(GameManager.current_level)
    if not level_exists:
        GameManager.show_win_game_scene()


func _add_cell_sprites() -> void:
    for cell in GridData.cells.values():
        var child: Node2D = null
        match cell.cell_type:
            CellType.CORNER:
                child = CORNER_CELL_SCENE.instantiate()
            CellType.SPAWN, CellType.SINK:
                child = EDGE_CELL_SCENE.instantiate()
                if cell.cell_type == CellType.SINK:
                    child.rotation_degrees = cell.get_rotation_degrees()
            CellType.CONVEYOR:
                child = CONVEYOR_CELL_SCENE.instantiate()
        child.position = cell.position
        child.location = cell.location
        add_child(child)

func _draw():
    draw_rect(background_rect, background_color)
    draw_rect(background_rect, background_border_color1, false, background_border_width1)
    draw_rect(background_rect, background_border_color2, false, background_border_width2) 


func _process(delta):
    GridData.tick_downtime(delta)

func _input(event: InputEvent) -> void:
    if GameManager.is_game_playing():
        if event.is_action_pressed("ui_accept"):
            GridData.set_downtime(not GridData.downtime) # Toggle downtime state
        if GridData.downtime:
            if event.is_action_pressed("left"):
                GridData.move_selection(-1, 0)
            if event.is_action_pressed("right"):
                GridData.move_selection(1, 0)
            if event.is_action_pressed("up"):
                GridData.move_selection(0, -1)
            if event.is_action_pressed("down"):
                GridData.move_selection(0, 1)

            if event.is_action_pressed("turn_left"):
                GridData.turn_selected_conveyor(Direction.LEFT)
            if event.is_action_pressed("turn_right"):
                GridData.turn_selected_conveyor(Direction.RIGHT)
            if event.is_action_pressed("turn_up"):
                GridData.turn_selected_conveyor(Direction.UP)
            if event.is_action_pressed("turn_down"):
                GridData.turn_selected_conveyor(Direction.DOWN)
