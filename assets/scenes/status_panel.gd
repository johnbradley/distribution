extends HBoxContainer

@onready var downtime: Label = $Downtime

func _ready() -> void:
    GridData.downtime_remaining_changed.connect(_change_downtime)

func _change_downtime(remaining) -> void:
    downtime.text = "%.1f" % remaining
