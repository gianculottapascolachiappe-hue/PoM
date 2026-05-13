extends Node

@onready var hand_zone = $"../Zones/HandZone"
@onready var drop_zone = $"../Zones/DropZone"
@onready var battlefield_zone = $"../Zones/PlayerPermanentsZone"

var player_deck: Array[CardData] = []
var hand_size := 7


func _ready():
	_setup_deck()
	_draw_starting_hand()


# ----------------------------
# DECK
# ----------------------------
func _setup_deck():
	var soldier = preload("res://Data/Cards/Soldier_TEST.tres")
	var knight = preload("res://Data/Cards/Knight_TEST.tres")

	player_deck.clear()

	for i in range(10):
		player_deck.append(soldier)
	for i in range(10):
		player_deck.append(knight)

	player_deck.shuffle()


# ----------------------------
# DRAW
# ----------------------------
func _draw_starting_hand():
	for i in range(hand_size):
		draw_card()


func draw_card():
	if player_deck.is_empty():
		return

	var data = player_deck.pop_front()

	var card = preload("res://Scenes/Cards/Card.tscn").instantiate()
	card.setup(data, "player")

	hand_zone.add_child(card)

	card.card_released.connect(_on_card_released)

	hand_zone.arrange_hand()


# ----------------------------
# DROP LOGIC
# ----------------------------
func _on_card_released(card: CardInstance, pos: Vector2):

	var inside = drop_zone.is_card_inside(card)

	if inside:
		ZoneManager.move_card(
			card,
			ZoneManager.Zone.HAND,
			ZoneManager.Zone.BATTLEFIELD
		)

		battlefield_zone.arrange_cards()

	else:
		ZoneManager.move_card(
			card,
			ZoneManager.Zone.BATTLEFIELD,
			ZoneManager.Zone.HAND
		)

		hand_zone.arrange_hand()
		hand_zone.arrange_hand()
