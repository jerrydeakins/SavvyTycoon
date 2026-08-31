extends StaticBody2D
class_name FarmPlot

enum State { EMPTY, PLANTED, GROWING, READY, SPOILED }

@export var plot_id: int = 0
@export_range(1, 4) var upgrade_level: int = 1

var state: State = State.EMPTY
var watered: bool = false
var growth_day: int = 0
var ready_days: int = 0
var crop_name: String = ""
var crop_yield: int = 1

func plant(crop: String) -> bool:
    if state != State.EMPTY:
        return false

    var gm = get_node("../../../GameManager")
    var crop_data: Dictionary = gm.get_crop_data(crop)
    if crop_data.is_empty():
        return false

    crop_name = crop
    var upgrade_data: Dictionary = gm.get_upgrade_data(upgrade_level)
    crop_yield = int(crop_data.get("base_yield", 1)) * int(upgrade_data.get("yield_multiplier", 1))
    state = State.PLANTED
    growth_day = 0
    ready_days = 0
    watered = false
    queue_redraw()
    return true

func water() -> bool:
    if state not in [State.PLANTED, State.GROWING]:
        return false
    watered = true
    state = State.GROWING
    queue_redraw()
    return true

func advance_growth_day() -> void:
    if state == State.READY:
        ready_days += 1
        var gm = get_node("../../../GameManager")
        var crop_data: Dictionary = gm.get_crop_data(crop_name)
        var harvest_window: int = int(crop_data.get("harvest_window_days", 2))
        if ready_days > harvest_window:
            state = State.SPOILED
        queue_redraw()
        return

    if state != State.GROWING or not watered:
        return

    growth_day += 1
    watered = false

    var gm = get_node("../../../GameManager")
    var crop_data: Dictionary = gm.get_crop_data(crop_name)
    var upgrade_data: Dictionary = gm.get_upgrade_data(upgrade_level)
    var base_growth_days: int = int(crop_data.get("growth_days", 2))
    var growth_reduction_days: int = int(upgrade_data.get("growth_reduction_days", 0))
    var required_days: int = max(1, base_growth_days - growth_reduction_days)

    if growth_day >= required_days:
        state = State.READY
    queue_redraw()

func harvest() -> int:
    if state != State.READY:
        return 0

    var result: int = crop_yield
    crop_name = ""
    crop_yield = 1
    state = State.EMPTY
    watered = false
    growth_day = 0
    ready_days = 0
    queue_redraw()
    return result

func clear_spoiled() -> bool:
    if state != State.SPOILED:
        return false
    crop_name = ""
    crop_yield = 1
    watered = false
    growth_day = 0
    ready_days = 0
    state = State.EMPTY
    queue_redraw()
    return true

func get_harvest_window_days() -> int:
    var gm = get_node("../../../GameManager")
    return int(gm.get_crop_data(crop_name).get("harvest_window_days", 2))

func get_upgrade_description() -> String:
    var gm = get_node("../../../GameManager")
    var current: Dictionary = gm.get_upgrade_data(upgrade_level)
    var next: Dictionary = gm.get_next_upgrade_data(upgrade_level)

    if next.is_empty():
        return "%s\nУрожай: %d\nРост: %d дн.\nМаксимальный уровень" % [
            current.get("name", "Грядка"),
            int(current.get("yield_multiplier", 1)),
            int(current.get("growth_reduction_days", 0))
        ]

    return "%s → %s\nУрожай: ×%d → ×%d\nСокращение роста: %d → %d дн." % [
        current.get("name", "Грядка"),
        next.get("name", "Улучшение"),
        int(current.get("yield_multiplier", 1)),
        int(next.get("yield_multiplier", 1)),
        int(current.get("growth_reduction_days", 0)),
        int(next.get("growth_reduction_days", 0))
    ]

func _draw() -> void:
    var soil_colors := {
        1: Color("#c9a77a"),
        2: Color("#9b7651"),
        3: Color("#60432e"),
        4: Color("#34251d")
    }
    var soil: Color = soil_colors.get(upgrade_level, soil_colors[1])
    if watered:
        soil = soil.darkened(0.22)

    draw_rect(Rect2(-42, -28, 84, 56), soil, true)
    draw_rect(Rect2(-42, -28, 84, 56), Color("#3a2b20"), false, 3.0)

    # A small level marker makes upgrades visible without a separate tree.
    if upgrade_level > 1:
        draw_circle(Vector2(31, -18), 7, Color("#d6b45f"))
        draw_string(ThemeDB.fallback_font, Vector2(28, -14), str(upgrade_level), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#3a2b20"))

    if watered:
        draw_line(Vector2(-24, -18), Vector2(-28, -10), Color("#5b7f8a"), 2.0)
        draw_line(Vector2(0, -18), Vector2(-4, -10), Color("#5b7f8a"), 2.0)
        draw_line(Vector2(24, -18), Vector2(20, -10), Color("#5b7f8a"), 2.0)

    if state == State.READY:
        var produce_color := Color("#6f8f45") if crop_name == "Морковь" else Color("#b5953e")
        for i in range(crop_yield):
            var x: float = -20.0 + float(i % 3) * 20.0
            var y: float = 6.0 if i < 3 else -8.0
            draw_circle(Vector2(x, y), 7, produce_color)
    elif state == State.SPOILED:
        draw_line(Vector2(-22, -14), Vector2(22, 14), Color("#6d5140"), 5.0)
        draw_line(Vector2(-22, 14), Vector2(22, -14), Color("#6d5140"), 5.0)
    elif state in [State.PLANTED, State.GROWING]:
        var sprout_color := Color("#6f8f45") if crop_name == "Морковь" else Color("#839447")
        draw_circle(Vector2(0, 0), 4, sprout_color)
        if growth_day >= 1:
            draw_circle(Vector2(-10, 8), 5, sprout_color)
            draw_circle(Vector2(10, -8), 5, sprout_color)
