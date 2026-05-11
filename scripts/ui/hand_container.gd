extends Control

@export var overlap := 80
@export var rearrange_speed := 0.15


func arrange_hand():

	var cards = get_children()
	var count = cards.size()

	if count == 0:
		return

	# dynamic card size
	var card_width = cards[0].current_size.x

	# overlap layout width
	var total_width = (count - 1) * overlap

	# centered hand
	var start_x = (size.x - total_width) * 0.5 - (card_width * 0.5)

	for i in range(count):

		var card = cards[i]

		if not card is Control:
			continue

		# =========================
		# LAYERING
		# =========================
		if card.is_dragging:
			card.z_index = 1000

		elif card.is_hovered:
			card.z_index = 100 + i

		else:
			card.z_index = i

		# =========================
		# DON'T MOVE DRAGGED CARD
		# =========================
		if card.is_dragging:
			continue

		var target_position = Vector2(
			start_x + i * overlap,
			0
		)

		# =========================
		# SMOOTH MOVEMENT
		# =========================
		var tween = create_tween()

		tween.tween_property(
			card,
			"position",
			target_position,
			rearrange_speed
		).set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)


func _on_card_relayout_requested():
	arrange_hand()
