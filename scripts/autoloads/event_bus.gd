extends Node

signal game_started
signal turn_started(player_id)

func _ready():
	print("[EventBus] READY")
