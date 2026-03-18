extends CharacterBody2D

const SPEED = 200.0
const SMOOTH = 10.0

@onready var anim = $AnimatedSprite2D

@onready var audio = $walk
var footstep_timer = 0.0
var footstep_interval = 0.75  # seconds between each step

var current_direction = Vector2.ZERO
var last_direction = Vector2.DOWN  # default facing direction

func _physics_process(delta):
	var direction = Vector2.ZERO
	if get_tree().paused:
		return  # 👈 stop processing if paused
		
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	
	if direction != Vector2.ZERO:
		footstep_timer -= delta
		if footstep_timer <= 0:
			audio.play()
			footstep_timer = footstep_interval
	else:
		footstep_timer = 0  # reset when not moving

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		last_direction = direction

	current_direction = current_direction.lerp(direction, SMOOTH * delta)

	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		_update_animation(current_direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		_play_idle(last_direction)

	move_and_slide()

func _update_animation(direction: Vector2):
	var threshold = 0.5
	if direction.y < -threshold and direction.x > threshold:
		anim.flip_h = false
		anim.play("walk-rightUp")
	elif direction.y < -threshold and direction.x < -threshold:
		anim.flip_h = true
		anim.play("walk-rightUp")
	elif direction.y > threshold and direction.x > threshold:
		anim.flip_h = false
		anim.play("walk-rightDown")
	elif direction.y > threshold and direction.x < -threshold:
		anim.flip_h = true
		anim.play("walk-rightDown")
	elif direction.x > threshold:
		anim.flip_h = false
		anim.play("walk-right")
	elif direction.x < -threshold:
		anim.flip_h = true
		anim.play("walk-right")
	elif direction.y < -threshold:
		anim.flip_h = false
		anim.play("walk-Up")
	elif direction.y > threshold:
		anim.flip_h = false
		anim.play("walk-Down")

func _play_idle(direction: Vector2):
	var threshold = 0.5
	if direction.y < -threshold and direction.x > threshold:
		anim.flip_h = false
		anim.play("idle_up_right")
	elif direction.y < -threshold and direction.x < -threshold:
		anim.flip_h = true
		anim.play("idle_up_right")
	elif direction.y > threshold and direction.x > threshold:
		anim.flip_h = false
		anim.play("idle_down_right")
	elif direction.y > threshold and direction.x < -threshold:
		anim.flip_h = true
		anim.play("idle_down_right")
	elif direction.x > threshold:
		anim.flip_h = false
		anim.play("idle_right")
	elif direction.x < -threshold:
		anim.flip_h = true
		anim.play("idle_right")
	elif direction.y < -threshold:
		anim.flip_h = false
		anim.play("idle_up")
	elif direction.y > threshold:
		anim.flip_h = false
		anim.play("idle_down")
