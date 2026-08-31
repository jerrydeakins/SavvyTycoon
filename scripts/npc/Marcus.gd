extends NPC
class_name Marcus

@export var order_crop: String = "Морковь"
@export var order_quantity: int = 5
@export var order_reward: int = 42
@export var order_days: int = 3

func _ready() -> void:
    npc_id = "marcus_van_dijk"
    display_name = "Маркус ван Дейк"
    relationship_gain_on_talk = 0
    dialogue_pages = ["Ты тот самый новый фермер? Посмотрим, что у тебя получится.", "Мне не нужно много. Мне нужно, чтобы ты привозил именно то, что обещал, и тогда, когда обещал."]
    super._ready()

func interact(hud) -> void:
    var relationship: int = get_relationship()
    var title: String = get_relationship_title()
    var order_manager = get_tree().get_first_node_in_group("order_manager")
    var gm = get_node("../GameManager")
    var pages: Array[String] = ["Маркус ван Дейк\nОтношение: %d/100 — %s" % [relationship, title]]

    if order_manager == null:
        pages.append("Сейчас я не могу оформить заказ. Загляни позже.")
        hud.start_dialogue(display_name, pages)
        return

    if order_manager.has_active_order(npc_id):
        var order: Dictionary = order_manager.get_active_order(npc_id)
        var crop_name: String = str(order["crop_name"])
        var quantity: int = int(order["quantity"])
        if gm.get_crop_quantity(crop_name) >= quantity:
            gm.remove_from_storage(crop_name, quantity)
            var completed: Dictionary = order_manager.complete_order(npc_id, crop_name, quantity)
            if not completed.is_empty():
                var reward: int = int(completed["reward"])
                var new_relationship: int = int(completed.get("relationship_after", get_relationship()))
                gm.add_money(reward)
                # Refresh the header after completing the order. Previously the
                # first dialogue page kept the pre-completion 0/100 value.
                pages[0] = "Маркус ван Дейк\nОтношение: %d/100 — %s" % [new_relationship, get_relationship_title()]
                pages.append("Отлично. Всё на месте.\nОплата: +$%d\nОтношение: +20\nТеперь: %d/100 — %s" % [reward, new_relationship, get_relationship_title()])
                hud.start_dialogue(display_name, pages)
                return
        pages.append(order_manager.get_order_text(order))
        pages.append("Когда соберёшь нужное количество, принеси его мне. Срок продолжает идти.")
        hud.start_dialogue(display_name, pages)
        return

    if order_manager.is_npc_on_cooldown(npc_id):
        pages.append("Спасибо за поставку. Давай продолжим завтра.")
        hud.start_dialogue(display_name, pages)
        return

    var new_order: Dictionary = order_manager.create_order(npc_id, order_crop, order_quantity, order_reward, order_days)
    if new_order.is_empty():
        pages.append("Сейчас у меня нет нового заказа. Загляни позже.")
        hud.start_dialogue(display_name, pages)
        return
    pages.append("Давай начнём с малого. Мне нужно %d шт. %s. Привези их в течение %d дней — заплачу $%d." % [int(new_order["quantity"]), str(new_order["crop_name"]), int(new_order["days_left"]), int(new_order["reward"])])
    hud.start_dialogue(display_name, pages)

func _draw() -> void:
    draw_circle(Vector2(0, -22), 11, Color("#2b211d"))
    draw_circle(Vector2(0, -17), 10, Color("#c58e62"))
    draw_rect(Rect2(-13, -7, 26, 35), Color("#5b4a72"), true)
    draw_rect(Rect2(-13, -7, 26, 35), Color("#2b211d"), false, 2.0)
    draw_line(Vector2(-7, 28), Vector2(-7, 39), Color("#47362a"), 5.0)
    draw_line(Vector2(7, 28), Vector2(7, 39), Color("#47362a"), 5.0)
    draw_string(ThemeDB.fallback_font, Vector2(-36, 57), "Маркус", HORIZONTAL_ALIGNMENT_CENTER, 72, 13, Color("#ffffff"))
