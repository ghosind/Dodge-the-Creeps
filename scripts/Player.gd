extends Area2D

signal hit

export var speed = 200
export var heart = 3
var screen_size
var velocity = Vector2()
var is_touch = false
var target_position

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _input(event):
	var target = Vector2()
	
	if event is InputEventScreenTouch and event.pressed:
		is_touch = true
		if position.distance_to(event.position) > 10:
			target = event.position - position
			target_position = event.position
	elif event is InputEventScreenDrag:
		is_touch = true
		if position.distance_to(event.position + event.relative) > 10:
			target = event.position + event.relative - position
			target_position = event.position + event.relative
	elif event is InputEventKey:
		is_touch = false
		if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
			target.x += 1
		if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
			target.x -= 1
		if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
			target.y += 1
		if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
			target.y -= 1

	velocity = target

func _process(delta):
	print_debug("position: ", position, ", target: ", target_position)
	if is_touch and position.distance_to(target_position) < 10:
		return

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x > 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0

func _on_Player_body_entered(body):
	body.queue_free()
	heart -= 1
	
	if heart == 0:
		hide()
		
		$CollisionShape2D.set_deferred("disabled", true)
	
	emit_signal("hit")

func start(pos):
	position = pos
	heart = 3
	
	show()
	
	$CollisionShape2D.set_deferred("disabled", false)
