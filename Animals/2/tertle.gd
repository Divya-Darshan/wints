extends CharacterBody2D

const SPEED := 200.0
var dir := 1

var dragging := false

@onready var rayright: RayCast2D = $Rayright
@onready var rayleft: RayCast2D = $Rayleft
@onready var gen: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:

	# Drag turtle with right mouse button
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):

		if global_position.distance_to(get_global_mouse_position()) < 50:
			dragging = true

	else:
		dragging = false

	if dragging:
		global_position = get_global_mouse_position()
		return

	# Normal movement
	if rayright.is_colliding():
		dir = -1
		gen.flip_h = true

	if rayleft.is_colliding():
		dir = 1
		gen.flip_h = false

	position.x += dir * SPEED * delta

func _on_area_2d_body_entered(body: Node2D) -> void:

	if body.has_method("player"):

		set_physics_process(false)

		var tween = create_tween()

		tween.parallel().tween_property(
			self,
			"global_position",
			body.global_position,
			0.3
		)

		tween.parallel().tween_property(
			self,
			"scale",
			Vector2.ZERO,
			0.3
		)

		await tween.finished

		body.add_turtle()

		queue_free()
