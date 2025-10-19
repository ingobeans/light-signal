extends Area3D

@onready var ui = self.get_node("../UI")

var inside = null
var climbing = false

func _ready() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	
func _process(_delta: float) -> void:
	if inside != null and Input.is_action_just_pressed("interact"):
		climbing = true
		inside.start_climb()
		ui.hide_message()
		pass
	
func _body_entered(body):
	ui.show_message("[E] climb")
	inside = body

func _body_exited(body):
	if body == inside:
		ui.hide_message()
		inside = null
