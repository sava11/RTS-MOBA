extends StaticBody2D
var choiced=false
export(int) var command=-1
var sc=1
onready var max_build_y=Array($c.polygon).max().y
onready var to_vec:=Vector2.DOWN*10+Vector2(0,max_build_y)
export(Color)var c_com=Color(1,1,1,1)
onready var status=$stats
onready var hub= $hurt_box
var varible=null
func _draw():
	if choiced:
		for e in range(0,len($c.polygon)-1):
			draw_line($c.polygon[e]+$c.position,$c.polygon[e+1]+$c.position,Color(50,200,50),0.5,true)
		draw_line($c.polygon[len($c.polygon)-1]+$c.position,$c.polygon[0]+$c.position,Color(50,200,50),0.5,true)
		#draw_polygon($c.polygon,PoolColorArray([Color(50,200,50)]),PoolVector2Array([]),null,null,true)
# Called when the node enters the scene tree for the first time.
func vision(t:bool):
	#$img.visible=t
	modulate.a=0.5+0.5*int(t)
func _ready():
	$Line2D.hide()
	if gl.command==command:
		hub.collision_layer=2
		hub.collision_mask=0
		collision_layer=9
		collision_mask=9
		vision(true)
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
		vision(false)
	pass
func _input(ev):
	var m=gl.get_camera().get_local_mouse_position()+gl.get_prkt_win()/2
	#print(m)
	if ev is InputEventMouseButton:
		if varible!=null and not(varible.rect_size.x<m.x and varible.rect_position.x<m.x):
			if ev.pressed==true and in_==false and (ev.button_index==1):
				choiced=false
func _physics_process(delta):
	update()
	if choiced==true :
		if varible==null:
			varible=preload("res://main/objs/building/main/menu.tscn").instance()
			varible.par=self
			varible.vars=PoolStringArray(["add_unit"])
			get_tree().current_scene.get_node("cl").add_child(varible)
	else:
		if varible!=null:
			varible.queue_free()
			varible=null
	
	if timers!=[] and trening==null:
		trening=timers[0]
		if trening.keys()==["test"]:
			trening_time=trening["test"]
	if trening!=null:
		if trening_time>0:
			trening_time-=delta
		else:
			if trening.keys()==["test"]:
				var t=preload("res://main/units/unit.tscn").instance()
				t.global_position=global_position+Vector2(0,max_build_y+t.get_node("c").shape.radius)
				t.command=command
				t.self_modulate=c_com
				t.get_node("spr").self_modulate=c_com
				if t.type==0:
					var arr=gl.to_glb_line($Line2D.points,global_position)
					arr.remove(0)
					t.mpath=Array(arr)
					print(arr)
					get_tree().current_scene.get_node("map/PlayGround").add_child(t)
				timers.remove(gl.i_search(timers,trening))
				trening=null
var trening=null
var trening_time=0
var timers=[]
func add_unit():
	timers.append({"test":2})
	pass
func _on_s_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm") and command==gl.command:
		if choiced==false:
			choiced=true
		else:
			choiced=false
var in_=false
func _on_main_mouse_entered():in_=true
func _on_main_mouse_exited():in_=false
func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage
	if status.he<=0:
		queue_free()
		get_tree().current_scene.call_deferred("emit_signal","reloadmap")
func _on_watchout_body_entered(body):
	#if body.command!=gl.command:
	#	body.vision(true)
	pass # Replace with function body.
func _on_watchout_body_exited(body):
	#if body.command!=gl.command:
	#	body.vision(false)
	pass # Replace with function body.
