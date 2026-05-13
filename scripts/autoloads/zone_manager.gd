extends Node


# ----------------------------
# ZONES (SINGLE SOURCE OF TRUTH)
# ----------------------------
enum Zone {
	HAND,
	BATTLEFIELD,
	GRAVEYARD
}

# ----------------------------
# STORAGE
# ----------------------------
var hand_cards: Array[CardInstance] = []
var battlefield_cards: Array[CardInstance] = []
var graveyard_cards: Array[CardInstance] = []

var DEBUG := true


# ----------------------------
# REGISTER
# ----------------------------
func register_card(card: CardInstance, zone: Zone, parent: Node) -> void:
	if card == null:
		return

	parent.add_child(card)

	card.zone = zone
	_add(card, zone)

	if DEBUG:
		print("[ZONE] REGISTER:", card.name, "->", zone)


# ----------------------------
# MOVE (ONLY VALID WAY TO CHANGE ZONE)
# ----------------------------
func move_card(card: CardInstance, from_zone: Zone, to_zone: Zone) -> void:
	if card == null:
		return

	if DEBUG:
		print("[ZONE] MOVE:", card.name, from_zone, "->", to_zone)

	_remove(card, from_zone)
	_add(card, to_zone)

	card.zone = to_zone

	# IMPORTANT RESET VISUAL STATE
	card.reset_visual_state()


# ----------------------------
# INTERNAL REMOVE
# ----------------------------
func _remove(card: CardInstance, zone: Zone) -> void:
	match zone:
		Zone.HAND:
			hand_cards.erase(card)
		Zone.BATTLEFIELD:
			battlefield_cards.erase(card)
		Zone.GRAVEYARD:
			graveyard_cards.erase(card)


# ----------------------------
# INTERNAL ADD
# ----------------------------
func _add(card: CardInstance, zone: Zone) -> void:
	match zone:
		Zone.HAND:
			if not hand_cards.has(card):
				hand_cards.append(card)

		Zone.BATTLEFIELD:
			if not battlefield_cards.has(card):
				battlefield_cards.append(card)

		Zone.GRAVEYARD:
			if not graveyard_cards.has(card):
				graveyard_cards.append(card)


# ----------------------------
# SAFE QUERIES
# ----------------------------
func get_hand_cards() -> Array:
	return hand_cards.filter(is_instance_valid)

func get_battlefield_cards() -> Array:
	return battlefield_cards.filter(is_instance_valid)

func get_graveyard_cards() -> Array:
	return graveyard_cards.filter(is_instance_valid)
