extends Area2D
func _ready():
	pass
var bs=[]
func _on_b_entered(b):
	if b.get("parametrs")!=null and b.parametrs.has("command")==true and get_parent().get("parametrs")!=null and get_parent().parametrs.has("command")==true and b.parametrs["command"]!=get_parent().parametrs["command"]:
		bs.append(b)
func _on_b_exited(b):
	if b.get("parametrs")!=null and b.parametrs.has("command")==true and get_parent().get("parametrs")!=null and get_parent().parametrs.has("command")==true and b.parametrs["command"]!=get_parent().parametrs["command"]:
		bs.remove(fnc.i_search(bs,b))
