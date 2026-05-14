#zone_manager.gd
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

	# 1. remove from old zone data
	_remove(card, from_zone)

	# 2. add to new zone data
	_add(card, to_zone)

	# 3. update logical state
	card.zone = to_zone

	# 4. reset visuals
	card.reset_visual_state()

# ---------------------------------------
# REPARENT VISUAL NODE (IMPORTANT FIX)
# ---------------------------------------
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

	# move card in scene tree
	var old_parent = card.get_parent()

	if old_parent != new_parent:
		old_parent.remove_child(card)
		new_parent.add_child(card)
	print("[DEBUG] new_parent:", new_parent)
	print("[DEBUG] card parent after:", card.get_parent())
	print("[DEBUG] hand zone:", get_tree().get_first_node_in_group("hand_zone"))

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
	var result: Array = []

	for c in hand_cards:
		if is_instance_valid(c) and c.zone == Zone.HAND:
			result.append(c)

	return result

func get_battlefield_cards() -> Array:
	return battlefield_cards.filter(is_instance_valid)

func get_graveyard_cards() -> Array:
	return graveyard_cards.filter(is_instance_valid)
