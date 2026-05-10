extends Node

@onready var hand_container = $"../HandContainer"

enum TurnState {
	PLAYER_TURN,
	ENEMY_TURN
}

var current_turn: TurnState


func _ready():
	print("[TurnManager] READY")

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


# =========================
# TURN FLOW (CLEAN VERSION)
# =========================
func _start_turn():

	print("===================================")
	print("[TurnManager] TURN START")

	match current_turn:
		TurnState.PLAYER_TURN:
			print("[TurnManager] Player Turn Begins")

			EventBus.turn_started.emit("player")
			PriorityManager.set_priority_for_player("player")
			ManaManager.start_turn()

			# TEMP TEST ONLY (keep here for now)
			spawn_test_card()

		TurnState.ENEMY_TURN:
			print("[TurnManager] Enemy Turn Begins")

			EventBus.turn_started.emit("enemy")
			PriorityManager.set_priority_for_player("enemy")
			ManaManager.start_turn()


func end_turn():
	print("[TurnManager] END TURN triggered")

	if current_turn == TurnState.PLAYER_TURN:
		print("[TurnManager] Switching to ENEMY TURN")
		current_turn = TurnState.ENEMY_TURN
	else:
		print("[TurnManager] Switching to PLAYER TURN")
		current_turn = TurnState.PLAYER_TURN

	_start_turn()


# =========================
# CARD SPAWN (TEMP SYSTEM)
# =========================
func spawn_test_card():
	print("[TurnManager] Spawning test card...")

	var card_scene = preload("res://Scenes/Cards/Card.tscn")
	var card_instance = card_scene.instantiate()

	hand_container.add_child(card_instance)

	print("[TurnManager] Card added to HandContainer")


# =========================
# CAST TEST (TEMP SYSTEM)
# =========================
func try_cast_test_spell():
	print("=== CAST ATTEMPT: Soldier_TEST ===")

	if not PriorityManager.can_act("player"):
		print("[CAST] BLOCKED by priority")
		return

	var paid = ManaManager.spend_white(1)

	if paid:
		print("[CAST] Soldier_TEST SUCCESSFULLY CAST")
		EventBus.card_casted.emit("Soldier_TEST")
	else:
		print("[CAST] FAILED - Not enough mana")
