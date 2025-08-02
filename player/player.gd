extends Area2D

@export var bullet_scene: PackedScene

signal hit

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var attack_direction = $AttackDirection
@onready var attack_timer = $AttackTimer
@onready var dash_timer = $DashTimer
@onready var dash_cool_down_timer = $DashCoolDownTimer

@export var speed = 400
var screen_size
var could_attack = true
var dash_velocity = 1000
var is_dashing = false
var velocity = Vector2.ZERO
var dash_direction = Vector2.ZERO
var count = 0
var could_dash = true
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()
	add_to_group("player")

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
			velocity = velocity.normalized() * speed
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


func _on_body_entered(body):
	hide()
	hit.emit()
	collision_shape.set_deferred("disabled", true)
	
	
func start(pos):
	position = pos
	show()
	collision_shape.disabled = false
	
	
func attack(direction):
	var bullet = bullet_scene.instantiate()
	bullet.direction = direction
	bullet.position = global_position
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
