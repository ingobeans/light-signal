extends Area3D

@onready var ui = self.get_node("../UI")
@onready var player = self.get_node("../Player")
@onready var visibility = $VisibleOnScreenNotifier3D
@onready var model = $key

var showing = false
var taken = false

func _process(_delta: float) -> void:
	if taken:
		return
	var should_show = visibility.is_on_screen() and get_overlapping_bodies()
	if not showing and should_show:
		ui.show_message("[E] pick up key")
	if showing and not should_show:
		ui.hide_message()
	showing = should_show
	
	if showing and Input.is_action_just_pressed("interact"):
		taken = true
		ui.hide_message()
		player.has_key = true
		model.visible = false
