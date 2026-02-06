extends Sprite2D

const CellColor = GridCell.CellColor
const Direction = GridCell.Direction

const FIRST_SPAWN_WAIT: float = 1.0
const SUBSEQUENT_SPAWN_WAIT: float = 4.0 # 4.0 right now gets every other conveyor cell
const CLEANUP_WAIT: float = 2.0
const ARROW_BLUE_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_blue.png")
const ARROW_RED_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_red.png")
const ARROW_YELLOW_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_yellow.png")

const BOX_SCENE: PackedScene = preload("res://assets/scenes/box.tscn")

var location: Vector2i
var spawn_color: CellColor
var spawn_cnt = 0
var spawn_direction: Direction
var tween: Tween

@onready var color_indicator:Sprite2D = $ColorIndicator

func _ready() -> void:
    GridData.spawn_changed.connect(on_change_spawn)
    GameManager.game_clock_state_changed.connect(game_clock_state_changed)

func game_clock_state_changed(running):
    if tween:
        if running:
            tween.play()
        else:
            tween.pause()

func on_change_spawn(cell: GridCell):
    if cell.location == location:
        spawn_cnt = cell.spawn_cnt
        spawn_color = cell.cell_color
        spawn_direction = cell.direction
        run_spawning_process()

func run_spawning_process() -> void:
    # Show spawning indicator immediately
    color_indicator.texture = get_arrow_texture()
    # Wait a bit and spawn the first box
    tween = get_tree().create_tween()
    tween.tween_interval(FIRST_SPAWN_WAIT)
    tween.tween_callback(spawn_box)

func spawn_box() -> void:
    var child = BOX_SCENE.instantiate()
    child.box_color = spawn_color
    var target_location = location
    target_location[0] -= 1
    child.target_location = target_location
    child.position = position
    get_parent().add_child(child)

    spawn_cnt -= 1
    if spawn_cnt:
        tween = get_tree().create_tween()
        tween.tween_interval(SUBSEQUENT_SPAWN_WAIT)
        tween.tween_callback(spawn_box)
    else:
        tween = get_tree().create_tween()
        tween.tween_interval(CLEANUP_WAIT)
        tween.tween_callback(reset_spawner)

func reset_spawner() -> void:
    color_indicator.texture = null

func get_arrow_texture() -> Texture2D:
    match spawn_color:
        CellColor.BLUE:
            return ARROW_BLUE_TEXTURE
        CellColor.RED:
            return ARROW_RED_TEXTURE
        CellColor.YELLOW:
            return ARROW_YELLOW_TEXTURE
    return null
