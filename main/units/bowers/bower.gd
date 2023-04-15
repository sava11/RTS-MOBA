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
func _ready():
	gm.unit_count+=1
	status.m_he=parametrs.HP
	status.he=parametrs.HP
	
	if gm.command==parametrs["command"]:
		hib["collision_layer"]=0
		hib["collision_mask"]=4
		hub.collision_layer=2
		hub.collision_mask=0
		collision_layer=9
		collision_mask=collision_layer
		$front.collision_layer=16
		$front.collision_mask=$front.collision_layer
		$r.collision_mask=16
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
		$r.collision_mask=8
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
	if attacked==true and $front.bs==[]:
		set_anim(rad2deg(fnc.angle(mvec)),"wait")
		$front.rotation_degrees=rad2deg(fnc.angle(mvec))-90
	if is_network_master():
		mvec=st.get_linear_velocity()
		if mpath!=[]:
			if mpath_i==len(mpath):
				mpath_i=len(mpath)-1
			$nav_ag.set_target_location(mpath[mpath_i])
		if $nav_ag.is_navigation_finished():
			mvec=mvec.move_toward(Vector2(0,0),parametrs["speed"]*10*step)
			mpath=[]
			return
		if mpath!=[]:
			
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
		nearst=null
		for ent in bs:
			len_l.append(self.global_position.distance_to(ent.global_position))
		for ent in bs:
			if len_l.min()==self.global_position.distance_to(ent.global_position) and fnc.i_search($front.bs,ent)!=-1:
				nearst=ent
				target_pos=nearst.global_position
		if nearst!=null and target_pos!=Vector2.ZERO:
			rpc("attk",target_pos)
		if nearst!=null and is_instance_valid(nearst):
			
			if global_position.distance_to(nearst.global_position)<100:
				mpath=[-global_position.direction_to(nearst.global_position)*parametrs["speed"]+global_position]
			else:
				mpath=[]
			mpath_i=0
		update()
		if bs==[]:
			mpath=save_mpath
			mpath_i=save_mpath_i
			nearst=null
			target_pos=Vector2.ZERO
		rset("ppos",global_position)
		rset("pmvec",mvec)
		rset("pbuffs",buffs)
	else:
		global_position=ppos
		mvec=pmvec
		buffs=pbuffs
	st.set_linear_velocity(mvec)
var target_pos=Vector2.ZERO
var nearst=null
var in_=false
func _on_gr_mouse_entered():in_=true
func _on_gr_mouse_exited():in_=false

var bs=[]
func _on_watchout_body_entered(b):
	if b!=self and b.get("parametrs")!=null and b.parametrs.has("command")==true and b.parametrs["command"]!=parametrs["command"]:
		bs.append(b)
func _on_watchout_body_exited(b):
	if b!=self and b.get("parametrs")!=null and b.parametrs.has("command")==true and b.parametrs["command"]!=parametrs["command"]:
		bs.remove(fnc.i_search(bs,b))

func end_att():
	attacked=true
	if bs==[]:
		set_anim($front.rotation_degrees,"wait")
func set_att():
	attacked=false
var attacked=true
func add_att_zone():
	var att=preload("res://main/boxes/hitboxdmgShaped.tscn").instance()
	#att.wait_time=1/attack_time
	att.command=parametrs["command"]
	att.collision_layer=hib["collision_layer"]
	att.collision_mask=hib["collision_mask"]
	att.damage=parametrs["dmg"]+buffs["aatt"]
	get_parent().call_deferred("add_child",att)
	#att.global_position=global_position
	att.global_position=$r.get_collision_point()

remote func attk(target_pos:Vector2):
	var t=target_pos-global_position
	$front.rotation_degrees=rad2deg(fnc.angle(target_pos-global_position))-90
	$r.cast_to=target_pos-global_position
	$AP.play("att",0,parametrs["attack_speed"])
	set_anim(rad2deg(fnc.angle(t)),"att")
	

func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage*(float(area.damage*area.scale_damage)/(parametrs["def"]+buffs["adef"]))
	if status.he<=0:
		gm.unit_count-=1
		gm.commands[area.command]["money"]+=parametrs["money_to_enemy"]
		yield(get_tree(),"idle_frame")
		rpc("delete")
remote func delete():
	queue_free()
