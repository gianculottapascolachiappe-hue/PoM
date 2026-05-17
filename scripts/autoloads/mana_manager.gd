# mana_manager.gd (autolaod)
extends Node


# ====================================================================
# MANA STATE
# ====================================================================
# Temporary system: only white mana for now
# Future: expand into full MTG-style mana pool
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
# Resets mana at the beginning of each turn
# Later this will be replaced by land system / ramp / etc.
# ====================================================================

func start_turn():

	white_mana = 1
	# ↑ TEMP VALUE (placeholder for real mana system)

	print("[ManaManager] Turn start - Mana reset to:", white_mana)


# ====================================================================
# MANA CHECK (WHITE)
# ====================================================================
# Centralized rule for "can I afford this?"
# NEVER compare white_mana directly outside this script
# ====================================================================

func can_pay_white(amount: int) -> bool:

	print("[ManaManager] Check can pay W:", amount, "| Available:", white_mana)

	return white_mana >= amount


# ====================================================================
# MANA PAYMENT (WHITE)
# ====================================================================
# Safe payment function used by gameplay systems
# Returns true if payment succeeded
# Returns false if not enough mana
# ====================================================================

func pay_white(amount: int) -> bool:

	if amount <= 0:
		print("[ManaManager] PAY SKIPPED (0 or negative cost)")
		return true

	if not can_pay_white(amount):
		print("[ManaManager] PAY FAILED (not enough white)")
		return false

	white_mana -= amount

	print("[ManaManager] PAY SUCCESS. Remaining:", white_mana)
	return true


# ====================================================================
# LEGACY SUPPORT (OPTIONAL)
# ====================================================================
# Keeps your old function alive so nothing breaks immediately
# You can delete this later once everything is migrated
# ====================================================================

func spend_white(amount: int) -> bool:
	return pay_white(amount)
