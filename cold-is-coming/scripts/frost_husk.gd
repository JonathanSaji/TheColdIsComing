## frost_husk.gd
## Base enemy for "The Cold Is Coming."
## Attach to a CharacterBody2D.
##
## Node Tree Expected:
##   FrostHusk (CharacterBody2D)
##   ├── Sprite2D
##   ├── CollisionShape2D
##   ├── NavigationAgent2D   <-- for pathfinding toward the flame
##   └── HitboxArea (Area2D) <-- detects player collision for melee damage
extends CharacterBody2D

# ─────────────────────────────────────────────
#  Signals
# ─────────────────────────────────────────────
signal died(enemy: CharacterBody2D, currency_drop: int)

# ─────────────────────────────────────────────
#  Stats  (set by WaveManager.apply_stats_to_enemy before adding to scene)
# ─────────────────────────────────────────────
var max_health:  float = 40.0
var health:      float = 40.0
var move_speed:  float = 60.0
var damage:      float = 8.0
var currency_value: int = 10

# ─────────────────────────────────────────────
#  State
# ─────────────────────────────────────────────
enum State { SEEK_FLAME, ATTACK_PLAYER, DEAD }
var _state: State = State.SEEK_FLAME

var _player:  CharacterBody2D = null
var _flame:   Node2D = null
var _attack_cooldown: float = 0.0
const ATTACK_INTERVAL := 1.0
const ATTACK_RANGE    := 40.0

@onready var _nav: NavigationAgent2D = $NavigationAgent2D

# ─────────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────────
func _ready() -> void:
	health = max_health

	# Find references via groups
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]

	var flames := get_tree().get_nodes_in_group("eternal_flame")
	if flames.size() > 0:
		_flame = flames[0]

	# Connect hitbox if present
	var hitbox: Area2D = get_node_or_null("HitboxArea")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	match _state:
		State.SEEK_FLAME:  _tick_seek_flame(delta)
		State.ATTACK_PLAYER: _tick_attack(delta)
		State.DEAD: pass


# ─────────────────────────────────────────────
#  Behaviour
# ─────────────────────────────────────────────
func _tick_seek_flame(delta: float) -> void:
	# Switch to attacking if the player is close
	if _player and global_position.distance_to(_player.global_position) < ATTACK_RANGE * 2.0:
		_state = State.ATTACK_PLAYER
		return

	# Navigate toward the flame
	if _flame:
		_nav.target_position = _flame.global_position

	var next_pos := _nav.get_next_path_position()
	var direction := (next_pos - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()


func _tick_attack(delta: float) -> void:
	if _player == null:
		_state = State.SEEK_FLAME
		return

	var dist := global_position.distance_to(_player.global_position)

	# Chase player if they ran away
	if dist > ATTACK_RANGE * 3.0:
		_state = State.SEEK_FLAME
		return

	# Move toward player
	if dist > ATTACK_RANGE:
		var dir := (_player.global_position - global_position).normalized()
		velocity = dir * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Melee swing
	_attack_cooldown -= delta
	if _attack_cooldown <= 0.0 and dist <= ATTACK_RANGE:
		_attack_cooldown = ATTACK_INTERVAL
		if _player.has_method("take_damage"):
			_player.take_damage(damage)


# ─────────────────────────────────────────────
#  Damage / Death
# ─────────────────────────────────────────────
func take_damage(amount: float) -> void:
	if _state == State.DEAD:
		return
	health -= amount
	if health <= 0.0:
		_die()


func _die() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO
	emit_signal("died", self, currency_value)
	# TODO: play death particles / animation before queue_free
	queue_free()


# ─────────────────────────────────────────────
#  Hitbox
# ─────────────────────────────────────────────
func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
