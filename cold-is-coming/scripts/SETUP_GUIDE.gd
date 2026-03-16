# The Cold Is Coming — GDScript Base
# ═══════════════════════════════════════════════════════════════════════
# FILE INDEX
# ═══════════════════════════════════════════════════════════════════════
#
#   camera_controller.gd   →  Attach to Camera2D (child of Player)
#   player.gd              →  Attach to Player (CharacterBody2D)
#   eternal_flame.gd       →  Attach to EternalFlame (Node2D)
#   wave_manager.gd        →  Attach to WaveManager (Node, or Autoload)
#   shop_item.gd           →  Resource class — create .tres files from it
#   shop_manager.gd        →  Attach to ShopManager (Node in main scene)
#   frost_husk.gd          →  Attach to FrostHusk (CharacterBody2D)
#
# ═══════════════════════════════════════════════════════════════════════
# RECOMMENDED SCENE TREE
# ═══════════════════════════════════════════════════════════════════════
#
#   World (Node2D)
#   ├── CanvasModulate            ← Color: dark blue (#1a1a2e) for "the Cold"
#   ├── TileMap                   ← frozen ground
#   │
#   ├── EternalFlame (Node2D)     ← eternal_flame.gd | group: "eternal_flame"
#   │   ├── PointLight2D          ← name it "FlameLight"; warm orange texture
#   │   ├── Sprite2D              ← flame sprite / animated sprite
#   │   └── AnimationPlayer       ← optional flicker animation
#   │
#   ├── Player (CharacterBody2D)  ← player.gd | group: "player"
#   │   ├── Sprite2D
#   │   ├── CollisionShape2D
#   │   ├── HeadTarget (Marker2D) ← move to where the head is on the sprite
#   │   └── Camera2D              ← camera_controller.gd
#   │
#   ├── EnemySpawner (Node2D)     ← your custom spawner; listens to wave_started
#   │
#   ├── WaveManager (Node)        ← wave_manager.gd
#   ├── ShopManager (Node)        ← shop_manager.gd
#   │
#   └── HUD (CanvasLayer)
#       ├── HealthBar
#       ├── WarmthBar
#       └── WaveLabel
#
# ═══════════════════════════════════════════════════════════════════════
# INPUT MAP  (Project → Project Settings → Input Map)
# ═══════════════════════════════════════════════════════════════════════
#
#   toggle_focus_view   →  V key
#
# ═══════════════════════════════════════════════════════════════════════
# POINTLIGHT2D SETUP (EternalFlame > FlameLight)
# ═══════════════════════════════════════════════════════════════════════
#
#   Texture:        a soft radial gradient (white center → transparent edge)
#                   Godot built-in: res://addons/...  or import your own PNG
#   Color:          warm orange  #FF7A2F  or  #FFB347
#   Energy:         1.5
#   texture_scale:  4.0  (matches eternal_flame.gd's `initial_light_scale`)
#   Blend Mode:     Add
#   Shadow:         enabled for extra atmosphere
#
# ═══════════════════════════════════════════════════════════════════════
# CANVAS MODULATE TRICK
# ═══════════════════════════════════════════════════════════════════════
#
#   Set CanvasModulate color to a very dark blue, e.g. #18182A
#   This makes the entire world near-black.
#   The PointLight2D on the Eternal Flame then punches through the dark,
#   creating a dramatic "island of warmth" effect.
#   As the flame shrinks, the darkness literally closes in on the player.
#
# ═══════════════════════════════════════════════════════════════════════
# WAVE SCALING CHEAT SHEET
# ═══════════════════════════════════════════════════════════════════════
#
#   Stat = Base × 1.15^(Wave - 1)
#
#   Wave  HP      Speed   Damage
#   1     40.0    60.0    8.0
#   2     46.0    69.0    9.2
#   3     52.9    79.4    10.6
#   5     69.8   104.6    13.9
#   10   161.8   242.2    32.3
#
# ═══════════════════════════════════════════════════════════════════════
# SHOP ITEM CREATION (example .tres)
# ═══════════════════════════════════════════════════════════════════════
#
#   1. In the FileSystem panel, right-click → New Resource → ShopItem
#   2. Save as:  res://items/ember_shard.tres
#   3. In the Inspector, fill in:
#       item_name:               "Ember Shard"
#       description:             "A piece of the fallen sun. Feeds the Flame."
#       cost:                    40
#       fuel_on_purchase:        0.5     ← boosts the flame's scale
#       light_radius_multiplier: 0.15    ← +15% warm radius
#   4. Add ember_shard.tres to ShopManager.all_items array
#
# ═══════════════════════════════════════════════════════════════════════
# CONNECTING WAVE MANAGER → SPAWNER (example)
# ═══════════════════════════════════════════════════════════════════════
#
#   In your EnemySpawner script:
#
#     func _ready():
#         WaveManager.wave_started.connect(_on_wave_started)
#
#     func _on_wave_started(wave: int):
#         var stats = WaveManager.get_scaled_stats(wave)
#         for i in stats.enemy_count:
#             var husk = FROST_HUSK_SCENE.instantiate()
#             add_child(husk)
#             WaveManager.apply_stats_to_enemy(husk)
#             husk.global_position = _random_spawn_point()
#             husk.died.connect(_on_enemy_died)
#
#     func _on_enemy_died(enemy, currency):
#         ShopManager.add_currency(currency)
#         WaveManager.on_enemy_defeated()
