extends CharacterBody3D



const JUMP_VELOCITY = 3.0
@onready var head = $head
@onready var camera_3d = $head/Camera3D
var sensetivity = 0.003
var t_bob = 0.0
var bob_freq = 3
var bob_amp = 0.1

const walk_speed = 2.0
const sprint_speed = 3.0
var speed = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# remove cursor
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
# rotate camera
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensetivity)
		camera_3d.rotate_x(-event.relative.y * sensetivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-45),deg_to_rad(60))

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
	# As good practice, you should replace UI actions with custom gameplay actions.
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
	if Input.is_action_just_pressed("shoot"):
		$head/Camera3D/sawed_off_without_shell/AnimationPlayer.play("shoot")
		

	move_and_slide()
	
func head_bob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq)* bob_amp
	pos.x = cos(time * bob_freq/2)* bob_amp
	
	return pos
