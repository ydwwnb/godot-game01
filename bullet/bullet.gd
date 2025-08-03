extends RigidBody2D

@onready var collision_shape = $CollisionShape2D


var direction = Vector2.RIGHT

@export var speed = 2000
@export var panetrate = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	# 连接信号
	#body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	linear_velocity = direction * speed


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	print(panetrate)
	if panetrate == 0:
		hide()
		collision_shape.set_deferred("disabled", true)
		queue_free()
	panetrate -= 1
