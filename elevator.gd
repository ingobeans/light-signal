extends Node3D

@onready var visibility = $MovingElevator/VisibleOnScreenNotifier3D
@onready var ui = self.get_node("../UI")
@onready var animation_player = $AnimationPlayer
@onready var audio_player = $MovingElevator/AudioStreamPlayer3D
@onready var area = $MovingElevator/Area3D
@onready var cage = $MovingElevator/Cage

var top = true

var interactable = false
var moving_up = true

func _process(_delta: float) -> void:
	var should_be_interactable = len(area.get_overlapping_bodies()) != 0 and not animation_player.is_playing() and visibility.is_on_screen()
	if !interactable and should_be_interactable:
		ui.show_message("[E] press button")
	elif interactable and !should_be_interactable:
		ui.hide_message()
	interactable = should_be_interactable
	
	if moving_up and not animation_player.is_playing():
		moving_up = false
		cage.position.y += 100

	if interactable and Input.is_action_just_pressed("interact"):
		if top:
			animation_player.play("going_down")
		else:
			animation_player.play("going_up")
			moving_up = true
			cage.position.y -= 100
		top = !top
		audio_player.play()
