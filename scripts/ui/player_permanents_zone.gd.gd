#player_permanents_zone.gd
extends Control
class_name PlayerPermanentsZone

@export var spacing := 220
@export var move_speed := 0.15

var battlefield_stacks: Dictionary = {}


func arrange_cards():
	print("\n================ BATTLEFIELD ARRANGE START ================\n")

	var cards: Array = ZoneManager.get_battlefield_cards()

	print("[BATTLEFIELD] Card count:", cards.size())

	battlefield_stacks.clear()

	# ---------------------------------------------
	# BUILD STACKS (SOURCE OF TRUTH GROUPING)
	# ---------------------------------------------
	for card in cards:
		if not is_instance_valid(card):
			continue

		var id = card.data  # IMPORTANT: use CardData reference

		if not battlefield_stacks.has(id):
			battlefield_stacks[id] = []

		battlefield_stacks[id].append(card)


	if battlefield_stacks.is_empty():
		print("[BATTLEFIELD] EXIT: no stacks\n")
		return


	# ---------------------------------------------
	# LAYOUT STACKS (NOT INDIVIDUAL CARDS)
	# ---------------------------------------------
	var stack_count = battlefield_stacks.keys().size()
	var total_width = (stack_count - 1) * spacing
	var start_x = (size.x - total_width) * 0.5

	print("[BATTLEFIELD] Stack count:", stack_count)
	print("[BATTLEFIELD] Zone size:", size)
	print("[BATTLEFIELD] Start X:", start_x)


	var stack_index := 0

	for id in battlefield_stacks.keys():
		var stack: Array = battlefield_stacks[id]

		var base_x = start_x + (stack_index * spacing)
		stack_index += 1

		print("\n--- STACK:", id, "SIZE:", stack.size(), "---")

		for i in range(stack.size()):
			var card: CardInstance = stack[i]

			if not is_instance_valid(card):
				continue

			print("Card:", card.data.card_name, "Index in stack:", i)

			# Z-index: top card is highest
			card.z_index = i

			# Arena-style pile offset
			var offset_x = i * 10
			var offset_y = i * 10

			var target_pos = Vector2(
				base_x + offset_x,
				-300 + offset_y
			)

			print("Target:", target_pos)

			if card.is_dragging:
				continue

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
