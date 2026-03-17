extends Node

@onready var selection = $Effects/selection
@onready var clicked = $Effects/clicked

func _ready():
	# Pass audio references to each button
	for button in [$Play, $Options, $Quit]:
		button.sfx_hover = selection
		button.sfx_click = clicked

func _on_play_pressed():
	clicked.play()
	Fade.fade_to_scene("res://scenes/game.tscn")

func _on_options_pressed():
	clicked.play()
	print("Options button pressed")

func _on_quit_pressed():
	clicked.play()
	get_tree().quit()
