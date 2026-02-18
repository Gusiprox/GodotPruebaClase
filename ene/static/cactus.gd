extends Area2D

var hearts: int = 3

func delHeart():
	hearts-=1

func _ready():
	add_to_group("jugadores")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		body.delHeart()
		queue_free()
