extends Area2D

const CellColor = GridCell.CellColor
const CellType = GridCell.CellType
const Direction = GridCell.Direction

const BOX_BLUE_TEXTURE: Texture2D = preload("res://assets/sprites/box_blue.png")
const BOX_RED_TEXTURE: Texture2D = preload("res://assets/sprites/box_red.png")
const BOX_YELLOW_TEXTURE: Texture2D = preload("res://assets/sprites/box_yellow.png")
const EXPLOSION_SCENE = preload("res://assets/game/explosion_particles.tscn")

# value that should be set when creating this cell
# Specifies GridData cell location for our first stop
var current_location: Vector2i
var target_location: Vector2i
var box_color: CellColor;

var original_position: Vector2
var target_position: Vector2
var t: float = 0.0
var moving: bool = false
var sprite: Sprite2D
var tween
var alive: bool = true
var first_move: bool = true

func _ready() -> void:
    GameManager.game_clock_running_changed.connect(game_clock_running_changed)
    target_position = GridData.get_position_from_location(target_location)
    tween = get_tree().create_tween()
    tween.tween_interval(GameConstants.WAIT_BEFORE_FIRST_MOVE)
    tween.tween_callback(start_move) 
    sprite = $Sprite
    sprite.texture = get_box_texture()
    GridData.add_pending_box()

func game_clock_running_changed(running):
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
    if first_move:
        first_move = false
        $SpawnSound.play()
    original_position = position
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
    if alive:
        alive = false
        queue_free()
        _explode_box()
        GridData.box_lost()
    if another_box.alive:
        another_box.alive = false
        another_box.queue_free()
        another_box._explode_box()
        GridData.box_lost()

func _explode_box() -> void:
    var explosion = EXPLOSION_SCENE.instantiate()
    explosion.emitting = true
    explosion.position = position
    get_parent().add_child(explosion)

func _move_toward_destination(delta: float) -> void:
    if t == 0.0: # The first movement should jump forward
        t = GameConstants.STARTING_TIME_JUMP
    t += delta * GameConstants.MOVE_TIME_MULTIPLIER
    position = original_position.lerp(target_position, t)
    if is_close_enough_to_target():
        finish_move()

func is_close_enough_to_target():
    # using a more efficient check than distance_to
    return position.distance_squared_to(target_position) < GameConstants.CLOSE_ENOUGH_SQUARED

func finish_move() -> void:
    # This may jump a little (this is intenional)
    position = target_position
    current_location = target_location
    moving = false
    # Find out where we are
    var current_cell = GridData.cells[target_location]
    if current_cell.cell_type == CellType.CONVEYOR:
        tween = get_tree().create_tween()
        tween.tween_interval(GameConstants.WAIT_BETWEEN_MOVES)
        tween.tween_callback(broadcast_send_state)
        tween.tween_interval(GameConstants.WAIT_AFTER_SEND_INDICATOR)
        tween.tween_callback(move_to_next_target)
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
    _explode_box()    
    queue_free()
    GridData.box_lost()

func determine_location(dir: Direction, loc: Vector2i, increment: int) -> Vector2i:
    var new_location = loc
    match dir:
        Direction.UP:
            new_location[1] -= increment
        Direction.DOWN:
            new_location[1] += increment
        Direction.LEFT:
            new_location[0] -= increment
        Direction.RIGHT:
            new_location[0] += increment
    return new_location

func broadcast_send_state() -> void:
    GridData.broadcast_send_state(current_location, GridCell.SendState.SEND)

func move_to_next_target() -> void:
    var current_cell = GridData.cells[target_location]
    target_location = determine_location(current_cell.direction, current_cell.location, 1)
    var next_cell = GridData.cells[target_location]
    if next_cell.cell_type == CellType.SINK:
        # Good destinations fly off the screen bad destinations blow up
        if next_cell.cell_color == box_color:
            $SpawnSound.play()
            var final_location = determine_location(current_cell.direction, current_cell.location, 3)
            target_position = GridData.get_position_from_location(final_location)
        else:
            target_position = GridData.get_position_from_location(target_location)    
    else:
        target_position = GridData.get_position_from_location(target_location)
    start_move()
