extends CanvasLayer

const LAUNCH_FORCE_FACTOR = 4
const DRAG_LENGTH_RANGE = Vector2(50 / LAUNCH_FORCE_FACTOR, 200 / LAUNCH_FORCE_FACTOR)

export (NodePath) var line_node_path
var line: Line2D

var start_drag_pos

func _ready():
	line = get_node(line_node_path)
	line.width = 5

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_begin_drag(event.position)
			else:
				_end_drag(event.position)
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("start_drag"):
			line.clear_points()
			var drag_delta = event.position - start_drag_pos
			if (drag_delta.length() > DRAG_LENGTH_RANGE.x):
				_draw_line(event.position)

func _begin_drag(position: Vector2):
	start_drag_pos = position

func _end_drag(_position: Vector2):
	line.clear_points()

func _draw_line(position: Vector2):
	var drag_delta = position - start_drag_pos
	var direction = drag_delta.normalized()
	var length = drag_delta.length()
	var end_point = start_drag_pos + direction * clamp(length, DRAG_LENGTH_RANGE.x, DRAG_LENGTH_RANGE.y)
	
	line.add_point(start_drag_pos)
	line.add_point(end_point)
