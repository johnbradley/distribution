extends Node2D

const CORNER_CELL_SCENE: PackedScene = preload("res://assets/scenes/corner_cell.tscn")
const SPAWN_CELL_SCENE: PackedScene = preload("res://assets/scenes/spawn_cell.tscn")
const SINK_CELL_SCENE: PackedScene = preload("res://assets/scenes/sink_cell.tscn")
const CONVEYOR_CELL_SCENE: PackedScene = preload("res://assets/scenes/conveyor_cell.tscn")

func _ready() -> void:
    GridData.reset()
    _add_cell_sprites()

func _add_cell_sprites() -> void:
    for cell in GridData.cells.values():
        var child: Node2D = null
        match cell.cell_type:
            GridData.CellType.CORNER:
                child = CORNER_CELL_SCENE.instantiate()
            GridData.CellType.SPAWN:
                child = SPAWN_CELL_SCENE.instantiate()
            GridData.CellType.SINK:
                child = SINK_CELL_SCENE.instantiate()
            GridData.CellType.CONVEYOR:
                child = CONVEYOR_CELL_SCENE.instantiate()
        child.position = cell.position
        child.location = cell.location
        add_child(child)

func _process(delta):
    GridData.try_update_downtime(delta)

func _input(event: InputEvent) -> void:
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
            GridData.turn_selected_conveyor(GridData.Direction.LEFT)
        if event.is_action_pressed("turn_right"):
            GridData.turn_selected_conveyor(GridData.Direction.RIGHT)
        if event.is_action_pressed("turn_up"):
            GridData.turn_selected_conveyor(GridData.Direction.UP)
        if event.is_action_pressed("turn_down"):
            GridData.turn_selected_conveyor(GridData.Direction.DOWN)

