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

# Properties
@export var location: Vector2i
@export var cell_type: CellType
@export var direction: Direction
@export var position: Vector2
@export var cell_color: CellColor
@export var spawn_cnt: int
@export var lifespan: float


func _init(l: Vector2i, t: CellType, d: Direction, c: CellColor) -> void:
    location = l
    cell_type = t
    direction = d
    cell_color = c
    spawn_cnt = 0
    lifespan = 0.0
    position = location_to_position(location)

func location_to_position(loc: Vector2i) -> Vector2:
    var x_pos = loc[0]*GameConstants.CELL_SIZE
    var y_pos = loc[1]*GameConstants.CELL_SIZE
    return Vector2(x_pos, y_pos)