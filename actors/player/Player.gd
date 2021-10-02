extends KinematicBody2D

onready var screen_size = get_viewport_rect().size

var animated_sprite: AnimatedSprite
var collider: CollisionShape2D
var shake_timer: Timer

var collider_initial_x = 0

const GRAVITY = 200
const DRAG = 0.01
const LAUNCH_FORCE_RANGE = Vector2(100, 300)
const LAUNCH_FORCE_FACTOR = 6

var velocity = Vector2()
var start_drag_pos = Vector2()
var is_dragging = false

func _ready():
	animated_sprite = $AnimatedSprite
	collider = $CollisionShape2D
	shake_timer = $ShakeTimer
	
	animated_sprite.animation = "idle"
	collider.disabled = true
	collider_initial_x = collider.position.x

func _input(event):
	if velocity.length() > 0:
		return;
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_begin_drag(event.position)
			else:
				_end_drag(event.position)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision and velocity != Vector2.ZERO:
			animated_sprite.animation = "landing"
			animated_sprite.rotation = (-collision.normal.tangent()).angle()
			velocity = Vector2.ZERO
			collider.disabled = true
	
	if velocity.length() > 0:
		velocity.y += GRAVITY * delta
		collider.disabled = false
		
		animated_sprite.rotation = velocity.angle()
		collider.position = velocity.normalized() * collider_initial_x
	
	var drag_multiplier = 1.0 - DRAG * delta
	velocity *= drag_multiplier
	
	position.x = wrapf(position.x, 0, screen_size.x)

func _begin_drag(position: Vector2):
	shake_timer.start()
	is_dragging = true
	animated_sprite.animation = "launching"
	start_drag_pos = position;

func _end_drag(position: Vector2):
	shake_timer.stop()
	animated_sprite.position.x = 0 # reset sprite from shaking
	is_dragging = false
	
	var drag_delta = position - start_drag_pos
	var direction = -drag_delta.normalized() # Invert it as we want a 'slingshot' interaction
	var force = clamp(drag_delta.length() * LAUNCH_FORCE_FACTOR, 0, LAUNCH_FORCE_RANGE.y)
	
	if force < LAUNCH_FORCE_RANGE.x:
		return;
	
	animated_sprite.animation = "flying"
	
	_launch(direction, force);

func _launch(direction: Vector2, force: float):
	if force < LAUNCH_FORCE_RANGE.x:
		return
	
	velocity = direction * force


func _on_AnimatedSprite_animation_finished():
	if animated_sprite.animation == "landing":
		animated_sprite.animation = "idle"


func _on_ShakeTimer_timeout():
	animated_sprite.position.x = randf() * 2
