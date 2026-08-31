extends NPC
class_name Marcus

func _ready() -> void:
    npc_id = "marcus_van_dijk"
    display_name = "Маркус ван Дейк"
    relationship_gain_on_talk = 0
    dialogue_pages = [
        "Ты тот самый новый фермер? Посмотрим, что у тебя получится.",
        "Мне не нужно много. Мне нужно, чтобы ты привозил именно то, что обещал, и тогда, когда обещал."
    ]
    super._ready()

func interact(hud) -> void:
    var relationship := get_relationship()
    var title := get_relationship_title()
    var pages: Array[String] = [
        "Маркус ван Дейк\nОтношение: %d/100 — %s" % [relationship, title]
    ]

    match get_relationship_level():
        0:
            pages.append("Я пока тебя почти не знаю. Поработаем — тогда и поговорим о поставках.")
        1:
            pages.append("Небольшие партии я уже могу у тебя брать. Если всё будет вовремя, доверия станет больше.")
        2:
            pages.append("Теперь я могу предложить тебе первые заказы. Заказы выгоднее обычной продажи, но у них есть срок.")
        3:
            pages.append("Мы уже работаем как партнёры. Я могу сообщать тебе о спросе заранее.")
        4:
            pages.append("Ты надёжный поставщик. Можем перейти к постоянному контракту.")

    hud.start_dialogue(display_name, pages)

func _draw() -> void:
    draw_circle(Vector2(0, -22), 11, Color("#2b211d"))
    draw_circle(Vector2(0, -17), 10, Color("#c58e62"))
    draw_rect(Rect2(-13, -7, 26, 35), Color("#5b4a72"), true)
    draw_rect(Rect2(-13, -7, 26, 35), Color("#2b211d"), false, 2.0)
    draw_line(Vector2(-7, 28), Vector2(-7, 39), Color("#47362a"), 5.0)
    draw_line(Vector2(7, 28), Vector2(7, 39), Color("#47362a"), 5.0)
    draw_string(ThemeDB.fallback_font, Vector2(-36, 57), "Маркус", HORIZONTAL_ALIGNMENT_CENTER, 72, 13, Color("#ffffff"))
