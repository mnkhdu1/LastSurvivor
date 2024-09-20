extends CharacterBody3D

const speed = 40
const max_distance = 500.0  # Maximum distance before queue_free

var initial_position: Vector3

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

func _ready():
	initial_position = global_position

func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	
	# Check if the object has traveled beyond the max_distance
	if global_position.distance_to(initial_position) > max_distance:
		queue_free()
	
