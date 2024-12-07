extends Node
var command=1
var tree=null
var cam=null
var commands={}
puppet var pcommands={}
const max_unit_value=150
var unit_count=0
signal _changed_tree_(to)
func set_tree(n):
	if n!=null:
		tree=n
		cam=n.get_node("cam")
func _ready():
	connect("_changed_tree_",self,"set_tree")
	emit_signal("_changed_tree_",get_tree().get_root().get_node("Node2D"))
	#cam=get_tree().get_root().get_node("Node2D/cam")
	###SET_COMMAND_NEED!!!!!!!!!!!!!!
	for e in get_tree().get_nodes_in_group("MBASE"):
		if e.command==gm.command:
			cam.global_position=e.global_position
func _get_nav_path(t):
	return tree.get_node("map").get_child(0).get_node("PlayGround/ground/").get_child(t)
func can_change_money(lcommand:int,value):
	if (value<0 and commands[lcommand].money>=abs(value)) or value>0:
		commands[lcommand].money+=value
		return true
	else:return false
func _physics_process(delta):
	if get_tree().is_network_server():
		rset("pcommands",commands)
	else:
		commands=pcommands
