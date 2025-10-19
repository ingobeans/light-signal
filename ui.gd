extends Control

@onready var dialogue = $Dialogue
@onready var dialogue_label = $Dialogue/Label

@onready var whitescreen = $ColorRect
@onready var video = $VideoStreamPlayer

var spawn_flashbang = 0.0

var flash_out = 0.0

func _process(delta: float) -> void:
	if spawn_flashbang < 2.0:
		spawn_flashbang += delta
		if spawn_flashbang >= 2.0:
			set_flashbang_amount(0.0)
			video.play()
	elif flash_out == 0.0 and gamestate.has_completed:
		flash_out = 0.01
	if spawn_flashbang >= 1.5 and mouse_filter != MouseFilter.MOUSE_FILTER_PASS:
		mouse_filter = MouseFilter.MOUSE_FILTER_PASS
	
	if flash_out > 0.0:
		flash_out += delta
		if flash_out >= 3.5:
			set_flashbang_amount(flash_out-3.5)
		if flash_out >= 5.0:
			get_tree().change_scene_to_file("res://win.tscn")
		

func set_flashbang_amount(amt:float):
	whitescreen.color.a = amt

func show_message(text:String):
	dialogue_label.text = text
	dialogue.visible = true
	
func hide_message():
	dialogue.visible = false
