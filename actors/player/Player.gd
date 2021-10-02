extends KinematicBody2D

var animated_sprite: AnimatedSprite
var flying_collider: CollisionShape2D
var idle_collider: CollisionShape2D
var shake_timer: Timer
var hurt_timer: Timer
var hurt_tween: Tween
var jump_audio: AudioStreamPlayer2D
var hit_audio: AudioStreamPlayer2D

var flying_collider_initial_x = 0
var idle_collider_initial_y = 0

const GRAVITY = 200
const DRAG = 0.01
const LAUNCH_FORCE_RANGE = Vector2(65, 150)
const LAUNCH_FORCE_FACTOR = 4

var velocity = Vector2()
var start_drag_pos = Vector2()
var is_dragging = false

var last_safe_room
var last_safe_position
var last_safe_rotation

func _ready():
	animated_sprite = $AnimatedSprite
	flying_collider = $FlyingCollisionShape2D
	idle_collider = $IdleCollisionShape2D
	shake_timer = $ShakeTimer
	hurt_timer = $HurtTimer
	hurt_tween = $HurtTween
	jump_audio = $JumpAudio
	hit_audio = $HitAudio
	
	animated_sprite.animation = "idle"
	flying_collider.disabled = true
	idle_collider.disabled = false
#	flying_collider_initial_x = flying_collider.position.x
#	idle_collider_initial_y = idle_collider.position.y
	flying_collider_initial_x = 0
	idle_collider_initial_y = 0

func _input(event):
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
			var inverse_tangent = -collision.normal.tangent()
			rotation = stepify(inverse_tangent.angle(), PI * .5)
			
			velocity = Vector2.ZERO
			flying_collider.disabled = true
			idle_collider.disabled = false
			
			animated_sprite.animation = "landing"
			
			last_safe_position = position
			last_safe_rotation = rotation
			last_safe_room = RoomManager.get_current_room()
	
	if velocity.length() > 0:
		velocity.y += GRAVITY * delta
		flying_collider.disabled = false
		idle_collider.disabled = true
		
		rotation = velocity.angle()
		flying_collider.position = velocity.normalized() * flying_collider_initial_x
	
	var drag_multiplier = 1.0 - DRAG * delta
	velocity *= drag_multiplier

func _begin_drag(evt_position: Vector2):
	is_dragging = true
	start_drag_pos = evt_position;
	
	if velocity.length() > 0:
		return
	
	shake_timer.start()
	animated_sprite.animation = "launching"

func _end_drag(evt_position: Vector2):
	if velocity.length() > 0:
		return
	
	shake_timer.stop()
	animated_sprite.position.x = 0 # reset sprite from shaking
	animated_sprite.animation = "idle"
	is_dragging = false
	
	var drag_delta = evt_position - start_drag_pos
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
	rotation = last_safe_rotation
	animated_sprite.animation = "idle"
	velocity = Vector2.ZERO
	flying_collider.disabled = false
	
	hurt_tween.remove_all()
	hurt_tween.interpolate_property(animated_sprite, "self_modulate",
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), .2, Tween.TRANS_BOUNCE)
	hurt_tween.start()
	hurt_timer.start()
	
	hit_audio.play()

func _on_AnimatedSprite_animation_finished():
	if animated_sprite.animation == "landing":
		if is_dragging:
			shake_timer.start()
			animated_sprite.animation = "launching"
		else:
			animated_sprite.animation = "idle"

func _on_ShakeTimer_timeout():
	if animated_sprite.position.x == 0:
		animated_sprite.position.x = .5
	
	animated_sprite.position.x = -animated_sprite.position.x

func _on_HurtTimer_timeout():
	hurt_tween.seek(0)
	hurt_tween.remove_all()
