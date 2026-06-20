extends CharacterBody2D

const SPEED = 100.0

@onready var gen: AnimatedSprite2D = $gen
@onready var row: AnimatedSprite2D = $row
@onready var fishbucket: Node2D = $fishbucket

var gravity_enabled := false
var hook_out := false
var is_busy := false

func _ready() -> void:
	#await get_tree().create_timer(1.0).timeout
	#die()
	fishbucket.has_big_bucket = true
	await get_tree().create_timer(1.0).timeout
	fishbucket.has_fish = true
	

	gen.visible = true
	row.visible = false


func _physics_process(delta: float) -> void:

	if gravity_enabled:
		velocity += get_gravity() * delta

	var direction := Input.get_axis("ui_left", "ui_right")

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


func die():

	is_busy = true
	velocity.x = 0

	row.visible = false
	gen.visible = true

	gen.play("death")

	await get_tree().create_timer(0.6).timeout

	gravity_enabled = true
