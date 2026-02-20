extends CharacterBody2D

@export var speed = 100

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")

var sentido = 1

func _ready() -> void:
	add_to_group("enemies")
	$ZombieAni.play("walk")

func dealDamage():
	queue_free()

func _on_ene_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		body.delHeart()

func _physics_process(delta: float) -> void:

	velocity.y += gravity * delta
	if is_on_wall():
		sentido = -sentido

	if sentido ==1 && $ZombieDetectLe.is_colliding():
		velocity.x = speed
		$ZombieAni.flip_h = false
	else:
		sentido = -1
	
	if sentido == -1 && $ZombieDetectRi.is_colliding():
		velocity.x = -speed
		$ZombieAni.flip_h = true
	else:
		sentido = 1

	move_and_slide()
