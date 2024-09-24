extends Node3D

@onready var color_rect = $ui/ColorRect
@onready var zombie_roar = $zombie_roar


func _process(delta):
	if !zombie_roar.is_playing():
				zombie_roar.play()  # Ensure roar plays continuously when running

func _on_character_body_3d_player_hit():
	color_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	color_rect.visible= false
