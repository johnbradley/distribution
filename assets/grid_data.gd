extends Node

const GRID_SIZE: int = 7
const CELL_SIZE: int = 128
const DOWNTIME_SECONDS: float = 30.0

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

class GridCell:
    var location: Vector2i
    var cell_type: CellType
    var direction: Direction
    var position: Vector2
    var cell_color: CellColor

    func _init(l: Vector2i, t: CellType, d: Direction, c: CellColor) -> void:
        location = l
        cell_type = t
        direction = d
        cell_color = c
        position = Vector2(location[0]*CELL_SIZE, location[1]*CELL_SIZE)

var cells: Dictionary[Vector2i, GridCell]

var downtime: bool = false
signal downtime_changed(value: bool)

const DOWNTIME_UPDATE_INCREMENT: float = 0.2
var downtime_remaining: float = 0.0
var downtime_accumulator: float = 0.0
signal downtime_remaining_changed(value: float)

signal selection_changed(selected_location: Vector2i)
var selected_location: Vector2i = Vector2i(0, 0)

signal conveyor_turned(grid_cell: GridCell)

func set_downtime(new_downtime) -> void:
    downtime = new_downtime
    if downtime:
        # Select center conveyor
        set_selected_location(Vector2i(3, 3))
    else:
        # Set to corner (a non-spawn location)
        set_selected_location(Vector2i(0, 0))
    downtime_changed.emit(downtime)

func reset_remaining_downtime(value: float):
    downtime_remaining = value
    downtime_accumulator = 0
    downtime_remaining_changed.emit(downtime_remaining)

func try_update_downtime(delta: float) -> void:
    if downtime:
        reduce_remaining_downtime(delta)

func reduce_remaining_downtime(delta: float) -> void:
    downtime_accumulator += delta
    if downtime_accumulator > DOWNTIME_UPDATE_INCREMENT:
        downtime_remaining -= downtime_accumulator
        downtime_accumulator = 0
        downtime_remaining_changed.emit(downtime_remaining)

func set_selected_location(location:Vector2i):
    selected_location = location
    selection_changed.emit(selected_location)

func increment_selected_location(offset: Vector2i):
    selected_location = selected_location + offset
    selection_changed.emit(selected_location)

func reset() -> void:
    reset_cells()
    reset_remaining_downtime(DOWNTIME_SECONDS)

func reset_cells() -> void:
    cells.clear()
    for i in range(GRID_SIZE):
        for j in range(GRID_SIZE):
            var location: Vector2i = Vector2i(i,j)
            var cell_type: CellType = get_cell_type(location)
            _set_cell(location, cell_type)

func _set_cell(location: Vector2i, cell_type: CellType) -> void:
    var direction = Direction.NA
    match cell_type:
        CellType.SPAWN:
            direction = Direction.LEFT
        CellType.SINK:
            if location[0] == 0:
                direction = Direction.LEFT
            if location[1] == 0:
                direction = Direction.DOWN
            if location[1] == GRID_SIZE -1:
                direction = Direction.UP
        CellType.CONVEYOR:
            direction = Direction.LEFT
    cells[location] = GridCell.new(location, cell_type, direction, CellColor.NONE)

func get_cell_type(location: Vector2i) -> CellType:
    var corner_locations = [0, GRID_SIZE -1]
    if location[0] in corner_locations and location[1] in corner_locations:
        return CellType.CORNER
    if location[0] in corner_locations or location[1] in corner_locations:
        # Right side edge is spawn cells, other edges are sink
        if location[0] == GRID_SIZE -1:
            return CellType.SPAWN
        else:
            return CellType.SINK
    return CellType.CONVEYOR

func get_position_from_location(location: Vector2i) -> Vector2:
    return Vector2(location[0]*CELL_SIZE, location[1]*CELL_SIZE)

func move_selection(x_offset, y_offset) -> void:
    var target_location: Vector2i = selected_location
    target_location[0] += x_offset
    target_location[1] += y_offset
    if cells.has(target_location):
        var grid_cell: GridCell = cells[target_location]
        if grid_cell.cell_type == CellType.CONVEYOR:
            set_selected_location(target_location)
    else:
        print("Ignoring invalid cell location ", target_location)

func turn_selected_conveyor(direction: Direction) -> void:
    var grid_cell: GridCell = cells[selected_location]
    grid_cell.direction = direction
    conveyor_turned.emit(grid_cell)
