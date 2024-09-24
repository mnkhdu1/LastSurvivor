extends CharacterBody3D

const ATTACK_RANGE = 1.2

@onready var skeleton = $Armature/Skeleton3D
@onready var animation_tree = $AnimationTree
@onready var zombie_roar = $AudioStreamPlayer3D
@onready var zombie_attack = $zombie_moan
var state_machine
var player = null
var health = 200
@onready var navigation_agent_3d = $NavigationAgent3D
var speed = 4

func _ready():
	player = get_parent().get_parent().get_parent().get_node("CharacterBody3D")
	$Armature/Skeleton3D.animate_physical_bones = true
	state_machine = animation_tree.get("parameters/playback")

func _process(delta):
	match state_machine.get_current_node():
		"run":
			#if !zombie_roar.is_playing():
				#zombie_roar.play()  # Ensure roar plays continuously when running

			velocity = Vector3.ZERO
			navigation_agent_3d.set_target_position(player.global_transform.origin)
			var next_nav_point = navigation_agent_3d.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			
			if next_nav_point != global_transform.origin:
				look_at_if_possible(next_nav_point)

			move_and_slide()

			# Always face the player
			look_at_if_possible(player.global_transform.origin)

		"attack":
			#if !zombie_attack.is_playing():
				#zombie_attack.play()  # Ensure attack sound plays as soon as the attack starts

			if player.global_transform.origin != global_transform.origin:
				look_at_if_possible(player.global_transform.origin)

	animation_tree.set("parameters/conditions/attack", target_in_range())
	animation_tree.set("parameters/conditions/run", !target_in_range())

	if health <= 0:
		animation_tree.set("root_motion_track", Vector3.ZERO)
		animation_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()

func target_in_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) < ATTACK_RANGE

func look_at_if_possible(target_position: Vector3):
	var direction = (target_position - global_transform.origin).normalized()
	var up_vector = Vector3.UP

	if !up_vector.cross(direction).is_zero_approx():  # Check if aligned
		look_at(target_position, up_vector)

func hit_finished():
	if global_transform.origin.distance_to(player.global_transform.origin) < ATTACK_RANGE:
		player.hit()

func _on_got_hit(part):
	health -= part.recieve_damage()
	print(health)
