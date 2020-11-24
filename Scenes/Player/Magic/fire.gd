extends KinematicBody

var current_speed = Vector3()
var speed_desplacement = 20
var time_seconds = 0

func _physics_process(_delta):
	time_seconds += _delta * 4
	current_speed.y += (cos(time_seconds)/1000) * 3

	var enemy = move_and_collide(current_speed)
	
	if(enemy != null):
		enemy = enemy.collider
		if(enemy.is_in_group("Enemy")):
			enemy.health -= 100
			$".".queue_free()
