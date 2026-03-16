## player.gd
## Attach to a CharacterBody2D.
##
## Node Tree Expected:
##   Player (CharacterBody2D)
##   ├── Sprite2D
##   ├── AnimationPlayer        (optional, referenced by name)
##   ├── CollisionShape2D
##   ├── HeadTarget (Marker2D)  <-- place at character's head height
##   ├── Camera2D               <-- camera_controller.gd attached here
##   └── HUD (CanvasLayer)      <-- optional, receives warmth/health signals
extends CharacterBody2D

# ─────────────────────────────────────────────
#  Signals
# ─────────────────────────────────────────────
signal health_changed(new_health: float, max_health: float)
signal died()
signal warmth_status_changed(is_freezing: bool)

# ─────────────────────────────────────────────
#  Inspector Exports
# ─────────────────────────────────────────────
@export_group("Movement")
@export var move_speed: float = 160.0

@export_group("Health")
@export var max_health: float = 100.0

@export_group("Freezing")
## Damage per second applied when outside the Eternal Flame radius.
@export var freeze_damage_per_second: float = 8.0
## Seconds between each freeze damage tick (cosmetic; total DPS stays the same).
@export var freeze_tick_interval: float = 0.5

@export_group("Thawing")
## How fast the player heals per second when inside the flame radius.
@export var thaw_speed: float = 5.0
## Multiplier applied to thaw_speed – modified by Shop items.
var thaw_speed_multiplier: float = 1.0

@export_group("References")
@export var eternal_flame_path: NodePath = NodePath()

# ─────────────────────────────────────────────
#  Private State
# ─────────────────────────────────────────────
var _health: float
var _is_freezing: bool = false
var _freeze_tick_timer: float = 0.0
var _eternal_flame: Node2D = null   # resolved in _ready

# ─────────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────────
func _ready() -> void:
	_health = max_health

	if eternal_flame_path:
		_eternal_flame = get_node_or_null(eternal_flame_path)

	# Fallback: search for an EternalFlame in the scene tree by group
	if _eternal_flame == null:
		var flames = get_tree().get_nodes_in_group("eternal_flame")
		if flames.size() > 0:
			_eternal_flame = flames[0]

	if _eternal_flame == null:
		push_warning("Player: No EternalFlame found. Freeze logic disabled. Add the flame to the 'eternal_flame' group.")

	# Make sure the input map action exists at runtime
	if not InputMap.has_action("toggle_focus_view"):
		var ev := InputEventKey.new()
		ev.keycode = KEY_V
		InputMap.add_action("toggle_focus_view")
		InputMap.action_add_event("toggle_focus_view", ev)


func _physics_process(delta: float) -> void:
	_handle_movement()
	_handle_warmth(delta)


# ─────────────────────────────────────────────
#  Movement
# ─────────────────────────────────────────────
func _handle_movement() -> void:
	var direction := Vector2(
		Input.get_axis("ui_left",  "ui_right"),
		Input.get_axis("ui_up",    "ui_down")
	).normalized()

	velocity = direction * move_speed
	move_and_slide()


# ─────────────────────────────────────────────
#  Warmth / Freeze
# ─────────────────────────────────────────────
func _handle_warmth(delta: float) -> void:
	if _eternal_flame == null:
		return

	var dist: float = global_position.distance_to(_eternal_flame.global_position)
	var warm_radius: float = _eternal_flame.get_warm_radius()   # defined in eternal_flame.gd

	if dist > warm_radius:
		# ── Outside the warmth radius → FREEZING ──
		if not _is_freezing:
			_is_freezing = true
			emit_signal("warmth_status_changed", true)

		_freeze_tick_timer -= delta
		if _freeze_tick_timer <= 0.0:
			_freeze_tick_timer = freeze_tick_interval
			var tick_damage := freeze_damage_per_second * freeze_tick_interval
			_apply_damage(tick_damage)
	else:
		# ── Inside the warmth radius → THAWING ──
		if _is_freezing:
			_is_freezing = false
			_freeze_tick_timer = 0.0
			emit_signal("warmth_status_changed", false)

		var heal := thaw_speed * thaw_speed_multiplier * delta
		_apply_heal(heal)


# ─────────────────────────────────────────────
#  Health Helpers
# ─────────────────────────────────────────────
func _apply_damage(amount: float) -> void:
	_health = max(0.0, _health - amount)
	emit_signal("health_changed", _health, max_health)
	if _health <= 0.0:
		_on_death()


func _apply_heal(amount: float) -> void:
	var prev := _health
	_health = min(max_health, _health + amount)
	if _health != prev:
		emit_signal("health_changed", _health, max_health)


func take_damage(amount: float) -> void:
	_apply_damage(amount)


func _on_death() -> void:
	emit_signal("died")
	# TODO: trigger death animation, show game-over screen, etc.
	queue_free()


# ─────────────────────────────────────────────
#  Public Getters
# ─────────────────────────────────────────────
func get_health() -> float:
	return _health

func is_freezing() -> bool:
	return _is_freezing
