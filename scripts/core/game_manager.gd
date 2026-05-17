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

	print("\n=== MANA TEST START ===")

	ManaManager.start_turn()

	print("Can pay 1 white?", ManaManager.can_pay_white(1))
	print("Can pay 2 white?", ManaManager.can_pay_white(2))

	print("Pay 1 white:", ManaManager.pay_white(1))
	print("After payment, can pay 1 white?", ManaManager.can_pay_white(1))

	print("=== MANA TEST END ===\n")

# ====================================================================
# DECK SETUP
# ====================================================================
# Temporary test deck builder
# ====================================================================

func _setup_deck():

	var soldier = preload("res://Data/Cards/Soldier_TEST.tres")
	var knight = preload("res://Data/Cards/Knight_TEST.tres")
	var lizardman = preload("res://Data/Cards/Lizardman_TEST.tres")
	var paladin = preload("res://Data/Cards/Paladin_TEST.tres")
	var spirit = preload("res://Data/Cards/Spirit_TEST.tres")

	player_deck.clear()

	for i in range(10):
		player_deck.append(soldier)

	for i in range(10):
		player_deck.append(knight)

	for i in range(4):
		player_deck.append(lizardman)

	for i in range(4):
		player_deck.append(paladin)

	for i in range(2):
		player_deck.append(spirit)

	player_deck.shuffle()


# --------------------------------------------------
# TEMP PLAY VALIDATION TEST
# --------------------------------------------------
func _input(event):

	if event.is_action_pressed("ui_accept"):

		print("\n========== TEST PLAY VALIDATION ==========")

		var hand := ZoneManager.get_hand_cards()

		if hand.is_empty():
			print("[TEST] No cards in hand")
			return

		var test_card: CardInstance = hand[0]

		print("[TEST] Testing:",
			test_card.data.card_name)

		var result := CardPlayManager.can_play(test_card)

		print("[TEST] RESULT:", result)



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
