extends Control
class_name PlayerPermanentsZone

@export var spacing := 220
@export var move_speed := 0.15


func arrange_cards():

	var cards: Array = []

	for c in get_children():

		if not (c is CardInstance):
			continue

		cards.append(c)


	var count = cards.size()

	if count == 0:
		return


	# =========================
	# CENTERING
	# =========================
	var total_width = (count - 1) * spacing
	var start_x = (size.x - total_width) * 0.5


	# =========================
	# POSITION CARDS
	# =========================
	for i in range(count):

		var card = cards[i]

		var target_pos = Vector2(
			start_x + (i * spacing),
			100
		)

		var tween = create_tween()

		tween.tween_property(
			card,
			"position",
			target_pos,
			move_speed
		).set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
