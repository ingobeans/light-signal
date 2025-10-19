extends Area3D

@onready var ui = self.get_node("../../UI")
@onready var player = self.get_node("../../Player")
@onready var visibility = $VisibleOnScreenNotifier3D
@onready var animation = $AnimationPlayer

@export var light_material: Material
@onready var light_spin_thing = self.get_node("../../lighthouse/lighthouse_light")

var showing = false
var opened = false

var time = 0.0

var lights = 0
var lightup_time = 1.0

func _process(delta: float) -> void:
	var should_show = not opened and visibility.is_on_screen() and get_overlapping_bodies()
	if not showing and should_show:
		ui.show_message("[E] pull switch")
	if showing and not should_show:
		ui.hide_message()
	showing = should_show
	
	if opened:
		time += delta
		if lights == 0 and time > lightup_time / 3:
			get_node("../Light_003").set_surface_override_material(0,light_material)
			lights += 1
		elif lights == 1 and time > 2 * lightup_time / 3:
			get_node("../Light_002").set_surface_override_material(0,light_material)
			lights += 1
		elif lights == 2 and time > 3 * lightup_time / 3:
			get_node("../Light_001").set_surface_override_material(0,light_material)
			lights += 1
			light_spin_thing.start()
		
	
	if showing and Input.is_action_just_pressed("interact"):
		opened = true
		animation.play("pull")
		ui.hide_message()
