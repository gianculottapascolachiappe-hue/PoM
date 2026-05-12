extends Control
class_name DropZone

func _ready():
	print("[DROPZONE] READY")


func is_card_inside(card: Control) -> bool:
	return get_global_rect().intersects(card.get_global_rect())
