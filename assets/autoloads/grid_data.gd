extends Node

const CellType = GridCell.CellType
const Direction = GridCell.Direction
const CellColor = GridCell.CellColor
const SinkType = GridCell.SinkType

var cells: Dictionary[Vector2i, GridCell]

var downtime: bool = false
signal downtime_changed(value: bool)

var downtime_remaining: float = 0.0
var downtime_accumulator: float = 0.0
signal downtime_remaining_changed(value: float)

signal selection_changed(selected_location: Vector2i)
var selected_location: Vector2i = Vector2i(0, 0)

var delivered_boxes: int = 0
var max_boxes_lost: int = 0
var lost_boxes: int = 0
var pending_boxes: int = 0
var total_boxes: int = 0
signal box_counts_changed(delivered: int, lost: int, pending: int, total_boxes: int, max_boxes_lost: int)

signal conveyor_turned(grid_cell: GridCell)
signal spawn_changed(grid_cell: GridCell)
signal sink_changed(grid_cell: GridCell)

func _ready() -> void:
    GameManager.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(game_state: GameManager.GameState) -> void:
    if game_state == GameManager.GameState.WIN or game_state == GameManager.GameState.LOST:
        downtime = false
        if downtime_remaining < 0.0:
            downtime_remaining = 0.0
            downtime_remaining_changed.emit(0.0)

func set_downtime(new_downtime) -> void:
    downtime = new_downtime
    if downtime:
        # Select center conveyor
        set_selected_location(Vector2i(3, 3))
    else:
        # Set to corner (a non-spawn location)
        set_selected_location(Vector2i(0, 0))
    downtime_changed.emit(downtime)
    GameManager.game_clock_running_changed.emit(not downtime)

func reset_remaining_downtime(value: float):
    downtime_remaining = value
    downtime_accumulator = 0
    downtime_remaining_changed.emit(downtime_remaining)

func tick_downtime(delta: float) -> void:
    if not downtime:
        return
    downtime_accumulator += delta
    if downtime_accumulator > GameConstants.DOWNTIME_UPDATE_INCREMENT:
        downtime_remaining -= downtime_accumulator
        downtime_accumulator = 0
        downtime_remaining_changed.emit(downtime_remaining)
        if downtime_remaining <= 0.0:
            GameManager.game_lost()

func set_selected_location(location:Vector2i):
    selected_location = location
    selection_changed.emit(selected_location)

func reset() -> void:
    reset_cells()
    downtime = false
    downtime_remaining = 0.0
    downtime_accumulator = 0.0
    selected_location = Vector2i(0, 0)
    delivered_boxes = 0
    lost_boxes = 0
    pending_boxes = 0
    total_boxes = 0
    max_boxes_lost = 0

func reset_cells() -> void:
    cells.clear()
    for i in range(GameConstants.GRID_SIZE):
        for j in range(GameConstants.GRID_SIZE):
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
                direction = Direction.UP
            if location[1] == GameConstants.GRID_SIZE -1:
                direction = Direction.DOWN
        CellType.CONVEYOR:
            direction = Direction.LEFT
    cells[location] = GridCell.new(location, cell_type, direction, CellColor.NONE)

func get_cell_type(location: Vector2i) -> CellType:
    var corner_locations = [0, GameConstants.GRID_SIZE -1]
    if location[0] in corner_locations and location[1] in corner_locations:
        return CellType.CORNER
    if location[0] in corner_locations or location[1] in corner_locations:
        # Right side edge is spawn cells, other edges are sink
        if location[0] == GameConstants.GRID_SIZE -1:
            return CellType.SPAWN
        else:
            return CellType.SINK
    return CellType.CONVEYOR

func get_position_from_location(location: Vector2i) -> Vector2:
    return Vector2(
        location[0]*GameConstants.CELL_SIZE + GameConstants.CELL_OFFSET,
        location[1]*GameConstants.CELL_SIZE + GameConstants.CELL_OFFSET)

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

func change_spawn(index: int, cell_color: CellColor, spawn_count: int) -> void:
    var cell:GridCell = cells[Vector2i(GameConstants.GRID_SIZE -1, index+1)]
    if cell.cell_type == CellType.SPAWN:
        cell.cell_color = cell_color
        cell.spawn_count = spawn_count
        spawn_changed.emit(cell)

func change_sink(index: int, sink_type: SinkType, cell_color: CellColor, lifespan: float) -> void:
    var location = Vector2i(0, 0)
    match sink_type:
        SinkType.LEFT:
            location[1] = index + 1
        SinkType.TOP:
            location[0] = index + 1
        SinkType.BOTTOM:
            location[0] = index + 1
            location[1] = GameConstants.GRID_SIZE - 1
    var cell:GridCell = cells[location]
    if cell.cell_type == CellType.SINK:
        cell.cell_color = cell_color
        cell.lifespan = lifespan
        sink_changed.emit(cell)

func reset_sink(location: Vector2i) -> void:
    var cell: GridCell = cells[location]
    cell.cell_color = CellColor.NONE
    sink_changed.emit(cell)

func add_pending_box() -> void:
    pending_boxes += 1
    box_counts_changed.emit(delivered_boxes, lost_boxes, pending_boxes, total_boxes, max_boxes_lost)
    check_for_game_over()

func box_delivered() -> void:
    delivered_boxes += 1
    pending_boxes -= 1
    box_counts_changed.emit(delivered_boxes, lost_boxes, pending_boxes, total_boxes, max_boxes_lost)
    check_for_game_over()

func box_lost() -> void:
    lost_boxes += 1
    pending_boxes -= 1
    box_counts_changed.emit(delivered_boxes, lost_boxes, pending_boxes, total_boxes, max_boxes_lost)
    check_for_game_over()

func set_total_boxes(total) -> void:
    total_boxes = total
    box_counts_changed.emit(delivered_boxes, lost_boxes, pending_boxes, total_boxes, max_boxes_lost)

func reset_spawner(location: Vector2i) -> void:
    cells[location].spawn_count = 0

func has_active_spawners() -> bool:
    for cell in cells.values():
        if cell.cell_type == CellType.SPAWN and cell.spawn_count > 0:
            return true
    return false

func set_max_boxes_lost(num: int) -> void:
    max_boxes_lost = num
    box_counts_changed.emit(delivered_boxes, lost_boxes, pending_boxes, total_boxes, max_boxes_lost)

func check_for_game_over() -> void:
    if lost_boxes > max_boxes_lost:
        GameManager.game_lost()
    elif total_boxes > 0 and delivered_boxes + lost_boxes == total_boxes:
        GameManager.game_won()
