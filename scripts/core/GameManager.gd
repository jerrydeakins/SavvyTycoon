extends Node

# Central economy/state layer. Crop and upgrade data live here so future
# continents can reuse the same rules with different content packs.

var money: int = 150
var day: int = 1
var season: int = 1
var storage_used: int = 0
var storage_capacity: int = 20
var inventory: Dictionary = {}

const EMERGENCY_FUNDS: int = 10
var emergency_funds_claimed: bool = false

const CROPS := {
    "Морковь": {"seed_cost": 5, "sell_price": 8, "growth_days": 2, "harvest_window_days": 2, "base_yield": 1},
    "Картофель": {"seed_cost": 15, "sell_price": 10, "growth_days": 3, "harvest_window_days": 4, "base_yield": 2}
}

const PLOT_UPGRADES := {
    1: {"cost": 0, "growth_reduction_days": 0, "yield_multiplier": 1, "name": "Базовая грядка"},
    2: {"cost": 30, "growth_reduction_days": 0, "yield_multiplier": 2, "name": "Улучшенная почва"},
    3: {"cost": 60, "growth_reduction_days": 1, "yield_multiplier": 2, "name": "Плодородная почва"},
    4: {"cost": 120, "growth_reduction_days": 1, "yield_multiplier": 3, "name": "Премиальная грядка"}
}

func add_money(amount: int) -> void:
    money += amount

func can_claim_emergency_funds() -> bool:
    return money <= 0 and not emergency_funds_claimed

func claim_emergency_funds() -> bool:
    if not can_claim_emergency_funds():
        return false
    emergency_funds_claimed = true
    money += EMERGENCY_FUNDS
    return true

func spend_money(amount: int) -> bool:
    if amount > money:
        return false
    money -= amount
    return true

func get_crop_data(crop_name: String) -> Dictionary:
    return CROPS.get(crop_name, {})

func get_upgrade_data(level: int) -> Dictionary:
    return PLOT_UPGRADES.get(level, {})

func get_next_upgrade_data(level: int) -> Dictionary:
    return PLOT_UPGRADES.get(level + 1, {})

func can_upgrade_plot(level: int) -> bool:
    return level < PLOT_UPGRADES.size()

func upgrade_plot(plot) -> bool:
    if plot == null or not can_upgrade_plot(plot.upgrade_level):
        return false
    var next_level: int = plot.upgrade_level + 1
    var data: Dictionary = get_upgrade_data(next_level)
    var cost: int = int(data.get("cost", 0))
    if not spend_money(cost):
        return false
    plot.upgrade_level = next_level
    plot.queue_redraw()
    return true

func get_crop_value(crop_name: String, quantity: int) -> int:
    var crop_data := get_crop_data(crop_name)
    return int(crop_data.get("sell_price", 0)) * quantity

func add_to_storage(crop_name: String, quantity: int) -> bool:
    if quantity <= 0 or storage_used + quantity > storage_capacity:
        return false
    inventory[crop_name] = get_crop_quantity(crop_name) + quantity
    storage_used += quantity
    return true

func get_crop_quantity(crop_name: String) -> int:
    return int(inventory.get(crop_name, 0))

func remove_from_storage(crop_name: String, quantity: int) -> bool:
    if quantity <= 0 or get_crop_quantity(crop_name) < quantity:
        return false
    var remaining: int = get_crop_quantity(crop_name) - quantity
    if remaining == 0:
        inventory.erase(crop_name)
    else:
        inventory[crop_name] = remaining
    storage_used -= quantity
    return true

func sell_all_inventory() -> Dictionary:
    if storage_used <= 0:
        return {"quantity": 0, "revenue": 0}
    var sold_quantity := 0
    var revenue := 0
    for crop_name in inventory.keys():
        var quantity := get_crop_quantity(crop_name)
        sold_quantity += quantity
        revenue += get_crop_value(crop_name, quantity)
    inventory.clear()
    storage_used = 0
    add_money(revenue)
    return {"quantity": sold_quantity, "revenue": revenue}
