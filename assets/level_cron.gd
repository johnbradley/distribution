class_name LevelCron extends Node

const LEVELS_JSON_PATH: String = "res://assets/puzzle_levels.json"
const CellType = GridCell.CellType
const Direction = GridCell.Direction
const CellColor = GridCell.CellColor
const SinkType = GridCell.SinkType

var tweens: Array[Tween] = []


func _ready() -> void:
    print("LC Ready")
    GameManager.game_clock_state_changed.connect(game_clock_state_changed)

func game_clock_state_changed(running):
    for tween in tweens:
        if running:
            tween.play()
        else:
            tween.pause()

func play_level(level_num: int) -> bool:
    tweens = []
    var level_data = read_level_data(level_num)
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
    var cell_idx = get_cell_idx(dict)

    var color = get_color(dict)
    match get_cell_type(dict):
        CellType.SPAWN:
            var box_count = get_box_count(dict)
            # var interval = get_interval(dict)
            GridData.change_spawn(cell_idx, color, box_count)
        CellType.SINK:
            var sink_type = get_sink_type(dict)
            var lifespan = get_lifespan(dict)
            GridData.change_sink(cell_idx, sink_type, color, lifespan)

func get_lifespan(dict: Dictionary) -> float:
    return dict["end_time"] - dict["start_time"]

func get_cell_type(dict: Dictionary) -> CellType:
    if dict["type"] == "spawn":
        return CellType.SPAWN      
    return CellType.SINK

func get_sink_type(dict: Dictionary) -> SinkType:
    if dict["position"] == "top":
        return SinkType.TOP
    if dict["position"] == "bottom":
        return SinkType.BOTTOM
    return SinkType.LEFT

func get_cell_idx(dict: Dictionary) -> int:
    if "spawn_cell" in dict:
        return dict["spawn_cell"] - 1
    if "sink_cell" in dict:
        return dict["sink_cell"] - 1
    return 0

func get_color(dict: Dictionary) -> CellColor:
    if dict["color"] == "red":
        return CellColor.RED
    if dict["color"] == "yellow":
        return CellColor.YELLOW
    if dict["color"] == "blue":
        return CellColor.BLUE
    return CellColor.NONE             

# "box_count": 5.0, "interval": 6.0 
func get_box_count(dict: Dictionary) -> int:
    return dict["box_count"]

func get_interval(dict: Dictionary) -> int:
    return dict["interval"]    

func read_level_data(level_num: int) -> Variant:
    var data = load_json_file(LEVELS_JSON_PATH)
    if data == null:
        return null
    for level_data in data["levels"]:
        if level_data["level"] == level_num:
            return level_data
    return null
    

func load_json_file(file_path: String) -> Variant:
    # Open the file
    var file = FileAccess.open(file_path, FileAccess.READ)
    
    # Check if file opened successfully
    if file == null:
        print("Error opening file: ", FileAccess.get_open_error())
        return null
    
    # Read the entire file as text
    var json_text = file.get_as_text()
    file.close()
    
    # Parse the JSON
    var json = JSON.new()
    var parse_result = json.parse(json_text)
    
    # Check if parsing was successful
    if parse_result != OK:
        print("Error parsing JSON: ", json.get_error_message())
        return null
    
    # Return the parsed data
    return json.data
