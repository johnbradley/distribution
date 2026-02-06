extends Area2D

const CellColor = GridData.CellColor
const CellType = GridData.CellType
const Direction = GridData.Direction

const WAIT_BEFORE_FIRST_MOVE: float = 1.0
const WAIT_BETWEEN_MOVES: float = 1.0
const MOVE_TIME_MULTIPLIER: float = 1.8
const STARTING_TIME_JUMP = 0.1 # Makes first movement faster
const BOX_BLUE_TEXTURE: Texture2D = preload("res://assets/sprites/box_blue.png")
const BOX_RED_TEXTURE: Texture2D = preload("res://assets/sprites/box_red.png")
const BOX_YELLOW_TEXTURE: Texture2D = preload("res://assets/sprites/box_yellow.png")

# value that should be set when creating this cell
# Specifies GridData cell location for our first stop
var target_location: Vector2i
var box_color: CellColor;

var original_position: Vector2
var target_position: Vector2
var t: float = 0.0
var moving: bool = false
var close_enough_squared_amt = 100 # 10^2
var sprite: Sprite2D
var tween

func _ready() -> void:
    GameManager.game_clock_state_changed.connect(game_clock_state_changed)
    tween = get_tree().create_tween()
    tween.tween_interval(WAIT_BEFORE_FIRST_MOVE)
    tween.tween_callback(start_move) 
    sprite = $Sprite
    sprite.texture = get_box_texture()
    GridData.add_pending_box()

func game_clock_state_changed(running):
    if tween:
        if running:
            tween.play()
        else:
            tween.pause()

func get_box_texture() -> Texture2D:
    match box_color:
        CellColor.BLUE:
            return BOX_BLUE_TEXTURE
        CellColor.RED:
            return BOX_RED_TEXTURE
        CellColor.YELLOW:
            return BOX_YELLOW_TEXTURE
    return null

func start_move() -> void:
    original_position = position
    target_position = GridData.get_position_from_location(target_location)    
    moving = true
    t = 0.0

func _physics_process(delta: float):
    if GameManager.is_game_playing():
        _handle_collisions()
        if moving and not GridData.downtime:
            _move_toward_destination(delta)

func _handle_collisions() -> void:
    var overlapping_areas = get_overlapping_areas()
    # If we hit another box we explode
    for area in overlapping_areas:
        if area.is_in_group("box"):
            _on_collision(area)

func _on_collision(another_box) -> void:
    queue_free()
    GridData.box_lost()
    another_box.queue_free()
    GridData.box_lost()

func _move_toward_destination(delta: float) -> void:
    if t == 0.0: # The first movement should jump forward
        t = STARTING_TIME_JUMP
    t += delta * MOVE_TIME_MULTIPLIER
    position = original_position.lerp(target_position, t)
    if is_close_enough_to_target():
        finish_move()

func is_close_enough_to_target():
    # using a more efficient check than distance_to
    return position.distance_squared_to(target_position) < close_enough_squared_amt

func finish_move() -> void:
    # This may jump a little (this is intenional)
    position = target_position
    moving = false
    # Find out where we are
    var current_cell = GridData.cells[target_location]
    if current_cell.cell_type == CellType.CONVEYOR:
        move_to_next_target(current_cell)
    elif current_cell.cell_type == CellType.SINK:
        if current_cell.cell_color == box_color:
            on_good_destination()
        else:
            on_bad_destination()
    else:
        on_bad_destination()

func on_good_destination() -> void:
    queue_free()
    GridData.box_delivered()

func on_bad_destination() -> void:
    queue_free()
    GridData.box_lost()

func move_to_next_target(current_cell: GridData.GridCell) -> void:
    match current_cell.direction:
        Direction.UP:
            target_location[1] -= 1
        Direction.DOWN:
            target_location[1] += 1
        Direction.LEFT:
            target_location[0] -= 1
        Direction.RIGHT:
            target_location[0] += 1
    target_position = GridData.get_position_from_location(target_location)
    tween = get_tree().create_tween()
    tween.tween_interval(WAIT_BETWEEN_MOVES)
    tween.tween_callback(start_move)
