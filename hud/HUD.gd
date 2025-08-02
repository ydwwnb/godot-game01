extends CanvasLayer

signal start_game

@onready var score_label = $ScoreLabel
@onready var message = $Message
@onready var start_button = $StartButton
@onready var message_timer = $MessageTimer
@onready var survival_time = $SurvivalTime

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func show_message(text):
	message.text = text
	message.show()
	message_timer.start()
	
func show_game_over():
	show_message("Game Over")
	await message_timer.timeout
	
	message.text = "Dodge the Creeps!"
	message.show()
	
	await get_tree().create_timer(1.0).timeout
	start_button.show()
	
func update_score(score):
	score_label.text = "score: " + str(score)
	
func update_survival_time(time):
	survival_time.text = "survival time: " + str(time)


func _on_start_button_pressed():
	start_button.hide()
	start_game.emit()


func _on_message_timer_timeout():
	message.hide()
