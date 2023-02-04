extends StaticBody2D
var choiced=false
var command=-1
var sc=1
func _draw():
	if choiced:
		for e in range(0,len($c.polygon)-1):
			draw_line($c.polygon[e],$c.polygon[e+1],Color(50,200,50),0.5,true)
		draw_line($c.polygon[len($c.polygon)-1],$c.polygon[0],Color(50,200,50),0.5,true)
		#draw_polygon($c.polygon,PoolColorArray([Color(50,200,50)]),PoolVector2Array([]),null,null,true)
# Called when the node enters the scene tree for the first time.
func _ready():pass
func _physics_process(delta):
	update()
func _on_s_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm") and command==gl.command:
		if choiced==false:
			choiced=true
		else:
			choiced=false
