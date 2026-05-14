#card_instance.gd
extends Control
class_name CardInstance

# ------------------------
# ZONE REFERENCE (IMPORTANT)
# ------------------------
var zone: ZoneManager.Zone = ZoneManager.Zone.HAND

# ------------------------
# NODES
# ------------------------
@onready var visual: Control = $Visual
@onready var card_frame: TextureRect = $Visual/CardFrame
@onready var stats_label: Label = $Visual/StatsLabel

# ------------------------
# SIGNALS
# ------------------------
signal card_released(card: CardInstance, global_pos: Vector2)

# ------------------------
# DATA
# ------------------------
var data: CardData
var card_owner: String

# ------------------------
# STATE
# ------------------------
var is_dragging := false
var is_hovered := false
var drag_offset := Vector2.ZERO
var hover_tween: Tween


# ------------------------
# READY
# ------------------------
func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	print("[CARD] READY:", name)


# ------------------------
# SETUP
# ------------------------
func setup(card_data: CardData, owner: String):
	data = card_data
	card_owner = owner

	print("[CARD] SETUP:", data.card_name)

	await ready
	update_visuals()


# ------------------------
# VISUALS
# ------------------------
func update_visuals():
	if data == null:
		return

	if card_frame and data.card_texture:
		card_frame.texture = data.card_texture

	if stats_label:
		stats_label.text = str(data.power) + "/" + str(data.toughness)


# ------------------------
# RESET VISUAL STATE (IMPORTANT)
# ------------------------
func reset_visual_state():
	is_dragging = false
	is_hovered = false

	if hover_tween:
		hover_tween.kill()

	visual.position.y = 0
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 0


# ------------------------
# INPUT
# ------------------------
func _gui_input(event):
	if not (event is InputEventMouseButton):
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.pressed:
		is_dragging = true
		drag_offset = get_global_mouse_position() - global_position

		mouse_filter = Control.MOUSE_FILTER_PASS
		z_index = 1000

		print("[CARD] DRAG START:", data.card_name if data else "NULL")

	else:
		if not is_dragging:
			return

		is_dragging = false

		card_released.emit(self, global_position)

		print("[CARD] DRAG END:", data.card_name if data else "NULL")


# ------------------------
# DRAG
# ------------------------
func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset


# ------------------------
# HOVER (FIXED)
# ------------------------
func _on_mouse_entered():
	if is_dragging:
		return

	if zone != ZoneManager.Zone.HAND:
		return

	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.tween_property(visual, "position:y", -100, 0.12)


func _on_mouse_exited():
	if is_dragging:
		return

	if zone != ZoneManager.Zone.HAND:
		return

	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.tween_property(visual, "position:y", 0, 0.10)
