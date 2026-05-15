# hand_zone.gd
extends Control
class_name HandZone



# ====================================================================
# HAND LAYOUT SETTINGS
# ====================================================================
# These directly affect card spacing & positioning
# ====================================================================

@export var overlap := 80.0
# ↑ Distance between cards (lower = tighter hand, higher = more spread)

@export var rearrange_speed := 0.15
# ↑ Animation speed for card repositioning



# ====================================================================
# INTERNAL STATE
# ====================================================================
# Prevents overlapping layout recalculations
# ====================================================================

var _is_arranging := false



# ====================================================================
# ARRANGE HAND
# ====================================================================
# Repositions all cards in the player's hand
# ====================================================================

func arrange_hand():

	if _is_arranging:
		return

	_is_arranging = true

	print("\n================ HAND ARRANGE START ================\n")


	# ------------------------------------------------
	# SOURCE OF TRUTH
	# ------------------------------------------------
	var cards: Array = ZoneManager.get_hand_cards()

	print("[HAND] Card count:", cards.size())

	var count := cards.size()

	if count == 0:
		print("[HAND] EXIT: no cards\n")
		_is_arranging = false
		return


	# ------------------------------------------------
	# CARD SIZE REFERENCE
	# ------------------------------------------------
	var card_width := 180.0
	# ↑ Fallback card width if dynamic size fails

	if cards[0].size.x > 0:
		card_width = cards[0].size.x

	print("[HAND] Card width:", card_width)


	# ------------------------------------------------
	# LAYOUT CALCULATION
	# ------------------------------------------------
	var total_width := (count - 1) * overlap

	var start_x := (size.x - total_width) * 0.5 - (card_width * 0.5)
	# ↑ Adjust this if hand alignment feels off-center


	print("[HAND] Zone size:", size)
	print("[HAND] Total width:", total_width)
	print("[HAND] Start X:", start_x)


	# ------------------------------------------------
	# POSITION CARDS
	# ------------------------------------------------
	for i in range(count):

		var card: CardInstance = cards[i]

		# Skip dragging cards (they control their own position)
		if card.is_dragging:
			print("SKIP (dragging)")
			continue


		var target := Vector2(
			start_x + i * overlap,
			0
		)

		print("Target:", target)


		# ------------------------------------------------
		# CANCEL OLD TWEEN
		# ------------------------------------------------
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



# ====================================================================
# EXTERNAL HOOK
# ====================================================================
# Called when something requests a hand refresh
# ====================================================================

func _on_card_relayout_requested():
	arrange_hand()
