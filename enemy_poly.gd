extends CharacterBody3D

var player = null
var speed = 0.1


@onready var navigation_agent_3d = $NavigationAgent3D



func _ready():
	player = get_parent().get_parent().get_node("CharacterBody3D")


func _process(delta):
	velocity = Vector3.ZERO
	navigation_agent_3d.set_target_position(player.global_transform.origin)
	var next_navigation_point = navigation_agent_3d.get_next_path_position()
	velocity = (next_navigation_point - global_transform.origin).normalized() * speed
	
	look_at(Vector3(player.global_position.x,global_position.y,player.global_position.z),Vector3.UP)
	move_and_slide()
