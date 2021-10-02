extends Node2D

export (Array, NodePath) var doors_to_open_path = []
export (Array, NodePath) var doors_to_close_path = []

export (Array, NodePath) var buttons_to_unpress_path = []
export (Array, NodePath) var buttons_to_press_path = []

var animated_sprite: AnimatedSprite
var collider: CollisionShape2D
var press_audio: AudioStreamPlayer2D

var doors_to_open = []
var doors_to_close = []

var buttons_to_unpress = []
var buttons_to_press = []

var pressed = false

func _ready():
	animated_sprite = $AnimatedSprite
	collider = $CollisionShape2D
	press_audio = $PressAudio
	
	doors_to_open = []
	for p in doors_to_open_path:
		doors_to_open.append(get_node(p))
	
	doors_to_close = []
	for p in doors_to_close_path:
		doors_to_close.append(get_node(p))
	
	buttons_to_unpress = []
	for p in buttons_to_unpress_path:
		buttons_to_unpress.append(get_node(p))
	
	buttons_to_press = []
	for p in buttons_to_press_path:
		buttons_to_press.append(get_node(p))
	
	animated_sprite.play("default")

func reset():
	if !pressed:
		return
	
	collider.disabled = false
	
	animated_sprite.play("press", true)
	pressed = false

func press():
	if pressed:
		return
	
	collider.disabled = true
	
	animated_sprite.play("press")
	pressed = true
	
	press_audio.play()
	
	for d in doors_to_open:
		d.open()
	
	for d in doors_to_close:
		d.close()
	
	for b in buttons_to_unpress:
		b.reset()
	
	for b in buttons_to_press:
		b.press()

func action():
	press()

func modify_velocity(velocity: Vector2, collision: KinematicCollision2D):
	var vel_bounced = velocity.bounce(collision.normal)
	vel_bounced = vel_bounced.normalized() * 50
	
	return vel_bounced
