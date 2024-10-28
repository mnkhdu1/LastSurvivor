extends Control

@onready var h_slider = $HBoxContainer2/VBoxContainer2/HSlider
@onready var check_box = $HBoxContainer2/VBoxContainer2/CheckBox
@onready var option_button = $HBoxContainer2/VBoxContainer2/OptionButton
@onready var button = $HBoxContainer3/VBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_option_button_item_selected(index):
	match index:
		0:
			
			get_viewport().set_content_scale_size(Vector2i(1920, 1080))
		1:
			
			get_viewport().set_content_scale_size(Vector2i(1154, 864))
		2:
			
			get_viewport().set_content_scale_size(Vector2i(1024, 768))


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0,value/5)


func _on_check_box_toggled(toggled_on):
	AudioServer.set_bus_mute(0,toggled_on)


func _on_button_button_up():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
