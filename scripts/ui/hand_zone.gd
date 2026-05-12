extends Control
class_name HandZone

@export var overlap := 80
@export var rearrange_speed := 0.15


func arrange_hand():

	var valid_cards: Array = []

	# =========================
	# COLLECT ONLY HAND CARDS
	# =========================
	for c in get_children():

		if not (c is Control):
			continue

		# safety check (cards not fully initialized yet)
		if not "zone" in c:
			continue

		if c.zone != CardInstance.CardZone.HAND:
			continue

		valid_cards.append(c)


	var count = valid_cards.size()

	if count == 0:
		return


	# =========================
	# STOP IF ANY CARD IS DRAGGING
	# =========================
	for c in valid_cards:
		if c.is_dragging:
			return


	# =========================
	# CARD SIZE (SAFE)
	# =========================
	var card_width := 180.0
	if valid_cards.size() > 0:
		card_width = valid_cards[0].size.x


	# =========================
	# LAYOUT CALC
	# =========================
	var total_width = (count - 1) * overlap
	var start_x = (size.x - total_width) * 0.5 - (card_width * 0.5)


	# =========================
	# POSITION CARDS
	# =========================
	for i in range(count):

		var card = valid_cards[i]

		# =========================
		# Z-INDEX RULES
		# =========================
		if card.is_dragging:
			card.z_index = 1000
		elif card.is_hovered:
			card.z_index = 100 + i
		else:
			card.z_index = i


		# =========================
		# DO NOT MOVE DRAGGED CARD
		# =========================
		if card.is_dragging:
			continue


		var target_position = Vector2(
			start_x + i * overlap,
			0
		)


		# =========================
		# SMOOTH TWEEN (CLEAN)
		# =========================
		if card.has_meta("hand_tween"):
			var old_tween = card.get_meta("hand_tween")
			if old_tween:
				old_tween.kill()

		var tween = create_tween()
		card.set_meta("hand_tween", tween)

		tween.tween_property(
			card,
			"position",
			target_position,
			rearrange_speed
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_card_relayout_requested():
	arrange_hand()
