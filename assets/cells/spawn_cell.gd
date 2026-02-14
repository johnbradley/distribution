extends Sprite2D

const CellColor = GameConstants.CellColor
const Direction = GameConstants.Direction

const ARROW_BLUE_TEXTURE = GameConstants.ARROW_BLUE_TEXTURE
const ARROW_RED_TEXTURE = GameConstants.ARROW_RED_TEXTURE
const ARROW_YELLOW_TEXTURE = GameConstants.ARROW_YELLOW_TEXTURE

const BOX_SCENE: PackedScene = preload("res://assets/game/box.tscn")

var location: Vector2i
var spawn_color: CellColor
var spawn_count = 0
var spawn_direction: Direction
var tween: Tween

@onready var color_indicator:Sprite2D = $ColorIndicator

func _ready() -> void:
    GridData.spawn_changed.connect(on_change_spawn)
    GameManager.game_clock_running_changed.connect(game_clock_running_changed)

func game_clock_running_changed(running):
    if tween:
        if running:
            tween.play()
        else:
            tween.pause()

func on_change_spawn(cell: GridCell):
    if cell.location == location:
        spawn_count = cell.spawn_count
        spawn_color = cell.cell_color
        spawn_direction = cell.direction
        run_spawning_process()

func run_spawning_process() -> void:
    # Show spawning indicator immediately
    color_indicator.texture = get_arrow_texture()
    # Wait a bit and spawn the first box
    tween = get_tree().create_tween()
    tween.tween_interval(GameConstants.FIRST_SPAWN_WAIT)
    tween.tween_callback(spawn_box)

func spawn_box() -> void:
    var child = BOX_SCENE.instantiate()
    child.box_color = spawn_color
    var target_location = location
    target_location[0] -= 1
    child.target_location = target_location
    var box_location = location
    box_location[0] += 2
    child.position = GridData.get_position_from_location(box_location)
    get_parent().add_child(child)

    spawn_count -= 1
    if spawn_count:
        tween = get_tree().create_tween()
        tween.tween_interval(GameConstants.SUBSEQUENT_SPAWN_WAIT)
        tween.tween_callback(spawn_box)
    else:
        tween = get_tree().create_tween()
        tween.tween_interval(GameConstants.CLEANUP_WAIT)
        tween.tween_callback(reset_spawner)

func reset_spawner() -> void:
    GridData.reset_spawner(location)
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
