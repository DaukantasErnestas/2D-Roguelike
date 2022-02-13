extends Particles2D

onready var enemy_spawn_particles = preload("res://Particles/EnemySpawnParticles.tscn")
onready var vine_sound = preload("res://SoundObjects/Vine_Boom.tscn")
onready var enemy_spawn_sound = preload("res://SoundObjects/Enemy_Spawn.tscn")
var enemy

var shake_intensity = 300
var shake_duration = 0.25

func _ready():
	emitting = true
	modulate = enemy.get_node("Sprite").modulate

func _on_SpawnTimer_timeout():
	emitting = false
	var particles_instance = enemy_spawn_particles.instance()
	if Global.vine_mode == false:
		Global.PlaySound(enemy_spawn_sound,global_position,Global.node_creation_parent)
	else:
		Global.PlaySound(vine_sound,global_position,Global.node_creation_parent,10)
	particles_instance.global_position = global_position
	particles_instance.modulate = enemy.get_node("Sprite").modulate
	Global.node_creation_parent.add_child(enemy)
	enemy.global_position = global_position
	enemy.color = enemy.get_node("Sprite").modulate
	enemy.get_node("Sprite").modulate *= 1.5
	visible = false
	Global.node_creation_parent.add_child(particles_instance)
	particles_instance.emitting = true
	Global.camera.shake(shake_intensity,shake_duration,shake_intensity)
