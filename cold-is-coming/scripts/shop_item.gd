## shop_item.gd
## A Resource that defines a single purchasable item in the Shop.
## Create instances via: File > New Resource > ShopItem
## Then assign them to the ShopManager's item pool.
extends Resource
class_name ShopItem

# ─────────────────────────────────────────────
#  Identity
# ─────────────────────────────────────────────
@export var item_name: String = "Unnamed Item"
@export var description: String = ""
@export var icon: Texture2D = null
@export var cost: int = 50

# ─────────────────────────────────────────────
#  Stat Modifiers
#  Non-zero values are applied when the item is purchased.
# ─────────────────────────────────────────────
@export_group("Player Modifiers")
@export var move_speed_bonus:          float = 0.0
@export var max_health_bonus:          float = 0.0
@export var thaw_speed_multiplier:     float = 0.0   ## Additive bonus to multiplier (e.g. 0.25 = +25%)
@export var freeze_resistance:         float = 0.0   ## Reduces freeze_damage_per_second by this amount

@export_group("Flame Modifiers")
@export var light_radius_multiplier:   float = 0.0   ## Additive bonus (e.g. 0.2 = +20% radius)
@export var flame_decay_reduction:     float = 0.0   ## Reduces the flame's decay_rate by this amount
@export var fuel_on_purchase:          float = 0.0   ## Immediately feeds the flame by this scale amount

@export_group("Flags")
@export var is_unique: bool = false   ## If true, removed from pool after purchase
@export var is_passive: bool = true   ## Passive items apply on purchase; active items would need extra logic


# ─────────────────────────────────────────────
#  Apply
# ─────────────────────────────────────────────

## Apply this item's effects to the player and/or the eternal flame.
## Call from ShopManager after a successful purchase.
func apply(player: Node, flame: Node) -> void:
	# ── Player modifiers ──
	if player:
		if move_speed_bonus != 0.0:
			player.move_speed += move_speed_bonus

		if max_health_bonus != 0.0:
			player.max_health += max_health_bonus

		if thaw_speed_multiplier != 0.0:
			player.thaw_speed_multiplier += thaw_speed_multiplier

		if freeze_resistance != 0.0:
			player.freeze_damage_per_second = max(0.0,
				player.freeze_damage_per_second - freeze_resistance)

	# ── Flame modifiers ──
	if flame:
		if light_radius_multiplier != 0.0:
			flame.light_radius_multiplier += light_radius_multiplier

		if flame_decay_reduction != 0.0:
			flame.decay_rate = max(0.0, flame.decay_rate - flame_decay_reduction)

		if fuel_on_purchase != 0.0:
			flame.add_fuel(fuel_on_purchase)

	print("ShopItem: Applied '%s'." % item_name)
