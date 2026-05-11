extends Node

enum TurnState {
	PLAYER_TURN,
	ENEMY_TURN
}

var current_turn: TurnState

@onready var game_manager = get_node("../GameManager")


func _ready():
	print("[TurnManager] READY")

	current_turn = TurnState.PLAYER_TURN
	print("[TurnManager] Initial turn set to PLAYER")

	EventBus.game_started.connect(_on_game_started)

func _on_game_started():
	print("[TurnManager] Game started received")
	_start_turn()

# -------------------------
# TURN INPUT TEST (OPTIONAL)
# -------------------------
func _input(event):

	if event.is_action_pressed("ui_accept"):
		print("=== ACTION TEST ===")

		var player_id = "player"

		if PriorityManager.can_act(player_id):
			print("[TEST] Player is allowed to act")
		else:
			print("[TEST] Player is BLOCKED")

	if event.is_action_pressed("ui_cancel"):
		end_turn()


# -------------------------
# TURN START
# -------------------------
func _start_turn():

	print("===================================")
	print("[TurnManager] TURN START")

	match current_turn:

		TurnState.PLAYER_TURN:
			print("[TurnManager] Player Turn Begins")

			EventBus.turn_started.emit("player")

			PriorityManager.set_priority_for_player("player")
			ManaManager.start_turn()

			# MTG CORE RULE:
			game_manager.draw_card()

		TurnState.ENEMY_TURN:
			print("[TurnManager] Enemy Turn Begins")

			EventBus.turn_started.emit("enemy")

			PriorityManager.set_priority_for_player("enemy")
			ManaManager.start_turn()


# -------------------------
# TURN SWITCH
# -------------------------
func end_turn():

	print("[TurnManager] END TURN triggered")

	if current_turn == TurnState.PLAYER_TURN:
		current_turn = TurnState.ENEMY_TURN
		print("[TurnManager] Switching to ENEMY TURN")
	else:
		current_turn = TurnState.PLAYER_TURN
		print("[TurnManager] Switching to PLAYER TURN")

	_start_turn()
