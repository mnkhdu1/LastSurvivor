extends CharacterBody3D

var bullet = load("res://bullet.tscn")
var shell_scene = load("res://shell.tscn")  # Load the shell scene
var instance
var bullet_count: int = 2  # Starting bullets in the magazine
var is_reloading: bool = false  # Track if the player is reloading
@onready var bullet_count_label: Label = $head/Camera3D/HUD/BulletCountLabel  # Path to the HUD Label node
@onready var health_label: Label =  $head/Camera3D/HUD/HealthBarIndicator # Health label in HUD
var max_health: int = 100  # Maximum health of the player
var current_health: int = max_health  # Player's current health

const JUMP_VELOCITY = 3.0
@onready var head = $head
@onready var camera_3d = $head/Camera3D
@onready var gun_barrel = $head/Camera3D/gun/RayCast3D
@onready var sfx_shoot = $sfx_shot
@onready var sfx_reload = $sfx_reload
@onready var sfx_clicking =  $sfx_clicking # Assuming you have a reload sound effect
signal player_hit
# Sensitivity and movement variables
var sensetivity = 0.003
var t_bob = 0.0
var bob_freq = 3
var bob_amp = 0.1

const walk_speed = 2.0
const sprint_speed = 4.0
var speed = 0
var damage = 20
var spread = 10  # Degrees
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var shoot_delay = 0.4  # Time in seconds between shots
var time_since_last_shot = 0.0  # Timer for managing shooting delay

# Remove cursor
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_hud()
	update_health()  # Update health label at start

# Rotate camera
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensetivity)
		camera_3d.rotate_x(-event.relative.y * sensetivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-45), deg_to_rad(60))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor():
		if Input.is_action_pressed("sprint"):
			speed = sprint_speed
		else:
			speed = walk_speed
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = head_bob(t_bob)

	time_since_last_shot += delta

	if Input.is_action_just_pressed("shoot") and time_since_last_shot >= shoot_delay and not is_reloading:
		shoot()

	if Input.is_action_just_pressed("reload") and not is_reloading:
		_reload()

	move_and_slide()

func update_hud():
	bullet_count_label.text = str(bullet_count)  # Update the Label text to show bullet count

func update_health():
	health_label.text = "Health: " + str(current_health)  # Update health label

func shoot():
	if bullet_count > 0:
		$head/Camera3D/gun/AnimationPlayer.play("shoot")
		sfx_shoot.play()

		var pellet_count = 6  # Number of pellets for the shotgun
		var spread_angle = deg_to_rad(spread)

		if gun_barrel and gun_barrel.is_inside_tree():
			for i in range(pellet_count):
				var instance = bullet.instantiate()
				instance.global_transform.origin = gun_barrel.global_transform.origin
				var gun_direction = gun_barrel.global_transform.basis.z
				var random_x = randf_range(-spread_angle, spread_angle)
				var random_y = randf_range(-spread_angle, spread_angle)
				var bullet_direction = gun_direction
				bullet_direction = bullet_direction.rotated(Vector3(1, 0, 0), random_x)
				bullet_direction = bullet_direction.rotated(Vector3(0, 1, 0), random_y)
				instance.transform.basis = Basis().looking_at(bullet_direction, Vector3.UP).orthonormalized()
				get_tree().root.add_child(instance)

			bullet_count -= 1
			update_hud()
			time_since_last_shot = 0.0
		else:
			print("Gun barrel is not ready or not inside the scene tree.")
	else:
		print("Out of ammo!")
		sfx_clicking.play()

func _reload():
	if not is_reloading:
		is_reloading = true
		$head/Camera3D/gun/AnimationPlayer.play("reload")
		sfx_reload.play()
		await $head/Camera3D/gun/AnimationPlayer.animation_finished
		var shell_instance = shell_scene.instantiate()
		shell_instance.global_transform.origin = gun_barrel.global_transform.origin
		get_parent().add_child(shell_instance)
		bullet_count = 2
		update_hud()
		is_reloading = false

func head_bob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos

# Called when the player is hit
func hit(damage: int):
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		die()
	update_health()

# Function to handle player death and restart game
func die():
	print("Player is dead!")
	set_process_input(false)  # Disable player input to simulate death
	#$head/Camera3D/gun/AnimationPlayer.play("death")  # Optional: play death animation
	
	# Wait for 1 second before restarting the game
	await get_tree().create_timer(1.0).timeout
	
	get_tree().reload_current_scene()  # Reload the current scene to restart the game
# Reload the current scene to restart the game
