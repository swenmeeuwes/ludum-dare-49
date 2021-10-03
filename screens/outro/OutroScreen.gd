extends Control

const TEXTS = [
	"Well...",
	"Atleast that is not our problem anymore.",
	"Did you have a look at the new hires?",
	"- The End -\nThanks for playing!"
]

var background: TextureRect

var panel: NinePatchRect
var text_field: RichTextLabel

var scientist_left: TextureRect
var scientist_right: TextureRect

var animation_player: AnimationPlayer

var panel_tween: Tween
var text_tween: Tween

var can_continue = false
var text_index = 0

func _ready():
	background = $Background
	
	panel = $DialoguePanel
	text_field = $DialoguePanel/RichTextLabel
	
	scientist_left = $Scientist_Left/Scientist
	scientist_right = $Scientist_Right/Scientist
	
	animation_player = $AnimationPlayer
	
	panel_tween = $DialoguePanelTween
	text_tween = $TextTween
	
	panel.modulate.a = 0
	text_field.text = ""
	
	animation_player.play("intro_start")

func _input(event):
	if event is InputEventKey and event.pressed or event is InputEventMouseButton and event.pressed:
		_next()
		
func _start_intro_dialogue():
	var t1 =_create_timer(.5)
	yield(t1, "timeout")
	t1.queue_free()
	
	_show_text(TEXTS[text_index])
	text_index += 1
	
	can_continue = true

func _end():
	# this is the end :D
	pass

func _next():
	if !can_continue:
		return
	
	if text_index >= TEXTS.size():
		_end()
		return
	
	_show_text(TEXTS[text_index])
	text_index += 1

func _show_text(text):
	can_continue = false
	
#	if panel.modulate.a > 0:
#		_panel_fade_out()
#		yield(panel_tween, "tween_completed")
	
	text_field.percent_visible = 0
	text_field.bbcode_text = text

	if panel.modulate.a == 0:
		_panel_fade_in()
		yield(panel_tween, "tween_completed")
	
	text_tween.interpolate_property(text_field, "percent_visible", 0, 1, .65)
	text_tween.start()
	yield(text_tween, "tween_completed")
	
	can_continue = true

func _panel_fade_out():
	panel_tween.interpolate_property(panel, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0),
		.35, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	panel_tween.start()

func _panel_fade_in():
	panel_tween.interpolate_property(panel, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1),
		.35, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	panel_tween.start()

func _create_timer(duration):
	var t = Timer.new()
	t.set_wait_time(duration)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	return t

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "intro_start":
		_start_intro_dialogue()
