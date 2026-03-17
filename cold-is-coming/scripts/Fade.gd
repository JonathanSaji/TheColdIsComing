extends CanvasLayer

var fade: ColorRect

func _ready():
	layer = 100
	fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 1)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.modulate.a = 0.0
	add_child(fade)
	# Set size after adding to scene tree
	await get_tree().process_frame
	fade.size = get_viewport().get_visible_rect().size

func fade_to_scene(path: String):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(fade, "modulate:a", 1.0, 0.8)
	tween.tween_callback(func(): get_tree().change_scene_to_file(path))
	tween.tween_property(fade, "modulate:a", 0.0, 0.8)
