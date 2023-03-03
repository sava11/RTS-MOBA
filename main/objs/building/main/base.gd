extends StaticBody2D
var parametrs={}
var choiced=false
export(String)var c_name=""
export(int) var command=-1
export(Color)var c_com=Color(1,1,1,1)
var sc=1
onready var status=$stats
onready var hub= $hurt_box
onready var map=get_parent().get_parent()
func _draw():
	if choiced:
		for e in range(0,len($c.polygon)-1):
			draw_line($c.polygon[e]+$c.position,$c.polygon[e+1]+$c.position,Color(50,200,50),0.5,true)
		draw_line($c.polygon[len($c.polygon)-1]+$c.position,$c.polygon[0]+$c.position,Color(50,200,50),0.5,true)


func _ready():
	parametrs=objs.bparametrs["MBASE"].duplicate()
	var color=parametrs["color"].duplicate()
	parametrs.command=command
	parametrs.name=c_name
	color.r=c_com.r
	color.g=c_com.g
	color.b=c_com.b
	color.a=c_com.a
	parametrs.color=color
	status.m_he=parametrs.HP
	status.he=parametrs.HP
	#print(parametrs)
	gm.commands.merge({command:parametrs})
	#print(gm.commands)
	if gm.command==command:
		hub.collision_layer=2
		hub.collision_mask=0
		collision_layer=9
		collision_mask=9
		#vision(true)
		$watchout.collision_layer=16
		$watchout.collision_mask=16
	else:
		hub.collision_layer=4
		hub.collision_mask=0
		collision_layer=17
		collision_mask=17
		#line.queue_free()
		$watchout.collision_layer=8
		$watchout.collision_mask=8
		#vision(false)

func _physics_process(delta):
	update()
func _on_s_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm") and command==gm.command:
		if choiced==false:
			choiced=true
		else:
			choiced=false
var in_=false
func _on_main_mouse_entered():in_=true
func _on_main_mouse_exited():in_=false
func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage
	var cmnd=area.command
	if status.he<=0:
		delete(cmnd)
func _on_watchout_body_entered(body):
	#if body.command!=gl.command:
	#	body.vision(true)
	pass # Replace with function body.
func _on_watchout_body_exited(body):
	#if body.command!=gl.command:
	#	body.vision(false)
	pass # Replace with function body.
func delete(cmnd:int):
	gm.commands[command]["battled_by"]=cmnd
	gm.commands[cmnd]["money"]+=objs.bparametrs["MBASE"].money_to_enemy
	queue_free()
	get_parent().get_parent()._reload()
