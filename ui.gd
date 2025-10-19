extends Control

@onready var dialogue = $Dialogue
@onready var dialogue_label = $Dialogue/Label

@onready var whitescreen = $ColorRect

func set_flashbang_amount(amt:float):
	whitescreen.color.a = amt

func show_message(text:String):
	dialogue_label.text = text
	dialogue.visible = true
	
func hide_message():
	dialogue.visible = false
