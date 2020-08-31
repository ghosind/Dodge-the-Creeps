extends Node

export (PackedScene) var Mob

const MAX_TIME = 1.5
const MIN_TIME = 0.5

var level
var highest
var score

func _ready():
	randomize()
	
	highest = 0

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	
	$HUD.show_game_over()
	
	if score > highest:
		highest = score
		$HUD.update_highest_score(highest)
	
	get_tree().call_group("mobs", "queue_free")
	
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	level = 1
	$MobTimer.wait_time = MAX_TIME
	
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$HUD.update_heart($Player.heart)
	
	$Music.play()

func _on_MobTimer_timeout():
	$MobPath/MobSpawnLocation.offset = randi()
	
	var mob = Mob.instance()
	add_child(mob)
	
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
	mob.position = $MobPath/MobSpawnLocation.position
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
	mob.linear_velocity = mob.linear_velocity.rotated(direction)

func _on_ScoreTimer_timeout():
	score += 1
	
	if score % 10 == 0:
		level = score / 10 + 1
		var timeout = MIN_TIME + (MAX_TIME - MIN_TIME) * (1.0 / level)
		$MobTimer.wait_time = timeout
	
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_HUD_start_game():
	new_game()

func _on_Player_hit():
	$HUD.update_heart($Player.heart)
	if $Player.heart == 0:
		game_over()
