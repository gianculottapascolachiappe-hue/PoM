extends Control
class_name DropZone

func is_card_inside(card: CardInstance) -> bool:
	var rect = get_global_rect()
	return rect.has_point(card.global_position)
