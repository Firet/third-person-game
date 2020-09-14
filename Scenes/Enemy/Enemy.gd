extends KinematicBody

var health = 200

func _process(_delta):
	if health <= 0:
		queue_free()
