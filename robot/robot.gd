class_name Robot
extends CharacterBody2D

@onready var body: AnimatedSprite2D = find_child("Body")
@onready var navigation_agent: NavigationAgent2D = find_child("NavigationAgent2D")
@onready var eating_progress: TextureProgressBar = find_child("EatingProgress")

var speed = 500
var feeding_point: FeedingPoint
var on_completed_navigation
var on_completed_eating

var cake_texture: Texture2D = load("res://food/assets/cake.png")
var cookie_texture: Texture2D = load("res://food/assets/cookie.png")


func _ready() -> void:
	add_to_group(GameSaver.SAVE_GROUP_NAME)

	navigation_agent.navigation_finished.connect(
		func():
			velocity = Vector2.ZERO
			body.animation = "idle"

			if on_completed_navigation:
				on_completed_navigation.call()
				on_completed_navigation = null
	)

	eating_progress.hide()


func on_save_game() -> RobotSavedData:
	if not feeding_point:
		return null

	var data := RobotSavedData.new()

	data.object_id = get_instance_id()
	data.scene_path = scene_file_path
	data.parent_path = get_parent().get_path()
	data.global_position = global_position

	data.feeding_point = Serializer.serialize(feeding_point)
	data.on_completed_navigation = Serializer.serialize(on_completed_navigation)
	data.on_completed_eating = Serializer.serialize(on_completed_eating)
	data.target_position = navigation_agent.target_position

	return data


func on_load_game(data: RobotSavedData):
	feeding_point = Serializer.deserialize(data.feeding_point)
	on_completed_navigation = Serializer.deserialize(data.on_completed_navigation)
	on_completed_eating = Serializer.deserialize(data.on_completed_eating)

	if on_completed_navigation:
		navigation_agent.target_position = data.target_position
	else:
		_start_eating()


func _physics_process(_delta: float) -> void:
	await get_tree().process_frame

	if navigation_agent.is_navigation_finished():
		return

	var curr_position := global_position
	var next_path_position := navigation_agent.get_next_path_position()
	var new_velocity = (next_path_position - curr_position).normalized() * speed

	navigation_agent.velocity = new_velocity
	velocity = new_velocity
	move_velocity()


func move_velocity():
	body.animation = "running" if velocity else "idle"
	body.flip_h = velocity.x < 0

	move_and_slide()


func go_eat(p_feeding_point: FeedingPoint, p_on_completed_eating: Callable):
	feeding_point = p_feeding_point
	navigation_agent.target_position = feeding_point.global_position

	feeding_point.reserve(self)

	on_completed_eating = p_on_completed_eating
	on_completed_navigation = _start_eating


func _start_eating():
	var food_texture = cake_texture if feeding_point.type == Food.Type.CAKE else cookie_texture

	eating_progress.texture_under = food_texture
	eating_progress.texture_progress = food_texture
	eating_progress.step = 100 / eating_progress.size.y
	eating_progress.value = 0

	var tween := get_tree().create_tween()

	tween.tween_interval(.3)
	tween.tween_callback(eating_progress.show)
	tween.tween_property(eating_progress, "value", 100, 2)
	tween.tween_property(self, "modulate", Color(modulate, 0), .5)
	tween.tween_callback(on_completed_eating)
	tween.tween_callback(func(): feeding_point.is_occupied = false)
	tween.tween_callback(queue_free)
	tween.play()
