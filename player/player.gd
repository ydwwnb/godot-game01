extends Area2D

@export var bullet_scene: PackedScene

signal hit

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var attack_direction = $AttackDirection
@onready var attack_timer = $AttackTimer
@onready var dash_timer = $DashTimer
@onready var dash_cool_down_timer = $DashCoolDownTimer


var screen_size
var could_attack = true
var dash_velocity = 1000
var is_dashing = false
var velocity = Vector2.ZERO
var dash_direction = Vector2.ZERO
var count = 0
var could_dash = true

# 可升级属性
@export var health = 2
@export var original_health = 2
@export var speed = 400
@export var speed_boost = 0.0 #速度增益
@export var damage = 1
@export var damage_boost = 0.0
@export var cool_down_time = 1
@export var cool_down_time_boost = 0.0 
@export var min_cool_down_time = 0.05
@export var shot_speed = 0.5
@export var shot_speed_boost = 0.0
@export var min_shot_seppd = 0.05
# 一次射击产生的子弹数量
@export var bullet_number = 1
@export var bullet_number_boost = 0
# 子弹穿透
@export var bullet_panetrate = 0
@export var bullet_panetrate_boost = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()
	add_to_group("player")
	add_to_group("pauseable")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_dashing:
		velocity = Vector2.ZERO
		if  Input.is_action_pressed("move_right"):
			velocity.x += 1
		if  Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if  Input.is_action_pressed("move_up"):
			velocity.y -= 1
		if  Input.is_action_pressed("move_down"):
			velocity.y += 1

		if velocity.length() > 0:
			velocity = velocity.normalized() * (speed * (1 + speed_boost))
			animated_sprite.play() 
		else :
			animated_sprite.stop()
	
	#else:
		#if velocity.length() > 0:
			#velocity = velocity.normalized() * dash_velocity
			#animated_sprite.play() 
		#else :
			#animated_sprite.stop()
	
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)
		
		if velocity.x != 0:
			animated_sprite.animation = "walk"
			animated_sprite.flip_v = false
			animated_sprite.flip_h = velocity.x < 0
		elif velocity.y != 0:
			animated_sprite.animation = "up"
			animated_sprite.flip_v = velocity.y > 0
	else:
		position += dash_direction.normalized() * dash_velocity * delta
	# 获取鼠标的世界坐标
	var mouse_pos = get_global_mouse_position()
  
	# 计算从 RigidBody2D 到鼠标的方向向量
	var direction = (mouse_pos - global_position).normalized()
	
	# 设置 Line2D 的起点（物体中心）和终点（指向鼠标方向）
	attack_direction.points = [Vector2.ZERO, direction * 50]
	
	if Input.is_action_pressed("player_attack") && could_attack:
		attack(direction)
		
	if Input.is_action_pressed("player_dash") && !is_dashing && could_dash:
		dash(direction)

# 初始化player
func init():
	health = original_health
	
func update_shot_speed():
	
	attack_timer.wait_time = shot_speed * (1 - shot_speed_boost)
	if attack_timer.wait_time <= min_shot_seppd:
		attack_timer.wait_time = min_shot_seppd
	
func update_cool_down():
	dash_cool_down_timer.wait_time = cool_down_time * (1 - cool_down_time_boost)
	if dash_cool_down_timer.wait_time <= min_cool_down_time:
		dash_cool_down_timer.wait_time = min_cool_down_time

	
func _on_body_entered(body):
	
	hit.emit()
	#health -= 1
	#if health == 0:
		#hide()
		#hit.emit()
		#collision_shape.set_deferred("disabled", true)
	
	
func start(pos):
	position = pos
	show()
	collision_shape.disabled = false
	
	
func attack(direction):
	for i in range(bullet_number + bullet_number_boost):
		var bullet = bullet_scene.instantiate()
		#bullet.direction = direction.rotated(deg_to_rad(pow(-1, i) * i * 1))
		bullet.direction = direction.rotated(pow(-1, i) * i * 5 * PI / 180)
		bullet.position = global_position
		bullet.panetrate = bullet_panetrate + bullet_panetrate_boost
		get_parent().add_child(bullet)
		could_attack = false
		attack_timer.start()
	
func dash(direction):
	dash_direction = direction
	is_dashing = true
	dash_timer.start()
	dash_cool_down_timer.start()
	could_dash = false
	
	

func _on_attack_timer_timeout():
	could_attack = true


func _on_dash_timer_timeout():
	count += 1
	dash_direction = Vector2.ZERO
	is_dashing = false
	velocity = Vector2.ZERO
	


func _on_dash_cool_down_timer_timeout():
	could_dash = true
