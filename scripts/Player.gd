extends Area2D

signal hit

export var speed = 200
export var heart = 3
var screen_size
var velocity = Vector2()

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _input(event):
	var target = Vector2()
	
	if event is InputEventScreenTouch and event.pressed:
		target = event.position - position
	elif event is InputEventScreenDrag:
		target = event.position + event.relative - position
	elif event is InputEventKey:
		if Input.is_action_pressed("ui_right"):
			target.x += 1
		if Input.is_action_pressed("ui_left"):
			target.x -= 1
		if Input.is_action_pressed("ui_down"):
			target.y += 1
		if Input.is_action_pressed("ui_up"):
			target.y -= 1
	
	velocity = target

func _process(delta):
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

func _on_Player_body_entered(_body):
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
