# mana_manager.gd (autolaod)
extends Node


# ====================================================================
# MANA STATE
# ====================================================================
# Currently only white mana is implemented (temporary system)
# ====================================================================

var white_mana: int = 0



# ====================================================================
# READY
# ====================================================================

func _ready():
	print("[ManaManager] READY")



# ====================================================================
# TURN START
# ====================================================================
# Resets / sets mana at beginning of turn
# ====================================================================

func start_turn():

	white_mana = 1
	# ↑ TEMP VALUE
	# Change this later for scaling mana system / lands / etc.

	print("[ManaManager] Turn start - Mana reset to:", white_mana)



# ====================================================================
# MANA SPEND (WHITE)
# ====================================================================
# Returns:
# - true  → payment successful
# - false → not enough mana
# ====================================================================

func spend_white(amount: int) -> bool:

	print("[ManaManager] Attempting to spend W:", amount, " | Available:", white_mana)

	if white_mana >= amount:

		white_mana -= amount

		print("[ManaManager] Payment successful. Remaining:", white_mana)
		return true

	else:

		print("[ManaManager] NOT ENOUGH MANA")
		return false
