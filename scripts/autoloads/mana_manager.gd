extends Node

var white_mana: int = 0

func _ready():
	print("[ManaManager] READY")

func start_turn():
	white_mana = 1  # TEMP: simple test value
	print("[ManaManager] Turn start - Mana reset to:", white_mana)

func spend_white(amount: int) -> bool:
	print("[ManaManager] Attempting to spend W:", amount, " | Available:", white_mana)

	if white_mana >= amount:
		white_mana -= amount
		print("[ManaManager] Payment successful. Remaining:", white_mana)
		return true
	else:
		print("[ManaManager] NOT ENOUGH MANA")
		return false
