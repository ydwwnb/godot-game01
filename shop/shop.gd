extends Control

signal buy_something(item)

@export var shop_item_scene : PackedScene
@onready var hflow = $HFlowContainer

# 用来限制打开商店按钮检测频率
var last_shop_press_time := 0.0
var input_cool_down := 0.2
var item_dic = { # key = item name, value  = (point, value)
	"health+1" : [1, 1, "player", "health"],
	"spead+10%" : [10, 0.1, "player", "speed"],
	"cooldown-10%" : [10, 0.1, "player", "cooldown"],
	"bullet+1" : [10, 1, "player", "bulletnum"],
	"panetrate+1" : [10, 1, "bullet", "panetrate"],
	"shotspeed+10%" : [10, 0.1, "player", "shotspeed"],
	"mob health-1" : [1, -1, "mob", "health"],
	"mob speed-10%" : [10, -0.1, "mob", "speed"],
}

var choosed_item_name

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for item in item_dic :
		var shop_item = shop_item_scene.instantiate()
		shop_item.choose_item.connect(_on_item_choosed)
		shop_item.item_name = item
		shop_item.point = int(item_dic[item][0])
		shop_item.value = int(item_dic[item][1])
		hflow.add_child(shop_item)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# 打开或关闭商店
	last_shop_press_time += delta
	if Input.is_action_pressed("open_or_close_shop") && (last_shop_press_time >= input_cool_down):
		visible = !visible
		get_tree().paused = visible
		last_shop_press_time = 0.0
		
func _on_item_choosed(item_name):
	print(item_name)
	choosed_item_name = item_name


func _on_buy_button_pressed():
	if choosed_item_name:
		buy_something.emit(item_dic[choosed_item_name])
