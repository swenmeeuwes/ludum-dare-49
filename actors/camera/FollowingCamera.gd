extends Camera2D

var target
var bounds: Rect2

func set_target(value):
	target = value

func set_bounds(x, y, w, h):
	bounds = Rect2(x, y, w, h)

func _process(_delta):
	if current && target:
		global_position = target.global_position
		global_position.x = clamp(global_position.x, bounds.position.x, bounds.size.x)
		global_position.y = clamp(global_position.y, bounds.position.y, bounds.size.y)
