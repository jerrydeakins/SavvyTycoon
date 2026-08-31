extends StaticBody2D
class_name SellPoint

func sell_all() -> Dictionary:
    var gm = get_node("../GameManager")
    return gm.sell_all_inventory()

func _draw() -> void:
    # Simple placeholder market stand. Art can be replaced without changing gameplay logic.
    draw_rect(Rect2(-46, -30, 92, 60), Color("#80623e"), true)
    draw_rect(Rect2(-46, -30, 92, 60), Color("#3a2b20"), false, 3.0)
    draw_rect(Rect2(-52, -40, 104, 18), Color("#b85b4d"), true)
    draw_rect(Rect2(-52, -40, 104, 18), Color("#3a2b20"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(-31, 5), "ПРОДАЖА", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#ffffff"))
