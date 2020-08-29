extends RigidBody2D

export var min_speed = 150
export var max_speed = 250

func _ready():
	var mob_type = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_type[randi() % mob_type.size()]
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
