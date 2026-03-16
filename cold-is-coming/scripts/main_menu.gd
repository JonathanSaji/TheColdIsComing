extends Control

@onready var fade = $ColorRect  # your black ColorRect

func _on_play_pressed():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.8)  # 0.8 = fade speed
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/Game.tscn"))

func _on_options_pressed():
	print("Options button pressed")

func _on_quit_pressed():
	get_tree().quit()
