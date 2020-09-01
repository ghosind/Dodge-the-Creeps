extends Node

export (PackedScene) var Mob

const MAX_TIME = 1.5
const MIN_TIME = 0.5

const SAVE_FILE_NAME = "user://save_game.dat"

var level
var highest = 0
var score

func _ready():
	randomize()
	
	load_game()
	
	$HUD.update_highest_score(highest)

func save_game():
	var game_file = File.new()
	game_file.open(SAVE_FILE_NAME, File.WRITE)
	print_debug(game_file)
	game_file.store_32(highest)
	game_file.close()

func load_game():
	var game_file = File.new()
	if not game_file.file_exists(SAVE_FILE_NAME):
		return
	
	game_file.open(SAVE_FILE_NAME, File.READ)
	highest = game_file.get_32()
	print_debug("game_file: ", game_file)
	print_debug("highest: ", highest)
	game_file.close()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	
	$HUD.show_game_over()
	
	if score > highest:
		highest = score
		$HUD.update_highest_score(highest)
		save_game()
	
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
	
	mob.linear_velocity = Vector2(mob.speed, 0)
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
