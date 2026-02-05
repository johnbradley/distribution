class_name LevelData

const LEVELS_DIR: String = "res://assets/levels"
const CellType = GridCell.CellType
const CellColor = GridCell.CellColor
const SinkType = GridCell.SinkType


static func read_level_data(level_num: int) -> Variant:
    var path = "%s/level_%d.json" % [LEVELS_DIR, level_num]
    return load_json_file(path)


static func load_json_file(file_path: String) -> Variant:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        print("Error opening file: ", FileAccess.get_open_error())
        return null
    var json_text = file.get_as_text()
    file.close()
    var json = JSON.new()
    var parse_result = json.parse(json_text)
    if parse_result != OK:
        print("Error parsing JSON: ", json.get_error_message())
        return null
    return json.data


static func get_lifespan(dict: Dictionary) -> float:
    return dict["end_time"] - dict["start_time"]


static func get_cell_type(dict: Dictionary) -> CellType:
    if dict["type"] == "spawn":
        return CellType.SPAWN
    return CellType.SINK


static func get_sink_type(dict: Dictionary) -> SinkType:
    if dict["position"] == "top":
        return SinkType.TOP
    if dict["position"] == "bottom":
        return SinkType.BOTTOM
    return SinkType.LEFT


static func get_cell_index(dict: Dictionary) -> int:
    if "spawn_cell" in dict:
        return dict["spawn_cell"] - 1
    if "sink_cell" in dict:
        return dict["sink_cell"] - 1
    return 0


static func get_color(dict: Dictionary) -> CellColor:
    if dict["color"] == "red":
        return CellColor.RED
    if dict["color"] == "yellow":
        return CellColor.YELLOW
    if dict["color"] == "blue":
        return CellColor.BLUE
    return CellColor.NONE


static func get_box_count(dict: Dictionary) -> int:
    return dict["box_count"]
