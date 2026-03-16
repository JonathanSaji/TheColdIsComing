## shop_manager.gd
## Manages the between-wave shop: currency, item pool, and purchase logic.
## Attach to a Node that persists across waves (e.g., GameManager or a CanvasLayer).
extends Node

# ─────────────────────────────────────────────
#  Signals
# ─────────────────────────────────────────────
signal currency_changed(new_amount: int)
signal item_purchased(item: ShopItem)
signal shop_closed()

# ─────────────────────────────────────────────
#  Inspector Exports
# ─────────────────────────────────────────────
@export var all_items: Array[ShopItem] = []   ## Populate in the Inspector with your .tres files
@export var items_per_offer: int = 3          ## How many items shown each wave

@export_group("References")
@export var player_path: NodePath = NodePath()
@export var flame_path:  NodePath = NodePath()

# ─────────────────────────────────────────────
#  State
# ─────────────────────────────────────────────
var currency: int = 0
var _current_offer: Array[ShopItem] = []
var _purchased_unique: Array[String] = []

@onready var _player: Node = get_node_or_null(player_path)
@onready var _flame:  Node = get_node_or_null(flame_path)

# ─────────────────────────────────────────────
#  Public API
# ─────────────────────────────────────────────

func add_currency(amount: int) -> void:
	currency += amount
	emit_signal("currency_changed", currency)


## Generate a fresh offer. Call at the start of each shop phase.
func generate_offer() -> Array[ShopItem]:
	var pool: Array[ShopItem] = []
	for item in all_items:
		if item.is_unique and item.item_name in _purchased_unique:
			continue
		pool.append(item)

	pool.shuffle()
	_current_offer = pool.slice(0, min(items_per_offer, pool.size()))
	return _current_offer


## Attempt to purchase an item. Returns true if successful.
func try_purchase(item: ShopItem) -> bool:
	if item not in _current_offer:
		push_warning("ShopManager: Item '%s' is not in the current offer." % item.item_name)
		return false

	if currency < item.cost:
		print("ShopManager: Cannot afford '%s' (cost %d, have %d)." % [item.item_name, item.cost, currency])
		return false

	currency -= item.cost
	emit_signal("currency_changed", currency)

	item.apply(_player, _flame)

	if item.is_unique:
		_purchased_unique.append(item.item_name)

	_current_offer.erase(item)
	emit_signal("item_purchased", item)
	return true


func close_shop() -> void:
	_current_offer.clear()
	emit_signal("shop_closed")
