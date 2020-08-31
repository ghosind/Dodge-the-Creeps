extends RigidBody2D

export var speed = 0

const MIN_SPEED = 150
const MAX_SPEED = 250

func _ready():
	var mob_type = $AnimatedSprite.frames.get_animation_names()
	var type = randi() % mob_type.size()
	var speed_type = type
	
	$AnimatedSprite.animation = mob_type[type]
	speed = MIN_SPEED + (MAX_SPEED - MIN_SPEED) / mob_type.size() * speed_type
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _process(_delta):
	$AnimatedSprite.play()
