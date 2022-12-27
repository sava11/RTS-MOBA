extends Area2D
var bs=[]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered",self,"b_in")
	connect("body_exited",self,"b_out")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func b_in(b):
	if not (b is TileMap) and bs.find(b)==-1:
		bs.append(b)
		b.choiced=true
		get_tree().current_scene.choised_units.append(b)
func b_out(b):
	if bs.find(b)!=-1:
		b.choiced=false
		bs.remove(bs.find(b))
		get_tree().current_scene.choised_units.remove(get_tree().current_scene.choised_units.find(b))
