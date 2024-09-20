extends Node

enum Body_parts{body,arm,leg,head}
var damage :int = 0 
var part_name = null
signal got_hit
# Called when the node enters the scene tree for the first time.
func _ready():
	if is_in_group("head"):
		part_name = Body_parts.head
	elif is_in_group("arm"):
		part_name = Body_parts.arm
	elif is_in_group("leg"):
		part_name = Body_parts.leg
	elif is_in_group("body"):
		part_name = Body_parts.body
	
	match part_name:
		0:
			damage = 35
		1:
			damage = 20
		2:
			damage = 20
		3:
			damage = 75
			


func _on_area_3d_body_entered(body):
	if body.is_in_group("bullet"):
		emit_signal("got_hit",self)
		
		body.queue_free()
		
func recieve_damage():
	return damage
