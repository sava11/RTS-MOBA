extends "res://main/Base/rb2d.gd"


func _on_allarm_body_entered(body):
	if body.get("command")!=null and body.get("command")!=command:print("Enemy on our base!")


func _on_allarm_body_exited(body):
	if body.get("command")!=null and body.get("command")!=command:print("Enemy NOT on our base!")
