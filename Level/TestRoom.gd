extends Spatial

onready var character = $Character


func _ready():
	print(character)
	character.translation = get_node("SpawnPlayer").global_transform.origin
