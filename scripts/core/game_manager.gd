extends Node

@onready var hand_zone: HandZone = $"../Zones/HandZone"
@onready var drop_zone: DropZone = $"../Zones/DropZone"

var player_deck: Array[CardData] = []
var hand_size := 7


func _ready():
	print("[GAME] READY")
	_start_game()


func _start_game():
	_setup_deck()
	_draw_starting_hand()


func _setup_deck():
	var card = preload("res://Data/Cards/Soldier_TEST.tres")

	player_deck.clear()

	for i in range(20):
		player_deck.append(card)

	player_deck.shuffle()


func _draw_starting_hand():
	for i in range(hand_size):
		draw_card()


func draw_card():

	if player_deck.is_empty():
		return

	var data = player_deck.pop_front()

	var card_scene = preload("res://Scenes/Cards/Card.tscn")
	var card = card_scene.instantiate()

	card.setup(data, "player")
	card.hand_container = hand_zone

	hand_zone.add_child(card)

	card.card_released.connect(_on_card_released)
	card.request_hand_relayout.connect(hand_zone._on_card_relayout_requested)

	hand_zone.arrange_hand()


func _on_card_released(card: CardInstance, pos: Vector2):

	print("[GAME] CARD RELEASED")

	var inside = drop_zone.is_card_inside(card)

	print("[GAME] INSIDE DROPZONE:", inside)

	if inside:
		print("[GAME] MOVE TO BATTLEFIELD")
		card.zone = CardInstance.CardZone.BATTLEFIELD
	else:
		print("[GAME] RETURN TO HAND")
		card.zone = CardInstance.CardZone.HAND

	hand_zone.arrange_hand()
