extends Control
class_name CardInstance

@onready var visual: Control = $Visual
@onready var card_frame: TextureRect = $Visual/CardFrame
@onready var stats_label: Label = $Visual/StatsLabel

signal request_hand_relayout


# =========================
# CARD DATA
# =========================
var data: CardData
var card_owner: String

# delayed setup safety
var pending_setup := false


# =========================
# SIZE SYSTEM
# =========================
var current_size: Vector2


# =========================
# STATE
# =========================
var is_hovered := false
var is_dragging := false


# =========================
# DRAG SYSTEM
# =========================
var drag_offset := Vector2.ZERO


# =========================
# ANIMATION
# =========================
var hover_tween: Tween


# =========================
# GODOT LIFECYCLE
# =========================
func _ready():

	print("========== CARD READY ==========")

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# delayed setup support
	if pending_setup:
		pending_setup = false
		update_visuals()


func _process(delta):

	# follow mouse while dragging
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset


# =========================
# INITIAL SETUP
# =========================
func setup(card_data: CardData, owner: String):

	data = card_data
	card_owner = owner

	print("[CardInstance] Setup:", data.card_name)

	set_zone("hand")

	# node not fully ready yet
	if not is_node_ready():
		pending_setup = true
		return

	update_visuals()


# =========================
# ZONE SYSTEM
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
# INPUT
# =========================
func _gui_input(event):

	if event is InputEventMouseButton:

		# =========================
		# START DRAG
		# =========================
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			is_dragging = true

			drag_offset = get_global_mouse_position() - global_position

			request_hand_relayout.emit()

			print("[Card] Drag Start:", data.card_name)

		# =========================
		# END DRAG
		# =========================
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:

			is_dragging = false

			request_hand_relayout.emit()

			print("[Card] Drag End:", data.card_name)


# =========================
# HOVER SYSTEM
# =========================
func _on_mouse_entered():

	if is_dragging:
		return

	is_hovered = true

	request_hand_relayout.emit()

	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()

	hover_tween.tween_property(
		visual,
		"position:y",
		-100,
		0.12
	).set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_OUT)

	print("[Card] Hover:", data.card_name)


func _on_mouse_exited():

	if is_dragging:
		return

	is_hovered = false

	request_hand_relayout.emit()

	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()

	hover_tween.tween_property(
		visual,
		"position:y",
		0,
		0.10
	).set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_OUT)

	print("[Card] Unhover:", data.card_name)
