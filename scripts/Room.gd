extends Node2D

class_name Room

onready var screen_size = get_viewport_rect().size

var camera: Camera2D
var area: Area2D
var collision_shape: CollisionShape2D

func _ready():
	camera = $Camera2D
	area = $Area2D
	collision_shape = $Area2D/CollisionShape2D
	
	_update_camera_limits(camera)
	
	area.connect("body_entered", self, "_on_Area2D_body_entered")

func _update_camera_limits(cam: Camera2D):
	if cam.has_method("set_bounds"):
		var shape: RectangleShape2D = collision_shape.shape
		var corrected_extends = Vector2(shape.extents.x - screen_size.x * .5, shape.extents.y - screen_size.y * .5)
		cam.set_bounds(collision_shape.global_position.x - corrected_extends.x, collision_shape.global_position.y - corrected_extends.y, 
			collision_shape.global_position.x + corrected_extends.x, collision_shape.global_position.y + corrected_extends.y)

func get_camera():
	return camera

func _on_Area2D_body_entered(body: Node):
	if body.is_in_group("player") and area.overlaps_body(body):
		RoomManager.set_room(self)
