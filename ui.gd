extends Control

@onready var dialogue = $Dialogue
@onready var dialogue_label = $Dialogue/Label

func show_message(text:String):
	dialogue_label.text = text
	dialogue.visible = true
	
func hide_message():
	dialogue.visible = false
