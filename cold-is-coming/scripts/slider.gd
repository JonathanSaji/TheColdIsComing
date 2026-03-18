extends Control  # or whatever your menu node is

func _ready():
	$HSlider.value = Global.music_volume  # 👈 pull from Global not local var

func _on_h_slider_value_changed(value):
	Global.music_volume = value
	get_node("/root/Main Menu/Music").volume_db = linear_to_db(max(value, 0.0001))
