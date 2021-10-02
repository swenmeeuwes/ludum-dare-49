extends Node2D

export (PackedScene) var player_scene
export (NodePath) var player_spawn_path
export (NodePath) var player_capsule_path

var flash: ColorRect
var animation_player: AnimationPlayer

var player_capsule
var player_spawn: Node2D
var player: Node2D

func _ready():
	flash = $CanvasLayer/Flash
	animation_player = $AnimationPlayer
	player_spawn = get_node(player_spawn_path)
	player_capsule = get_node(player_capsule_path)
	
	flash.self_modulate.a = 0

func _spawn_player():
	player = player_scene.instance()
	add_child(player)
	
	player.position = player_spawn.position
	player.launch(Vector2.UP.rotated(-.05 * PI), 175)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "flash_to_white":
		player_capsule.break_capsule()
		_spawn_player()
		animation_player.play("flash_from_white")


func _on_FlashDelayTimer_timeout():
	animation_player.play("flash_to_white")
