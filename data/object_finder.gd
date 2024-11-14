extends Node

# A mapping of object IDs from the loaded saved game state to the current object IDs after loading.
var object_id_by_saved_id := {}


func get_object(saved_id: int) -> Object:
	if saved_id in object_id_by_saved_id:
		return instance_from_id(object_id_by_saved_id[saved_id])
	else:
		return instance_from_id(saved_id)


func register(saved_id: int, current_object_id: int):
	object_id_by_saved_id[saved_id] = current_object_id
