extends Control

@onready var downtimeLabel: Label = %DowntimeLabel
@onready var downtime: Label = %Downtime
@onready var downtime_animation_player: AnimationPlayer = %DowntimeAnimationPlayer
@onready var lost_boxes_label: Label = %LostBoxesLabel
@onready var lost_boxes_animation_player: AnimationPlayer = %LostBoxesAnimationPlayer

const empty_char: String = " -"
const x_char: String = " X"

func _ready() -> void:
    GridData.downtime_remaining_changed.connect(_change_downtime)
    GridData.box_counts_changed.connect(_on_box_counts_changed)
    _change_downtime(GridData.downtime_remaining)

func _change_downtime(remaining) -> void:
    if remaining < 10.0:
        downtime_animation_player.play("danger")
    downtime.text = "%.2f" % remaining

func _on_box_counts_changed(delivered_boxes: int, lost_boxes: int, pending_boxes: int,
        total_boxes: int, max_boxes_lost: int):
    var new_text = ""
    for i in range(max_boxes_lost):
        if i < lost_boxes:
            new_text += x_char 
        else:
            new_text += empty_char
    lost_boxes_label.text = new_text
    if lost_boxes >= max_boxes_lost:
        lost_boxes_animation_player.play("danger")
        
