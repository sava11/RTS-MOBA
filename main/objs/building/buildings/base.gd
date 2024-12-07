extends StaticBody2D
var unit=null
var upreset_name="sword"
var preset_name="swords"
var parametrs={}
export(int) var command=-1
export(Color)var c_com=Color(1,1,1,1)
var sc=1
onready var pb=$vcont/pb
onready var status=$stats
onready var hub= $hurt_box
onready var map=get_parent().get_parent().get_parent()
var mxattlvl=2
var mxdeflvl=2
var settle={
	"def":0,
	"defi":0,
	"att":0,
	"atti":0,
}
var set_pos=Vector2.ZERO
var com_data={}
var tree={
	
}
func _ready():
	#print(gm.commands[command])
	com_data=gm.commands[command]
	tree={
	"remont":{
		"img":"res://main/img/molot.png",
		"value":10,
		"remonted":true,
		"can_payd":false,
		"fnc_path":"",
		"fnc":"remont"
	},
	"add_att":{
		"img":objs.bparametrs[preset_name].update_att,
		"value":50,
		"can_payd":false,
		"fnc_path":"",
		"fnc":"add_att"
	},
	"add_def":{
		"img":objs.bparametrs[preset_name].update_def,
		"value":50,
		"can_payd":false,
		"fnc_path":"",
		"fnc":"add_def"
	},
	"add_unit":{
		"img":"res://main/img/sword.png",
		"unit":upreset_name,
		"can_payd":false,
		"value":25,
	},
	
	}
	if com_data.p_id>0:
		set_network_master(com_data.p_id)
	unit=load(objs.bparametrs[preset_name].unit)
	parametrs=objs.bparametrs[preset_name].duplicate()
	parametrs.command=command
	for e in tree.keys():
		if tree[e].has("fnc_path"):
			tree[e]["fnc_path"]=str(get_path())
	status.m_he=parametrs.HP
	status.he=parametrs.HP
	var img_id=fnc.get_ang_move(global_rotation_degrees-180,45)
	$img.animation=str(img_id)
	$img.playing=true
	$img.global_rotation_degrees=0
	#$hurt_box/col.global_rotation_degrees=0
	$a1/p.global_position=set_pos
	$a1.command=command
	#fnc.change_parent($a1/z_ingx,pb)
	pb.rect_position=Vector2(-pb.rect_size.x*pb.rect_scale.x/2,0)
	$vcont.global_rotation_degrees=0
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
	#print(com_data)
	#modulate=Color(com_data["color"]["r"],com_data["color"]["g"],com_data["color"]["b"],com_data["color"]["a"])

func _physics_process(delta):
	if is_network_master():
			update()
			pb.max_value=status.m_he
			pb.value=status.he
			if Geometry.is_point_in_polygon(get_global_mouse_position(), fnc.to_glb_PV_and_rot($c.polygon,$c.global_position,$c.global_rotation_degrees)):
				pb.visible=true
			else:
				pb.visible=false

			if status.he<status.m_he:tree.remont.remonted=false
			if timers!=[] and trening==null:
				trening=timers[0]
				if trening.keys()==["test"]:
					trening_time=trening["test"]
			if gm.unit_count<gm.max_unit_value:
				if len(timers)<2:
					timers.append({"test":parametrs["create_unit_time"]})
			if trening!=null and gm.unit_count<gm.max_unit_value and map.pause==false:
				if trening_time>0:
					trening_time-=delta
				else:
					if trening.keys()==["test"]:
						rpc("_add_unit",get_tree().get_network_unique_id())
						timers.remove(fnc.i_search(timers,trening))
						trening=null
var trening=null
var trening_time=0
var timers=[]
remote func add_att():
	if gm.commands[command]["money"]>=tree["add_att"]["value"] and settle["atti"]<mxattlvl:
		settle["att"]+=5
		settle["atti"]+=1
		gm.commands[gm.command]["money"]-=tree["add_att"]["value"]
remote func add_def():
	if gm.commands[gm.command]["money"]>=tree["add_def"]["value"] and settle["defi"]<mxdeflvl:
		settle["def"]+=5
		settle["defi"]+=1
		gm.commands[gm.command]["money"]-=tree["add_def"]["value"]
remotesync func _add_unit(id):
	if gm.unit_count<gm.max_unit_value:
		var t=unit.instance()
		t.parametrs=objs.parametrs[upreset_name].duplicate()
		t.parametrs["command"]=command
		#t.self_modulate=c_com
		t.get_node("spr").self_modulate=c_com
		var en=map.get_nearst_enemy_base(global_position,command)
		if parametrs.unit =="res://main/units/holys/holy.tscn":
			t.parametrs["add_def"]+=settle["def"]
			t.parametrs["add_att"]+=settle["att"]
		else:
			t.parametrs["def"]+=settle["def"]
			t.parametrs["dmg"]+=settle["att"]
		if t.parametrs["type"]==0 :
			var arr=map.get_min_points(global_position)
			t.mpath=Array(arr)
			if en!=null:
				t.mpath.append(en.global_position)
		map.get_node("PlayGround").add_child(t)
		t.set_network_master(id)
		t.get_node("spr").modulate=Color(com_data["color"]["r"],com_data["color"]["g"],com_data["color"]["b"],com_data["color"]["a"])
		t.global_position=set_pos
remotesync func add_unit(id):
	if gm.commands[command]["money"]>=25 and gm.unit_count<gm.max_unit_value:
		_add_unit(id)
		gm.commands[command]["money"]-=25
	pass
func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage
	if status.he<=0:
		delete(area.command)
remotesync func delete(cmnd:int):
	gm.commands[cmnd]["money"]+=objs.bparametrs[preset_name].money_to_enemy
	$a1.rebuild()

remote func remont():
	if tree.remont.remonted==false and gm.can_change_money(parametrs.command,-tree.remont.value)==true:
		status.he=status.m_he
		tree.remont.remonted=true


