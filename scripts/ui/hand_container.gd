extends Control

@export var overlap := 80

func arrange_hand():
	var cards = get_children()
	var count = cards.size()
	var card_width = 180

	if count == 0:
		return

	var total_width = (count - 1) * overlap
	var start_x = (size.x - total_width) * 0.5 - (card_width * 0.5)

	for i in range(count):
		var card = cards[i]

		if card is Control:
			card.position = Vector2(start_x + i * overlap, 0)

			card.z_index = i
