extends CharacterBody3D

var bullet = load("res://bullet.tscn")
var shell_scene = load("res://shell.tscn")  # Load the shell scene
var instance
var bullet_count: int = 2 # Starting bullets in the magazine
var is_reloading: bool = false  # Track if the player is reloading

const JUMP_VELOCITY = 3.0
@onready var head = $head
@onready var camera_3d = $head/Camera3D
@onready var gun_barrel = $head/Camera3D/sawed_off_without_shell/RayCast3D
@onready var sfx_shoot = $sfx_shot
@onready var sfx_reload = $sfx_reload  # Assuming you have a reload sound effect

# Sensitivity and movement variables
var sensetivity = 0.003
var t_bob = 0.0
var bob_freq = 3
var bob_amp = 0.1

const walk_speed = 2.0
const sprint_speed = 3.0
var speed = 0
var damage = 20
var spread = 10  # Degrees
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var shoot_delay = 0.4 # Time in seconds between shots
var time_since_last_shot = 0.0  # Timer for managing shooting delay

# Remove cursor
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Rotate camera
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensetivity)
		camera_3d.rotate_x(-event.relative.y * sensetivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-45), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor():
		if Input.is_action_pressed("sprint"):    
			speed = sprint_speed
		else:
			speed = walk_speed
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
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
	
	time_since_last_shot += delta  # Increment the timer

	if Input.is_action_just_pressed("shoot") and time_since_last_shot >= shoot_delay and not is_reloading:
		shoot()
	
	if Input.is_action_just_pressed("reload") and not is_reloading:
		_reload()

	move_and_slide()

func shoot():
	if bullet_count > 0:  # Check if there are bullets to shoot
		$head/Camera3D/sawed_off_without_shell/AnimationPlayer.play("shoot")
		sfx_shoot.play()
		
		var pellet_count = 12  # Number of pellets for the shotgun
		var spread_angle = deg_to_rad(spread)  # Convert spread angle from degrees to radians

		for i in range(pellet_count):
			instance = bullet.instantiate()  # Instantiate a new bullet

			# Set the position of the bullet to the gun barrel
			instance.position = gun_barrel.global_position
			
			# Get the direction of the gun barrel
			var gun_direction = gun_barrel.global_transform.basis.z
			
			# Apply random spread for each pellet
			var random_x = randf_range(-spread_angle, spread_angle)
			var random_y = randf_range(-spread_angle, spread_angle)
			
			# Calculate random direction for the bullet
			var bullet_direction = gun_direction
			bullet_direction = bullet_direction.rotated(Vector3(1, 0, 0), random_x)  # X-axis (up/down) spread
			bullet_direction = bullet_direction.rotated(Vector3(0, 1, 0), random_y)  # Y-axis (left/right) spread
			
			# Update the bullet's transform to use the new direction
			instance.transform.basis = Basis().looking_at(bullet_direction, Vector3.UP).orthonormalized()
			
			# Add the bullet to the scene
			get_parent().add_child(instance)
		
		bullet_count -= 1 # Decrease bullet count after shooting
		time_since_last_shot = 0.0  # Reset the timer
	else:
		print("Out of ammo!")  # Optional: Notify when out of ammo

func _reload():
	if not is_reloading:
		is_reloading = true
		$head/Camera3D/sawed_off_without_shell/AnimationPlayer.play("reload")  # Play reload animation
		sfx_reload.play()  # Play reload sound
		await $head/Camera3D/sawed_off_without_shell/AnimationPlayer.animation_finished  # Wait for animation to finish
		
		# Instantiate the shell scene
		var shell_instance = shell_scene.instantiate()  # Create a new shell instance
		shell_instance.position = gun_barrel.global_position  # Set position to the gun barrel
		shell_instance.rotation_degrees = Vector3(0, 0, 0)  # Adjust rotation if necessary
		get_parent().add_child(shell_instance)  # Add the shell to the scene
		
		bullet_count = 2  # Reset bullets to 2 after reloading
		is_reloading = false

func head_bob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	
	return pos
