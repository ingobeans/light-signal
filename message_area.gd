extends Area3D

@export var text: String
@onready var ui = self.get_node("../UI")

func _ready() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	
func _body_entered(_body):
	ui.show_message(text)

func _body_exited(_body):
	ui.hide_message()
