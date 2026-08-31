extends CanvasLayer

@onready var money_label: Label = $Panel/Margin/VBox/Money
@onready var day_label: Label = $Panel/Margin/VBox/Day
@onready var time_label: Label = $Panel/Margin/VBox/Time
@onready var storage_label: Label = $Panel/Margin/VBox/Storage
@onready var inventory_label: Label = $Panel/Margin/VBox/Inventory
@onready var prompt_label: Label = $Prompt
@onready var message_label: Label = $Message
@onready var next_day_button: Button = $NextDay
@onready var emergency_button: Button = $EmergencyFunds
@onready var upgrade_label: Label = $UpgradeInfo
@onready var carrot_button: Button = $Carrot
@onready var potato_button: Button = $Potato
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var dialogue_title: Label = $DialoguePanel/Margin/VBox/Title
@onready var dialogue_text: Label = $DialoguePanel/Margin/VBox/Text
@onready var dialogue_continue_button: Button = $DialoguePanel/Margin/VBox/Actions/Continue
@onready var dialogue_close_button: Button = $DialoguePanel/Margin/VBox/Actions/Close

const STATE_EMPTY: int = 0
const STATE_PLANTED: int = 1
const STATE_GROWING: int = 2
const STATE_READY: int = 3
const STATE_SPOILED: int = 4

var message_time: float = 0.0
var dialogue_pages: Array[String] = []
var dialogue_page_index: int = 0
var dialogue_speaker: String = ""

func _ready() -> void:
    next_day_button.pressed.connect(_on_next_day_pressed)
    emergency_button.pressed.connect(_on_emergency_funds_pressed)
    carrot_button.pressed.connect(_on_crop_selected.bind("Морковь"))
    potato_button.pressed.connect(_on_crop_selected.bind("Картофель"))
    dialogue_continue_button.pressed.connect(_on_dialogue_continue_pressed)
    dialogue_close_button.pressed.connect(_on_dialogue_close_pressed)

func _process(delta: float) -> void:
    var gm = get_node("../GameManager")
    var time_manager = get_node("../TimeManager")
    var player = get_node("../Player")

    money_label.text = "Деньги: %d" % gm.money
    day_label.text = "День: %d" % gm.day
    time_label.text = "Время: %s" % time_manager.get_clock_text()
    storage_label.text = "Склад: %d/%d" % [gm.storage_used, gm.storage_capacity]
    inventory_label.text = "Морковь: %d  •  Картофель: %d" % [gm.get_crop_quantity("Морковь"), gm.get_crop_quantity("Картофель")]
    carrot_button.text = "✓ Морковь" if player.selected_crop == "Морковь" else "Морковь"
    potato_button.text = "✓ Картофель" if player.selected_crop == "Картофель" else "Картофель"

    # At $0 the player may continue to the next day and wait for existing crops.
    # The one-time emergency grant is a separate safety net for a cash-flow dead end.
    emergency_button.visible = gm.can_claim_emergency_funds()
    next_day_button.visible = time_manager.debug_controls_enabled

    message_time -= delta
    if message_time <= 0.0:
        message_label.visible = false

    var plot = player.current_plot
    var sell_point = player.current_sell_point
    var mentor = player.current_mentor
    upgrade_label.visible = false

    if mentor != null and player._is_closest_interactable(mentor):
        prompt_label.visible = true
        prompt_label.text = "E  Поговорить с Эльс"
        return

    if sell_point != null and (plot == null or player.global_position.distance_to(sell_point.global_position) < player.global_position.distance_to(plot.global_position)):
        prompt_label.visible = true
        if gm.storage_used > 0:
            prompt_label.text = "E  Продать весь урожай  •  %d шт." % gm.storage_used
        else:
            prompt_label.text = "Склад пуст"
        return

    if plot == null:
        prompt_label.visible = false
        return

    prompt_label.visible = true
    upgrade_label.visible = true
    upgrade_label.text = "U  Улучшение грядки\n" + plot.get_upgrade_description()

    match plot.state:
        STATE_EMPTY:
            var crop_data: Dictionary = gm.get_crop_data(player.selected_crop)
            var seed_cost: int = int(crop_data.get("seed_cost", 5))
            prompt_label.text = "E  Посадить %s  •  $%d" % [player.selected_crop, seed_cost]
        STATE_PLANTED:
            prompt_label.text = "E  Полить грядку"
        STATE_GROWING:
            if plot.watered:
                var required_days: int = int(gm.get_upgrade_data(plot.upgrade_level).get("growth_days", 2))
                prompt_label.text = "Грядка полита  •  %d/%d дней" % [plot.growth_day, required_days]
            else:
                var required_days: int = int(gm.get_upgrade_data(plot.upgrade_level).get("growth_days", 2))
                prompt_label.text = "E  Полить грядку  •  рост %d/%d" % [plot.growth_day, required_days]
        STATE_READY:
            var days_left: int = plot.get_harvest_window_days() - plot.ready_days
            if days_left <= 1:
                prompt_label.text = "E  Собрать %s  •  ×%d  •  испортится завтра" % [plot.crop_name, plot.crop_yield]
            else:
                prompt_label.text = "E  Собрать %s  •  ×%d" % [plot.crop_name, plot.crop_yield]
        STATE_SPOILED:
            prompt_label.text = "E  Убрать испорченный урожай"

func _on_next_day_pressed() -> void:
    get_node("../TimeManager").advance_day()
    show_message("Наступил день %d" % get_node("../TimeManager").day)

func _on_emergency_funds_pressed() -> void:
    var gm = get_node("../GameManager")
    if gm.claim_emergency_funds():
        emergency_button.visible = false
        show_message("Аварийная помощь: +$%d" % gm.EMERGENCY_FUNDS)

func _on_crop_selected(crop_name: String) -> void:
    get_node("../Player").select_crop(crop_name)

func start_dialogue(title: String, pages: Array[String]) -> void:
    if pages.is_empty():
        return
    dialogue_speaker = title
    dialogue_pages = pages
    dialogue_page_index = 0
    get_node("../TimeManager").set_clock_paused(true)
    dialogue_panel.visible = true
    _show_current_dialogue_page()

func _show_current_dialogue_page() -> void:
    var page_count: int = dialogue_pages.size()
    dialogue_title.text = "%s  •  %d/%d" % [dialogue_speaker, dialogue_page_index + 1, page_count]
    dialogue_text.text = dialogue_pages[dialogue_page_index]
    dialogue_continue_button.text = "Закончить" if dialogue_page_index == page_count - 1 else "Продолжить"

func _on_dialogue_continue_pressed() -> void:
    if dialogue_page_index >= dialogue_pages.size() - 1:
        _close_dialogue()
        return
    dialogue_page_index += 1
    _show_current_dialogue_page()

func _on_dialogue_close_pressed() -> void:
    _close_dialogue()

func _close_dialogue() -> void:
    dialogue_panel.visible = false
    dialogue_pages.clear()
    dialogue_page_index = 0
    get_node("../TimeManager").set_clock_paused(false)

func show_message(text: String) -> void:
    message_label.text = text
    message_label.visible = true
    message_time = 2.0
