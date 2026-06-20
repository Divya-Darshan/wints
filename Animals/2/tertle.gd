extends CharacterBody2D

const SPEED := 1.0
var dir := 1

@onready var rayright: RayCast2D = $Rayright
@onready var rayleft: RayCast2D = $Rayleft
@onready var gen: AnimatedSprite2D = $AnimatedSprite2D

@export var mutation_time := 0.1
@export var growth_amount := 0.1
@export var max_scale := 8.0

var player: Node2D = null

func _ready() -> void:
	mutation_loop()

func _physics_process(delta: float) -> void:

	if player:
		position = position.move_toward(player.position, 100 * delta)
		return

	if rayright.is_colliding():
		gen.flip_h = !gen.flip_h
		dir = -1

	if rayleft.is_colliding():
		gen.flip_h = !gen.flip_h
		dir = 1

	position.x += dir * SPEED * delta


func mutation_loop() -> void:

	while true:

		await get_tree().create_timer(mutation_time).timeout

		if scale.x < max_scale:
			scale += Vector2(growth_amount, growth_amount)

			if scale.x > max_scale:
				scale = Vector2(max_scale, max_scale)


func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
