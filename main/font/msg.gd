extends RichTextLabel

func _physics_process(delta):
	self_modulate.a=$t.time_left/$t.wait_time

func _on_t_timeout():
	queue_free()
	pass # Replace with function body.
