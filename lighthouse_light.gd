extends Node3D

@onready var animation = $AnimationPlayer
@onready var light = $OmniLight3D
@export var glow: Material
@onready var environment: WorldEnvironment = self.get_node("../../WorldEnvironment")
@onready var ui = self.get_node("../../UI")

var counter = 0.0

func start():
	animation.play("spin")
	counter += 0.01
	$Cylinder.set_surface_override_material(0,glow)

func _process(delta: float) -> void:
	if counter > 0.0 and counter < 4.0:
		counter += delta
		if counter < 2.0:
			light.light_energy = 0.1 * 13.4 ** counter
			animation.speed_scale = counter
		else:
			environment.environment.tonemap_exposure = 1 + 0.1 * 13.4 ** (counter-2.0)
			environment.environment.tonemap_white = 13.9 ** -(counter-2.0)
			if counter > 3.0:
				ui.set_flashbang_amount(counter-3.0)
	
	if counter >= 4.0:
		environment.environment.tonemap_exposure = 1.0
		environment.environment.tonemap_white = 1.0
		gamestate.has_completed = true
		get_tree().reload_current_scene()
