extends Position2D


var connections=[]
func _physics_process(delta):
	if len(connections)==0:
		queue_free()
