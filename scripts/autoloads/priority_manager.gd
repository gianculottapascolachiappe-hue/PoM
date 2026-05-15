# priority_manager.gd (autoload)
extends Node


# -------------------------------------------------
# PRIORITY STATES
# -------------------------------------------------
enum PriorityState {
	PLAYER_PRIORITY,
	ENEMY_PRIORITY
}


# -------------------------------------------------
# CURRENT STATE
# -------------------------------------------------
var current_priority: PriorityState = PriorityState.PLAYER_PRIORITY


# -------------------------------------------------
# DEBUG TOGGLE (optional control for print spam)
# -------------------------------------------------
var DEBUG := true


# -------------------------------------------------
# READY
# -------------------------------------------------
func _ready():
	print("[PriorityManager] READY (AUTOLOAD)")


# -------------------------------------------------
# SET PRIORITY
# -------------------------------------------------
func set_priority_for_player(player_id: String):

	if player_id == "player":
		current_priority = PriorityState.PLAYER_PRIORITY
		if DEBUG:
			print("[PriorityManager] Priority → PLAYER")
	else:
		current_priority = PriorityState.ENEMY_PRIORITY
		if DEBUG:
			print("[PriorityManager] Priority → ENEMY")


# -------------------------------------------------
# ACTION CHECK
# -------------------------------------------------
func can_act(player_id: String) -> bool:

	var allowed := false

	if player_id == "player" and current_priority == PriorityState.PLAYER_PRIORITY:
		allowed = true
	elif player_id == "enemy" and current_priority == PriorityState.ENEMY_PRIORITY:
		allowed = true

	if DEBUG:
		print("[PriorityManager] can_act(", player_id, ") = ", allowed)

	return allowed
