extends Control

var confetti: Array[Dictionary] = []
var elapsed: float = 0.0
var active: bool = false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(false)

func play() -> void:
    confetti.clear()
    elapsed = 0.0
    active = true
    set_process(true)
    for i in range(42):
        confetti.append({
            "pos": Vector2(randf_range(40.0, size.x - 40.0), randf_range(-120.0, 80.0)),
            "velocity": Vector2(randf_range(-90.0, 90.0), randf_range(70.0, 230.0)),
            "rotation": randf_range(0.0, TAU),
            "spin": randf_range(-6.0, 6.0),
            "size": randf_range(5.0, 10.0),
            "shape": i % 3
        })
    queue_redraw()

func _process(delta: float) -> void:
    if not active:
        return
    elapsed += delta
    for item in confetti:
        item["velocity"] = Vector2(item["velocity"]).lerp(Vector2(item["velocity"].x, 360.0), min(delta * 0.8, 1.0))
        item["pos"] = Vector2(item["pos"]) + Vector2(item["velocity"]) * delta
        item["rotation"] = float(item["rotation"]) + float(item["spin"]) * delta
    queue_redraw()
    if elapsed > 2.8:
        active = false
        set_process(false)

func _draw() -> void:
    if not active:
        return

    var center := size * 0.5
    var ray_alpha := max(0.0, 1.0 - elapsed / 1.5)
    for i in range(16):
        var angle := TAU * float(i) / 16.0
        var inner := center + Vector2(cos(angle), sin(angle)) * 185.0
        var outer := center + Vector2(cos(angle), sin(angle)) * (270.0 + 45.0 * sin(elapsed * 4.0 + i))
        draw_line(inner, outer, Color(1.0, 0.82, 0.28, ray_alpha * 0.55), 3.0)

    for item in confetti:
        var pos: Vector2 = item["pos"]
        var s: float = item["size"]
        var rot: float = item["rotation"]
        var points := PackedVector2Array([
            Vector2(-s, -s * 0.45), Vector2(s, -s * 0.45),
            Vector2(s * 0.7, s * 0.45), Vector2(-s * 0.7, s * 0.45)
        ])
        var transform := Transform2D(rot, pos)
        var transformed := PackedVector2Array()
        for point in points:
            transformed.append(transform * point)
        var alpha := clamp(1.0 - max(0.0, pos.y - size.y * 0.45) / (size.y * 0.65), 0.15, 1.0)
        var tone := int(item["shape"])
        var color := Color("#f6c453") if tone == 0 else (Color("#7ac7ff") if tone == 1 else Color("#ff7a7a"))
        color.a = alpha
        draw_colored_polygon(transformed, color)

    var balloon_positions := [
        Vector2(center.x - 235.0, center.y - 110.0),
        Vector2(center.x + 235.0, center.y - 90.0),
        Vector2(center.x - 270.0, center.y + 90.0),
        Vector2(center.x + 270.0, center.y + 100.0)
    ]
    var balloon_colors := [Color("#ff7a7a"), Color("#7ac7ff"), Color("#f6c453"), Color("#a6d96a")]
    var balloon_alpha := min(1.0, elapsed / 0.35)
    for i in range(balloon_positions.size()):
        var p: Vector2 = balloon_positions[i]
        var c: Color = balloon_colors[i]
        c.a = balloon_alpha * 0.9
        draw_circle(p, 22.0, c)
        draw_line(p + Vector2(0, 22), p + Vector2(4, 72), Color(1, 1, 1, balloon_alpha * 0.65), 1.5)
