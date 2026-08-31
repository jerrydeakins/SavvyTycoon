extends CharacterBody2D

@export var speed: float = 180.0
@export var interaction_radius: float = 72.0

var current_plot = null
var current_sell_point = null
var current_mentor = null
var upgrade_plot = null
var selected_crop: String = "Морковь"

const STATE_EMPTY: int = 0
const STATE_PLANTED: int = 1
const STATE_GROWING: int = 2
const STATE_READY: int = 3
const STATE_SPOILED: int = 4

func _physics_process(_delta: float) -> void:
    var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_vector * speed
    move_and_slide()

    current_plot = _get_nearest_plot()
    current_sell_point = _get_nearest_sell_point()
    current_mentor = _get_nearest_mentor()
    upgrade_plot = current_plot

    if Input.is_action_just_pressed("upgrade") and current_plot != null:
        _upgrade_current_plot(current_plot)
        return

    if Input.is_action_just_pressed("interact"):
        if _is_closest_interactable(current_mentor):
            current_mentor.interact(get_node("../HUD"))
        elif _is_closest_interactable(current_sell_point):
            _sell_at_point(current_sell_point)
        else:
            _interact_with_plot(current_plot)

func _get_nearest_plot():
    var nearest = null
    var nearest_distance: float = interaction_radius

    for node in get_tree().get_nodes_in_group("farm_plots"):
        if not is_instance_valid(node):
            continue
        var distance: float = global_position.distance_to(node.global_position)
        if distance <= nearest_distance:
            nearest = node
            nearest_distance = distance

    return nearest

func _get_nearest_sell_point():
    var nearest = null
    var nearest_distance: float = interaction_radius

    for node in get_tree().get_nodes_in_group("sell_points"):
        if not is_instance_valid(node):
            continue
        var distance: float = global_position.distance_to(node.global_position)
        if distance <= nearest_distance:
            nearest = node
            nearest_distance = distance

    return nearest

func _get_nearest_mentor():
    var nearest = null
    var nearest_distance: float = interaction_radius

    for node in get_tree().get_nodes_in_group("mentor_npcs"):
        if not is_instance_valid(node):
            continue
        var distance: float = global_position.distance_to(node.global_position)
        if distance <= nearest_distance:
            nearest = node
            nearest_distance = distance

    return nearest

func _is_closest_interactable(target) -> bool:
    if target == null:
        return false

    var target_distance: float = global_position.distance_to(target.global_position)
    for other in [current_plot, current_sell_point, current_mentor]:
        if other != null and other != target and global_position.distance_to(other.global_position) < target_distance:
            return false
    return true

func _sell_at_point(point) -> void:
    var gm = get_node("../GameManager")
    var hud = get_node("../HUD")

    if gm.storage_used <= 0:
        hud.show_message("На складе нет моркови")
        return

    var sale: Dictionary = point.sell_all()
    hud.show_message("Продано: %d шт. • +$%d" % [int(sale["quantity"]), int(sale["revenue"])])

func select_crop(crop_name: String) -> void:
    var gm = get_node("../GameManager")
    if gm.get_crop_data(crop_name).is_empty():
        return
    selected_crop = crop_name

func _interact_with_plot(plot) -> void:
    if plot == null:
        return

    var gm = get_node("../GameManager")
    var hud = get_node("../HUD")

    match plot.state:
        STATE_EMPTY:
            var crop_data: Dictionary = gm.get_crop_data(selected_crop)
            var seed_cost: int = int(crop_data.get("seed_cost", 5))
            if gm.spend_money(seed_cost) and plot.plant(selected_crop):
                hud.show_message("Посажено: %s (-$%d)" % [selected_crop, seed_cost])
            else:
                hud.show_message("Недостаточно денег на семена")

        STATE_PLANTED:
            if plot.water():
                hud.show_message("Грядка полита")

        STATE_GROWING:
            if plot.water():
                hud.show_message("Грядка полита")
            else:
                hud.show_message("Морковь растёт")

        STATE_READY:
            var quantity: int = plot.crop_yield
            if quantity <= 0:
                return
            if gm.storage_used + quantity > gm.storage_capacity:
                # Check capacity before harvesting so the crop is never destroyed.
                hud.show_message("Склад заполнен — нужно продать урожай")
                return

            var crop_name: String = plot.crop_name
            var harvested: int = plot.harvest()
            if gm.add_to_storage(crop_name, harvested):
                hud.show_message("Собрано: %s ×%d" % [crop_name, harvested])

        STATE_SPOILED:
            if plot.clear_spoiled():
                hud.show_message("Испорченный урожай убран")

func _upgrade_current_plot(plot) -> void:
    var gm = get_node("../GameManager")
    var hud = get_node("../HUD")

    if not gm.can_upgrade_plot(plot.upgrade_level):
        hud.show_message("У грядки максимальный уровень")
        return

    var next_data: Dictionary = gm.get_next_upgrade_data(plot.upgrade_level)
    var cost: int = int(next_data.get("cost", 0))
    if gm.upgrade_plot(plot):
        hud.show_message("Грядка улучшена до уровня %d (-$%d)" % [plot.upgrade_level, cost])
    else:
        hud.show_message("Недостаточно денег для улучшения: $%d" % cost)
