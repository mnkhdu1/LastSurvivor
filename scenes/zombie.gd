extends CharacterBody3D

const attack_range = 0.8

@onready var skeleton = $Armature/Skeleton3D
@onready var animation_tree = $AnimationTree
@onready var zombie_roar = $AudioStreamPlayer3D
@onready var zombie_attack = $zombie_moan
var state_machine
var player = null
var health = 30
@onready var navigation_agent_3d = $NavigationAgent3D
var speed = 1

func _ready():
	player = get_parent().get_parent().get_parent().get_node("CharacterBody3D")
	$Armature/Skeleton3D.animate_physical_bones = true
	state_machine = animation_tree.get("parameters/playback")


func _process(delta):
	match state_machine.get_current_node():
		"run":
			if !zombie_roar.is_playing():
				zombie_roar.play()  # Ensure roar plays continuously when running
			velocity = Vector3.ZERO
			
			navigation_agent_3d.set_target_position(player.global_transform.origin)
			var next_nav_point = navigation_agent_3d.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
			move_and_slide()
		"attack":
			
			if !zombie_attack.is_playing():
				zombie_attack.play()  # Ensure attack sound plays as soon as the attack starts
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	animation_tree.set("parameters/conditions/attack", target_in_range())
	animation_tree.set("parameters/conditions/run", !target_in_range())
	if health<=0:
		queue_free()

func target_in_range():
	return global_position.distance_to(player.global_position) < attack_range
func hit_finished():
	if global_position.distance_to(player.global_position) < attack_range:
		player.hit()


func _on_got_hit(part):
	health = health - part.recieve_damage()
	print(health)
