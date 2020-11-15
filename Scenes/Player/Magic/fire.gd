extends KinematicBody

var current_speed = Vector3()
var speed_desplacement = 20

func _physics_process(_delta):
	
	var enemy = move_and_collide(current_speed)
	
	if(enemy != null):
		enemy = enemy.collider
		if(enemy.is_in_group("Enemy")):
			enemy.health -= 100
			$".".queue_free()
