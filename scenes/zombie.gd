extends CharacterBody3D

const attack_range =0.8

@onready var skeleton = $Armature/Skeleton3D 
@onready var animation_tree = $AnimationTree
var state_machine
var player = null
@onready var navigation_agent_3d = $NavigationAgent3D
var speed = 1
func _ready():
	player = get_parent().get_parent().get_parent().get_node("CharacterBody3D")
	$Armature/Skeleton3D.animate_physical_bones = true
	state_machine = animation_tree.get("parameters/playback")

func _process(delta):
	
	match state_machine.get_current_node():
		"run":
			velocity = Vector3.ZERO
			navigation_agent_3d.set_target_position(player.global_transform.origin)
			var next_nav_point = navigation_agent_3d.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z+velocity.z), Vector3.UP)
			move_and_slide()
		"attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	animation_tree.set("parameters/conditions/attack", target_in_range())
	animation_tree.set("parameters/conditions/run", !target_in_range())
	

	
	
	
func target_in_range():
	return global_position.distance_to(player.global_position)< attack_range
	
	
