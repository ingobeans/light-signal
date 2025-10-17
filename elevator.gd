extends Node3D

@onready var visibility = $MovingElevator/VisibleOnScreenNotifier3D
@onready var ui = self.get_node("../UI")
@onready var player = self.get_node("../Player")
@onready var animation_player = $AnimationPlayer

var dist = 1.6

var top = true

var interactable = false

func _process(_delta: float) -> void:
	#print(visibility.global_position.distance_to(player.global_position), animation_player.current_animation, visibility.is_on_screen())
	var should_be_interactable = visibility.global_position.distance_to(player.global_position) < dist and not animation_player.is_playing() and visibility.is_on_screen()
	if !interactable and should_be_interactable:
		ui.show_message("[E] press button")
	elif interactable and !should_be_interactable:
		ui.hide_message()
	interactable = should_be_interactable

	if interactable and Input.is_action_just_pressed("interact"):
		if top:
			animation_player.play("going_down")
		else:
			animation_player.play("going_up")
		top = !top
