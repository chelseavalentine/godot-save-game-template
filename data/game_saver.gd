extends Node

const SAVE_GROUP_NAME = "Persist"
var save_filename = "user://saved-game.tres"
var game_load_name_template = "Game load %d"


func _ready() -> void:
	pass


func save_game():
	var saved_game := SavedGame.new()

	_gather_nodes_to_save(saved_game)

	var save_thread := Thread.new()

	save_thread.start(ResourceSaver.save.bind(saved_game, save_filename))
	save_thread.wait_to_finish()

	print("Saved the game at %s" % OS.get_user_data_dir())


func _gather_nodes_to_save(saved_game: SavedGame):
	var nodes_to_persist = get_tree().get_nodes_in_group(SAVE_GROUP_NAME)
	var root_node: Node = get_tree().root

	for node in nodes_to_persist:
		if not node.has_method("on_save_game"):
			print(node.name + " needs 'on_save_game()' implemented")

		var saved_node_data = node.on_save_game()
		var is_global_node = node.get_parent() == root_node

		if not saved_node_data:
			continue

		saved_node_data.object_id = node.get_instance_id()
		saved_game.nodes.append(saved_node_data)


func load_game():
	get_tree().paused = true

	if not FileAccess.file_exists(save_filename):
		get_tree().paused = false
		return

	var maybe_saved_game = SafeResourceLoader.load(save_filename)

	if not maybe_saved_game:
		print("Couldn't read filename %s" % save_filename)
		get_tree().paused = false
		return false

	var saved_game: SavedGame = maybe_saved_game
	var static_node_data = saved_game.nodes.filter(func(node): return node is StaticNodeSavedData)
	var dynamic_node_data = saved_game.nodes.filter(func(node): return node is DynamicNodeSavedData)

	# Create all nodes and register them.
	var found_static_nodes = static_node_data.map(_find_and_register_static_node)
	var created_dynamic_nodes = dynamic_node_data.map(_create_and_register_dynamic_node)

	# Set up dynamic nodes first, because static things may rely on them and args for callables should be registered
	# already.
	_load_nodes(dynamic_node_data, created_dynamic_nodes)
	_load_nodes(static_node_data, found_static_nodes)

	get_tree().paused = false


func _find_and_register_static_node(data: StaticNodeSavedData):
	var node = get_node(data.node_path)

	ObjectFinder.register(data.object_id, node.get_instance_id())

	return node


func _create_and_register_dynamic_node(data: DynamicNodeSavedData):
	var restored_node = load(data.scene_path).instantiate()

	get_node(data.parent_path).add_child(restored_node)
	restored_node.global_position = data.global_position

	ObjectFinder.register(data.object_id, restored_node.get_instance_id())

	return restored_node


func _load_nodes(data: Array, actual_nodes: Array):
	for i in range(data.size()):
		var node: Node = actual_nodes[i]

		node.on_load_game(data[i])
