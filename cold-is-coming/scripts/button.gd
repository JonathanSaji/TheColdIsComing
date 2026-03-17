extends Button

@onready var highlight = $NinePatchRect
var tween: Tween
var sfx_hover: AudioStreamPlayer
var sfx_click: AudioStreamPlayer

func _ready() -> void:
	highlight.modulate.a = 0

func _on_mouse_entered():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 1.0, 0.3)
	if sfx_hover: sfx_hover.play()

func _on_mouse_exited():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 0.0, 0.3)
