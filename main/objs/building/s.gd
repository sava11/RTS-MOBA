extends StaticBody2D
var choiced=false
var cb_ch=true
var sc=1
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed==true and event.button_index!=1 and event.button_index!=4 and event.button_index!=5:
			choiced=false
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
	if Input.is_action_just_pressed("lbm") and cb_ch==true and not(Input.is_action_pressed("shif")):
		choiced=false
	if Input.is_action_just_released("lbm"):
		cb_ch=true
func _on_s_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm")==true and choiced==true:
		choiced=false
		get_tree().current_scene.choised_units.remove(get_tree().current_scene.choised_units.find(self))
	elif Input.is_action_just_pressed("lbm")==true and choiced==false:
		choiced=true
		get_tree().current_scene.choised_units.append(self)
	if Input.is_action_just_pressed("lbm"):
		cb_ch=false
