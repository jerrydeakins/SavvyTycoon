extends StaticBody2D
class_name Els

@export var display_name: String = "Эльс ван дер Берг"
@export var dialogue_pages: Array[String] = [
    "Ты новенький фермер, верно? Начни с простого: выбери культуру, посади её, полей и собери урожай.",
    "Когда появятся деньги, поговорим о том, как сделать хозяйство сильнее. Не гонись за количеством грядок — сначала сделай их прибыльными."
]

func _ready() -> void:
    var sprite: Sprite2D = Sprite2D.new()
    sprite.texture = ResourceLoader.load("res://assets/characters/character-1/els_world.svg") as Texture2D
    sprite.position = Vector2(0, -67)
    sprite.scale = Vector2(0.58, 0.58)
    sprite.z_index = 1
    add_child(sprite)

func interact(hud) -> void:
    hud.start_dialogue(display_name, dialogue_pages)

func _draw() -> void:
    draw_string(ThemeDB.fallback_font, Vector2(-27, 57), "Эльс", HORIZONTAL_ALIGNMENT_CENTER, 54, 13, Color("#ffffff"))
