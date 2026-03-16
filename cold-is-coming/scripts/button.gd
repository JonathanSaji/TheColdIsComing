extends Button

@onready var highlight = $NinePatchRect  # your overlay node
var tween: Tween

func _ready() -> void:
	highlight.modulate.a = 0


func _on_mouse_entered():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 1.0, 0.3)  # 0.3 = speed in seconds

func _on_mouse_exited():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 0.0, 0.3)
