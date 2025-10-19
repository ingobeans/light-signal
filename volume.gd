extends HSlider

func _ready() -> void:
	var sfx_index= AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(sfx_index, 0.0)

func _value_changed(new_value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(sfx_index, (new_value-50.0) / 2.0)
	$AudioStreamPlayer2D.play()
