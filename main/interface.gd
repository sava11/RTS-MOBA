extends CanvasLayer
func _ready():
	var win=fnc.get_prkt_win()
func _process(delta):
	$txt.text="money:"
	var xlen=len($txt.text)*$txt.get("custom_fonts/normal_font").size
	$txt.rect_size.x=xlen
	$txt/mny.text=str(gm.commands[gm.command]["money"])


