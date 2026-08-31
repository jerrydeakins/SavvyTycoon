extends Node
class_name RelationshipManager

# Shared relationship state for all ordinary NPCs.
# Values are intentionally kept as plain data so dialogue/orders can be moved
# to data resources later without changing the relationship API.

const MIN_RELATIONSHIP: int = 0
const MAX_RELATIONSHIP: int = 100

var relationships: Dictionary = {}

func get_relationship(npc_id: String) -> int:
    return clampi(int(relationships.get(npc_id, 0)), MIN_RELATIONSHIP, MAX_RELATIONSHIP)

func change_relationship(npc_id: String, amount: int) -> int:
    var value: int = clampi(get_relationship(npc_id) + amount, MIN_RELATIONSHIP, MAX_RELATIONSHIP)
    relationships[npc_id] = value
    return value

func set_relationship(npc_id: String, value: int) -> int:
    var clamped: int = clampi(value, MIN_RELATIONSHIP, MAX_RELATIONSHIP)
    relationships[npc_id] = clamped
    return clamped

func get_relationship_level(npc_id: String) -> int:
    var value := get_relationship(npc_id)
    if value < 20:
        return 0
    if value < 40:
        return 1
    if value < 60:
        return 2
    if value < 80:
        return 3
    return 4

func get_relationship_title(npc_id: String) -> String:
    match get_relationship_level(npc_id):
        0: return "Незнакомец"
        1: return "Знакомый"
        2: return "Доверие"
        3: return "Партнёр"
        4: return "Надёжный партнёр"
    return "Незнакомец"
