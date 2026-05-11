extends Node

@onready var hand_container: Control = $"../HandContainer"

var player_deck: Array[CardData] = []
var player_hand_size := 7

func _ready():
	print("[GameManager] READY")
	_start_game()


func _start_game():
	print("[GameManager] Starting game flow...")

	_setup_test_deck()
	draw_starting_hand()

	EventBus.game_started.emit()
	print("[GameManager] Game started signal emitted")


# -------------------------
# DECK SETUP
# -------------------------
func _setup_test_deck():
	print("[GameManager] Setting up test deck...")

	var soldier = preload("res://Data/Cards/Soldier_TEST.tres")

	player_deck.clear()

	for i in range(20):
		player_deck.append(soldier)

	player_deck.shuffle()

	print("[GameManager] Deck size:", player_deck.size())


# -------------------------
# DRAW SINGLE CARD
# -------------------------
func draw_card():

	if player_deck.is_empty():
		print("[GameManager] No cards left to draw!")
		return

	var card_data = player_deck.pop_front()

	var card_scene = preload("res://Scenes/Cards/Card.tscn")
	var card = card_scene.instantiate()

	card.setup(card_data, "player")

	hand_container.add_child(card)
	hand_container.arrange_hand()
	
	print("[GameManager] Drew card:", card_data.card_name)


# -------------------------
# STARTING HAND
# -------------------------
func draw_starting_hand():
	print("[GameManager] Drawing starting hand...")

	for i in range(player_hand_size):
		draw_card()
