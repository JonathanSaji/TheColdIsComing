extends CanvasLayer

var fade: ColorRect

func _ready():
	layer = 100
	fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 1)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.modulate.a = 1.0  
	add_child(fade)
	await get_tree().process_frame
	fade.size = get_viewport().get_visible_rect().size
	# Fade in automatically on game start
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(fade, "modulate:a", 0.0, 3)

func fade_to_scene(path: String):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(fade, "modulate:a", 1.0, 0.8)
	tween.tween_callback(func(): get_tree().change_scene_to_file(path))
	tween.tween_property(fade, "modulate:a", 0.0, 0.8)
	
# Fade in a CanvasLayer (make it visible)
func fade_in(canvas_layer: CanvasLayer, duration: float = 0.5):
	canvas_layer.visible = true
	var child = canvas_layer.get_child(0)  # 👈 targets the Panel/Control inside
	child.modulate.a = 0.0
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(child, "modulate:a", 1.0, duration)

# Fade out a CanvasLayer (make it invisible)
func fade_out(canvas_layer: CanvasLayer, duration: float = 0.5, on_complete: Callable = Callable()):
	var child = canvas_layer.get_child(0)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(child, "modulate:a", 0.0, duration)
	tween.tween_callback(func():
		canvas_layer.visible = false
		if on_complete.is_valid():
			on_complete.call()  # 👈 runs after fade completes
	)
	
func fade_and_quit(duration: float = 2):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(fade, "modulate:a", 1.0, duration)
	tween.tween_callback(func(): get_tree().quit())
