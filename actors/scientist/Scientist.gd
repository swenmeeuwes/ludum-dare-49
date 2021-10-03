extends KinematicBody2D

var movement_speed = 48

var sprite: Sprite
var collider: CollisionShape2D
var fade_tween: Tween
var explosion_audio: AudioStreamPlayer2D
var particles: Particles2D

var is_destroyed = false
var is_sleeping = true

var direction
var distance

var start_x

func _ready():
	sprite = $Sprite
	collider = $Area2D/CollisionShape2D
	fade_tween = $FadeTween
	explosion_audio = $ExplosionAudio
	particles = $Particles2D
	
	start_x = position.x
	
#	var amount_of_frames = (sprite.hframes * sprite.vframes) - 1
#	sprite.frame = randi() % amount_of_frames
	
	if randi() % 2 == 0:
		direction = -1
	else:
		direction = 1
	
	sprite.flip_h = direction != 1
	
	distance = 24 + randf() * 12
	movement_speed = 48 + randf() * 24

func _process(delta):
	if is_destroyed or is_sleeping:
		return
	
	var vel = Vector2(movement_speed * direction, 0)
	move_and_slide(vel)
	
#	position.x += MOVEMENT_SPEED * delta * direction
	
	if abs(position.x - start_x) >= distance:
		direction = -direction
	
	sprite.flip_h = direction != 1

func _on_Area2D_body_entered(body):
	if !body.is_in_group("player") or is_destroyed:
		return
	
	is_destroyed = true
	
	collider.disabled = true
	explosion_audio.play()
	
	fade_tween.interpolate_property(sprite, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .35)
	fade_tween.start()
	
	particles.one_shot = true
	particles.emitting = true


func _on_FadeTween_tween_all_completed():
	queue_free()


func _on_ActionvationTimer_timeout():
	is_sleeping = false
