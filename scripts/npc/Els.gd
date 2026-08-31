extends StaticBody2D
class_name Els

@export var display_name: String = "Эльс ван дер Берг"
@export var dialogue_pages: Array[String] = [
    "Ты новенький фермер, верно? Начни с простого: выбери культуру, посади её, полей и собери урожай.",
    "Когда появятся деньги, поговорим о том, как сделать хозяйство сильнее. Не гонись за количеством грядок — сначала сделай их прибыльными."
]

func interact(hud) -> void:
    hud.start_dialogue(display_name, dialogue_pages)

func _draw() -> void:
    # Placeholder silhouette. The supplied character sheet is the visual authority
    # for replacing this with final sprite art later.
    draw_circle(Vector2(-2, -22), 12, Color("#2b211d"))
    draw_circle(Vector2(0, -18), 11, Color("#d49a6a"))
    draw_circle(Vector2(-4, -25), 7, Color("#2b211d"))
    draw_rect(Rect2(-13, -6, 26, 34), Color("#445936"), true)
    draw_rect(Rect2(-13, -6, 26, 34), Color("#2b211d"), false, 2.0)
    draw_line(Vector2(-7, 28), Vector2(-7, 39), Color("#47362a"), 5.0)
    draw_line(Vector2(7, 28), Vector2(7, 39), Color("#47362a"), 5.0)
    draw_string(ThemeDB.fallback_font, Vector2(-27, 57), "Эльс", HORIZONTAL_ALIGNMENT_CENTER, 54, 13, Color("#ffffff"))
