extends Node


# -------------------------------------------------
# GAME FLOW
# -------------------------------------------------
signal game_started
signal turn_started(player_id)

# -------------------------------------------------
# ZONE SYSTEM (UI REACTS TO THESE)
# -------------------------------------------------
signal zone_changed(zone: String)
signal hand_changed
signal battlefield_changed
signal graveyard_changed

# -------------------------------------------------
# OPTIONAL DEBUG HOOK
# -------------------------------------------------
var DEBUG := true


# -------------------------------------------------
# READY
# -------------------------------------------------
func _ready():
	print("[EventBus] READY")


# -------------------------------------------------
# SAFE EMITTER WRAPPER (optional but VERY useful)
# -------------------------------------------------
func emit_safe(signal_name: String, args: Array = []) -> void:
	if DEBUG:
		print("[EventBus] emit:", signal_name, args)

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
