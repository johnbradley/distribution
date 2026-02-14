extends Sprite2D

const CellType = GridCell.CellType
const CellColor = GridCell.CellColor
const Direction = GridCell.Direction

const ARROW_BLUE_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_blue.png")
const ARROW_RED_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_red.png")
const ARROW_YELLOW_TEXTURE: Texture2D = preload("res://assets/sprites/arrow_yellow.png")

const BOX_SCENE: PackedScene = preload("res://assets/game/box.tscn")

@onready var color_indicator: Sprite2D = $ColorIndicator

var location: Vector2i
var cell_type: CellType
var tween: Tween

# Spawn-only state
var spawn_color: CellColor
var spawn_count: int = 0
var spawn_direction: Direction

func _ready() -> void:
    var cell = GridData.cells[location]
    cell_type = cell.cell_type

    if cell_type == CellType.SPAWN:
        offset = Vector2(32, 0)
        flip_h = true
        GridData.spawn_changed.connect(_on_spawn_changed)
    else:
        offset = Vector2(-32, 0)
        GridData.sink_changed.connect(_on_sink_changed)

    GameManager.game_clock_running_changed.connect(_on_game_clock_running_changed)

func _on_game_clock_running_changed(running: bool) -> void:
    if tween:
        if running:
            tween.play()
        else:
            tween.pause()

func _get_arrow_texture(color: CellColor) -> Texture2D:
    match color:
        CellColor.BLUE:
            return ARROW_BLUE_TEXTURE
        CellColor.RED:
            return ARROW_RED_TEXTURE
        CellColor.YELLOW:
            return ARROW_YELLOW_TEXTURE
    return null

# --- Spawn logic ---

func _on_spawn_changed(cell: GridCell) -> void:
    if cell.location == location:
        spawn_count = cell.spawn_count
        spawn_color = cell.cell_color
        spawn_direction = cell.direction
        _run_spawning_process()

func _run_spawning_process() -> void:
    color_indicator.texture = _get_arrow_texture(spawn_color)
    tween = get_tree().create_tween()
    tween.tween_interval(GameConstants.FIRST_SPAWN_WAIT)
    tween.tween_callback(_spawn_box)

func _spawn_box() -> void:
    if not GameManager.is_game_playing():
        return
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
        tween.tween_callback(_spawn_box)
    else:
        tween = get_tree().create_tween()
        tween.tween_interval(GameConstants.CLEANUP_WAIT)
        tween.tween_callback(_reset_spawner)

func _reset_spawner() -> void:
    GridData.reset_spawner(location)
    color_indicator.texture = null

# --- Sink logic ---

func _on_sink_changed(cell: GridCell) -> void:
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
        if schedule_reset:
            tween = get_tree().create_tween()
            tween.tween_interval(cell.lifespan)
            tween.tween_callback(_reset_sink)

func _reset_sink() -> void:
    GridData.reset_sink(location)
