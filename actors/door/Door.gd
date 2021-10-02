extends Node2D

var animated_sprite: AnimatedSprite
var collider: CollisionShape2D

func _ready():
	animated_sprite = $AnimatedSprite
	collider = $StaticBody2D/CollisionShape2D
	
	animated_sprite.play("default")

func open():
	collider.disabled = true
	animated_sprite.play("open")
