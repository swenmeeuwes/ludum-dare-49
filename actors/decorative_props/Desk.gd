extends Node2D

var sprite: Sprite
var collider: CollisionShape2D
var fade_tween: Tween
var explosion_audio: AudioStreamPlayer2D
var particles: Particles2D

var is_destroyed = false

func _ready():
	sprite = $Sprite
	collider = $Area2D/CollisionShape2D
	fade_tween = $FadeTween
	explosion_audio = $ExplosionAudio
	particles = $Particles2D
	
	var amount_of_frames = (sprite.hframes * sprite.vframes) - 1
	sprite.frame = randi() % amount_of_frames


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
