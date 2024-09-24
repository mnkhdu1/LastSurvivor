extends Node3D

@export var enemy_scene: PackedScene
@onready var spawner_timer = $Spawner_Timer
var navigation
var current_wave
var spawn_interval = 2
var spawn_region
var all_enemies = []

func _ready():
	navigation = get_parent()
	spawner_timer.start(spawn_interval)

func _process(delta):
	
	pass

func _on_Spawner_Timer_timeout():
	spawn_enemy()
	spawner_timer.start()
	

func spawn_enemy():
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.position = global_position  # Use the spawner's global position
	navigation.add_child(enemy_instance)  # Add the enemy to the navigation parent
	all_enemies.append(enemy_instance)  # Keep track of all spawned enemies
	
	
