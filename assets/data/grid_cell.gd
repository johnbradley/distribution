extends Resource
class_name GridCell

enum CellColor {
    NONE,
    RED,
    YELLOW,
    BLUE
}

enum CellType {
    CORNER,
    SPAWN,
    SINK,
    CONVEYOR
}

enum Direction {
    NA,
    UP,
    DOWN,
    LEFT,
    RIGHT
}

enum SinkType {
    TOP,
    LEFT,
    BOTTOM,
}

enum SendState {
    NORMAL,
    PREP,
    SEND,
}

# Properties
@export var location: Vector2i
@export var cell_type: CellType
@export var direction: Direction
@export var position: Vector2
@export var cell_color: CellColor
@export var spawn_count: int
@export var lifespan: float
@export var send_state: SendState

func _init(l: Vector2i, t: CellType, d: Direction, c: CellColor) -> void:
    location = l
    cell_type = t
    direction = d
    cell_color = c
    spawn_count = 0
    lifespan = 0.0
    send_state = SendState.NORMAL
    position = GridData.get_position_from_location(location)

func get_rotation_degrees() -> int:
    match direction:
        Direction.UP:
            return 90
        Direction.RIGHT:
            return 180
        Direction.DOWN:
            return 270
    return 0
