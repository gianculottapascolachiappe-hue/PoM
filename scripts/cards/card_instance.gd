extends Control
class_name CardInstance

@onready var card_frame = $CardFrame
@onready var stats_label = $StatsLabel

var data: CardData
var card_owner: String
var is_ready := false


func _ready():
	print("========== CARD READY ==========")

	is_ready = true

	# If setup already happened, apply visuals now
	if data != null:
		update_visuals()


func setup(card_data: CardData, owner: String):
	data = card_data
	card_owner = owner

	print("[CardInstance] Setup:", data.card_name)

	# Only update visuals if node is ready
	if is_ready:
		update_visuals()


func update_visuals():

	if data == null:
		return

	if data.card_texture:
		card_frame.texture = data.card_texture

	stats_label.text = str(data.power) + "/" + str(data.toughness)

	print("[CardInstance] Visuals updated")
