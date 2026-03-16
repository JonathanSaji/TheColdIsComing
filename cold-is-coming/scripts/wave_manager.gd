## wave_manager.gd
## Attach to an autoload singleton or a Node in the main scene.
## Handles wave transitions and exposes scaled enemy stats.
##
## Scaling Formula:  Stat = Base × 1.15^Wave
extends Node

# ─────────────────────────────────────────────
#  Signals
# ─────────────────────────────────────────────
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_cleared()

# ─────────────────────────────────────────────
#  Inspector Exports
# ─────────────────────────────────────────────
@export_group("Wave Config")
@export var scale_exponent: float = 1.15   ## The base of the exponential growth.

@export_group("Enemy Base Stats")
@export var base_max_health: float  = 40.0
@export var base_move_speed: float  = 60.0
@export var base_damage:     float  = 8.0

@export_group("Spawn Config")
@export var base_enemy_count: int   = 5    ## Enemies on wave 1.
@export var count_per_wave:   int   = 2    ## Additional enemies per wave.

# ─────────────────────────────────────────────
#  State
# ─────────────────────────────────────────────
var current_wave: int = 0
var _enemies_remaining: int = 0
var _wave_active: bool = false

# ─────────────────────────────────────────────
#  Public API
# ─────────────────────────────────────────────

## Call this to advance to the next wave and begin spawning.
func start_next_wave() -> void:
	if _wave_active:
		push_warning("WaveManager: Cannot start a new wave while one is already active.")
		return

	current_wave += 1
	_wave_active = true

	var stats := get_scaled_stats(current_wave)
	_enemies_remaining = stats.enemy_count

	print("── Wave %d Starting ──" % current_wave)
	print("  HP: %.1f | Speed: %.1f | Damage: %.1f | Count: %d" % [
		stats.max_health, stats.move_speed, stats.damage, stats.enemy_count
	])

	emit_signal("wave_started", current_wave)
	# The actual spawning is handled by a spawner that connects to "wave_started".


## Call this whenever an enemy is defeated.
func on_enemy_defeated() -> void:
	_enemies_remaining = max(0, _enemies_remaining - 1)
	if _enemies_remaining == 0 and _wave_active:
		_end_wave()


## Returns a Dictionary of scaled stats for any given wave number.
## Safe to call without side effects (e.g., for UI previews).
func get_scaled_stats(wave: int) -> Dictionary:
	var multiplier := pow(scale_exponent, wave - 1)   # Wave 1 = base stats
	return {
		"wave":        wave,
		"max_health":  base_max_health * multiplier,
		"move_speed":  base_move_speed * multiplier,
		"damage":      base_damage     * multiplier,
		"enemy_count": base_enemy_count + (wave - 1) * count_per_wave,
	}


## Convenience: apply scaled stats directly to an enemy node.
## The enemy must expose `max_health`, `move_speed`, and `damage` properties.
func apply_stats_to_enemy(enemy: Node) -> void:
	var stats := get_scaled_stats(current_wave)
	if "max_health"  in enemy: enemy.max_health  = stats.max_health
	if "move_speed"  in enemy: enemy.move_speed  = stats.move_speed
	if "damage"      in enemy: enemy.damage      = stats.damage
	if "health"      in enemy: enemy.health      = stats.max_health   # reset to full


# ─────────────────────────────────────────────
#  Internal
# ─────────────────────────────────────────────
func _end_wave() -> void:
	_wave_active = false
	print("── Wave %d Complete ──" % current_wave)
	emit_signal("wave_completed", current_wave)
	# The game loop (or HUD) listens to "wave_completed" to show the shop.
