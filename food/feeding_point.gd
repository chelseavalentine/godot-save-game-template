class_name FeedingPoint
extends Marker2D

var type: Food.Type
var is_occupied := false


func _ready() -> void:
	add_to_group(GameSaver.SAVE_GROUP_NAME)


func on_save_game() -> FeedingPointSavedData:
	var data := FeedingPointSavedData.new()

	data.object_id = get_instance_id()
	data.node_path = get_path()
	data.is_occupied = is_occupied

	return data


func on_load_game(data: FeedingPointSavedData):
	is_occupied = data.is_occupied


func reserve(robot: Robot):
	is_occupied = true
