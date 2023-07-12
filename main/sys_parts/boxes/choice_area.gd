extends Area2D
var node=null
func _on_choice_area_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("rbm"):
		node=get_node_or_null(gamestate.player_name.hero_path)
		if is_instance_valid(node) and node.get("command")!=null:# and node.command!=get_parent().command:
			node.objet_target=self
			node.not_in_target=true
func _on_choice_area_mouse_exited():
	if is_instance_valid(node):node.not_in_target=false
