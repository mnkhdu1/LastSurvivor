extends Node3D

@onready var ammo_1 = $HUD/ammo_1
@onready var ammo_2 = $HUD/ammo_2
@onready var wave = $map/NavigationRegion3D/Spawners

@onready var current_wave = $HUD/current_wave

@onready var character_body_3d = $CharacterBody3D
@onready var health_bar = $HUD/health_bar


func _ready():
	
	character_body_3d.connect("player_hit",player_hited)
	

func _process(delta):
	
	health_bar.text = str(character_body_3d.current_health)
	current_wave.text = str(wave.current_wave)
	
	
	match character_body_3d.bullet_count:
		2:
			ammo_1.visible = true
			ammo_2.visible = true
		1:
			ammo_2.visible = false
		0:
			ammo_1.visible = false
			
			

func player_hited():
	$HUD/ColorRect.visible = true
	$HUD/ColorRect2.visible = true
	$HUD/ColorRect3.visible = true
	$HUD/ColorRect4.visible = true
	
	await get_tree().create_timer(2).timeout
	$HUD/ColorRect.visible = false
	$HUD/ColorRect2.visible = false
	$HUD/ColorRect3.visible = false
	$HUD/ColorRect4.visible = false
