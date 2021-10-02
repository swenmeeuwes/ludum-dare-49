extends Node2D

var animated_sprite: AnimatedSprite
var collider: CollisionShape2D
var open_audio: AudioStreamPlayer2D

func _ready():
	animated_sprite = $AnimatedSprite
	collider = $StaticBody2D/CollisionShape2D
	open_audio = $OpenAudio
	
	animated_sprite.play("default")

func open():
	collider.disabled = true
	animated_sprite.play("open")
	open_audio.play()
