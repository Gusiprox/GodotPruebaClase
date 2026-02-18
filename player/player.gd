extends CharacterBody2D

@export var gravity = 2
@export var speed = 500
@export var acceleration = 600
@export var friction = 1000
@export var lockDownFriction = 5500
@export var jumpForce = -700
@export var airAcceleration = 2000

@onready var count: Control = $CanvasLayer/Count
@onready var life: Control = $CanvasLayer/Life

@onready var playerAni = $PlayerAni

var coins: int = 0
var hearts: int = 3
var _iniFriction = friction

func _ready() -> void:
	add_to_group("jugadores")
	count.reload(coins)
	life.reload(hearts)

func die():
	set_physics_process(false)
	playerAni.play("dead")
	$PlayerTimer.start()
	await $PlayerTimer.timeout
	get_tree().reload_current_scene()

func addCoin():
	coins+=1
	count.reload(coins)

func delHeart():
	hearts-=1
	life.reload(hearts)
	if hearts == 0:
		die()

func handleFriction():
		if _iniFriction != friction or Input.is_action_pressed("lockDown"):
			friction = friction + lockDownFriction
		else:
			friction = _iniFriction

func updateAnimation(inputAxis):
	if inputAxis !=0:
		playerAni.speed_scale = velocity.length()/100
		playerAni.flip_h = (inputAxis<0)
		playerAni.play("run")
	elif not is_on_floor():
		playerAni.play("jump")
	else:
		playerAni.speed_scale=1
		playerAni.play("idle")

func handleAirAcceleration(inputAxis, delta):
	if is_on_floor(): return
	if inputAxis != 0:
		velocity.x = move_toward(velocity.x, speed*inputAxis, airAcceleration *delta)

func handleJump():
	if is_on_floor():
		if Input.is_action_pressed("salto"):
			velocity.y = jumpForce

func applyFriction(inputAxis, delta):
	if inputAxis==0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction*delta)

func applyGravity(delta):
	if not is_on_floor():
		velocity+=get_gravity() * delta * gravity
		
func handleAcceleration(inputAxis, delta):
	if not is_on_floor(): return
	if inputAxis != 0:
		velocity.x = move_toward(velocity.x, speed*inputAxis, acceleration*delta)

func _physics_process(delta: float) -> void:
	var inputAxis = Input.get_axis("moveIzquierda", "moveDerecha")
	
	applyGravity(delta)
	handleAcceleration(inputAxis, delta)
	handleFriction()
	applyFriction(inputAxis, delta)
	handleJump()
	handleAirAcceleration(inputAxis, delta)
	updateAnimation(inputAxis)
	move_and_slide()
