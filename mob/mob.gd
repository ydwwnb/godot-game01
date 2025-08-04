extends RigidBody2D

signal mob_killed(score_value)

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var visible_on_screen_not_filter = $VisibleOnScreenNotifier2D
@onready var velocity_direction = $VelocityDirection
@onready var mob_dash_timer = $MobDashTimer
@onready var mob_dash_cool_down_timer = $MobDashCoolDownTimer
@onready var navigation_agent = $NavigationAgent2D
@onready var navigation_region = $NavigationRegion2D
@onready var prepare_to_dash_timer = $PrepareDashTimer
# walk: 原始类型，只会按照初始方向行进
# swim： 一直朝着玩家方向前进
# fly： 四处游走，发现玩家在周围一定距离内后，向当时的玩家方向冲刺
var mob_type
var player_position = Vector2.ZERO
var direction_to_player = Vector2.ZERO
var direction_to_wander = Vector2.ZERO
var distance_to_player
var dash_direction = Vector2.ZERO
var is_dashing = false
var dash_speed = 1000
var is_dash_cooling_down = false
var screen_size
var is_prepareing_to_dash = false
var is_ready_to_dash = false
var is_could_to_dash =false
var count = 0

# 商店属性
@export var health = 1
@export var health_boost = 0
@export var speed = 200
@export var speed_boost = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# 绑定导航地图
	navigation_agent.set_navigation_map(get_world_2d().navigation_map)
	# 降低路径更新频率
	navigation_agent.path_max_distance = 50.0
	# 减小路径点间距
	navigation_agent.path_desired_distance = 10.0
	navigation_agent.target_desired_distance = 10.0
	screen_size = get_viewport_rect().size
	contact_monitor = true
	max_contacts_reported = 1
	var mob_types = Array(animated_sprite.sprite_frames.get_animation_names())
	animated_sprite.animation = mob_types.pick_random()
	animated_sprite.animation = "fly"
	animated_sprite.play() 
	mob_type = str(animated_sprite.animation)
	if mob_type == "fly":
		set_new_target()
	
	add_to_group("mobs")
	add_to_group("pauseable")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player_position = player.global_position
		direction_to_player = (player_position - global_position).normalized()
		distance_to_player = (player_position - global_position).length()
	if mob_type == "fly":
		#如果不是冲刺状态，向随机方向游走
		if !is_dashing && !is_prepareing_to_dash && !is_ready_to_dash:
			#如果导航结束，设置一个新的位置
			if navigation_agent.is_navigation_finished():
				print("finished")
				set_new_target()
			var next_path_pos = navigation_agent.get_next_path_position()
			direction_to_wander = (next_path_pos - global_position).normalized()
			rotation = direction_to_wander.angle()
			linear_velocity = direction_to_wander * speed
			#检查和玩家的距离，如果小于某个值就进入准备冲刺阶段
			
		is_could_to_dash = (distance_to_player < 500 && !is_dashing && !is_dash_cooling_down && !is_prepareing_to_dash && !is_ready_to_dash)
		if is_could_to_dash:
			# 可以冲刺，进入冲刺准备阶段
			prepare_to_dash_timer.start()
			is_prepareing_to_dash = true
		elif is_prepareing_to_dash:
			# 准备冲刺，mob停止移动，方向始终朝向player
			linear_velocity = Vector2.ZERO
			rotation = direction_to_player.angle()
			dash_direction = direction_to_player
		elif is_ready_to_dash:
			# 可以冲刺，mob冲向player
			is_ready_to_dash = false
			rotation = dash_direction.angle()
			linear_velocity = dash_direction * dash_speed
			is_dash_cooling_down = true
			is_dashing = true
			mob_dash_timer.start()
			mob_dash_cool_down_timer.start()
			#强制完成mob的导航状态
			force_finish_navigation()
	elif mob_type == "swim":
		rotation = direction_to_player.angle()
		linear_velocity = direction_to_player * linear_velocity.length()
		#velocity_direction.top_level = true
		#velocity_direction.global_position = global_position
		#velocity_direction.points = [Vector2.ZERO, direction.normalized() * 50]
		#print(linear_velocity)


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func update_velocity_line():
	var velocity = linear_velocity
	if velocity.length() > 0:
		#var start_point = Vector2.ZERO
		#var end_point = velocity.normalized() * 50
		#velocity_direction.points = [start_point, end_point]
		velocity_direction.top_level = true
		velocity_direction.global_position = global_position
		velocity_direction.points = [Vector2.ZERO, velocity.normalized() * 50]
		
	else:
		velocity_direction.points = []
		
		


func _on_body_entered(body):
	health -= 1
	if health == 0:
		emit_signal("mob_killed", 1)
		hide()
		collision_shape.set_deferred("disabled", true)
		queue_free()
	
func mob_run():
	pass


func _on_mob_dash_timer_timeout():
	is_dashing = false
	is_ready_to_dash =false


func _on_mob_dash_cool_down_timer_timeout():
	is_dash_cooling_down = false
	
# 给flymob设置新的目标位置
func set_new_target():
	# 防止路径距离过短
	var is_distance_ok = false
	var target_position
	while !is_distance_ok:
		var random_offset = Vector2(
			randf_range(-500, 500),
			randf_range(-300, 300)
		)
		target_position = (global_position + random_offset).clamp(Vector2.ZERO, screen_size)
		var distance = (target_position - global_position).length()
		if distance > 100:
			is_distance_ok = true
	
	navigation_agent.target_position = target_position
	
# 强制完成导航状态
func force_finish_navigation():
	
	navigation_agent.target_position = global_position
	print(navigation_agent.is_navigation_finished())
	
	

func _on_prepare_dash_timer_timeout() -> void:
	# 冲刺准备时间结束，将is_prepareing_to_dash 修改为false
	# 将is_ready_to_dash修改为true
	is_prepareing_to_dash = false
	is_ready_to_dash = true
