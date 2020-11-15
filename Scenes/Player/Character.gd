extends KinematicBody

export var gravity_force = 20
export var jump_force = 10
export var default_speed = 25
export (PackedScene) var fire


const MOVEMENT_ACELERATION = 5
const MOUSE_SENSITIVITY = 0.5
const MAX_DEGREE_ROTATION = 10
const MIN_DEGREE_ROTATION = -90
const SPRINT_SPEED = 25
const CROUCH_MOVE_SPEED = 1
const TIME_TO_CROUCH = 20
const CROUCH_HEIGHT = 0.5
const DEFAULT_HEIGHT = 1
const SHOOT_DAMAGE = 100

var current_speed
var is_sprinting = false
var is_walking = false
var is_jumping = false
var is_crouching = false
var is_swimming = false
var number_of_jumps = 0
var movement_vector = Vector3()
var vertical_vector = Vector3()
var state = IDLE
var velocity 

enum {
	IDLE,
	WALKING,
	RUNNING,
	JUMPING,
	CROUCH_IDLE,
	CROUCH_WALKING,
	SWIMMING_IDLE,
	SWIMMING
}


onready var pivot = $Pivot
onready var timer_sprint = $TimerSprint
onready var anim = $Player/AnimationPlayer
onready var collision_player = $CollisionShape


func _ready():
	set_mouse_captured()
	

func _input(event):
	set_mouse_visible()
	move_camera_direction(event)


func _process(_delta: float): 
	manage_states()
	sprint()
	shoot(_delta)
	walking(_delta)
	jump(_delta)
	crouch(_delta)
	swim(_delta)


func set_mouse_captured():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func set_mouse_visible():
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func move_camera_direction(event):
	if event is InputEventMouseMotion:
		# deg2rad change float degres to radones, related to 3D physics
		rotate_y(deg2rad(-event.relative.x * MOUSE_SENSITIVITY))
		# Move camera(pivot) vertically. Rotate is what you are goint to move
		pivot.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
		# Limit the max and min angle degrees camera. Rotation is what was already rotated
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(MIN_DEGREE_ROTATION), deg2rad(MAX_DEGREE_ROTATION))


func manage_states():
	current_speed = default_speed
	
	if is_jumping:
		state = JUMPING
	elif is_swimming and !is_walking:
		state = SWIMMING_IDLE
	elif is_swimming and is_walking:
		state = SWIMMING
	elif is_crouching and !is_walking:
		state = CROUCH_IDLE
	elif is_crouching and is_walking:
		state = CROUCH_WALKING
	elif is_sprinting and is_walking:
		state = RUNNING
		current_speed = SPRINT_SPEED
	elif is_walking and not is_sprinting:
		state = WALKING
	else:
		state = IDLE
		current_speed = default_speed

	match state:
		IDLE:
			anim.play("idle")
		WALKING:
			anim.play("walking")
		RUNNING:
			anim.play("running")
		JUMPING:
			anim.play("jumping")
		CROUCH_IDLE:
			anim.play("crouch-idle")
		CROUCH_WALKING:
			anim.play("crouch-walking")
		SWIMMING_IDLE:
			anim.play("trading-water")
		SWIMMING:
			anim.play("trading-water")

func swim(delta):
	var collision = move_and_collide(velocity * delta)
	if collision and collision.collider.name == "Water":
		is_swimming = true
	elif collision and collision.collider.name != "Water":
		is_swimming = false

func walking(delta):
	#Every frame we are assigning a Vector3 to direction. If it's not here it going to throw errors
	var movementDirection = Vector3()
	if Input.is_action_pressed("move_forward"):
		# Basis is related to matrix tranform 
		# in z we substract to going forward
		movementDirection -= transform.basis.z
		is_walking = true
	elif Input.is_action_pressed("move_backward"):
		movementDirection += transform.basis.z
		is_walking = true
	elif Input.is_action_pressed("move_right"):
		movementDirection += transform.basis.x
		is_walking = true
	elif Input.is_action_pressed("move_left"):
		movementDirection -= transform.basis.x
		is_walking = true
	else:
		is_walking = false

	# We normalize the movementDirection
	movementDirection = movementDirection.normalized()
	movement_vector = movementDirection * current_speed
	# Second argument is time. If we omit interpolate, the movement less subtle
	movement_vector.linear_interpolate(movement_vector, MOVEMENT_ACELERATION * delta)
	velocity = move_and_slide(movement_vector, Vector3.UP, true)


func jump(delta):
	velocity = move_and_slide(vertical_vector, Vector3.UP, true)
	
	if is_on_floor():
		number_of_jumps = 0
		is_jumping = false

	if not is_on_floor():
		vertical_vector.y -= gravity_force * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_jumping = true
		if number_of_jumps == 0:
			vertical_vector.y  = jump_force
			number_of_jumps = 1
	
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		if number_of_jumps == 1:
			vertical_vector.y = jump_force
			number_of_jumps = 2


func shoot(_delta):
	
	if(Input.is_action_just_pressed("shoot")):
		var new_fire = fire.instance()
		var test_scene = get_tree().get_nodes_in_group("mainTest")
		
		if test_scene != []:
			test_scene[0].add_child(new_fire)
			new_fire.translation = get_node("Spawn_fire").global_transform.origin
			# normalized to simplify the float numbers. 
			new_fire.current_speed = (-new_fire.speed_desplacement * _delta) * global_transform.basis.z.normalized()


func sprint():
	if Input.is_action_just_pressed("move_sprint") and not is_sprinting:
		is_sprinting = true
		timer_sprint.start()
	elif Input.is_action_just_pressed("move_sprint") and is_sprinting: 
		is_sprinting = false


func _on_Timer_sprint_timeout():
	is_sprinting = false		


func crouch(delta):
	if Input.is_action_pressed("crouch"):
		is_crouching = true
		collision_player.shape.height -= TIME_TO_CROUCH * delta
		current_speed = CROUCH_MOVE_SPEED
		collision_player.shape.height = clamp(collision_player.shape.height, CROUCH_HEIGHT, DEFAULT_HEIGHT)
	else:
		is_crouching = false
		collision_player.shape.height = 1
