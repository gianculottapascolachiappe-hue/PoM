extends Control
class_name CardInstance

signal request_hand_relayout
signal card_released(card: CardInstance, global_pos: Vector2)

@onready var visual: Control = $Visual
@onready var card_frame: TextureRect = $Visual/CardFrame
@onready var stats_label: Label = $Visual/StatsLabel

enum CardZone {
	HAND,
	BATTLEFIELD,
	GRAVEYARD
}

# =========================
# STATE
# =========================
var data: CardData
var card_owner: String

var zone: CardZone = CardZone.HAND
var is_dragging := false
var is_hovered := false

var hand_container: Control
var drag_offset := Vector2.ZERO

var hover_tween: Tween


# =========================
# READY
# =========================
func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


# =========================
# SETUP
# =========================
func setup(card_data: CardData, owner: String):
	data = card_data
	card_owner = owner

	if is_node_ready():
		_apply_setup()
	else:
		await ready
		_apply_setup()


func _apply_setup():
	if data == null:
		return

	update_visuals()


func update_visuals():
	if data == null:
		return

	if card_frame:
		card_frame.texture = data.card_texture

	stats_label.text = str(data.power) + "/" + str(data.toughness)


func _process(_delta):

	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset


func _gui_input(event):

	if not (event is InputEventMouseButton):
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return


	# =========================
	# START DRAG
	# =========================
	if event.pressed:

		# only allow drag from hand
		if zone != CardZone.HAND:
			return

		is_dragging = true
		is_hovered = false

		if hover_tween:
			hover_tween.kill()

		# store offset so card doesn't snap to mouse center
		drag_offset = get_global_mouse_position() - global_position

		# IMPORTANT: allow interaction while dragging (DO NOT block input)
		mouse_filter = Control.MOUSE_FILTER_PASS

		# mark for hand system
		set_meta("dragging_lock", true)

		# bring card visually above others
		z_index = 1000

		print("[CARD] DRAG START:", data.card_name)


	# =========================
	# DROP
	# =========================
	else:

		if not is_dragging:
			return

		is_dragging = false

		# restore normal interaction
		mouse_filter = Control.MOUSE_FILTER_STOP

		# release layout lock
		set_meta("dragging_lock", false)

		# reset z order
		z_index = 0

		print("[CARD] RELEASE:", data.card_name, "POS:", global_position)

		# send final drop info to game logic
		card_released.emit(self, global_position)

		# request hand re-layout
		request_hand_relayout.emit()

		print("[CARD] DRAG END:", data.card_name)


# =========================
# HOVER
# =========================
func _on_mouse_entered():
	if is_dragging:
		return

	is_hovered = true

	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()

	hover_tween.tween_property(visual, "position:y", -100, 0.12)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_mouse_exited():
	if is_dragging:
		return

	is_hovered = false

	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()

	hover_tween.tween_property(visual, "position:y", 0, 0.10)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
