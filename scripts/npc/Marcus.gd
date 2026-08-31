extends NPC
class_name Marcus

@export var order_min_relationship: int = 20
@export var order_crop: String = "Морковь"
@export var order_quantity: int = 5
@export var order_reward: int = 42
@export var order_days: int = 3

func _ready() -> void:
    npc_id = "marcus_van_dijk"
    display_name = "Маркус ван Дейк"
    relationship_gain_on_talk = 0
    super._ready()

func interact(hud) -> void:
    var relationship: int = get_relationship()
    var title: String = get_relationship_title()
    var order_manager = get_tree().get_first_node_in_group("order_manager")

    var pages: Array[String] = [
        "Маркус ван Дейк\nОтношение: %d/100 — %s" % [relationship, title]
    ]

    if relationship < order_min_relationship:
        pages.append("Я пока тебя почти не знаю. Поработаем — тогда и поговорим о поставках.")
        hud.start_dialogue(display_name, pages)
        return

    if order_manager == null:
        pages.append("Сейчас я не могу оформить заказ. Загляни позже.")
        hud.start_dialogue(display_name, pages)
        return

    if order_manager.has_active_order(npc_id):
        var order: Dictionary = order_manager.get_active_order(npc_id)
        pages.append(order_manager.get_order_text(order))
        pages.append("Привези заказ мне до истечения срока.")
        hud.start_dialogue(display_name, pages)
        return

    var new_order: Dictionary = order_manager.create_order(
        npc_id, order_crop, order_quantity, order_reward, order_days
    )
    pages.append("Мне нужно %d шт. %s. Если привезёшь их в течение %d дней, заплачу $%d." % [
        int(new_order["quantity"]),
        str(new_order["crop_name"]),
        int(new_order["days_left"]),
        int(new_order["reward"])
    ])
    hud.start_dialogue(display_name, pages)

func _draw() -> void:
    draw_circle(Vector2(0, -22), 11, Color("#2b211d"))
    draw_circle(Vector2(0, -17), 10, Color("#c58e62"))
    draw_rect(Rect2(-13, -7, 26, 35), Color("#5b4a72"), true)
    draw_rect(Rect2(-13, -7, 26, 35), Color("#2b211d"), false, 2.0)
    draw_line(Vector2(-7, 28), Vector2(-7, 39), Color("#47362a"), 5.0)
    draw_line(Vector2(7, 28), Vector2(7, 39), Color("#47362a"), 5.0)
    draw_string(ThemeDB.fallback_font, Vector2(-36, 57), "Маркус", HORIZONTAL_ALIGNMENT_CENTER, 72, 13, Color("#ffffff"))
