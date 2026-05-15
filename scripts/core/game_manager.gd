# game_manager.gd
extends Node



# ====================================================================
# REFERENCES
# ====================================================================
# Core scene dependencies (UI zones + gameplay zones)
# ====================================================================

@onready var hand_zone = $"../Zones/HandZone"
@onready var drop_zone = $"../Zones/DropZone"
@onready var battlefield_zone = $"../Zones/PlayerPermanentsZone"



# ====================================================================
# DECK STATE
# ====================================================================

var player_deck: Array[CardData] = []
var hand_size := 7



# ====================================================================
# INITIALIZATION
# ====================================================================

func _ready():
	_setup_deck()
	_draw_starting_hand()



# ====================================================================
# DECK SETUP
# ====================================================================
# Temporary test deck builder
# ====================================================================

func _setup_deck():

	var soldier = preload("res://Data/Cards/Soldier_TEST.tres")
	var knight = preload("res://Data/Cards/Knight_TEST.tres")

	player_deck.clear()

	for i in range(10):
		player_deck.append(soldier)

	for i in range(10):
		player_deck.append(knight)

	player_deck.shuffle()



# ====================================================================
# STARTING HAND
# ====================================================================

func _draw_starting_hand():

	for i in range(hand_size):
		draw_card()



# ====================================================================
# DRAW CARD
# ====================================================================

func draw_card():

	if player_deck.is_empty():
		return

	var data = player_deck.pop_front()

	var card = preload("res://Scenes/Cards/Card.tscn").instantiate()
	card.setup(data, "player")

	# Register into HAND (single source of truth)
	ZoneManager.register_card(
		card,
		ZoneManager.Zone.HAND,
		hand_zone
	)

	card.card_released.connect(_on_card_released)

	_refresh_ui()



# ====================================================================
# CARD RELEASE LOGIC
# ====================================================================
# Handles:
# - Drop on battlefield
# - Return to hand
# ====================================================================

func _on_card_released(card: CardInstance, _pos: Vector2):

	var inside: bool = drop_zone.is_card_inside(card)

	# ------------------------------------------------
	# DROPPED ON BATTLEFIELD
	# ------------------------------------------------
	if inside:

		card.reset_visual_state()

		ZoneManager.move_card(
			card,
			ZoneManager.Zone.HAND,
			ZoneManager.Zone.BATTLEFIELD
		)

	# ------------------------------------------------
	# RETURN TO HAND
	# ------------------------------------------------
	else:

		card.reset_visual_state()

		ZoneManager.move_card(
			card,
			ZoneManager.Zone.BATTLEFIELD,
			ZoneManager.Zone.HAND
		)

	_refresh_ui()



# ====================================================================
# UI REFRESH
# ====================================================================
# Forces both zones to re-layout cards.
# This is the "authoritative visual update step".
# ====================================================================

func _refresh_ui():
	hand_zone.arrange_hand()
	battlefield_zone.arrange_cards()
