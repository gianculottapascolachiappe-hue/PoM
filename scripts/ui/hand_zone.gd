extends Control
class_name HandZone

@export var overlap := 80.0
@export var rearrange_speed := 0.15

var _is_arranging := false


func arrange_hand():

	if _is_arranging:
		return

	_is_arranging = true

	print("\n================ HAND ARRANGE START ================\n")

	var cards: Array[CardInstance] = []

	# ---------------------------------------------
	# SOURCE OF TRUTH (TEMP: scene children only)
	# ---------------------------------------------
	for c in get_children():
		if c is CardInstance:
			cards.append(c)

	print("[HAND] Card count:", cards.size())

	var count := cards.size()

	if count == 0:
		print("[HAND] EXIT: no cards\n")
		_is_arranging = false
		return


	# ---------------------------------------------
	# CARD WIDTH SAFETY
	# ---------------------------------------------
	var card_width := 180.0
	if cards[0].size.x > 0:
		card_width = cards[0].size.x

	print("[HAND] Card width:", card_width)


	# ---------------------------------------------
	# LAYOUT CALC
	# ---------------------------------------------
	var total_width := (count - 1) * overlap
	var start_x := (size.x - total_width) * 0.5 - (card_width * 0.5)

	print("[HAND] Zone size:", size)
	print("[HAND] Total width:", total_width)
	print("[HAND] Start X:", start_x)


	# ---------------------------------------------
	# POSITION CARDS
	# ---------------------------------------------
	for i in range(count):

		var card := cards[i]

		print("\n--- CARD DEBUG ---")
		print("Name:", card.data.card_name if card.data else "NULL")
		print("Index:", i)
		print("Before position:", card.position)

		# Z INDEX
		if card.is_dragging:
			card.z_index = 1000
		elif card.is_hovered:
			card.z_index = 100 + i
		else:
			card.z_index = i


		# SKIP DRAGGING
		if card.is_dragging:
			print("SKIP (dragging)")
			continue


		var target := Vector2(
			start_x + i * overlap,
			0
		)

		print("Target:", target)

		# ---------------------------------------------
		# CANCEL OLD TWEEN SAFELY
		# ---------------------------------------------
		if card.has_meta("hand_tween"):
			var old_tween = card.get_meta("hand_tween")
			if old_tween:
				old_tween.kill()

		card.position.y = 0

		var tween := create_tween()
		card.set_meta("hand_tween", tween)

		tween.tween_property(card, "position", target, rearrange_speed)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)


	print("\n================ HAND ARRANGE END ================\n")

	_is_arranging = false


func _on_card_relayout_requested():
	arrange_hand()
