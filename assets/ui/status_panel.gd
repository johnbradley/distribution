extends Control

@onready var downtime: Label = $Downtime
@onready var delivered: Label = $Delivered
@onready var lost: Label = $Lost
@onready var pending: Label = $Pending
@onready var total: Label = $Total

func _ready() -> void:
    GridData.downtime_remaining_changed.connect(_change_downtime)
    GridData.box_counts_changed.connect(_on_box_counts_changed)
    _change_downtime(GridData.downtime_remaining)

func _change_downtime(remaining) -> void:
    downtime.text = "%.1f" % remaining

func _on_box_counts_changed(delivered_boxes: int, lost_boxes: int, pending_boxes: int,
        total_boxes: int, max_boxes_lost: int):
    delivered.text = str(delivered_boxes)
    lost.text = "{0} / {1}".format([str(lost_boxes), str(max_boxes_lost)])
    pending.text = str(pending_boxes)
    total.text = str(total_boxes)
