extends KinematicBody2D

onready var bullet = preload("res://Assets/Player/PlayerBullet.tscn")
onready var shoot_particles = preload("res://Particles/ShootParticles.tscn")
onready var shoot_sound = preload("res://SoundObjects/Player_Shoot.tscn")
onready var vine_sound = preload("res://SoundObjects/Vine_Boom.tscn")
onready var flash_material = preload("res://Shaders/Flash.tres")

var velocity = Vector2.ZERO
var speed = 200
var dash_speed = 400
var kb_resistance = 0
var health = 100
var can_shoot = true
var is_dashing = false
var can_dash = true
var immune = false
var shoot_speed = 500
var shot_knockback = 1000
var shot_damage = 34

var shoot_shake_intensity = 75
var shoot_shake_duration = 0.1
var dash_shake_intensity = 100
var dash_shake_duration = 0.33

var color

signal debug_mode_toggled
var signal_emitted = false

func _ready():
	Global.player = self
	color = $Sprite.modulate
func _exit_tree():
	Global.player = null

func _input(event):
	if Input.is_action_just_pressed("debug_mode_toggle"):
		for connection_node in Global.node_creation_parent.get_node("ConnectionNodes").get_children():
			connection_node.modulate.a = int(!Global.debug_mode)
		$AreaPolygon.visible = !Global.debug_mode
		$CollisionPolygon.visible = !Global.debug_mode
		Global.debug_mode = !Global.debug_mode
		emit_signal("debug_mode_toggled")
	if Input.is_action_just_pressed("vine_mode_toggle"):
		Global.vine_mode = !Global.vine_mode
	if event.is_action_pressed("shoot"):
		if can_shoot and is_dashing == false:
			shoot()
	if event.is_action_pressed("dash"):
		if can_dash and velocity.length() > 0:
			dash()

func _process(_delta):
	if signal_emitted == false:
		emit_signal("debug_mode_toggled")
		signal_emitted = true
	if Global.debug_mode:
		$Camera2D.zoom = lerp($Camera2D.zoom,Vector2(3,3),0.1)
	else:
		$Camera2D.zoom = lerp($Camera2D.zoom,Vector2(1,1),0.3)

func _physics_process(_delta):
	if is_dashing:
		look_at(global_position+velocity)
		rotation_degrees += 90
		$DashParticles.emitting = true
		$DashParticles.process_material.angle = -rotation_degrees
	else:
		$DashParticles.emitting = false
		look_at(get_global_mouse_position())
		rotation_degrees += 90
	
	if immune == false and is_dashing == false:
		velocity.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
		velocity.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
		velocity = velocity.normalized()
		velocity *= speed
	elif immune == true and is_dashing == false:
		velocity = lerp(velocity, Vector2(0,0),0.3)
	elif immune == true and is_dashing == true:
		velocity = velocity.normalized()
		velocity *= dash_speed
	
	var _move = move_and_slide(velocity)

func shoot():
	if Global.node_creation_parent != null:
		can_shoot = false
		var bullet_instance = bullet.instance()
		Global.node_creation_parent.add_child(bullet_instance)
		bullet_instance.speed = shoot_speed
		bullet_instance.damage = shot_damage
		bullet_instance.knockback = shot_knockback
		bullet_instance.global_position = $Positions/BulletSpawnPos.global_position
		bullet_instance.look_at(get_global_mouse_position())
		var particles_instance = shoot_particles.instance()
		add_child(particles_instance)
		particles_instance.emitting = true
		var sound_instance
		if Global.vine_mode == false:
			sound_instance = shoot_sound.instance()
		else:
			sound_instance = vine_sound.instance()
		add_child(sound_instance)
		sound_instance.play()
		Global.camera.shake(shoot_shake_intensity,shoot_shake_duration,shoot_shake_intensity)
		$ShootTimer.start()

func dash():
	is_dashing = true
	set_collision_mask_bit(0, false)
	set_collision_layer_bit(1,false)
	can_dash = false
	immune = true
	Global.camera.shake(dash_shake_intensity,dash_shake_duration,dash_shake_intensity)
	$DashTimer.start()

func _on_ShootTimer_timeout():
	if Input.is_action_pressed("shoot"):
		shoot()
	else:
		can_shoot = true
		
func take_damage(amount,knockback,enemy):
	if immune == false:
		health -= amount
		velocity = -global_position.direction_to(enemy.global_position) * (knockback - knockback * kb_resistance)
		on_damage_taken()
	
func on_damage_taken():
	$Sprite.material = flash_material
	$Sprite.modulate = Color.white
	$FlashTimer.start()
	immune = true
	if health <= 0:
		die()
		
func die():
	on_death()
	
func on_death():
	queue_free()

func on_flash_end():
	$Sprite.material = null
	$Sprite.modulate = color
	immune = false

func _on_DashTimer_timeout():
	set_collision_mask_bit(0, true)
	is_dashing = false
	can_dash = true
	$DashImmunity.start()

func _on_DashCooldownTimer_timeout():
	immune = false

func _on_Player_debug_mode_toggled():
	for connection_node in Global.node_creation_parent.get_node("ConnectionNodes").get_children():
		connection_node.modulate.a = int(Global.debug_mode)
	$AreaPolygon.visible = Global.debug_mode
	$AreaPolygon.visible = Global.debug_mode
	$CollisionPolygon.visible = Global.debug_mode
