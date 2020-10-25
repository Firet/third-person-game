extends Area


func _on_Coin_body_entered(body):
	if body.is_in_group("Character"):
		queue_free()
