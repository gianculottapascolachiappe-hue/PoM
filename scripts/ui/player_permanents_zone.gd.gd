#player_permanents_zone.gd
extends Control
class_name PlayerPermanentsZone

@export var spacing := 220
@export var move_speed := 0.15



func arrange_cards():
	print("\n================ BATTLEFIELD ARRANGE START ================\n")

	# -------------------------------------------------
	# SOURCE OF TRUTH = ZoneManager
	# -------------------------------------------------
	var cards: Array = ZoneManager.get_battlefield_cards()

	print("[BATTLEFIELD] Card count:", cards.size())

	var count = cards.size()

	if count == 0:
		print("[BATTLEFIELD] EXIT: no cards\n")
		return


	# -------------------------------------------------
	# CENTERING CALCULATION
	# -------------------------------------------------
	var total_width = (count - 1) * spacing
	var start_x = (size.x - total_width) * 0.5

	print("[BATTLEFIELD] Zone size:", size)
	print("[BATTLEFIELD] Total width:", total_width)
	print("[BATTLEFIELD] Start X:", start_x)


	# -------------------------------------------------
	# POSITION CARDS
	# -------------------------------------------------
	for i in range(count):

		var card: CardInstance = cards[i]

		if not is_instance_valid(card):
			continue

		print("\n--- CARD DEBUG ---")
		print("Name:", card.data.card_name if card.data else "NULL")
		print("Index:", i)
		print("Before position:", card.position)

		# Z-index rule
		if card.is_dragging:
			card.z_index = 1000
		else:
			card.z_index = i

		# target position
		var target_pos = Vector2(
			start_x + (i * spacing),
			-300
		)

		print("Target position:", target_pos)

		# never fight drag
		if card.is_dragging:
			print("SKIP (dragging)")
			continue

		# kill old tween
		if card.has_meta("battlefield_tween"):
			var old_tween = card.get_meta("battlefield_tween")
			if old_tween:
				old_tween.kill()

		var tween = create_tween()
		card.set_meta("battlefield_tween", tween)

		print("Creating tween...")

		tween.tween_property(
			card,
			"position",
			target_pos,
			move_speed
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		print("Tween applied")

	print("\n================ BATTLEFIELD ARRANGE END ================\n")
