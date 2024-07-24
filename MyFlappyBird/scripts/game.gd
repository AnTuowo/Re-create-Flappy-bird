extends Node2D

@export var pipe_scene : PackedScene
@onready var score_label = $ScoreLabel

#Determine the game states: running, over or start
var game_running : bool
var game_over : bool

#Used to move the background image smoothly
var scroll

var score : int = 0
#Make the game faster or slower
const SCROLL_SPEED : int = 4

var screen_size : Vector2i
var ground_height : int

#Customize the array of pipes
var pipes : Array = []
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

#Initial state of the game
func new_game():
	#reset variables
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$ScoreLabel.text = "SCORE: " + str(score)
	
	#Generate starting pipes
	$GameOver.hide()
	for pipe in pipes:
		pipe.queue_free()
	pipes.clear()
	generate_pipes()
	
	
	$Bird.reset()
	print("New game setup complete")

#Waiting for the mouse click  to start the game or to make the bird flaps
func _input(event):
	if game_over == false:
		if Input.is_action_just_pressed("left_click"):
			if game_running == false:
				start_game()
			else:
				if $Bird.flying:
					$Bird.flap()
					check_top()

#Start the game
func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$PipeTimer.start()
	

func _process(delta):
	if game_running == true:
		scroll +=SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0
		
		#Move the ground node
		$Ground.position.x = -scroll
		
		#Move the pipe node
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED

#cool down
func _on_pipe_timer_timeout():
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	
	#get x-coordinate position with delay
	pipe.position.x = screen_size.x + PIPE_DELAY
	
	#get randomized y-coordinate
	pipe.position.y =  (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	 
	#If Game reveives signal from Ground and/or Pipes, trigger bird_hit or/and add_point function
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(add_point)
	
	#add to the game scene
	add_child(pipe)
	
	#to keep track of the pipes
	pipes.append(pipe)

#If the bird touches the ceilling, the bird falls
func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()
		
func stop_game():
	$PipeTimer.stop()
	$Bird.flying = false
	game_running = false
	game_over = true
	$GameOver.show()

func bird_hit():
	$Bird.falling = true
	stop_game()
	
func add_point():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score)

func _on_game_over_restart():
	new_game()

func _on_ground_hit():
	$Bird.falling = false
	$Bird.flying  = false
	stop_game()
