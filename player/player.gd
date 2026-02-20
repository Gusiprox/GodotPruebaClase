extends CharacterBody2D

@export var gravity = 2
@export var speed = 500
@export var acceleration = 600
@export var friction = 1500
@export var lockDownFriction = 5500
@export var jumpForce = -700
@export var airAcceleration = 2000
@export var iniExtraJump = 1

@onready var count: Control = $CanvasLayer/Count
@onready var life: Control = $CanvasLayer/Life

@onready var playerAni = $PlayerAni

enum states{
	IDLE,
	RUN,
	FALLING,
	ATACKING
}

var extraJump: int = iniExtraJump
var coins: int = 0
var hearts: int = 3
var _iniFriction = friction
var actualState: states = states.IDLE
var atackAnimation: bool = false

func _ready() -> void:
	add_to_group("jugadores")
	count.reload(coins)
	life.reload(hearts)
	returnExtraJump()

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

func returnExtraJump():
	extraJump = iniExtraJump

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

func handleHorizontalView(inputAxis):
		#playerAni.speed_scale = velocity.length()/100
		if inputAxis != 0:
			playerAni.flip_h = (inputAxis<0)

func handleAirAcceleration(inputAxis, delta):
	if is_on_floor(): return
	if inputAxis != 0:
		velocity.x = move_toward(velocity.x, speed*inputAxis, airAcceleration *delta)

func handleJump():
	if Input.is_action_just_pressed("salto"):
		if is_on_floor():
			jump()
			returnExtraJump()

func jump():
		actualState = states.FALLING
		velocity.y = jumpForce

func handleJumpSecond():
	if extraJump > 0 and Input.is_action_just_pressed("salto"):
		jump()
		extraJump-=1

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
	
	match actualState:
		states.IDLE:
			playerAni.play("idle")
			if inputAxis != 0:
				actualState = states.RUN
			if Input.is_action_just_pressed("atack"):
				actualState = states.ATACKING
		states.RUN:
			handleAcceleration(inputAxis, delta)
			
			playerAni.play("run")
			handleHorizontalView(inputAxis)
			
			if inputAxis == 0:
				actualState = states.IDLE
			if Input.is_action_just_pressed("atack"):
				actualState = states.ATACKING
				
		states.FALLING:
			handleAirAcceleration(inputAxis, delta)
			handleJumpSecond()
			playerAni.play("jump")
			
			if is_on_floor():
				returnExtraJump()
				actualState = states.IDLE
		states.ATACKING:
			playerAni.play("atack")
			if playerAni.frame >= 3:
				handleAcceleration(inputAxis,delta)
				$Area2D/CollisionShape2D.disabled = false
			else:
				inputAxis = 0
			if playerAni.frame == 9:
				actualState = states.IDLE
				$Area2D/CollisionShape2D.disabled = true

	handleFriction()
	applyFriction(inputAxis, delta)
	handleJump()
	applyGravity(delta)
	move_and_slide()
	print(actualState)

#func _physics_process(delta: float) -> void:
#	var inputAxis = Input.get_axis("moveIzquierda", "moveDerecha")
#	
#	applyGravity(delta)
#	handleAcceleration(inputAxis, delta)
#	handleFriction()
#	applyFriction(inputAxis, delta)
#	handleJump()
#	handleAirAcceleration(inputAxis, delta)
#	updateAnimation(inputAxis)
#	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.dealDamage()
		addCoin()
