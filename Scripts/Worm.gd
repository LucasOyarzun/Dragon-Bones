extends KinematicBody2D

var lineal_vel = Vector2()
export var speed_x = 100
var speed_y = 500
var gravity = 20

export var facing_right = false
var waiting_before_turn_back = 0

onready var playback = $AnimationTree.get("parameters/playback")
var target_vel = -1
var moving = false                  # Variable de si se mueve o no
var timer_moving = 0                # Tiempo que lleva moviendose o quieto
export var moving_lapse = 3         # Tiempo que se mueve
var stay_lapse = 1.8                # Tiempo que se queda quieto

export var fireball_lapse = 1.1            # Tiempo que se demorará en lanzar la bola de fuego
var fireball_created = false        # Si es que ya lanzo la bola de fuego

onready var area = $Area2D.connect("body_entered", self, "on_body_entered")
# Guardamos bala como una variable
var Fireball = preload("res://Scenes/FireBall.tscn")
var Cura = preload("res://Scenes/Cura.tscn")

var player_vassel = null

func _physics_process(delta: float) -> void:
	lineal_vel = move_and_slide(lineal_vel, Vector2.UP)
	lineal_vel.y += gravity
	waiting_before_turn_back-=delta                  # Tiempo antes de darse la vuelta
	timer_moving+=delta
	
	if is_on_floor():
		lineal_vel.x = lerp(lineal_vel.x, target_vel * speed_x, 0.5)
	else:
		lineal_vel.x = lerp(lineal_vel.x, target_vel * speed_x, 0.1)
		
	if not(moving):
		lineal_vel.x = 0
	if(moving_lapse>0):
		if(timer_moving> fireball_lapse and moving == false and fireball_created == false) :   # Cuando decide lanzar la bola
			# Lanza la bola de fuego
			var fireball = Fireball.instance()           # Instanciamos la escena fireball
			get_parent().add_child(fireball)           # Lo agregamos como hijo de main para que no se mueva con el worm
			if facing_right:
				fireball.global_position = global_position+Vector2(40, -10) # Posicion inicial la de este enemigo
				fireball.rotation = 0
			else:
				fireball.global_position = global_position+Vector2(-40, -10) # Posicion inicial la de este enemigo
				fireball.rotation = PI
			
			fireball_created = true
	
	else:
		if(timer_moving> fireball_lapse and fireball_created == false) :   # Cuando decide lanzar la bola
			# Lanza la bola de fuego
			var fireball = Fireball.instance()           # Instanciamos la escena fireball
			get_parent().add_child(fireball)           # Lo agregamos como hijo de main para que no se mueva con el worm
			if facing_right:
				fireball.global_position = global_position+Vector2(40, -10) # Posicion inicial la de este enemigo
				fireball.rotation = 0
			else:
				fireball.global_position = global_position+Vector2(-40, -10) # Posicion inicial la de este enemigo
				fireball.rotation = PI
			
			fireball_created = true
		
	if(timer_moving> stay_lapse and moving == false):   # Cuando decide moverse
		moving = true
		timer_moving = 0
	elif(timer_moving> moving_lapse and moving ==true): # Cuando decide quedarse quieto
		moving = false
		timer_moving = 0
		fireball_created = false
		
	# Para que de vueltas en la plataforma
	if !$RayCast2D.is_colliding() or $RayCast2D2.is_colliding():
		if(waiting_before_turn_back<0):
			waiting_before_turn_back= 0.5
			facing_right = !(facing_right)
			scale.x = -1
			target_vel = -target_vel
		
	
	# Animations
	if is_on_floor():
		if abs(lineal_vel.x) > 10:
			playback.travel("Walk")
		else:
			playback.travel("Attack")

func on_body_entered(body: Node):
	if body.is_in_group("player"): # Si choca con el jugador
		var player: Player = body
		var knockdir = (player.transform.origin - transform.origin).normalized() * 100 # Knockback
		player.knockback(knockdir)
		player.take_damage(1)
		$Re_entered_timer.start()
		player_vassel = player

func take_damage():
	queue_free()

func _on_Re_entered_timeout() -> void:
	if player_vassel != null:
		player_vassel.take_damage(1)
		var knockdir = (player_vassel.transform.origin - transform.origin).normalized() * 100 # Knockback
		player_vassel.knockback(knockdir)

func _on_player_body_exited(body: Node) -> void:
	if body.is_in_group("player"): # Si choca con el jugador
		player_vassel = null
