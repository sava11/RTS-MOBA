extends StaticBody2D
export(float,1,9999) var see_range=250
enum t{MAIN,swords,bows,holys}
export(NodePath)var add_node_path
export(t)var type=t.swords
export var command=-1
export var c_name=""
export var c_com=Color(1,1,1,1)
export(float,0.001,99999) var add_hp_max=100
export(float,0.001,99999) var add_hp_speed=100
var battle_path:=PoolVector2Array([])
var preset_name=""
var updpreset_name=""
var cd={}
var build_area=null
var buffs={
	"uatt":0,
	"udef":0,
	}
onready var status=$stats
onready var hub= $hurt_box
var tree={}
var pid=0#get_tree().get_network_unique_id()
var remont_value=0
func remont():
	remonted=false

func settle_tree():
	if type!=t.MAIN:
		match type:
			1:
				if preset_name!="":
					cd=gm.objs.buildings[preset_name].duplicate()
				else:
					cd=gm.objs.buildings["swords"].duplicate()
					preset_name="swords"
			2:
				if preset_name!="":
					cd=gm.objs.buildings[preset_name].duplicate()
				else:
					cd=gm.objs.buildings["bows"].duplicate()
					preset_name="bows"
		tree={
			"remont":{
				"img":"res://main/img/molot.png",
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
			}
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
				"fnc_path":"",
				"fnc":"remont"
			},}
	updpreset_name=cd.get("next_lvl","")
	if updpreset_name!="":
		tree.merge({"update_build":{
				"img":"res://main/img/up.png",
				"value":50,
				"fnc":"upd_build"
				
			}})
	status.set_he(cd.hp)
	status.s_m_h(cd.hp)
	

func _ready():
	settle_tree()
	if pid!=0:
		set_network_master(pid)
	$s.texture=load(cd.img+str(fnc.get_ang_move(global_rotation_degrees+180,45)+1)+".png")
	$s.global_rotation_degrees=0
	if type==t.MAIN:
		gm.commands.merge({command:cd})
	yield(get_tree(),"idle_frame")
	if gm.command_id==command:
		hub.collision_layer=2
		hub.collision_mask=0
		$vcont/pb.self_modulate=Color(0,1.0,0,1)
	else:
		$Light2D.queue_free()
		hub.collision_layer=4
		hub.collision_mask=0
		$vcont/pb.self_modulate=Color(1.0,0,0,1)
	$hurt_box/col.polygon=$c.polygon
	$vcont.global_rotation_degrees=0
	for e in tree.keys():
		if tree[e].has("fnc_path"):
			tree[e]["fnc_path"]=str(get_path())
	
	#cd.command=command
	#cd.p_id=cd.p_id
	#status.m_he=cd.hp
	#status.he=cd.hp
	#if ((get_tree().network_peer==null ) or is_network_master()):#and command==gm.command_id
	
#func _draw():
#	if choiced:
#		for e in range(0,len($c.polygon)-1):
#			draw_line($c.polygon[e]+$c.position,$c.polygon[e+1]+$c.position,Color(50,200,50),0.5,true)
#		draw_line($c.polygon[len($c.polygon)-1]+$c.position,$c.polygon[0]+$c.position,Color(50,200,50),0.5,true)

puppet var pstatus_he=0
puppet var pstatus_m_he=0
var remonted=true
func _process(delta):
	#gm.commands[gm.command_id]["money"]-=25*delta
	update()
	#gm.command[gm.command_id]["money"]
	if is_network_master():
		$vcont/pb.value=status.he
		$vcont/pb.max_value=status.m_he
		if type!=t.MAIN:
			if len(timers)<2:
				timers.append(cd.unit.ucrt)
			timers[0]-=delta
			if timers[0]<0:
				rpc("add_unit",pid,"kb_"+str(int(rand_range(10000+command*100000,99999+command*100000))))
				timers.remove(0)
		rset("pstatus_he",status.he)
		rset("pstatus_m_he",status.m_he)
		if status.he<status.m_he and remont_value<add_hp_max and remonted==false and gm.can_change_money(command,-round(cd["rem_value"]*delta)):
			status.he+=add_hp_speed*delta
			remont_value+=add_hp_speed*delta
		else:
			remonted=true
			remont_value=0
	else:
		status.he=pstatus_he
		status.m_he=pstatus_m_he
		$vcont/pb.value=status.he
		$vcont/pb.max_value=status.m_he
	
		
var timers=[]
remotesync func _area_add_unit(un,id,n):
	rpc("add_unit",un,id,n)
remotesync func add_unit(id,n):
	if cd.unit.unit_path!="" and cd.unit.unit_path!="null":
		var unit=load(cd.unit.unit_path).instance()
		unit.pid=id
		unit.name=n
		unit.set_network_master(id)
		unit.command=command
		#var path=gm.gms.get_min_points(global_position)
		#print(command," ",path)
		unit.battle_path=battle_path
		#unit.target=path[len(path)-1]
		#unit._temp_target=path[len(path)-1]
		unit.cd=cd.unit
		unit.get_node("s2").texture=load(unit.cd.img)
		unit.buffs["aatt"]+=buffs["uatt"]
		unit.buffs["adef"]+=buffs["udef"]
		unit.get_node("stats").m_he=cd.unit.hp
		unit.global_position=$pos.global_position
		unit.pgp=$pos.global_position
		
		if get_node_or_null(add_node_path)!=null:get_node(add_node_path).call_deferred("add_child",unit)
		else:get_parent().call_deferred("add_child",unit)

func set_player_name(new_name):
	get_node("label").set_text(new_name)
func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage
	if status.he<=0:
		gm.commands[area.command]["money"]+=cd["money_to_enemy"]
		if is_network_master():
			if build_area!=null:
				build_area.rpc("rebuild")
			else:
				print("deleteing")
				rpc("delete",area.command)
sync func delete(c:int):
	gm.gms._reload()
	gm.commands[c].battled_by=c
	gamestate.end_game()
	queue_free()

