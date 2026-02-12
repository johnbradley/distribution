class_name LevelCron extends Node

const CellType = GridCell.CellType

var tweens: Array[Tween] = []


func _ready() -> void:
    GameManager.game_clock_state_changed.connect(game_clock_state_changed)

func game_clock_state_changed(running):
    for tween in tweens:
        if running:
            tween.play()
        else:
            tween.pause()

func play_level(level_num: int) -> bool:
    tweens = []
    var level_data = LevelData.read_level_data(level_num)
    if level_data:
        var total_boxes = 0
        var downtime_limit = level_data["downtime_limit"]
        var max_boxes_lost = level_data["max_boxes_lost"]
        GridData.reset_remaining_downtime(downtime_limit)
        GridData.set_max_boxes_lost(max_boxes_lost)
        for event in level_data["events"]:
            schedule_event(event)
            total_boxes += event.get("box_count", 0)
        GridData.set_total_boxes(total_boxes)
        return true
    else:
        return false

func schedule_event(dict: Dictionary):
    var time = dict["start_time"]
    var tween = get_tree().create_tween()
    tween.tween_interval(time)
    tween.tween_callback(process_event.bind(dict))
    tweens.append(tween)

func process_event(dict: Dictionary) -> void:
    var cell_idx = LevelData.get_cell_idx(dict)
    var color = LevelData.get_color(dict)
    match LevelData.get_cell_type(dict):
        CellType.SPAWN:
            var box_count = LevelData.get_box_count(dict)
            GridData.change_spawn(cell_idx, color, box_count)
        CellType.SINK:
            var sink_type = LevelData.get_sink_type(dict)
            var lifespan = LevelData.get_lifespan(dict)
            GridData.change_sink(cell_idx, sink_type, color, lifespan)
