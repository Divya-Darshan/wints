extends CharacterBody2D

const SPEED = 100.0

@onready var chest: Sprite2D = $Chest
@onready var gen: AnimatedSprite2D = $gen
@onready var row: AnimatedSprite2D = $row
@onready var fishbucket: Node2D = $fishbucket
@onready var health: AnimatedSprite2D = $health
@onready var pannal: Node2D = $"../Area2D/Node2D"
@onready var color_rect: ColorRect = $"../CanvasLayer/ColorRect"

var gravity_enabled := false
var hook_out := false
var is_busy := false
var health_lev := 3

var turtles_caught := 0

var has_big_bucket := false
var has_chest := false

var bucket_capacity := 5

func player():
	pass


func _ready() -> void:

	color_rect.modulate.a = 0.0

	pannal.visible = false

	chest.visible = false

	fishbucket.has_big_bucket = false
	fishbucket.has_fish = false

	gen.visible = true
	row.visible = false


func _physics_process(delta: float) -> void:

	if gravity_enabled:
		velocity += get_gravity() * delta

	var direction := Input.get_axis("a", "d")

	if direction:

		velocity.x = direction * SPEED

		if not is_busy:

			gen.visible = false
			row.visible = true

			row.play("row")

			if direction < 0:
				row.flip_h = true
			else:
				row.flip_h = false

	else:

		velocity.x = move_toward(velocity.x, 0, SPEED)

		if not is_busy:
			row.visible = false
			gen.visible = true

	if Input.is_action_just_pressed("fish"):
		use_hook()

	move_and_slide()


func use_hook():

	if is_busy:
		return

	is_busy = true

	row.visible = false
	gen.visible = true

	if hook_out:
		hook_out = false
		gen.play("fish")
	else:
		hook_out = true
		gen.play("sfish")

	await gen.animation_finished

	is_busy = false


func heath_update():

	health.play(str(health_lev))
	health_lev -= 1

	if health_lev == -1:

		$"../boder/wall".queue_free()

		die()


func die():

	is_busy = true
	velocity.x = 0

	row.visible = false
	gen.visible = true

	gen.play("death")

	await get_tree().create_timer(1.0).timeout

	gravity_enabled = true

	# Let boat sink
	await get_tree().create_timer(2.0).timeout

	# Fade to black
	var tween = create_tween()

	tween.tween_property(
		color_rect,
		"modulate:a",
		1.0,
		1.5
	)

	await tween.finished

	await get_tree().create_timer(0.5).timeout

	get_tree().reload_current_scene()


func add_turtle():

	if turtles_caught >= bucket_capacity:
		print("Bucket Full")
		return

	turtles_caught += 1

	print("Turtles Caught:", turtles_caught)

	fishbucket.has_fish = true

	if fishbucket.has_method("bounce_bucket"):
		fishbucket.bounce_bucket()

	# Upgrade to big bucket automatically
	if turtles_caught >= 5 and !has_big_bucket:

		has_big_bucket = true
		bucket_capacity = 10

		fishbucket.has_big_bucket = true

		print("BIG BUCKET UNLOCKED")

	# Unlock chest automatically
	if turtles_caught >= 15 and !has_chest:

		has_chest = true

		chest.visible = true

		print("CHEST UNLOCKED")


func _on_area_2d_body_entered(body: Node2D) -> void:

	if body.has_method("player"):

		pannal.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:

	if body.has_method("player"):

		pannal.visible = false
