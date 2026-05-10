extends Node
class_name CardInstance

var data: CardData
var card_owner: String

func setup(card_data: CardData, owner: String):
	data = card_data
	card_owner = owner

	print("[CardInstance] Spawned:", data.card_name, "Owner:", card_owner)
