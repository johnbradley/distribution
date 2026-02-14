extends Sprite2D

const Direction = GridCell.Direction

var location: Vector2i
var selection_indicator:Sprite2D

func _ready() -> void:
    selection_indicator = $SelectionIndicator
    GridData.selection_changed.connect(on_selection_changed)
    GridData.conveyor_turned.connect(on_conveyor_turned)

func on_selection_changed(selected_location: Vector2i) -> void:
    selection_indicator.visible = location == selected_location

func on_conveyor_turned(grid_cell: GridCell) -> void:
    if grid_cell.location == location:
        rotation_degrees = grid_cell.get_rotation_degrees()
