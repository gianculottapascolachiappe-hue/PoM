# card_play_manager.gd
extends Node

# --------------------------------------------------
# CARD PLAY VALIDATION SYSTEM
# --------------------------------------------------
# PURPOSE:
# Central authority for:
# - checking if cards can be played
# - spending mana
# - future gameplay rules
#
# IMPORTANT:
# This script should become the ONLY place
# that decides if a card play is legal.
# --------------------------------------------------


# --------------------------------------------------
# DEBUG
# --------------------------------------------------
var DEBUG := true


# --------------------------------------------------
# READY
# --------------------------------------------------
func _ready():
	print("[CardPlayManager] READY")


# --------------------------------------------------
# PARSE MANA COST
# --------------------------------------------------
# Converts:
# "2W" -> { generic = 2, white = 1 }
# "WW" -> { generic = 0, white = 2 }
# "3RW" -> { generic = 3, red = 1, white = 1 }
# --------------------------------------------------
func parse_mana_cost(cost: String) -> Dictionary:

	cost = cost.to_upper()

	var result := {
		"generic": 0,
		"white": 0,
		"red": 0,
		"blue": 0,
		"green": 0,
		"black": 0
	}

	print("\n========== MANA PARSE START ==========")
	print("[MANA PARSE] Raw Cost:", cost)

	for symbol in cost:

		print("[MANA PARSE] Reading:", symbol)

		match symbol:

			"W":
				result.white += 1
				print("[MANA PARSE] +1 WHITE")

			"R":
				result.red += 1
				print("[MANA PARSE] +1 RED")

			"U":
				result.blue += 1
				print("[MANA PARSE] +1 BLUE")

			"G":
				result.green += 1
				print("[MANA PARSE] +1 GREEN")

			"B":
				result.black += 1
				print("[MANA PARSE] +1 BLACK")

			_:
				if symbol.is_valid_int():
					result.generic += int(symbol)
					print("[MANA PARSE] +", symbol, " GENERIC")

	print("[MANA PARSE] RESULT:", result)
	print("========== MANA PARSE END ==========\n")

	return result


# --------------------------------------------------
# VALIDATE CARD PLAY
# --------------------------------------------------
func can_play(card: CardInstance) -> bool:

	if DEBUG:
		print("\n========== PLAY VALIDATION START ==========")

	# -----------------------------------------
	# NULL SAFETY
	# -----------------------------------------
	if card == null:
		print("[PLAY CHECK] FAILED: card is null")
		return false

	if card.data == null:
		print("[PLAY CHECK] FAILED: card data missing")
		return false

	print("[PLAY CHECK] Card:", card.data.card_name)

	# -----------------------------------------
	# MUST BE IN HAND
	# -----------------------------------------
	if card.zone != ZoneManager.Zone.HAND:
		print("[PLAY CHECK] FAILED: card not in hand")
		return false

	print("[PLAY CHECK] Zone OK")

	# -----------------------------------------
	# PRIORITY CHECK
	# -----------------------------------------
	if not PriorityManager.can_act(card.card_owner):
		print("[PLAY CHECK] FAILED: no priority")
		return false

	print("[PLAY CHECK] Priority OK")

	# -----------------------------------------
	# TEMP MANA CHECK
	# -----------------------------------------
	var mana_cost = parse_mana_cost(card.data.mana_cost)

	print("[PLAY CHECK] Parsed Cost:", mana_cost)

	print("[PLAY CHECK] Required White:",
		mana_cost.white)

	print("[PLAY CHECK] Available White:",
		ManaManager.white_mana)

	# -----------------------------------------
	# TEMP WHITE MANA CHECK
	# -----------------------------------------
	if ManaManager.white_mana < mana_cost.white:

		print("[PLAY CHECK] FAILED: not enough white mana")
		return false

	print("[PLAY CHECK] Mana OK")

	print("[PLAY CHECK] RESULT: SUCCESS")
	print("========== PLAY VALIDATION END ==========\n")

	return true
