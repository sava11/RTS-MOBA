extends StaticBody2D
export(int) var command=-1
export(Color)var c_com=Color(1,1,1,1)
export(float,-1,999)var auto_cr_time=0
var sc=1
onready var status=$stats
onready var hub= $hurt_box
onready var map=get_parent().get_parent().get_parent()
var set_pos=Vector2.ZERO
var com_data={}
var tree={}
func _ready():
	var img_id=fnc.get_ang_move(global_rotation_degrees-180,45)
	$img.animation=str(img_id)
	$img.playing=true
	$img.global_rotation_degrees=0
	if gm.command==command:
		hub.collision_layer=2
		hub.collision_mask=0
		collision_layer=9
		collision_mask=9
		#vision(true)
		#$watchout.collision_layer=16
		#$watchout.collision_mask=16
	else:
		hub.collision_layer=4
		hub.collision_mask=0
		collision_layer=17
		collision_mask=17
		#line.queue_free()
		#$watchout.collision_layer=8
		#$watchout.collision_mask=8
	#yield(get_tree(),"idle_frame")
	com_data=gm.commands[command]
	#modulate=Color(com_data["color"]["r"],com_data["color"]["g"],com_data["color"]["b"],com_data["color"]["a"])

func _physics_process(delta):
	update()
	if timers!=[] and trening==null:
		trening=timers[0]
		if trening.keys()==["test"]:
			trening_time=trening["test"]
	if auto_cr_time>=0 and gm.unit_count<gm.max_unit_value:
		if auto_time_temp>=auto_cr_time:
			timers.append({"test":2})
			auto_time_temp=0
	auto_time_temp+=delta
	if trening!=null and gm.unit_count<gm.max_unit_value:
		if trening_time>0:
			trening_time-=delta
		else:
			if trening.keys()==["test"]:
				_add_unit()
				timers.remove(fnc.i_search(timers,trening))
				trening=null
var trening=null
var trening_time=0
var timers=[]
var auto_time_temp=0
func _add_unit():
	if gm.unit_count<gm.max_unit_value:
		var t=preload("res://main/units/unit.tscn").instance()
		t.command=command
		t.self_modulate=c_com
		t.get_node("spr").self_modulate=c_com
		var en=map.get_nearst_enemy_base(global_position,command)
		if t.type==0:
			var arr=map.get_min_points(global_position)
			t.mpath=Array(arr)
			if en!=null:
				t.mpath.append(en.global_position)
			map.get_node("PlayGround").add_child(t)
		t.modulate=Color(com_data["color"]["r"],com_data["color"]["g"],com_data["color"]["b"],com_data["color"]["a"])
		t.global_position=set_pos
func add_unit():
	if get_tree().current_scene.money>=25 and gm.unit_count<gm.max_unit_value:
		_add_unit()
		get_tree().current_scene.money-=25
	pass


func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage
	if status.he<=0:
		queue_free()
		map._reload()
func _on_watchout_body_entered(body):
	#if body.command!=gl.command:
	#	body.vision(true)
	pass # Replace with function body.
func _on_watchout_body_exited(body):
	#if body.command!=gl.command:
	#	body.vision(false)
	pass # Replace with function body.
