extends Node2D

@onready var spawn_area := find_child("SpawnArea")
@onready var spawn_timer: Timer = find_child("SpawnTimer")
@onready var save_timer: Timer = find_child("SaveTimer")
@onready var prefab_robot: Robot = find_child("Robot")
@onready var cookie: Food = find_child("Cookie")
@onready var cake: Food = find_child("Cake")
@onready var foods: Array[Food] = [cookie, cake]
@onready var served_counter: Label = find_child("ServedCounter")
var num_served := 0
var lock := Mutex.new()


func _ready() -> void:
	add_to_group(GameSaver.SAVE_GROUP_NAME)

	var tilemap: TileMapLayer = find_child("TileMapLayer")

	prefab_robot.hide()
	prefab_robot.navigation_agent.set_navigation_map(tilemap.get_navigation_map())

	save_timer.timeout.connect(GameSaver.save_game)
	spawn_timer.timeout.connect(_spawn_robot)

	_spawn_robot()
	GameSaver.load_game()


func on_save_game() -> MainSceneSavedData:
	var data := MainSceneSavedData.new()

	data.node_path = get_path()
	data.num_robots_served = num_served

	return data


func on_load_game(data: MainSceneSavedData):
	lock.lock()

	num_served = data.num_robots_served

	_update_displayed_amount_served()
	lock.unlock()


func _spawn_robot():
	if not foods.all(func(food: Food): return food.get_free_point()):
		return

	var new_robot: Robot = prefab_robot.duplicate()

	spawn_area.add_child(new_robot)

	new_robot.global_position = Vector2(randi_range(0, spawn_area.size.x), randi_range(0, spawn_area.size.y))
	new_robot.show()

	var chosen_food: Food = foods.pick_random()

	new_robot.go_eat(chosen_food.get_free_point(), _incr_num_served)


func _incr_num_served():
	lock.lock()
	num_served += 1
	_update_displayed_amount_served()
	lock.unlock()


func _update_displayed_amount_served():
	served_counter.text = "Number of robots served: %d" % num_served
