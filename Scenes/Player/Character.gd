extends KinematicBody

export var gravityForce = 20
export var jumpForce = 10
export var vel = 10
var acel = 5
var numberOfJumps = 0

var mouse_sens = 0.5 

var direccion = Vector3()
var velocity = Vector3()
var verticalDirection = Vector3()

onready var pivot = $Pivot


func _ready():
	set_mouse_captured()
	

func _input(event):
	set_mouse_visible()
	move_camera_direction(event)

func _process(delta):
	#Every frame we are assigning a Vector3 to direction. If it's not here it going to throw errors
	direccion = Vector3() 
	move_player()
	jump(delta)
	
	# We normalize the direccion
	direccion = direccion.normalized()
	velocity = direccion * vel
	# Second argument is time. If we omit interpolate, the movement less subtle (brusco)
	velocity.linear_interpolate(velocity, acel * delta)
	move_and_slide(velocity, Vector3.UP)


func set_mouse_captured():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func set_mouse_visible():
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func move_camera_direction(event):
	if event is InputEventMouseMotion:
		# deg2rad change float degres to radones, related to 3D physics
		rotate_y(deg2rad(-event.relative.x * mouse_sens))
		# Move camera(pivot) vertically. rotate is what you are goint to move
		pivot.rotate_x(deg2rad(-event.relative.y * mouse_sens))
		# Limit the max and min angle degrees camera. rotation is what was already rotated
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-90), deg2rad(90))

func move_player():
	if Input.is_action_pressed("move_forward"):
		# Basis is related to matrix tranform 
		# in z we substract to going forward
		direccion -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direccion += transform.basis.z
	
	if Input.is_action_pressed("move_left"):
		direccion -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direccion += transform.basis.x

func jump(delta):
	move_and_slide(verticalDirection, Vector3.UP)
	
	if is_on_floor():
		numberOfJumps = 0

	if not is_on_floor():
		verticalDirection.y -= gravityForce * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if numberOfJumps == 0:
			verticalDirection.y  = jumpForce
			numberOfJumps = 1
	
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		if numberOfJumps == 1:
			verticalDirection.y = jumpForce
			numberOfJumps = 2
