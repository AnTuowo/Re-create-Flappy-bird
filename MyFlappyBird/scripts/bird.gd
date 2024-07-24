extends CharacterBody2D

#How quick the bird drops
const GRAVITY : int = 1000

#Limit the max full speed 
const MAX_VEL : int = 600

#How much the bird jumps up
const FLAP_SPEED : int = -400

#The start coordinate of the bird
const START_POS = Vector2(100, 400)

#The flag is active as long as the bird has not collided with anything
var flying : bool = false

#The flag is active if the bird hit the pipe
var falling : bool = false

#Call when the node enters the scene tree for the 1. time
func _ready():
	reset()

func reset():
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)

#Call every delta
func _physics_process(delta):
	if flying or falling:
		velocity.y += GRAVITY * delta
		
		#terminal velocity
		if  velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
			$AnimatedSprite2D.play()
		elif falling:
			set_rotation(deg_to_rad(90))
			$AnimatedSprite2D.stop()
			
		move_and_collide(velocity * delta) #To move the bird?
		var collision = move_and_collide(velocity * delta)
		if collision:
			print("I collided with ", collision.get_collider().name)
			
	else: # If the bird touches the ground
		$AnimatedSprite2D.stop()

func flap():
	velocity.y = FLAP_SPEED
