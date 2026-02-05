extends Sprite2D

var location: Vector2i
var _selection_indicator:Sprite2D

func _ready() -> void:
    _selection_indicator = $SelectionIndicator
    GridData.selection_changed.connect(on_selection_changed)
    GridData.conveyor_turned.connect(on_conveyor_turned)

func on_selection_changed(selected_location: Vector2i) -> void:
    _selection_indicator.visible = location == selected_location

func on_conveyor_turned(grid_cell: GridData.GridCell) -> void:
    if grid_cell.location == location:
        match grid_cell.direction:
            GridData.Direction.UP:
                rotation_degrees = 90
            GridData.Direction.RIGHT:
                rotation_degrees = 180
            GridData.Direction.DOWN:
                rotation_degrees = 270
            GridData.Direction.LEFT:
                rotation_degrees = 0
