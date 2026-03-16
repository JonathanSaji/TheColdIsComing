## eternal_flame.gd
## Attach to a Node2D that represents the Eternal Flame.
##
## Node Tree Expected:
##   EternalFlame (Node2D)  <-- add to group "eternal_flame"
##   ├── PointLight2D       <-- referenced as $FlameLight
##   ├── Sprite2D           <-- the visual flame (optional)
##   └── AnimationPlayer    <-- optional, for flame flicker animation
##
## The PointLight2D's texture_scale IS the authoritative warm radius.
## "Warmth" is a 0.0–1.0 value derived from current radius vs. starting radius.
extends Node2D

# ─────────────────────────────────────────────
#  Signals
# ─────────────────────────────────────────────
signal warmth_changed(warmth: float)         # 0.0 (dead) → 1.0 (full)
signal flame_extinguished()

# ─────────────────────────────────────────────
#  Inspector Exports
# ─────────────────────────────────────────────
@export_group("Light")
## Starting texture_scale for the PointLight2D. Acts as the "full warmth" radius.
@export var initial_light_scale: float = 4.0
## Minimum scale before the flame is considered extinguished.
@export var min_light_scale: float = 0.2
## How fast the light shrinks per second under normal conditions.
@export var decay_rate: float = 0.02

@export_group("Warm Radius")
## The warm radius in world pixels when the light is at initial_light_scale.
## Adjust this to match your PointLight2D texture size.
## warm_radius scales linearly with the light scale.
@export var base_warm_radius: float = 240.0

@export_group("Shop Modifiers")
## Multiplier applied to base_warm_radius – modified by Shop items.
var light_radius_multiplier: float = 1.0
## Multiplier applied to decay_rate (values < 1.0 slow decay).
var decay_rate_multiplier: float = 1.0

@export_group("Flicker")
@export var flicker_enabled: bool = true
@export var flicker_speed: float = 3.5
@export var flicker_magnitude: float = 0.08   # ± fraction of current scale

# ─────────────────────────────────────────────
#  Private State
# ─────────────────────────────────────────────
var _current_scale: float
var _warmth: float = 1.0          # 0.0 – 1.0
var _extinguished: bool = false
var _flicker_time: float = 0.0

@onready var _light: PointLight2D = $FlameLight

# ─────────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────────
func _ready() -> void:
	add_to_group("eternal_flame")
	_current_scale = initial_light_scale
	_apply_light_scale(_current_scale)


func _process(delta: float) -> void:
	if _extinguished:
		return

	# ── Decay ──
	var effective_decay := decay_rate * decay_rate_multiplier * delta
	_current_scale = max(min_light_scale, _current_scale - effective_decay)

	# ── Warmth ──
	var new_warmth := (_current_scale - min_light_scale) / (initial_light_scale - min_light_scale)
	new_warmth = clampf(new_warmth, 0.0, 1.0)
	if not is_equal_approx(new_warmth, _warmth):
		_warmth = new_warmth
		emit_signal("warmth_changed", _warmth)

	# ── Extinguish check ──
	if _current_scale <= min_light_scale:
		_extinguish()
		return

	# ── Flicker ──
	if flicker_enabled:
		_flicker_time += delta * flicker_speed
		var flicker_offset := sin(_flicker_time) * flicker_magnitude * _current_scale
		_apply_light_scale(_current_scale + flicker_offset)
	else:
		_apply_light_scale(_current_scale)


# ─────────────────────────────────────────────
#  Public API
# ─────────────────────────────────────────────

## Returns the current effective warm radius in world pixels.
func get_warm_radius() -> float:
	return base_warm_radius * (_current_scale / initial_light_scale) * light_radius_multiplier


## Returns warmth as a 0.0–1.0 float.
func get_warmth() -> float:
	return _warmth


## Feed the flame – increases the light scale (used by items/upgrades).
func add_fuel(amount: float) -> void:
	_current_scale = min(initial_light_scale, _current_scale + amount)
	if _extinguished and _current_scale > min_light_scale:
		_extinguished = false
		_light.enabled = true


## Instantly set a new decay rate (e.g., from a Shop item).
func set_decay_rate(new_rate: float) -> void:
	decay_rate = new_rate


# ─────────────────────────────────────────────
#  Internal
# ─────────────────────────────────────────────
func _apply_light_scale(scale_value: float) -> void:
	if _light:
		_light.texture_scale = scale_value


func _extinguish() -> void:
	if _extinguished:
		return
	_extinguished = true
	_warmth = 0.0
	_apply_light_scale(min_light_scale)
	if _light:
		_light.enabled = false
	emit_signal("warmth_changed", 0.0)
	emit_signal("flame_extinguished")
	print("The Eternal Flame has been extinguished. The Cold has won.")
