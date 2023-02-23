extends CanvasLayer
func _ready():
	var win=fnc.get_prkt_win()
func _process(delta):
	$mny.text="money: "+str(gm.money)


