extends Area2D

var monedas: int = 0

func addCoin():
	monedas+=1

func _ready():
	add_to_group("jugadores")
	$CoinAni.play("idle")

func _onBodyEntered(body: Node2D):
	if body.is_in_group("jugadores"):
		body.addCoin()
		queue_free()
