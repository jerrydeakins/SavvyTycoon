extends Node
class_name OrderManager

signal order_created(order)
signal order_completed(order)
signal order_failed(order)

var active_orders: Array[Dictionary] = []
var next_order_id: int = 1
var npc_cooldowns: Dictionary = {}

func _ready() -> void:
    add_to_group("order_manager")

func _get_relationship_manager():
    # RelationshipManager is a sibling in Main. Prefer the direct node so the
    # order result cannot silently fail because a group was not registered.
    var manager = get_node_or_null("../RelationshipManager")
    if manager != null:
        return manager
    return get_tree().get_first_node_in_group("relationship_manager")

func create_order(npc_id: String, crop_name: String, quantity: int, reward: int, days_left: int) -> Dictionary:
    if is_npc_on_cooldown(npc_id):
        return {}
    var order := {"id": next_order_id, "npc_id": npc_id, "crop_name": crop_name, "quantity": quantity, "reward": reward, "days_left": days_left, "status": "active"}
    next_order_id += 1
    active_orders.append(order)
    order_created.emit(order)
    return order

func get_active_order(npc_id: String) -> Dictionary:
    for order in active_orders:
        if order.get("npc_id", "") == npc_id and order.get("status", "") == "active":
            return order
    return {}

func has_active_order(npc_id: String) -> bool:
    return not get_active_order(npc_id).is_empty()

func is_npc_on_cooldown(npc_id: String) -> bool:
    return int(npc_cooldowns.get(npc_id, 0)) > 0

func complete_order(npc_id: String, crop_name: String, quantity: int) -> Dictionary:
    for order in active_orders:
        if order.get("npc_id", "") != npc_id or order.get("status", "") != "active":
            continue
        if order.get("crop_name", "") != crop_name or int(order.get("quantity", 0)) != quantity:
            return {}

        order["status"] = "completed"
        active_orders.erase(order)
        npc_cooldowns[npc_id] = 1

        var relationship_manager = _get_relationship_manager()
        var relationship_after: int = 0
        if relationship_manager != null:
            relationship_after = relationship_manager.change_relationship(npc_id, 20)
        else:
            push_error("OrderManager: RelationshipManager not found; relationship was not updated for " + npc_id)

        order["relationship_change"] = 20
        order["relationship_after"] = relationship_after
        order_completed.emit(order)
        return order
    return {}

func advance_day() -> void:
    for npc_id in npc_cooldowns.keys():
        npc_cooldowns[npc_id] = max(0, int(npc_cooldowns[npc_id]) - 1)

    var expired: Array[Dictionary] = []
    for order in active_orders:
        order["days_left"] = int(order.get("days_left", 0)) - 1
        if int(order["days_left"]) <= 0:
            expired.append(order)

    for order in expired:
        order["status"] = "failed"
        active_orders.erase(order)
        var relationship_manager = _get_relationship_manager()
        if relationship_manager != null:
            var relationship_after: int = relationship_manager.change_relationship(str(order.get("npc_id", "")), -10)
            order["relationship_change"] = -10
            order["relationship_after"] = relationship_after
        else:
            push_error("OrderManager: RelationshipManager not found; relationship was not updated for failed order")
        var hud = get_node_or_null("../HUD")
        if hud != null:
            hud.show_message("Заказ просрочен: %s ×%d" % [str(order.get("crop_name", "")), int(order.get("quantity", 0))])
        npc_cooldowns[str(order.get("npc_id", ""))] = 1
        order_failed.emit(order)

func get_order_text(order: Dictionary) -> String:
    return "Заказ: %s ×%d\nНаграда: $%d\nОсталось дней: %d" % [str(order.get("crop_name", "")), int(order.get("quantity", 0)), int(order.get("reward", 0)), int(order.get("days_left", 0))]
