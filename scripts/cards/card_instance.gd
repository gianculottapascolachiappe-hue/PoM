extends Control
class_name CardInstance

@onready var card_frame: TextureRect = $CardFrame
@onready var stats_label: Label = $StatsLabel

var data: CardData
var card_owner: String

var current_size: Vector2
var is_ready := false

var is_hovered := false



# =========================
# GODOT LIFECYCLE
# =========================
func _ready():
	print("========== CARD READY ==========")

	is_ready = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


	if data != null:
		update_visuals()


# =========================
# INITIAL SETUP
# =========================
func setup(card_data: CardData, owner: String):
	data = card_data
	card_owner = owner

	print("[CardInstance] Setup:", data.card_name)

	# initialize size immediately (important for layout stability)
	set_zone("hand")

	if is_ready:
		update_visuals()


# =========================
# ZONE SYSTEM (LAYOUT ONLY)
# =========================
func set_zone(zone: String):

	if data == null:
		return

	match zone:
		"hand":
			current_size = data.base_size

		"battlefield":
			current_size = data.base_size * 0.8

		"graveyard":
			current_size = data.base_size * 0.7

		_:
			current_size = data.base_size

	custom_minimum_size = current_size


# =========================
# VISUAL UPDATE
# =========================
func update_visuals():

	if data == null:
		return

	if data.card_texture:
		card_frame.texture = data.card_texture

	stats_label.text = str(data.power) + "/" + str(data.toughness)

	print("[CardInstance] Visuals updated")


# =========================
# HOVER SYSTEM (VISUAL ONLY)
# =========================
func _on_mouse_entered():
	is_hovered = true

	z_index = 10
	position.y -= 100

	print("[Card] Hover:", data.card_name)


func _on_mouse_exited():
	is_hovered = false

	z_index = 0
	position.y += 100

	print("[Card] Unhover:", data.card_name)
