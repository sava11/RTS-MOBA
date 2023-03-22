extends Node
var commands={}
var command={}
puppet var pcommands={} 
var command_id=2
func can_change_money(lcommand:int,value):
	if (value<0 and commands[lcommand].money>=abs(value)) or value>0:
		commands[lcommand].money+=value
		return true
	else:return false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_tree().network_peer!=null:
		if get_tree().is_network_server():
			rset("pcommands", commands)
		else:
			commands=pcommands
	pass
