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
var mpath=[]
var mpath_i=0
var to_enemy_follow_path=[]
var pathing=false
onready var status=$stats
var hib={"collision_layer":0,"collision_mask":0}
onready var hub= $hurt_box

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
		#$rc.collision_mask=16
	else:
		hib["collision_layer"]=0
		hib["collision_mask"]=2
		hub.collision_layer=4
		hub.collision_mask=0
		collision_layer=17
		collision_mask=collision_layer
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
var old_napravl=0
func _integrate_forces(st):
	mvec=st.get_linear_velocity()
	step=st.get_step()
	if mpath!=[]:
		if mpath_i==len(mpath):
			mpath_i=len(mpath)-1
		$nav_ag.set_target_location(mpath[mpath_i])
	if attacked==true:
		old_napravl=rad2deg(fnc.angle(mvec))
		set_anim(old_napravl,"wait")
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
	var len_l=PoolVector2Array([])
	if sbs!=[]:
		var poss=[]
		if len(sbs)>1:
			for e in sbs:
				poss.append(e.global_position)
			mpath=[fnc.centr(poss)]
		else:
			if global_position.distance_to(sbs[0].global_position)>=10:
				mpath=[sbs[0].global_position]
			else:
				var com=gm.commands[parametrs.command]
				var pos=Vector2(com.posx,com.posy)
				mpath=[]
		mpath_i=0
	update()
	if bs==[]:
		mpath=save_mpath
		mpath_i=save_mpath_i
	st.set_linear_velocity(mvec)
func end_att():
	attacked=true
var attacked=true
var in_=false
func _on_gr_mouse_entered():in_=true
func _on_gr_mouse_exited():in_=false

var bs=[]
var sbs=[]
func _on_watchout_body_entered(b):
	if b!=self and b.get("parametrs")!=null and b.parametrs.has("command")==true:
		if b.parametrs["command"]!=parametrs["command"]:
			bs.append(b)
		else:
			sbs.append(b)
			if b.get("buffs")!=null:
				b.buffs.adef+=parametrs.add_def
				b.buffs.aatt+=parametrs.add_att
func _on_watchout_body_exited(b):
	if b!=self and b.get("parametrs")!=null and b.parametrs.has("command")==true:
		if b.parametrs["command"]!=parametrs["command"]:
			bs.remove(fnc.i_search(bs,b))
		else:
			sbs.remove(fnc.i_search(sbs,b))
			if b.get("buffs")!=null:
				b.buffs.adef-=parametrs.add_def
				b.buffs.aatt-=parametrs.add_att
func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage*(float(area.damage*area.scale_damage)/(parametrs["def"]))
	area.queue_free()
	if status.he<=0:
		gm.unit_count-=1
		gm.commands[area.command]["money"]+=parametrs["money_to_enemy"]
		yield(get_tree(),"idle_frame")
		queue_free()

