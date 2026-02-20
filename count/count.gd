extends Control

func _ready() -> void:
	$AniCount.play("default")

func reload(coins:int):
	$HboxCount/LblCount.text = str(coins)
