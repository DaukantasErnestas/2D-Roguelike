extends KinematicBody2D

var velocity = Vector2(1,0)
var speed = 0
var knockback = 0 
var damage = 0
var can_collide = true

onready var collide_sound = preload("res://SoundObjects/Bullet_Hit.tscn")
onready var vine_sound = preload("res://SoundObjects/Vine_Boom.tscn")
onready var collide_particles = preload("res://Particles/BulletExplodeParticles.tscn")

var connection_1_connected = false

func _ready():
	$VisibilityPolygon.visible = Global.debug_mode
	$CollisionPolygon.visible = Global.debug_mode

func _physics_process(_delta):
	if connection_1_connected == false:
		connection_1_connected = true
		Global.player.connect("debug_mode_toggled",self,"on_debug_mode_toggled")
	var _move = move_and_slide(velocity.rotated(rotation) * speed)
	for i in get_slide_count():
		if can_collide:
			can_collide = false
			var collision = get_slide_collision(i)
			if collision.collider.is_in_group("Enemy"):
				collision.collider.take_damage(damage, knockback)
				queue_free()
			else:
				if Global.vine_mode == false:
					Global.PlaySound(collide_sound,global_position,Global.node_creation_parent)
				else:
					Global.PlaySound(vine_sound,global_position,Global.node_creation_parent, -10)
				var particles_instance = collide_particles.instance()
				Global.node_creation_parent.add_child(particles_instance)
				particles_instance.global_position = global_position
				particles_instance.look_at(global_position+velocity.rotated(rotation))
				particles_instance.emitting = true
				queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func on_debug_mode_toggled():
	$VisibilityPolygon.visible = Global.debug_mode
	$CollisionPolygon.visible = Global.debug_mode
