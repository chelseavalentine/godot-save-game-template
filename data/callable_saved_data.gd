class_name CallableSavedData
extends BaseNodeSavedData

@export var method_name: String
@export var bound_args := []


func _to_string():
	return "#{%d}.%s() %s" % [object_id, method_name, str(bound_args)]
