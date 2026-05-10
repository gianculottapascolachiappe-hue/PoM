extends Node


enum TurnState {
	PLAYER_TURN,
	ENEMY_TURN
}

var current_turn: TurnState

func _ready():
	print("[TurnManager] READY")
	
	# Start game state
	current_turn = TurnState.PLAYER_TURN
	print("[TurnManager] Initial turn set to PLAYER")

	_start_turn()


func _input(event):
	if event.is_action_pressed("ui_accept"):
		var player_id = "player"

		print("=== ACTION TEST ===")
		if PriorityManager.can_act(player_id):
			print("[TEST] Player is allowed to act")
		else:
			print("[TEST] Player is BLOCKED")

	if event.is_action_pressed("ui_cancel"):
		end_turn()


func _start_turn():
	EventBus.turn_started.emit("player")
	PriorityManager.set_priority_for_player("player")
	ManaManager.start_turn()

	match current_turn:
		TurnState.PLAYER_TURN:
			print("[TurnManager] Player Turn Begins")
			EventBus.turn_started.emit("player")

			PriorityManager.set_priority_for_player("player")

		TurnState.ENEMY_TURN:
			print("[TurnManager] Enemy Turn Begins")
			EventBus.turn_started.emit("enemy")

			PriorityManager.set_priority_for_player("enemy")

func end_turn():
	print("[TurnManager] END TURN triggered")

	if current_turn == TurnState.PLAYER_TURN:
		print("[TurnManager] Switching to ENEMY TURN")
		current_turn = TurnState.ENEMY_TURN
	else:
		print("[TurnManager] Switching to PLAYER TURN")
		current_turn = TurnState.PLAYER_TURN

	_start_turn()


func try_cast_test_spell():
	print("=== CAST ATTEMPT: Soldier_TEST ===")

	if PriorityManager.can_act("player"):
		var paid = ManaManager.spend_white(1)

		if paid:
			print("[CAST] Soldier_TEST SUCCESSFULLY CAST")
		else:
			print("[CAST] FAILED - Not enough mana")
