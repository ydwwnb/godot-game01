extends Control

signal choose_item(item_name)

@onready var color_rect = $Panel/ColorRect
@onready var item_name_label = $Panel/ItemName
@onready var point_label = $Panel/Point


var pressed_color = Color(0.26, 0.86, 1, 1)
var un_pressed_color = Color(0.26, 0.86, 0.8, 1)

var item_name
var point:int
var value:int

# Called when the node enters the scene tree for the first time.
func _ready():
	item_name_label.text = str(item_name)
	point_label.text = str(point) + " point"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	choose_item.emit(item_name)
	#color_rect.color = un_pressed_color
