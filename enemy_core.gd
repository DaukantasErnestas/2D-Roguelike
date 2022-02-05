extends KinematicBody2D

var health = 100
var damage = 10
var speed = 100
var knockback = 2000
var kb_resistance = 0
var velocity = Vector2.ZERO
onready var flash_material = preload("res://Flash.tres")
var immune = false
var color

func _ready():
	color = $Sprite.modulate

func _physics_process(_delta):
	if Global.player != null:
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
		
func die():
	on_death()
	
func on_death():
	queue_free()

func on_flash_end():
	$Sprite.material = null
	$Sprite.modulate = color
	immune = false
