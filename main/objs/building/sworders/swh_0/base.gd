extends StaticBody2D
export(int,0,99999) var money_to_enemy=25
export(int) var command=-1
export(Color)var c_com=Color(1,1,1,1)
var sc=1
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
	0:{
		"img":"res://main/img/updsword.png",
		"value":50,
		"fnc_path":"",
		"fnc":"add_att"
	},
	1:{
		"img":"res://main/img/updsheild.png",
		"value":50,
		"fnc_path":"",
		"fnc":"add_def"
	},
	2:{
		"img":"res://main/img/sword.png",
		"unit":load("res://main/units/unit.tscn"),
		"value":25,
	},
	
}
func _ready():
	for e in tree.keys():
		if tree[e].has("fnc_path"):
			tree[e]["fnc_path"]=str(get_path())
	var img_id=fnc.get_ang_move(global_rotation_degrees-180,45)
	$img.animation=str(img_id)
	$img.playing=true
	$img.global_rotation_degrees=0
	$hurt_box/col.global_rotation_degrees=0
	$a1/p.global_position=set_pos
	$a1.command=command
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
	if gm.unit_count<gm.max_unit_value:
		if len(timers)<2:
			timers.append({"test":10})
	if trening!=null and gm.unit_count<gm.max_unit_value:
		if trening_time>0:
			trening_time-=delta
		else:
			if trening.keys()==["test"]:
				_add_unit(preload("res://main/units/unit.tscn"))
				timers.remove(fnc.i_search(timers,trening))
				trening=null
var trening=null
var trening_time=0
var timers=[]
func add_att():
	if gm.commands[gm.command]["money"]>=tree[1]["value"] and settle["atti"]<mxattlvl:
		settle["att"]+=5
		settle["atti"]+=1
		gm.commands[gm.command]["money"]-=tree[1]["value"]
func add_def():
	if gm.commands[gm.command]["money"]>=tree[0]["value"] and settle["defi"]<mxdeflvl:
		settle["def"]+=5
		settle["defi"]+=1
		gm.commands[gm.command]["money"]-=tree[0]["value"]
func _add_unit(unit):
	if gm.unit_count<gm.max_unit_value:
		var t=unit.instance()
		t.command=command
		#t.self_modulate=c_com
		t.get_node("spr").self_modulate=c_com
		var en=map.get_nearst_enemy_base(global_position,command)
		t.def+=settle["def"]
		t.get_node("att_pos").damage+=settle["att"]
		if t.type==0:
			var arr=map.get_min_points(global_position)
			t.mpath=Array(arr)
			if en!=null:
				t.mpath.append(en.global_position)
			map.get_node("PlayGround").add_child(t)
		t.modulate=Color(com_data["color"]["r"],com_data["color"]["g"],com_data["color"]["b"],com_data["color"]["a"])
		t.global_position=set_pos
func add_unit(unit):
	if gm.commands[gm.command]["money"]>=25 and gm.unit_count<gm.max_unit_value:
		_add_unit(unit)
		gm.commands[gm.command]["money"]-=25
	pass
func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage
	if status.he<=0:
		delete(area.get_parent().command)
func delete(cmnd:int):
	gm.commands[cmnd]["money"]+=money_to_enemy
	queue_free()
	map._reload()
	
