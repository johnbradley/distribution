extends Sprite2D

const Direction = GridCell.Direction
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var location: Vector2i
var selection_indicator:Sprite2D
@onready var locked_in: Sprite2D = %LockedIn

func _ready() -> void:
    selection_indicator = $SelectionIndicator
    GridData.selection_changed.connect(on_selection_changed)
    GridData.conveyor_turned.connect(on_conveyor_turned)
    GridData.send_state_changed.connect(on_send_state_changed)

func on_selection_changed(selected_location: Vector2i) -> void:
    selection_indicator.visible = location == selected_location

func on_conveyor_turned(grid_cell: GridCell) -> void:
    if grid_cell.location == location:
        rotation_degrees = grid_cell.get_rotation_degrees()

func on_send_state_changed(cell_location: Vector2i, send_state: GridCell.SendState)-> void:
    if cell_location == location:
        match send_state:
            GridCell.SendState.SEND:
                animation_player.play("sending")
