extends Sprite2D

@export var sway_distance: float = 3.0
@export var sway_speed: float = 0.5

var start_x: float
var time_passed: float = 0.0

func _ready() -> void:
	start_x = position.x

func _process(delta: float) -> void:
	time_passed += delta
	position.x = start_x + sin(time_passed * sway_speed) * sway_distance
