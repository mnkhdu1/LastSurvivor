extends Node3D

@onready var color_rect = $ui/ColorRect




func _on_character_body_3d_player_hit():
	color_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	color_rect.visible= false
