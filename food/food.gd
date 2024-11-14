class_name Food
extends Sprite2D

@export var type: Type = Type.CAKE
@onready var feeding_points = find_children("FeedingPoint*", "FeedingPoint")


enum Type {
	CAKE,
	COOKIE,
}


func _ready() -> void:
	for point in feeding_points:
		(point as FeedingPoint).type = type


func get_free_point() -> FeedingPoint:
	var free_points = feeding_points.filter(func(point: FeedingPoint): return not point.is_occupied)

	return free_points.pick_random()
