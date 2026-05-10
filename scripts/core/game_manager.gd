extends Node

func _ready():
	print("===================================")
	print("[GameManager] READY")
	print("[GameManager] Initializing game...")

	_start_game()

func _start_game():
	print("[GameManager] Starting game flow...")

	EventBus.game_started.emit()

	print("[GameManager] Game started signal emitted")
	print("===================================")
	print("[GameManager] Waiting for TurnManager to take control")
