extends KinematicBody

export var gravity_force = 20
export var jump_force = 10
export var movement_velolocity = 10

var movement_aceleration = 5
var number_of_jumps = 0
var mouse_sensitivity = 0.5 

var movement_vector = Vector3()
var vertical_vector = Vector3()

onready var pivot = $Pivot


func _ready():
	set_mouse_captured()
	

func _input(event):
	set_mouse_visible()
	move_camera_direction(event)


func _process(delta): 
	move_player(delta)
	jump(delta)


func set_mouse_captured():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func set_mouse_visible():
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func move_camera_direction(event):
	if event is InputEventMouseMotion:
		# deg2rad change float degres to radones, related to 3D physics
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		# Move camera(pivot) vertically. rotate is what you are goint to move
		pivot.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		# Limit the max and min angle degrees camera. rotation is what was already rotated
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-90), deg2rad(90))


func move_player(delta):
	#Every frame we are assigning a Vector3 to direction. If it's not here it going to throw errors
	var movementDirection = Vector3()
	if Input.is_action_pressed("move_forward"):
		# Basis is related to matrix tranform 
		# in z we substract to going forward
		movementDirection -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		movementDirection += transform.basis.z
	
	if Input.is_action_pressed("move_left"):
		movementDirection -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		movementDirection += transform.basis.x

	# We normalize the movementDirection
	movementDirection = movementDirection.normalized()
	movement_vector = movementDirection * movement_velolocity
	# Second argument is time. If we omit interpolate, the movement less subtle
	movement_vector.linear_interpolate(movement_vector, movement_aceleration * delta)
	move_and_slide(movement_vector, Vector3.UP)


func jump(delta):
	move_and_slide(vertical_vector, Vector3.UP)
	
	if is_on_floor():
		number_of_jumps = 0

	if not is_on_floor():
		vertical_vector.y -= gravity_force * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if number_of_jumps == 0:
			vertical_vector.y  = jump_force
			number_of_jumps = 1
	
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		if number_of_jumps == 1:
			vertical_vector.y = jump_force
			number_of_jumps = 2
