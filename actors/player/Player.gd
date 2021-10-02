extends KinematicBody2D

var animated_sprite: AnimatedSprite
var collider: CollisionShape2D
var shake_timer: Timer
var hurt_timer: Timer
var hurt_tween: Tween
var jump_audio: AudioStreamPlayer2D
var hit_audio: AudioStreamPlayer2D

var collider_initial_x = 0

const GRAVITY = 200
const DRAG = 0.01
const LAUNCH_FORCE_RANGE = Vector2(50, 200)
const LAUNCH_FORCE_FACTOR = 4

var velocity = Vector2()
var start_drag_pos = Vector2()
var is_dragging = false

var last_safe_room
var last_safe_position
var last_safe_rotation

func _ready():
	animated_sprite = $AnimatedSprite
	collider = $CollisionShape2D
	shake_timer = $ShakeTimer
	hurt_timer = $HurtTimer
	hurt_tween = $HurtTween
	jump_audio = $JumpAudio
	hit_audio = $HitAudio
	
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
		if collision.collider.is_in_group("hurtful"):
			respawn()
			return
		
		if collision.collider.has_method("action"):
			collision.collider.action()
		
		if collision.collider.has_method("modify_velocity"):
			velocity = collision.collider.modify_velocity(velocity, collision)
		else:
			animated_sprite.animation = "landing"
			animated_sprite.rotation = (-collision.normal.tangent()).angle()
			velocity = Vector2.ZERO
			collider.disabled = true
			
			last_safe_position = position
			last_safe_rotation = animated_sprite.rotation
			last_safe_room = RoomManager.get_current_room()
	
	if velocity.length() > 0:
		velocity.y += GRAVITY * delta
		collider.disabled = false
		
		animated_sprite.rotation = velocity.angle()
		collider.position = velocity.normalized() * collider_initial_x
	
	var drag_multiplier = 1.0 - DRAG * delta
	velocity *= drag_multiplier

func _begin_drag(position: Vector2):
	shake_timer.start()
	is_dragging = true
	animated_sprite.animation = "launching"
	start_drag_pos = position;

func _end_drag(position: Vector2):
	shake_timer.stop()
	animated_sprite.position.x = 0 # reset sprite from shaking
	animated_sprite.animation = "idle"
	is_dragging = false
	
	var drag_delta = position - start_drag_pos
	var direction = -drag_delta.normalized() # Invert it as we want a 'slingshot' interaction
	var force = clamp(drag_delta.length() * LAUNCH_FORCE_FACTOR, 0, LAUNCH_FORCE_RANGE.y)
	
	if force < LAUNCH_FORCE_RANGE.x:
		return;
	
	launch(direction, force)

func launch(direction: Vector2, force: float):
	if force < LAUNCH_FORCE_RANGE.x:
		return
	
	animated_sprite.animation = "flying"
	jump_audio.play()
	
	velocity = direction * force

func respawn():
	RoomManager.set_room(last_safe_room)
	position = last_safe_position
	animated_sprite.rotation = last_safe_rotation
	animated_sprite.animation = "idle"
	velocity = Vector2.ZERO
	collider.disabled = false
	
	hurt_tween.remove_all()
	hurt_tween.interpolate_property(animated_sprite, "self_modulate",
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), .2, Tween.TRANS_BOUNCE)
	hurt_tween.start()
	hurt_timer.start()
	
	hit_audio.play()

func _on_AnimatedSprite_animation_finished():
	if animated_sprite.animation == "landing":
		animated_sprite.animation = "idle"

func _on_ShakeTimer_timeout():
	if animated_sprite.position.x == 0:
		animated_sprite.position.x = .5
	
	animated_sprite.position.x = -animated_sprite.position.x

func _on_HurtTimer_timeout():
	hurt_tween.seek(0)
	hurt_tween.remove_all()
