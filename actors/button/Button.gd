extends Node2D

var animated_sprite: AnimatedSprite
var collider: CollisionShape2D

var pressed = false

func _ready():
	animated_sprite = $AnimatedSprite
	collider = $CollisionShape2D
	
	animated_sprite.play("default")

func _press():
	collider.disabled = true
	
	animated_sprite.play("press")
	pressed = true

func action():
	_press()

func modify_velocity(velocity: Vector2, collision: KinematicCollision2D):
	var vel_bounced = velocity.bounce(collision.normal)
	vel_bounced = vel_bounced.normalized() * 50
	
	return vel_bounced
