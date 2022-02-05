extends KinematicBody2D

var velocity = Vector2(1,0)
var speed = 0
var knockback = 0 
var damage = 0
var can_collide = true

onready var collide_sound = preload("res://SoundObjects/Bullet_Hit.tscn")

func _physics_process(_delta):
	var _move = move_and_slide(velocity.rotated(rotation) * speed)
	for i in get_slide_count():
		if can_collide:
			can_collide = false
			var collision = get_slide_collision(i)
			if collision.collider.is_in_group("Enemy"):
				collision.collider.take_damage(damage, knockback)
				queue_free()
			else:
				Global.PlaySound(collide_sound,global_position,Global.node_creation_parent)
				queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
