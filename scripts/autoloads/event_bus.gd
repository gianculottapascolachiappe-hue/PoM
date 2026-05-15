# event_bus.gd (autoload)
extends Node


# ====================================================================
# EVENT BUS (GLOBAL SIGNAL HUB)
# ====================================================================
# Central communication system for the game.
#
# Used by:
# - ZoneManager
# - UI (Hand / Battlefield / Graveyard)
# - Game flow systems
# ====================================================================



# ====================================================================
# GAME FLOW SIGNALS
# ====================================================================

signal game_started
signal turn_started(player_id)



# ====================================================================
# ZONE SYSTEM SIGNALS (UI REACTS TO THESE)
# ====================================================================
# These signals should trigger UI updates only.
# ====================================================================

signal zone_changed(zone: String)
signal hand_changed
signal battlefield_changed
signal graveyard_changed



# ====================================================================
# DEBUG SETTINGS
# ====================================================================

var DEBUG := true
# ↑ Toggle global event logging here



# ====================================================================
# READY
# ====================================================================

func _ready():
	print("[EventBus] READY")



# ====================================================================
# SAFE EMITTER WRAPPER
# ====================================================================
# Centralized signal emission helper.
#
# Benefits:
# - Debug logging in one place
# - Prevents scattered emit calls
# - Makes debugging event flow MUCH easier
# ====================================================================

func emit_safe(signal_name: String, args: Array = []) -> void:

	# ------------------------------------------------
	# Debug logging
	# ------------------------------------------------
	if DEBUG:
		print("[EventBus EMIT] ", signal_name, " | args: ", args)


	# ------------------------------------------------
	# Signal routing
	# ------------------------------------------------
	match signal_name:

		"hand_changed":
			hand_changed.emit()

		"battlefield_changed":
			battlefield_changed.emit()

		"graveyard_changed":
			graveyard_changed.emit()

		"zone_changed":
			if args.size() > 0:
				zone_changed.emit(args[0])
