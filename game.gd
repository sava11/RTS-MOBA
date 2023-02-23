extends Node
var command=1
onready var cam=get_tree().current_scene.get_node("cam")
var commands={}
const max_unit_value=150
var unit_count=0
var money=250
func _ready():
	###SET_COMMAND_NEED!!!!!!!!!!!!!!
	for e in get_tree().get_nodes_in_group("MBASE"):
		if e.command==gm.command:
			cam.global_position=e.global_position
func _get_nav_path(t):
	return get_tree().current_scene.get_node("map").get_child(0).get_node("PlayGround/ground/").get_child(t)
