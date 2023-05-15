extends CanvasLayer
func _ready():
	connect("msg",self,"add_start_txt")
	if gamestate.player_name.hero=="visitor":
		set_process(false)
signal msg(msg)
func add_start_txt(n):
	var msg=preload("res://main/sys_parts/txt_msg/txt_msg.tscn").instance()
	$c/msgs.add_child(msg)
func _process(delta):
	if gm.commands.get(gm.command_id)!=null:
		$c/txt.text="money:"
		$c/txt/mny.text=str(gm.commands[gm.command_id]["money"])
