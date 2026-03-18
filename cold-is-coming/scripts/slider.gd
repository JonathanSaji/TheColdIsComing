extends Control  # or whatever your menu node is

func _ready():
	$HSlider.value = Global.music_volume  # 👈 pull from Global not local var

func _on_h_slider_value_changed(value):
	Global.music_volume = value  # 👈 save to Global so it persists
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(value)
	)
