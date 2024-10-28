extends Node3D

@export var enemy_scene: PackedScene

var navigation
var spawn_interval = 2.0
var spawn_timer
var current_wave = 1

var all_enemies = []
var spawn_points = []
@export var enemies_per_wave = 2  # Number of enemies to spawn each wave
var enemies_spawned = 0   # Track how many enemies have spawned in the current wave

func _ready():
	navigation = get_parent()
	
	spawn_points = get_children()
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.connect("timeout", _on_Spawner_Timer_timeout)
	spawn_timer.autostart = false  # Start the timer when ready
	add_child(spawn_timer)
	
	randomize()  
	start_wave()

func start_wave():
	 
	spawn_timer.start()   # Start the timer for spawning enemies

func _on_Spawner_Timer_timeout():
	if enemies_spawned < enemies_per_wave:
		spawn_enemy()
		print("Enemy spawned")
	else:
		if all_enemies.size() == 0:
			end_wave()

func random_spawn_point():
	if spawn_points.size() == 0:
		print("No spawn points available!")
		return null  
	
	var random_index = randi() % spawn_points.size()
	return spawn_points[random_index]

func spawn_enemy():
	var spawn_point = random_spawn_point()
	if spawn_point:
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.position = spawn_point.global_position
		navigation.add_child(enemy_instance)
		
		all_enemies.append(enemy_instance)
		enemies_spawned += 1  # Increment the count of spawned enemies
		
		# Connect the enemy's death signal to the manager
		enemy_instance.connect("dead", _on_enemy_dead)

func _on_enemy_dead(enemy):
	all_enemies.erase(enemy)  # Remove the enemy from the active list
	# Check if all enemies are dead


func end_wave():
	spawn_timer.stop()  # Stop the timer
	current_wave += 1   # Move to the next wave
	enemies_per_wave += 2  # Increase difficulty (optional)
	spawn_interval -= 0.3
	print("Wave", current_wave, "completed!")
	enemies_spawned = 0
	# You can add a delay here before starting the next wave
	await get_tree().create_timer(2.0).timeout  # Wait 2 seconds
	 # Start the next wave
	start_wave()
