extends Panel

export(PoolStringArray)var vars
var par=null
func _ready():
	var ls=$buttons.get_children()
	for e in range(0,len(ls)):
		ls[e].connect("button_down",par,vars[e])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
