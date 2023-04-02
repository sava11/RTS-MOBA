extends StaticBody2D
enum t{MAIN,swords,bows,holys}
export(NodePath)var add_node_path
export(t)var type=t.swords
export var command=-1
export var c_name=""
export var c_com=Color(1,1,1,1)

var preset_name=""
var upreset_name=""
var cd={}

var buffs={
	"uatt":0,
	"udef":0,
	}

onready var status=$stats
onready var hub= $hurt_box
var tree={}
var pid=1#get_tree().get_network_unique_id()

func settle_tree():
	if type!=t.MAIN:
		match type:
			1:
				cd=gm.objs.buildings.swords.duplicate()
				preset_name="swords"
				upreset_name="sword1"
			2:
				cd=gm.objs.buildings.bows.duplicate()
				preset_name="bows"
				upreset_name="bow1"
			3:
				cd=gm.objs.buildings.holys.duplicate()
				preset_name="holys"
				upreset_name="holy1"
		tree={
			"remont":{
				"img":"res://main/img/molot.png",
				"value":10,
				"remonted":true,
				"fnc_path":"",
				"fnc":"remont"
			},
			"add_att":{
				"img":gm.objs.buildings[preset_name].update_att,
				"value":50,
				"fnc_path":"",
				"fnc":"add_att"
			},
			"add_def":{
				"img":gm.objs.buildings[preset_name].update_def,
				"value":50,
				"fnc_path":"",
				"fnc":"add_def"
			},
			"add_unit":{
				"img":"res://main/img/sword.png",
				"unit":upreset_name,
				"value":cd.units[upreset_name].add_value,
			},}
	else:
		cd=gm.objs.buildings.MBASE.duplicate()
		var color=cd["color"].duplicate()
		cd.name=c_name
		color.r=c_com.r
		color.g=c_com.g
		color.b=c_com.b
		color.a=c_com.a
		cd.color=color
		#cd.posx=global_position.x
		#cd.posy=global_position.y
		#cd.money=cd.money/(command)
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
	if gm.command_id==command:
		hub.collision_layer=2
		hub.collision_mask=0
	else:
		hub.collision_layer=4
		hub.collision_mask=0
	$hurt_box/col.polygon=$c.polygon
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
#func _draw():
#	if choiced:
#		for e in range(0,len($c.polygon)-1):
#			draw_line($c.polygon[e]+$c.position,$c.polygon[e+1]+$c.position,Color(50,200,50),0.5,true)
#		draw_line($c.polygon[len($c.polygon)-1]+$c.position,$c.polygon[0]+$c.position,Color(50,200,50),0.5,true)

puppet var pstatus_he=0
puppet var pstatus_m_he=0
func _process(delta):
	#gm.commands[gm.command_id]["money"]-=25*delta
	update()
	#gm.command[gm.command_id]["money"]
	if get_tree().is_network_server():
		$vcont/pb.value=status.he
		$vcont/pb.max_value=status.m_he
		#if type!=t.MAIN:
		#	if len(timers)<2:
		#		timers.append({upreset_name:cd.units[upreset_name].ucrt})
		#	var unit_to_train=timers[0]
		#	unit_to_train[unit_to_train.keys()[0]]-=delta
		#	if unit_to_train[unit_to_train.keys()[0]]<=0:
		#		rpc("add_unit",upreset_name,pid)
		#		timers.remove(0)
		rset("pstatus_he",status.he)
		rset("pstatus_m_he",status.m_he)
	else:
		status.he=pstatus_he
		status.m_he=pstatus_m_he
		$vcont/pb.value=status.he
		$vcont/pb.max_value=status.m_he
		
var timers=[]
#sync func add_unit(un,id):
#	if cd.units[un].unit_path!="" and cd.units[un].unit_path!="null":
#		var unit=load(cd.units[un].unit_path).instance()
#		unit.pid=id
#		unit.command=command
#		var path=gm.gms.get_min_points(global_position)
#		unit.target=path[len(path)-1]
#		unit._temp_target=path[len(path)-1]
#		unit.cd=cd.units[upreset_name]
#		unit.buffs["aatt"]+=buffs["uatt"]
#		unit.buffs["adef"]+=buffs["udef"]
#		unit.get_node("stats").m_he=cd.units[upreset_name].hp
#		if get_node_or_null(add_node_path)!=null:get_node(add_node_path).call_deferred("add_child",unit)
#		else:get_parent().call_deferred("add_child",unit)
#		unit.global_position=$pos.global_position

func set_player_name(new_name):
	get_node("label").set_text(new_name)
