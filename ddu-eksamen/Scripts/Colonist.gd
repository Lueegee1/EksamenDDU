extends Node
class_name  Colonist

func die():
	queue_free()

@export var sprite: Sprite2D
@export var productivity: int
@export var hitbox: CollisionObject2D
