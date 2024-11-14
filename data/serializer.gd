class_name Serializer
extends Node


static func serialize(thing) -> Variant:
	if thing == null:
		return null
	elif thing is Callable:
		return _serialize_callable(thing)
	elif thing is Array:
		return _serialize_array(thing)
	elif thing is Dictionary:
		return _serialize_dictionary(thing)
	elif thing is Node:
		return _create_object_data(thing)
	else:
		if thing is Object and thing.has_method("get_script"):
			var script = thing.get_script()

			if script and script.has_method("get_global_name"):
				print("Unsupported thing to serialize: " + str(thing.get_script().get_global_name()))
				return null

		return thing


static func _serialize_callable(callable: Callable) -> CallableSavedData:
	if callable == null:
		return null

	var save_data := CallableSavedData.new()

	if str(callable.get_method()) == "<anonymous lambda>":
		print("Found anonymous callable that needs to be made into a class method that can be serialized.")
		print(callable.get_object().get_script())
		print()

	save_data.object_id = callable.get_object_id()

	save_data.method_name = callable.get_method()
	save_data.bound_args = _serialize_array(callable.get_bound_arguments())

	return save_data


static func _serialize_dictionary(raw_dictionary: Dictionary) -> Dictionary:
	var serialized_dictionary := {}

	for key in raw_dictionary.keys():
		serialized_dictionary[serialize(key)] = serialize(raw_dictionary.get(key))

	return serialized_dictionary


static func _serialize_array(array: Array) -> Array:
	var serialized_elements = []

	for element in array:
		serialized_elements.append(serialize(element))

	return serialized_elements


static func deserialize(thing) -> Variant:
	if thing is CallableSavedData:
		return _deserialize_callable(thing)
	elif thing is ObjectSavedData:
		return ObjectFinder.get_object((thing as ObjectSavedData).object_id)
	elif thing is Array:
		return _deserialize_array(thing)
	elif thing is Dictionary:
		return _deserialize_dictionary(thing)
	else:
		if thing is Object and thing.has_method("get_script") and thing.get_script():
			print("Unsupported thing to deserialize: " + str(thing.get_script().get_global_name()) + " for " + str(thing))
			return null

		return thing


static func _deserialize_callable(data: CallableSavedData) -> Callable:
	var found_object = ObjectFinder.get_object(data.object_id)
	var callable: Callable = Callable.create(found_object, data.method_name)
	var args := data.bound_args.map(deserialize)

	if not found_object:
		print("Didn't find object for method %s" % data.method_name)

	return callable.bindv(args)


static func _deserialize_dictionary(serialized_dictionary: Dictionary) -> Dictionary:
	var deserialized_dictionary = {}

	for key in serialized_dictionary.keys():
		deserialized_dictionary[deserialize(key)] = deserialize(serialized_dictionary.get(key))

	return deserialized_dictionary


static func _deserialize_array(array: Array) -> Array:
	return array.map(deserialize)


static func _create_object_data(object: Object):
	var data: ObjectSavedData = ObjectSavedData.new()

	data.object_id = object.get_instance_id()

	return data
