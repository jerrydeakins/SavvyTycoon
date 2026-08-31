extends StaticBody2D
class_name NPC

@export var npc_id: String = "npc"
@export var display_name: String = "NPC"
@export var relationship_gain_on_talk: int = 0
@export var dialogue_pages: Array[String] = []

func _ready() -> void:
    add_to_group("npcs")
    queue_redraw()

func get_relationship_manager():
    return get_tree().get_first_node_in_group("relationship_manager")

func get_relationship() -> int:
    var manager = get_relationship_manager()
    if manager == null:
        return 0
    return manager.get_relationship(npc_id)

func get_relationship_level() -> int:
    var manager = get_relationship_manager()
    if manager == null:
        return 0
    return manager.get_relationship_level(npc_id)

func get_relationship_title() -> String:
    var manager = get_relationship_manager()
    if manager == null:
        return "Незнакомец"
    return manager.get_relationship_title(npc_id)

func change_relationship(amount: int) -> int:
    var manager = get_relationship_manager()
    if manager == null:
        return 0
    return manager.change_relationship(npc_id, amount)

func interact(hud) -> void:
    if relationship_gain_on_talk != 0:
        change_relationship(relationship_gain_on_talk)
    hud.start_dialogue(display_name, dialogue_pages)

func _draw() -> void:
    # Generic placeholder. Individual NPC scripts can override this later.
    draw_circle(Vector2(0, -22), 11, Color("#2b211d"))
    draw_circle(Vector2(0, -17), 10, Color("#d49a6a"))
    draw_rect(Rect2(-13, -7, 26, 35), Color("#5b4a72"), true)
    draw_rect(Rect2(-13, -7, 26, 35), Color("#2b211d"), false, 2.0)
    draw_line(Vector2(-7, 28), Vector2(-7, 39), Color("#47362a"), 5.0)
    draw_line(Vector2(7, 28), Vector2(7, 39), Color("#47362a"), 5.0)
