extends Node

@export var mob_scene: PackedScene
@onready var survival_timer = $SurvivalTimer
@onready var mob_timer = $MobTimer
@onready var start_timer = $StartTimer
@onready var hud = $HUD
@onready var music = $Music
@onready var death_sound = $DeathSound
@onready var player = $Player
@onready var start_position = $StartPosition
@onready var mob_spawn_location = $MobPath/MobSpawnLocation
var score:int
var survival_time_count:int
var max_mob_count = 5

func _ready():
	pass
	
func _process(delta):
	if survival_time_count > 5:
		max_mob_count = survival_time_count

func _on_player_hit():
	#game over
	survival_timer.stop()
	mob_timer.stop()
	
	hud.show_game_over()
	music.stop()
	death_sound.play()

func new_game():
	
	get_tree().call_group("mobs", "queue_free")
	
	score = 0
	player.start(start_position.position)
	start_timer.start()
	
	hud.update_score(score)
	hud.show_message("Get Ready")
	
	music.play()

func _on_start_timer_timeout():
	mob_timer.start()
	survival_timer.start()


func _on_survival_timer_timeout():
	survival_time_count += 1
	hud.update_survival_time(survival_time_count)

func _on_mob_timer_timeout():
	#数量超过上限不再生成
	var mob_count = get_tree().get_nodes_in_group("mobs").size()
	if mob_count < max_mob_count:
		# Create a new instance of the Mob scene.
		var mob = mob_scene.instantiate()
		# 链接mob被击中信号
		mob.mob_killed.connect(_on_mob_killed)
		# Choose a random location on Path2D.
		mob_spawn_location.progress_ratio = randf()
		# Set the mob's position to the random location.
		mob.position = mob_spawn_location.position

		# Set the mob's direction perpendicular to the path direction.
		var direction = mob_spawn_location.rotation + PI / 2
		# Add some randomness to the direction.
		direction += randf_range(-PI / 4, PI / 4)
		mob.rotation = direction

		# Choose the velocity for the mob.
		var velocity = Vector2(randf_range(150.0, 550.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction)

		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
	
func _on_mob_killed(score_value):
	print("mob killed")
	score += score_value
	hud.update_score(score)	
	
	
	
	
	
	
	
	
	
	
	

