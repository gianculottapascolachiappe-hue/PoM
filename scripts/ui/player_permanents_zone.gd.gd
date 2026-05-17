# player_permanents_zone.gd
extends Control
class_name PlayerPermanentsZone



# ====================================================================
# BATTLEFIELD LAYOUT SETTINGS
# ====================================================================
# Controls spacing + animation feel for battlefield stacks
# ====================================================================

@export var spacing := 220
# ↑ Distance between each stack (horizontal spread)

@export var move_speed := 0.15
# ↑ Animation speed for repositioning cards



# ====================================================================
# STACK STATE
# ====================================================================
# Groups cards by identity (CardData reference)
# ====================================================================

var battlefield_stacks: Dictionary = {}



# ====================================================================
# ARRANGE BATTLEFIELD
# ====================================================================
# Core layout function:
# - Groups identical cards into stacks
# - Positions stacks across battlefield
# - Offsets cards inside stacks (pile effect)
# ====================================================================

func arrange_cards():

	print("\n================ BATTLEFIELD ARRANGE START ================\n")

	var cards: Array = ZoneManager.get_battlefield_cards()

	print("[BATTLEFIELD] Card count:", cards.size())

	battlefield_stacks.clear()



	# =================================================================
	# BUILD STACKS (GROUPING PHASE)
	# =================================================================
	for card in cards:

		if not is_instance_valid(card):
			continue

		var id = card.data
		# ↑ STACK KEY (CardData reference)
		# Change this ONLY if you want different grouping behavior

		if not battlefield_stacks.has(id):
			battlefield_stacks[id] = []

		battlefield_stacks[id].append(card)



	# No cards check
	if battlefield_stacks.is_empty():
		print("[BATTLEFIELD] EXIT: no stacks\n")
		return



	# =================================================================
	# STACK LAYOUT CALCULATION
	# =================================================================

	var stack_count = battlefield_stacks.keys().size()

	var total_width = (stack_count - 1) * spacing
	
	var start_x = (size.x - total_width) * 0.5 
	# ↑ Adjust if battlefield feels too left/right shifted


	print("[BATTLEFIELD] Stack count:", stack_count)
	print("[BATTLEFIELD] Zone size:", size)
	print("[BATTLEFIELD] Start X:", start_x)



	# =================================================================
	# POSITION STACKS
	# =================================================================

	var stack_index := 0

	for id in battlefield_stacks.keys():

		var stack: Array = battlefield_stacks[id]

		var base_x = start_x + (stack_index * spacing)
		stack_index += 1

		print("\n--- STACK:", id, "SIZE:", stack.size(), "---")



		# =============================================================
		# POSITION CARDS INSIDE STACK
		# =============================================================

		for i in range(stack.size()):

			var card: CardInstance = stack[i]

			if not is_instance_valid(card):
				continue

			print("Card:", card.data.card_name, "Stack Index:", i)


			# ---------------------------------------------
			# Z-INDEX (PILE ORDER)
			# ---------------------------------------------
			card.z_index = i
			# ↑ Higher index = visually on top



			# ---------------------------------------------
			# STACK OFFSET (PILE EFFECT)
			# ---------------------------------------------
			var offset_x = i * 10
			var offset_y = i * 10
			# ↑ Increase for more "spread out" stack look


			var target_pos = Vector2(
				base_x + offset_x,
				offset_y
			)


			print("Target:", target_pos)


			# Skip dragging cards
			if card.is_dragging:
				continue


			# ---------------------------------------------
			# CANCEL OLD TWEEN
			# ---------------------------------------------
			if card.has_meta("battlefield_tween"):
				var old_tween = card.get_meta("battlefield_tween")
				if old_tween:
					old_tween.kill()


			var tween = create_tween()
			card.set_meta("battlefield_tween", tween)


			tween.tween_property(
				card,
				"position",
				target_pos,
				move_speed
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


	print("\n================ BATTLEFIELD ARRANGE END ================\n")
