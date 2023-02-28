extends RigidBody2D
export(int,0,99999) var money_to_enemy=5
export(int)var command=0
export(int)var type=0
export(float,0.5,99)var attack_time=0.5
export(float)var def=0
#export(float,0.5,99999)var damage=5
var path: Array = []
export(int) var SPEED: int = 40
var mvec:=Vector2.ZERO
var mpath=[]
var mpath_i=0
var to_enemy_follow_path=[]
var pathing=false
onready var status=$stats
onready var hib= $att_pos
onready var hub= $hurt_box
#var tarcgets=[]
# тип для выбора управления
func get_init():
	return type

func _ready():
	gm.unit_count+=1
	#$att_pos.damage=damage
	if gm.command==command:
		hib.collision_layer=0
		hib.collision_mask=4
		hub.collision_layer=2
		hub.collision_mask=0
		collision_layer=9
		collision_mask=collision_layer
		$front.collision_layer=16
		$front.collision_mask=$front.collision_layer
		#$rc.collision_mask=16
	else:
		hib.collision_layer=0
		hib.collision_mask=2
		hub.collision_layer=4
		hub.collision_mask=0
		collision_layer=17
		collision_mask=collision_layer
		$front.collision_layer=8
		$front.collision_mask=$front.collision_layer
		#$rc.collision_mask=8
	$nav_ag.set_navigation(gm._get_nav_path(type))
	$no.set_navigation(gm._get_nav_path(type))
var step=0
func set_anim(ang:float,t:String):
	var type=0
	type=fnc.get_ang_move(ang-180,45)+1
	if type!=0:
		var input=t+"-"+str(type)
		$spr.play(input)
		if t=="att":
			$spr.speed_scale=(attack_time)*1/step/15
onready var save_mpath=mpath
var save_mpath_i=0
func _integrate_forces(st):
	mvec=st.get_linear_velocity()
	step=st.get_step()
	if mpath!=[]:
		if mpath_i==len(mpath):
			mpath_i=len(mpath)-1
		$nav_ag.set_target_location(mpath[mpath_i])
	if $nav_ag.is_navigation_finished():
		mvec=mvec.move_toward(Vector2(0,0),SPEED*10*step)
		mpath=[]
		return
	if mpath!=[]:
		if attacked==true and $front.bs==[]:
			set_anim(rad2deg(fnc.angle(mvec)),"wait")
			$front.rotation_degrees=rad2deg(fnc.angle(mvec))-90
		path = $nav_ag.get_nav_path()
		mvec = mvec.move_toward(global_position.direction_to($nav_ag.get_next_location()) * SPEED,SPEED*5*step)
		if len(mpath)==1:
			if global_position.distance_to($nav_ag.get_final_location())<10:
				mpath=[]
		elif len(mpath)>1:
			if global_position.distance_to($nav_ag.get_final_location())<10:
				mpath_i=fnc.circ(mpath_i+1,0,len(mpath))
				save_mpath_i=mpath_i
	else:
		mvec=mvec.move_toward(Vector2(0,0),SPEED*10*step)
	var len_l=[]
	for ent in bs:
		len_l.append(self.global_position.distance_to(ent.global_position))
	for ent in bs:
		if len_l.min()==self.global_position.distance_to(ent.global_position):
			nearst=ent
	if fnc.i_search($front.bs,nearst)!=-1:
		$front.rotation_degrees=rad2deg(fnc.angle(nearst.global_position-global_position))-90
		hib.rotation_degrees=$front.rotation_degrees+90
		attk(nearst.global_position)
	#РАДЗДЕЛИТЬ ПУТИ НА "ДЛЯ ВРАГОВ" и на "ДЛЯ ПУТИ"
	if nearst!=null and is_instance_valid(nearst) :
		mpath_i=0
		mpath=[nearst.global_position]
	update()
	if bs==[]:
		mpath=save_mpath
		mpath_i=save_mpath_i
		nearst=null
	st.set_linear_velocity(mvec)
var nearst=null
var in_=false
func _on_gr_mouse_entered():in_=true
func _on_gr_mouse_exited():in_=false

var bs=[]
func _on_watchout_body_entered(b):
	if b!=self and b.command!=command:
		bs.append(b)
func _on_watchout_body_exited(b):
	if b!=self and b.command!=command:
		bs.remove(fnc.i_search(bs,b))

func end_att():
	attacked=true
	if $front.bs==[]:
		set_anim($front.rotation_degrees,"wait")
	
var attacked=true

func attk(target_pos):
	var t=target_pos-global_position
	#hib.position=fnc.move(hib.rotation_degrees)*10+Vector2(0,-36)
	$AP.play("att",0,attack_time)
	set_anim(rad2deg(fnc.angle(t)),"att")
	attacked=false

func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage/(def+1)
	if status.he<=0:
		gm.commands[area.get_parent().command]["money"]+=money_to_enemy
		queue_free()
