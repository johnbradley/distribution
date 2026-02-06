extends Control

@onready var level: Label = $Level
@onready var downtime: Label = $Downtime
@onready var delivered: Label = $Delivered
@onready var lost: Label = $Lost
@onready var pending: Label = $Pending
@onready var total: Label = $Total

func _ready() -> void:
    GridData.downtime_remaining_changed.connect(_change_downtime)
    GridData.box_counts_changed.connect(_on_box_counts_changed)
    _change_downtime(GridData.downtime_remaining)
    level.text = str(GameManager.current_level)

func _change_downtime(remaining) -> void:
    downtime.text = "%.1fs" % remaining

func _on_box_counts_changed(delivered_boxes: int, lost_boxes: int, pending_boxes: int, total_boxes: int):
    delivered.text = str(delivered_boxes)
    lost.text = str(lost_boxes)
    pending.text = str(pending_boxes)
    total.text = str(total_boxes)
