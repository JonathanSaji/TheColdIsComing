extends Node

@onready var pause_menu = $PauseMenu

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action("ui_cancel") and event.is_pressed() and not event.is_echo():
		if get_tree().paused:
			pause_menu.visible = false
			get_tree().paused = false
		else:
			pause_menu.visible = true
			get_tree().paused = true
