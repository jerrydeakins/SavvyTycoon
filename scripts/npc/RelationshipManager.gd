extends Node
class_name RelationshipManager

# Compatibility facade for NPC relationship access.
# The actual runtime state lives in GameManager so every system uses one
# authoritative state store.

func _get_game_manager():
    return get_node_or_null("../GameManager")

func get_relationship(npc_id: String) -> int:
    var gm = _get_game_manager()
    if gm == null:
        push_error("RelationshipManager: GameManager not found")
        return 0
    return gm.get_relationship(npc_id)

func change_relationship(npc_id: String, amount: int) -> int:
    var gm = _get_game_manager()
    if gm == null:
        push_error("RelationshipManager: GameManager not found")
        return 0
    return gm.change_relationship(npc_id, amount)

func set_relationship(npc_id: String, value: int) -> int:
    var gm = _get_game_manager()
    if gm == null:
        push_error("RelationshipManager: GameManager not found")
        return 0
    return gm.set_relationship(npc_id, value)

func get_relationship_level(npc_id: String) -> int:
    var gm = _get_game_manager()
    if gm == null:
        return 0
    return gm.get_relationship_level(npc_id)

func get_relationship_title(npc_id: String) -> String:
    var gm = _get_game_manager()
    if gm == null:
        return "Незнакомец"
    return gm.get_relationship_title(npc_id)
