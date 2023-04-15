extends RigidBody2D
#export(Dictionary)var parametrs={
#	"speed":100,
#	"command":-1,
#	"type":0,
#	"dmg":5,
#	"attack_speed":2,
#	"def":5,
#	"money_to_enemy":5,
#}
var parametrs={}#NEED USE objs.parametrs["_name_"].duplicate()

#export(int,0,99999) var money_to_enemy=5
#export(int)var command=0
#export(int)var type=0
#export(float,0.5,99)var attack_time=0.5
#export(float,0,99999)var dmg=5
#export(float)var def=5
#export(float,0.5,99999)var damage=5
#export(int) var SPEED: int = 40
var path: Array = []
var mvec:=Vector2.ZERO
puppet var pmvec=Vector2.ZERO
puppet var ppos=Vector2.ZERO
var mpath=[]
var mpath_i=0
var to_enemy_follow_path=[]
var pathing=false
onready var status=$stats
var hib={"collision_layer":0,"collision_mask":0}
onready var hub= $hurt_box
var buffs={"adef":0,"aatt":0}
puppet var pbuffs={"adef":0,"aatt":0}
var dmg_polyg=PoolVector2Array([Vector2(-15,-15),Vector2(-15,15),Vector2(15,15),Vector2(15,-15)])



func _ready():
	gm.unit_count+=1
	if gm.command==parametrs["command"]:
		hib["collision_layer"]=0
		hib["collision_mask"]=4
		hub.collision_layer=2
		hub.collision_mask=0
		collision_layer=9
		collision_mask=collision_layer
		$front.collision_layer=16
		$front.collision_mask=$front.collision_layer
		#$rc.collision_mask=16
	else:
		hib["collision_layer"]=0
		hib["collision_mask"]=2
		hub.collision_layer=4
		hub.collision_mask=0
		collision_layer=17
		collision_mask=collision_layer
		$front.collision_layer=8
		$front.collision_mask=$front.collision_layer
		#$rc.collision_mask=8
	$nav_ag.set_navigation(gm._get_nav_path(parametrs["type"]))
	$no.set_navigation(gm._get_nav_path(parametrs["type"]))
var step=0
func set_anim(ang:float,t:String):
	var type=0
	type=fnc.get_ang_move(ang-180,45)+1
	if type!=0:
		var input=t+"-"+str(type)
		$spr.play(input)
		if t=="att":
			$spr.speed_scale=(parametrs["attack_speed"])*1/step/15
onready var save_mpath=mpath
var save_mpath_i=0
func _integrate_forces(st):
	step=st.get_step()
	if is_network_master():
		$pb.max_value=status.m_he
		$pb.value=status.he
		mvec=st.get_linear_velocity()
		if mpath!=[]:
			if mpath_i==len(mpath):
				mpath_i=len(mpath)-1
			$nav_ag.set_target_location(mpath[mpath_i])
		if $nav_ag.is_navigation_finished():
			mvec=mvec.move_toward(Vector2(0,0),parametrs["speed"]*10*step)
			mpath=[]
			mvec=Vector2(0,0)
			return
		if mpath!=[]:
			if attacked==true and $front.bs==[]:
				set_anim(rad2deg(fnc.angle(mvec)),"wait")
				$front.rotation_degrees=rad2deg(fnc.angle(mvec))-90
			path = $nav_ag.get_nav_path()
			mvec = mvec.move_toward(global_position.direction_to($nav_ag.get_next_location()) * parametrs["speed"],parametrs["speed"]*5*step)
			if len(mpath)==1:
				if global_position.distance_to($nav_ag.get_final_location())<10:
					mpath=[]
			elif len(mpath)>1:
				if global_position.distance_to($nav_ag.get_final_location())<10:
					mpath_i=fnc.circ(mpath_i+1,0,len(mpath)-1)
					save_mpath_i=mpath_i
		else:
			mvec=mvec.move_toward(Vector2(0,0),parametrs["speed"]*10*step)
		var len_l=[]
		for ent in bs:
			len_l.append(self.global_position.distance_to(ent.global_position))
		for ent in bs:
			if len_l.min()==self.global_position.distance_to(ent.global_position):
				nearst=ent
		if fnc.i_search($front.bs,nearst)!=-1:
			rpc("attk",nearst.global_position)
		if nearst!=null and is_instance_valid(nearst) :
			mpath_i=0
			if global_position.distance_to(nearst.global_position)>10:
				mpath=[nearst.global_position]
			else:mpath=[]
		if bs==[]:
			mpath=save_mpath
			mpath_i=save_mpath_i
			nearst=null
		rset("ppos",global_position)
		rset("pmvec",mvec)
		rset("pbuffs",buffs)
	else:
		global_position=ppos
		mvec=pmvec
		buffs=pbuffs
	st.set_linear_velocity(mvec)

var nearst=null
var in_=false
func _on_gr_mouse_entered():$pb.show()
func _on_gr_mouse_exited():$pb.hide()

var bs=[]
func _on_watchout_body_entered(b):
	if b!=self and b.get("parametrs")!=null and b.parametrs.has("command")==true and b.parametrs["command"]!=parametrs["command"]:
		bs.append(b)
func _on_watchout_body_exited(b):
	if b!=self and b.get("parametrs")!=null and b.parametrs.has("command")==true and b.parametrs["command"]!=parametrs["command"]:
		bs.remove(fnc.i_search(bs,b))

func end_att():
	attacked=true
	if $front.bs==[]:
		set_anim($front.rotation_degrees,"wait")
	
var attacked=true

func add_att_zone():
	var att=preload("res://main/boxes/hitboxdmg.tscn").instance()
	#att.wait_time=1/attack_time
	#print(att.wait_time)
	att.command=parametrs["command"]
	att.get_child(0).polygon=dmg_polyg
	att.collision_layer=hib["collision_layer"]
	att.collision_mask=hib["collision_mask"]
	att.damage=parametrs["dmg"]+buffs["aatt"]
	get_parent().call_deferred("add_child",att)
	att.global_position=global_position
	att.rotation_degrees=$front.rotation_degrees
remote func attk(target_pos):
	$front.rotation_degrees=rad2deg(fnc.angle(target_pos-global_position))-90
	var t=target_pos-global_position
	$AP.play("att",0,parametrs["attack_speed"])
	set_anim(rad2deg(fnc.angle(t)),"att")
	attacked=false

func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage*(float(area.damage*area.scale_damage)/(parametrs["def"]+buffs["adef"]))
	if status.he<=0:
		print(get_network_master())
		gm.unit_count-=1
		gm.commands[area.command]["money"]+=parametrs["money_to_enemy"]
		yield(get_tree(),"idle_frame")
		rpc("delete")
remote func delete():
	queue_free()

func _on_nav_ag_velocity_computed(safe_velocity):
	mvec=safe_velocity
