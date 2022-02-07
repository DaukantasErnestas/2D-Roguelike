extends Particles2D

export(PackedScene) var enemy_to_spawn
onready var enemy_spawn_particles = preload("res://Particles/EnemySpawnParticles.tscn")
var enemy

func _ready():
	emitting = true
	enemy = enemy_to_spawn.instance()
	modulate = enemy.get_node("Sprite").modulate

func _on_SpawnTimer_timeout():
	emitting = false
	var particles_instance = enemy_spawn_particles.instance()
	particles_instance.global_position = global_position
	particles_instance.modulate = enemy.get_node("Sprite").modulate
	Global.node_creation_parent.add_child(enemy)
	enemy.global_position = global_position
	enemy.color = enemy.get_node("Sprite").modulate
	enemy.get_node("Sprite").modulate *= 1.5
	visible = false
	Global.node_creation_parent.add_child(particles_instance)
	particles_instance.emitting = true
