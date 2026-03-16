## camera_controller.gd
## Attach to a Camera2D node that is a child of the Player scene.
## Requires a Marker2D named "HeadTarget" as a sibling (also child of Player).
##
## Node Tree Expected:
##   Player (CharacterBody2D)
##   ├── Sprite2D
##   ├── HeadTarget (Marker2D)  <-- position this at the character's head in editor
##   └── Camera2D  <-- attach this script here
extends Camera2D

# ─────────────────────────────────────────────
#  Inspector Exports
# ─────────────────────────────────────────────
@export_group("Standard View")
@export var zoom_standard: float = 1.0
@export var offset_standard: Vector2 = Vector2.ZERO

@export_group("Focused View")
@export var zoom_focused: float = 1.8
## How many pixels ABOVE the pivot the head marker sits.
## The camera offset will shift UP by this amount so the head is centred.
@export var head_target_name: String = "HeadTarget"

@export_group("Transition")
@export var tween_duration: float = 0.35
@export var tween_ease: Tween.EaseType = Tween.EASE_OUT
@export var tween_trans: Tween.TransitionType = Tween.TRANS_CUBIC

# ─────────────────────────────────────────────
#  Private State
# ─────────────────────────────────────────────
var _focused: bool = false
var _active_tween: Tween = null
var _head_marker: Marker2D = null

# ─────────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────────
func _ready() -> void:
	# Resolve the HeadTarget marker relative to the Player (our owner/parent)
	_head_marker = get_parent().get_node_or_null(head_target_name)
	if _head_marker == null:
		push_warning("CameraController: Could not find Marker2D '%s' on parent node. Focused offset will be Vector2.ZERO." % head_target_name)

	# Snap to default state without animation on first frame
	zoom   = Vector2(zoom_standard, zoom_standard)
	offset = offset_standard


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_focus_view"):
		_toggle_view()


# ─────────────────────────────────────────────
#  Public API
# ─────────────────────────────────────────────

## Force a specific view without toggling.
func set_focused(value: bool) -> void:
	if _focused == value:
		return
	_focused = value
	_animate_to_current_state()


## Returns true when the camera is in (or transitioning toward) Focused mode.
func is_focused() -> bool:
	return _focused


# ─────────────────────────────────────────────
#  Internal
# ─────────────────────────────────────────────
func _toggle_view() -> void:
	_focused = !_focused
	_animate_to_current_state()


func _animate_to_current_state() -> void:
	# Kill any in-progress tween cleanly
	if _active_tween and _active_tween.is_running():
		_active_tween.kill()

	var target_zoom:   Vector2
	var target_offset: Vector2

	if _focused:
		target_zoom = Vector2(zoom_focused, zoom_focused)
		# Shift the camera so the head marker is the screen centre.
		# The marker's *local* position relative to the player IS the offset we need
		# (Camera2D offset is in local/player space for a child camera).
		target_offset = -(_head_marker.position if _head_marker else Vector2.ZERO)
	else:
		target_zoom   = Vector2(zoom_standard, zoom_standard)
		target_offset = offset_standard

	_active_tween = create_tween()
	_active_tween.set_ease(tween_ease)
	_active_tween.set_trans(tween_trans)
	_active_tween.set_parallel(true)  # run both properties simultaneously

	_active_tween.tween_property(self, "zoom",   target_zoom,   tween_duration)
	_active_tween.tween_property(self, "offset", target_offset, tween_duration)
