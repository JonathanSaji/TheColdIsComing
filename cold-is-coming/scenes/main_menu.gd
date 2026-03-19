extends Node

@onready var selection = $Effects/selection
@onready var clicked = $Effects/clicked
@onready var canvas = $Option

func _ready():
	canvas.visible = false
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	# Pass audio references to each button
	for button in [$Play, $Options, $Quit]:
		button.sfx_hover = selection
		button.sfx_click = clicked

func _on_play_pressed():
	clicked.play()
	Fade.fade_to_scene("res://scenes/game.tscn")

func _on_options_pressed():
	clicked.play()
	if canvas.visible:
		Fade.fade_out(canvas)
		canvas.visible = false
	else:
		Fade.fade_in(canvas)
		canvas.visible = true

func _on_quit_pressed():
	clicked.play()
	Fade.fade_and_quit()
	
func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(value)
		)
