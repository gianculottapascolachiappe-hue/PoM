# zone_manager.gd (autoload)
extends Node

# -------------------------------------------------
# ZONE MANAGER
# -------------------------------------------------
# Central zone system (single source of truth).
# Handles card ownership between HAND, BATTLEFIELD,
# and GRAVEYARD, including registration, movement,
# and safe queries for UI/layout systems.
# -------------------------------------------------


# ==================================================
# ZONES (GLOBAL STATE DEFINITIONS)
# ==================================================
enum Zone {
	HAND,
	BATTLEFIELD,
	GRAVEYARD
}


# ==================================================
# STORAGE (SOURCE OF TRUTH)
# ==================================================
var hand_cards: Array[CardInstance] = []
var battlefield_cards: Array[CardInstance] = []
var graveyard_cards: Array[CardInstance] = []

var DEBUG := true


# ==================================================
# REGISTER CARD INTO SYSTEM
# ==================================================
func register_card(card: CardInstance, zone: Zone, parent: Node) -> void:
	if card == null:
		return

	if hand_cards.has(card) or battlefield_cards.has(card) or graveyard_cards.has(card):
		_remove(card, card.zone)

	parent.add_child(card)

	card.zone = zone
	_add(card, zone)

	if DEBUG:
		print("[ZONE] REGISTER:", card.name, "->", zone)


# ==================================================
# MOVE CARD BETWEEN ZONES (MAIN API)
# ==================================================
func move_card(card: CardInstance, from_zone: Zone, to_zone: Zone) -> void:
	if card == null:
		return

	if DEBUG:
		print("[ZONE] MOVE:", card.name, from_zone, "->", to_zone)

	# 1. update zone storage
	_remove(card, from_zone)
	_add(card, to_zone)

	# 2. update logical state
	card.zone = to_zone

	# 3. reset visual state
	card.reset_visual_state()


# ==================================================
# RE-PARENTING LOGIC (VISUAL TREE HANDLING)
# ==================================================
	var new_parent: Node = null

	match to_zone:
		Zone.HAND:
			new_parent = get_tree().get_first_node_in_group("hand_zone")
		Zone.BATTLEFIELD:
			new_parent = get_tree().get_first_node_in_group("battlefield_zone")
		Zone.GRAVEYARD:
			new_parent = get_tree().get_first_node_in_group("graveyard_zone")

	if new_parent == null:
		push_error("ZoneManager: missing zone group for " + str(to_zone))
		return

	var old_parent = card.get_parent()

	if old_parent != new_parent:
		old_parent.remove_child(card)
		new_parent.add_child(card)

	if DEBUG:
		print("[ZONE] new_parent:", new_parent)
		print("[ZONE] card parent after:", card.get_parent())


# ==================================================
# INTERNAL REMOVE
# ==================================================
func _remove(card: CardInstance, zone: Zone) -> void:
	match zone:
		Zone.HAND:
			hand_cards.erase(card)
		Zone.BATTLEFIELD:
			battlefield_cards.erase(card)
		Zone.GRAVEYARD:
			graveyard_cards.erase(card)


# ==================================================
# INTERNAL ADD
# ==================================================
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


# ==================================================
# SAFE QUERIES (FILTERED OUTPUT FOR UI)
# ==================================================
func get_hand_cards() -> Array[CardInstance]:
	var result: Array[CardInstance] = []

	for c in hand_cards:
		if is_instance_valid(c) and c.data != null:
			result.append(c)

	return result


func get_battlefield_cards() -> Array[CardInstance]:
	var result: Array[CardInstance] = []

	for c in battlefield_cards:
		if is_instance_valid(c) and c.data != null:
			result.append(c)

	return result


func get_graveyard_cards() -> Array:
	return graveyard_cards.filter(is_instance_valid)
