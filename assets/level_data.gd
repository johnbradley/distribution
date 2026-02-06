class_name LevelData
extends Resource

@export var level_idx: int
@export var events: Array[CellEvent] = []

func get_sorted_events() -> Array[CellEvent]:
    var sorted = events.duplicate()
    sorted.sort_custom(func(a, b): return a.time < b.time)
    return sorted
