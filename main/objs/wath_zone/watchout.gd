extends Area2D
func _ready():
	pass
var bs=[]
func _on_b_entered(b):
	if b.command!=get_parent().command:
		bs.append(b)
func _on_b_exited(b):
	if b.command!=get_parent().command:
		bs.remove(gl.i_search(bs,b))
