extends Node

enum PriorityState {
	PLAYER_PRIORITY,
	ENEMY_PRIORITY
}

var current_priority: PriorityState = PriorityState.PLAYER_PRIORITY

func _ready():
	print("[PriorityManager] READY (AUTOLOAD)")

func set_priority_for_player(player_id: String):
	if player_id == "player":
		current_priority = PriorityState.PLAYER_PRIORITY
		print("[PriorityManager] Priority → PLAYER")
	else:
		current_priority = PriorityState.ENEMY_PRIORITY
		print("[PriorityManager] Priority → ENEMY")

func can_act(player_id: String) -> bool:
	var allowed := false

	if player_id == "player" and current_priority == PriorityState.PLAYER_PRIORITY:
		allowed = true
	elif player_id == "enemy" and current_priority == PriorityState.ENEMY_PRIORITY:
		allowed = true

	print("[PriorityManager] can_act(", player_id, ") = ", allowed)
	return allowed
