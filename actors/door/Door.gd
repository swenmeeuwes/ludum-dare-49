extends Node2D

var animated_sprite: AnimatedSprite
var collider: CollisionShape2D
var open_audio: AudioStreamPlayer2D

var is_open = false

func _ready():
	animated_sprite = $AnimatedSprite
	collider = $StaticBody2D/CollisionShape2D
	open_audio = $OpenAudio
	
	animated_sprite.play("default")

func open():
	if is_open:
		return
	
	collider.disabled = true
	animated_sprite.play("open")
	open_audio.play()
	
	is_open = true

func close():
	if !is_open:
		return
	
	collider.disabled = false
	animated_sprite.play("open", true)
	open_audio.play() # TODO: Close sound?
	
	is_open = false
