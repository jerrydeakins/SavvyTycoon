extends Node

signal day_changed(day: int)

# 0.44 game minutes/sec makes the 06:00–18:00 workday last about 27 minutes.
@export var minutes_per_real_second: float = 0.44
@export var workday_start_minutes: float = 360.0
@export var workday_end_minutes: float = 1080.0
@export var debug_controls_enabled: bool = true

var day: int = 1
var season: int = 1
var game_minutes: float = 360.0
var clock_paused: bool = false

func _ready() -> void:
    var gm = get_node("../GameManager")
    day = gm.day

func _process(delta: float) -> void:
    if clock_paused:
        return

    game_minutes += delta * minutes_per_real_second
    if game_minutes >= workday_end_minutes:
        advance_day()

func advance_day() -> void:
    day += 1
    game_minutes = workday_start_minutes
    var gm = get_node("../GameManager")
    gm.day = day
    day_changed.emit(day)
    _process_farm_growth()

func _process_farm_growth() -> void:
    var plots = get_tree().get_nodes_in_group("farm_plots")
    for plot in plots:
        if not is_instance_valid(plot):
            continue
        plot.advance_growth_day()

func set_clock_paused(value: bool) -> void:
    clock_paused = value

func get_clock_text() -> String:
    var total_minutes: int = int(game_minutes)
    var hours: int = total_minutes / 60
    var minutes: int = total_minutes % 60
    return "%02d:%02d" % [hours, minutes]
