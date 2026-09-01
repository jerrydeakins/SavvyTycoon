extends Control

@onready var title_label: Label = $Center/Panel/Margin/VBox/Title
@onready var speaker_label: Label = $Center/Panel/Margin/VBox/Speaker
@onready var reward_label: Label = $Center/Panel/Margin/VBox/Reward
@onready var relationship_label: Label = $Center/Panel/Margin/VBox/Relationship
@onready var level_label: Label = $Center/Panel/Margin/VBox/Level
@onready var close_button: Button = $Center/Panel/Margin/VBox/Close
@onready var effects: Control = $Effects

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false
    close_button.pressed.connect(_on_close_pressed)

func show_result(speaker: String, reward: int, relationship_change: int, new_relationship: int, relationship_title: String, level_up: bool) -> void:
    speaker_label.text = speaker
    reward_label.text = "+$%d" % reward
    relationship_label.text = "Отношение  +%d    →    %d/100" % [relationship_change, new_relationship]
    level_label.text = "★ Новый уровень: %s" % relationship_title
    level_label.visible = level_up
    title_label.text = "ЗАКАЗ ВЫПОЛНЕН!"

    visible = true
    modulate = Color(1, 1, 1, 0)
    scale = Vector2(0.92, 0.92)

    var time_manager = get_node_or_null("../../TimeManager")
    if time_manager != null:
        time_manager.set_clock_paused(true)

    var tween := create_tween().set_parallel(true)
    tween.tween_property(self, "modulate", Color.WHITE, 0.2)
    tween.tween_property(self, "scale", Vector2.ONE, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    effects.play()
    close_button.grab_focus()

func _on_close_pressed() -> void:
    var time_manager = get_node_or_null("../../TimeManager")
    if time_manager != null:
        time_manager.set_clock_paused(false)
    visible = false

func _unhandled_key_input(event: InputEvent) -> void:
    if not visible or not event.pressed:
        return
    if event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
        _on_close_pressed()
        get_viewport().set_input_as_handled()
