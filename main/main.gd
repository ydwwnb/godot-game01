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
@onready var shop = $HUD/shop

var score:int
var survival_time_count:int
var max_mob_count = 5

var mob_health_boost = 0
var mob_speed_boost = 0.0

func _ready():
	pass
	
func _process(delta):
			
	if survival_time_count > 5:
		max_mob_count = survival_time_count

func _on_player_hit():
	#game over
	player.health -= 1
	hud.update_health(player.health)
	if player.health == 0:	
		survival_timer.stop()
		mob_timer.stop()
		hud.show_game_over()
		music.stop()
		death_sound.play()
		player.hide()
		player.collision_shape.set_deferred("disabled", true)

func new_game():
	
	get_tree().call_group("mobs", "queue_free")
	# 初始化player
	init_player()
	start_timer.start()
	score = 100
	survival_time_count = 0
	hud.update_score(score)
	hud.update_health(player.health)
	hud.show_message("Get Ready")
	
	music.play()
	
func init_player():
	player.init()
	player.start(start_position.position)
	
# 更新hud
func update_hud_health():
	hud.update_health(player.health)
	
func update_hud_score():
	hud.update_score(score)

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
		mob.speed_boost = mob_speed_boost
		mob.health_boost = mob_health_boost
		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
	
func _on_mob_killed(score_value):
	print("mob killed")
	score += score_value
	hud.update_score(score)	
	
	
func _on_shop_buy_something(item):
	var point = item[0]
	var value = item[1]
	var boost_for = item[2]
	var boost_type = item[3]
	
	# 判断分数是否足够
	if score < point: #分数不够
		pass
	else:
		score -= point
		update_hud_score()
		if boost_for == "player":
			if boost_type == "health":
				##
				player.health += int(value)
				update_hud_health()
			elif boost_type == "speed":
				##
				player.speed_boost += float(value)
			elif boost_type == "bulletnum":
				##
				player.bullet_number_boost += int(value)
			elif boost_type == "cooldown":
				##
				player.cool_down_time_boost += float(value)
				player.update_cool_down()
			elif boost_type == "shotspeed":
				##
				player.shot_speed_boost += float(value)
				player.update_shot_speed()
		elif boost_for == "bullet":
			if boost_type == "panetrate":
				player.bullet_panetrate_boost += int(value)
		elif boost_for == "mob":
			if boost_type == "health":
				mob_health_boost += int(value)
			if boost_type == "speed":
				mob_speed_boost += float(value)
		
		
		
		
		
		
		
		
		
