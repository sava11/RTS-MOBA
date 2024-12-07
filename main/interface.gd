extends CanvasLayer
func _ready():
	connect("msg",self,"add_start_txt")
	var win=fnc.get_prkt_win()
signal msg(msg)
func add_start_txt(n):
	var msg=preload("res://main/maps/map/strt_txt.tscn").instance()
	
	$msgs.add_child(msg)
func _process(delta):
	$txt.text="money:"
	var xlen=len($txt.text)*$txt.get("custom_fonts/normal_font").size
	$txt.rect_size.x=xlen
	$txt/mny.text=str(gm.commands[gm.command]["money"])


