extends KinematicBody2D

var health = 100
var damage = 10
var speed = 100
var knockback = 2000
var kb_resistance = 0
var velocity = Vector2.ZERO
onready var flash_material = preload("res://Shaders/Flash.tres")
onready var death_sound = preload("res://SoundObjects/Enemy_Died.tscn")
onready var vine_sound = preload("res://SoundObjects/Vine_Boom.tscn")
onready var death_particles = preload("res://Particles/EnemyDeathParticles.tscn")
var immune = false
var map_icon = "enemy"
var connection_1_connected = false
var color

var hit_shake_intensity = 50
var hit_shake_duration = 0.2
var die_shake_intensity = 300
var die_shake_duration = 0.25

signal enemy_died

func _ready():
	Global.Update_Minimap()
	if color == null:
		color = $Sprite.modulate

func _physics_process(_delta):
	$Sprite.modulate = lerp($Sprite.modulate,color,0.1)
	if Global.player != null:
		if connection_1_connected == false:
			connection_1_connected = true
			Global.player.connect("debug_mode_toggled",self,"on_debug_mode_toggled")
		look_at(Global.player.global_position)
		if immune == false:
			velocity = global_position.direction_to(Global.player.global_position) * speed
		else:
			velocity = lerp(velocity, Vector2(0,0),0.3)
		var _move = move_and_slide(velocity)
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.is_in_group("Player"):
				collision.collider.take_damage(damage,knockback,self)

func take_damage(amount, Knockback):
	if immune == false:
		health -= amount
		velocity = -global_position.direction_to(Global.player.global_position) * (Knockback - knockback * kb_resistance)
		on_damage_taken()
		
func on_damage_taken():
	$Sprite.material = flash_material
	$Sprite.modulate = Color.white
	$FlashTimer.start()
	immune = true
	if health <= 0:
		die()
	else:
		Global.camera.shake(hit_shake_intensity,hit_shake_duration,hit_shake_intensity)
		
func die():
	on_death()
	
func on_death():
	remove_from_group("map_object")
	Global.camera.shake(die_shake_intensity,die_shake_duration,die_shake_intensity)
	Global.Update_Minimap()
	emit_signal("enemy_died")
	if Global.vine_mode == false:
		Global.PlaySound(death_sound,global_position,Global.node_creation_parent)
	else:
		Global.PlaySound(vine_sound,global_position,Global.node_creation_parent)
	var particles_instance = death_particles.instance()
	particles_instance.global_position = global_position
	Global.node_creation_parent.add_child(particles_instance)
	particles_instance.emitting = true
	particles_instance.modulate = color
	particles_instance.self_modulate = Color.from_hsv(0,0.2,0.5,1)
	particles_instance.z_index = -4094
	queue_free()

func on_flash_end():
	$Sprite.material = null
	$Sprite.modulate = color
	immune = false
	
func on_debug_mode_toggled():
	$CollisionPolygon.visible = Global.debug_mode
