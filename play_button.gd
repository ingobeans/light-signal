extends Button

var counter = 0.0
@export var fade: ColorRect

func _process(delta: float) -> void:
	if counter > 0.0:
		counter += delta
		
		fade.color.a = counter
		
	if counter >= 1.0:
		get_tree().change_scene_to_file("res://world.tscn")

func _pressed() -> void:
	counter = 0.01
	fade.visible = true
