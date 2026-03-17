extends CanvasLayer

var fade: ColorRect

func _ready():
	fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 1)
	fade.anchors_preset = Control.PRESET_FULL_RECT
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.modulate.a = 0.0
	add_child(fade)

func fade_to_scene(path: String):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(fade, "modulate:a", 1.0, 0.8)
	tween.tween_callback(func(): get_tree().change_scene_to_file(path))
	tween.tween_property(fade, "modulate:a", 0.0, 0.8)
