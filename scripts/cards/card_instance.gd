# card_instance.gd
extends Control
class_name CardInstance


# ====================================================================
# CARD INSTANCE
# ====================================================================
# Runtime card object responsible for:
#
# - Dragging
# - Hover visuals
# - Mouse interaction
# - Visual updates
# - Emitting release signals
#
# This is the INTERACTIVE card node used during gameplay.
# ====================================================================



# ====================================================================
# ZONE STATE
# ====================================================================
# Tracks where the card currently exists.
#
# Examples:
# - HAND
# - BATTLEFIELD
# - GRAVEYARD
# ====================================================================

var zone: ZoneManager.Zone = ZoneManager.Zone.HAND



# ====================================================================
# NODE REFERENCES
# ====================================================================

@onready var visual: Control = $Visual
@onready var card_frame: TextureRect = $Visual/CardFrame
@onready var stats_label: Label = $Visual/StatsLabel



# ====================================================================
# SIGNALS
# ====================================================================
# Fired when player releases dragged card.
# Used by Battlefield / DropZone logic.
# ====================================================================

signal card_released(card: CardInstance, global_pos: Vector2)



# ====================================================================
# CARD DATA
# ====================================================================

var data: CardData
var card_owner: String



# ====================================================================
# INTERACTION STATE
# ====================================================================

var is_dragging := false
var is_hovered := false

var drag_offset := Vector2.ZERO
var hover_tween: Tween

var hover_delay_timer: SceneTreeTimer


# ====================================================================
# HOVER VISUAL SETTINGS
# ====================================================================
# Change these values to tweak hover feel.
# ====================================================================

@export var hover_lift_height := -360
# ↑ Higher negative value = card lifts higher on hover

@export var hover_scale := Vector2(2, 2)
# ↑ Increase for bigger hover zoom effect

@export var hover_speed := 0.12
# ↑ Hover animation speed

@export var unhover_speed := 0.10
# ↑ Return animation speed



# ====================================================================
# DRAG VISUAL SETTINGS
# ====================================================================

@export var drag_z_index := 1000
# ↑ Card render priority while dragging

@export var hover_z_index := 500
# ↑ Card render priority while hovered



# ====================================================================
# READY
# ====================================================================

func _ready():

	# Mouse hover signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	print("[CARD READY] ", name)



# ====================================================================
# SETUP
# ====================================================================
# Initializes runtime card data.
# ====================================================================

func setup(card_data: CardData, owner: String):

	data = card_data
	card_owner = owner

	print("[CARD SETUP] ", data.card_name)

	await ready
	update_visuals()



# ====================================================================
# UPDATE VISUALS
# ====================================================================
# Applies CardData visuals to runtime card.
# ====================================================================

func update_visuals():

	if data == null:
		return

	# ------------------------------------------------
	# Card artwork
	# ------------------------------------------------
	if card_frame and data.card_texture:
		card_frame.texture = data.card_texture

	# ------------------------------------------------
	# Power / Toughness
	# ------------------------------------------------
	if stats_label:
		stats_label.text = str(data.power) + "/" + str(data.toughness)



# ====================================================================
# RESET VISUAL STATE
# ====================================================================
# IMPORTANT:
# Used when card changes zones or interaction ends.
#
# Resets:
# - Hover
# - Scale
# - Dragging
# - Z-index
# ====================================================================

func reset_visual_state():

	is_dragging = false
	is_hovered = false

	if hover_tween:
		hover_tween.kill()

	# ------------------------------------------------
	# Reset hover visuals
	# ------------------------------------------------
	visual.position.y = 0
	visual.scale = Vector2.ONE

	# ------------------------------------------------
	# Reset mouse behavior
	# ------------------------------------------------
	mouse_filter = Control.MOUSE_FILTER_STOP

	# ------------------------------------------------
	# Reset render priority
	# ------------------------------------------------
	z_index = 0



# ====================================================================
# INPUT
# ====================================================================
# Handles drag start / drag release.
# ====================================================================

func _gui_input(event):

	if not (event is InputEventMouseButton):
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return


	# ================================================================
	# DRAG START
	# ================================================================
	if event.pressed:

		is_dragging = true

		# Offset prevents snapping to cursor center
		drag_offset = get_global_mouse_position() - global_position

		# Allows drop zones beneath card to receive mouse
		mouse_filter = Control.MOUSE_FILTER_PASS

		# Render above everything
		z_index = drag_z_index

		print("[DRAG START] ", data.card_name if data else "NULL")


	# ================================================================
	# DRAG END
	# ================================================================
	else:

		if not is_dragging:
			return

		is_dragging = false

		card_released.emit(self, global_position)

		print("[DRAG END] ", data.card_name if data else "NULL")



# ====================================================================
# DRAG FOLLOW
# ====================================================================
# Moves card with cursor while dragging.
# ====================================================================

func _process(_delta):

	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset



# ====================================================================
# HOVER ENTER
# ====================================================================
# Hover only works while card is in HAND.
# ====================================================================

func _on_mouse_entered():

	if is_dragging:
		return

	if zone != ZoneManager.Zone.HAND:
		return


	if hover_tween:
		hover_tween.kill()

	# ------------------------------------------------
	# Bring hovered card above neighbors
	# ------------------------------------------------
	z_index = hover_z_index

	hover_tween = create_tween()


	# ------------------------------------------------
	# Lift card upward
	# ------------------------------------------------
	hover_tween.parallel().tween_property(
		visual,
		"position:y",
		hover_lift_height,
		hover_speed
	)


	# ------------------------------------------------
	# Scale card larger
	# ------------------------------------------------
	hover_tween.parallel().tween_property(
		visual,
		"scale",
		hover_scale,
		hover_speed
	)

	print("[HOVER] ", data.card_name)



# ====================================================================
# HOVER EXIT
# ====================================================================

func _on_mouse_exited():

	if is_dragging:
		return

	if zone != ZoneManager.Zone.HAND:
		return

	is_hovered = false

	if hover_tween:
		hover_tween.kill()

	# Reset render priority
	z_index = 0

	hover_tween = create_tween()


	# ------------------------------------------------
	# Return card to normal position
	# ------------------------------------------------
	hover_tween.parallel().tween_property(
		visual,
		"position:y",
		0,
		unhover_speed
	)


	# ------------------------------------------------
	# Return card to normal size
	# ------------------------------------------------
	hover_tween.parallel().tween_property(
		visual,
		"scale",
		Vector2.ONE,
		unhover_speed
	)

	print("[UNHOVER] ", data.card_name)
