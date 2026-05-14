extends Resource
class_name CardData

@export var base_size := Vector2(180, 260)

@export var card_id: String = ""
@export var card_name: String = ""

@export var supertypes: Array[String] = []
@export var card_types: Array[String] = []
@export var subtypes: Array[String] = []

@export var mana_cost: String = ""
@export var mana_value: int = 1

@export var power: int = 0
@export var toughness: int = 0

@export var card_texture: Texture2D
