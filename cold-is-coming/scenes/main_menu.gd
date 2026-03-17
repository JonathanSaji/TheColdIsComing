extends Node

@onready var selection = $Effects/selection
@onready var clicked = $Effects/clicked

func _on_play_pressed():
	clicked.play()
	Fade.fade_to_scene("res://scenes/Game.tscn")  # update path to your game scene

func _on_options_pressed():
	clicked.play()
	print("Options button pressed")

func _on_quit_pressed():
	clicked.play()
	get_tree().quit()
