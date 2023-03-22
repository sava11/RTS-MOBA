extends StaticBody2D
enum t{MAIN,swords,bows,holys}
export(t)var type=t.swords
var preset_name=""
var upreset_name=""
var cd={}
export var command=-1
export var c_name=""
export var c_com=Color(1,1,1,1)
var choiced=false
puppet var pchoiced=false
onready var status=$stats
var tree={}
onready var pid=1

func settle_tree():
	if type!=t.MAIN:
		match type:
			1:
				cd=objs.objs.buildings.swords.duplicate()
				preset_name="swords"
			2:
				cd=objs.objs.buildings.bows.duplicate()
				preset_name="bows"
			3:
				cd=objs.objs.buildings.holys.duplicate()
				preset_name="holys"
		tree={
			"remont":{
				"img":"res://main/img/molot.png",
				"value":10,
				"remonted":true,
				"fnc_path":"",
				"fnc":"remont"
			},
			"add_att":{
				"img":objs.objs.buildings[preset_name].update_att,
				"value":50,
				"fnc_path":"",
				"fnc":"add_att"
			},
			"add_def":{
				"img":objs.objs.buildings[preset_name].update_def,
				"value":50,
				"fnc_path":"",
				"fnc":"add_def"
			},
			"add_unit":{
				"img":"res://main/img/sword.png",
				"unit":upreset_name,
				"value":25,
			},}
	else:
		cd=objs.objs.buildings.MBASE.duplicate()
		var color=cd["color"].duplicate()
		cd.name=c_name
		color.r=c_com.r
		color.g=c_com.g
		color.b=c_com.b
		color.a=c_com.a
		cd.color=color
		cd.posx=global_position.x
		cd.posy=global_position.y
		cd.money=cd.money/(command)
		tree={
			"remont":{
				"img":"res://main/img/molot.png",
				"value":50,
				"remonted":true,
				"fnc_path":"",
				"fnc":"remont"
			},}

func _ready():
	#yield(get_tree(),"idle_frame")
	set_network_master(pid)
	settle_tree()
	$vcont.global_rotation_degrees=0
	for e in tree.keys():
		if tree[e].has("fnc_path"):
			tree[e]["fnc_path"]=str(get_path())
	cd.command=command
	#cd.p_id=cd.p_id
	#status.m_he=cd.hp
	#status.he=cd.hp
	#if ((get_tree().network_peer==null ) or is_network_master()):#and command==gm.command_id
	if type==t.MAIN:
		gm.commands.merge({command:cd})
func _draw():
	if choiced:
		for e in range(0,len($c.polygon)-1):
			draw_line($c.polygon[e]+$c.position,$c.polygon[e+1]+$c.position,Color(50,200,50),0.5,true)
		draw_line($c.polygon[len($c.polygon)-1]+$c.position,$c.polygon[0]+$c.position,Color(50,200,50),0.5,true)
func _process(delta):
	#gm.commands[gm.command_id]["money"]-=25*delta
	update()
	#gm.command[gm.command_id]["money"]
	#if get_tree().network_peer==null or is_network_master():
		
		#if get_tree().network_peer!=null:
			#rset("pchoiced", choiced)
	#else:
	#	choiced=pchoiced
			#if Input.is_action_just_pressed("rbm"):
			#	get_parent().get_parent().rpc("add_new_sts", Vector2(500,500),get_tree().get_network_unique_id())
		
	
func _on_s_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm") and command==gm.command_id:
		if choiced==false:
			choiced=true
		else:
			choiced=false
func set_player_name(new_name):
	get_node("label").set_text(new_name)
