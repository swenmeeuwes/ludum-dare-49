extends Node2D

var animated_sprite: AnimatedSprite

func _ready():
	animated_sprite = $AnimatedSprite
	animated_sprite.animation = "default"

func break_capsule():
	animated_sprite.animation = "broken"
