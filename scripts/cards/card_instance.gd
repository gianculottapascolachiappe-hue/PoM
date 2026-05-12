extends Control
class_name CardInstance

# =========================
# NODES
# =========================
@onready var visual: Control = $Visual
@onready var card_frame: TextureRect = $Visual/CardFrame
@onready var stats_label: Label = $Visual/StatsLabel

# =========================
# SIGNALS
# =========================
signal request_hand_relayout
signal card_released(card: CardInstance, global_pos: Vector2)

# =========================
# ENUM ZONES
# =========================
enum CardZone {
	HAND,
	BATTLEFIELD,
	GRAVEYARD
}

# =========================
# DATA
# =========================
var data: CardData
var card_owner: String

# =========================
# STATE
# =========================
var zone: CardZone = CardZone.HAND
var is_dragging := false
var is_hovered := false
var is_in_hand := true

# =========================
# DRAG
# =========================
var drag_offset := Vector2.ZERO

# =========================
# VISUAL
# =========================
var hover_tween: Tween


# =========================
# READY
# =========================
func _ready():

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	print("[CARD] READY:", name)


# =========================
# SETUP
# =========================
func setup(card_data: CardData, owner: String):

	data = card_data
	card_owner = owner

	print("[CARD] SETUP:", data.card_name)

	await ready
	_apply_setup()


func _apply_setup():

	if data == null:
		return

	zone = CardZone.HAND
	is_in_hand = true

	update_visuals()

	print("[CARD] APPLIED:", data.card_name)


func update_visuals():

	if data == null:
		return

	if card_frame and data.card_texture:
		card_frame.texture = data.card_texture

	if stats_label:
		stats_label.text = str(data.power) + "/" + str(data.toughness)


# =========================
# ZONE SYSTEM
# =========================
func set_zone(new_zone: CardZone):

	zone = new_zone

	match zone:

		CardZone.HAND:
			is_in_hand = true

		CardZone.BATTLEFIELD:
			is_in_hand = false

		CardZone.GRAVEYARD:
			is_in_hand = false

	request_hand_relayout.emit()


# =========================
# INPUT
# =========================
func _gui_input(event):

	if not (event is InputEventMouseButton):
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return


	# =========================
	# DRAG START
	# =========================
	if event.pressed:

		if zone != CardZone.HAND:
			return

		is_dragging = true
		is_hovered = false

		if hover_tween:
			hover_tween.kill()

		drag_offset = get_global_mouse_position() - global_position

		mouse_filter = Control.MOUSE_FILTER_PASS

		z_index = 1000

		print("[CARD] DRAG START:", data.card_name)


	# =========================
	# DROP
	# =========================
	else:

		if not is_dragging:
			return

		is_dragging = false

		mouse_filter = Control.MOUSE_FILTER_STOP
		z_index = 0

		print("[CARD] RELEASE:", data.card_name, "POS:", global_position)

		card_released.emit(self, global_position)
		request_hand_relayout.emit()

		print("[CARD] DRAG END:", data.card_name)


# =========================
# DRAG MOVEMENT
# =========================
func _process(_delta):

	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset


# =========================
# HOVER
# =========================
func _on_mouse_entered():

	if is_dragging:
		return

	if zone != CardZone.HAND:
		return

	is_hovered = true

	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()

	hover_tween.tween_property(
		visual,
		"position:y",
		-100,
		0.12
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)	


func _on_mouse_exited():

	if is_dragging:
		return

	if zone != CardZone.HAND:
		return

	is_hovered = false

	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()

	hover_tween.tween_property(
		visual,
		"position:y",
		0,
		0.10
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
