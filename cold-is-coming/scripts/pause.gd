extends CanvasLayer

func _ready():
	visible = false

func _on_resume_pressed():
	get_tree().paused = false
	visible = false

func _on_main_menu_pressed():
	get_tree().paused = false
	Fade.fade_to_scene("res://scenes/main_menu.tscn")

func _on_quit_pressed():
	get_tree().paused = false
	Fade.fade_and_quit()
