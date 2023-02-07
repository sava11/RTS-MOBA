extends RigidBody2D
enum types{space,sky,ground,water,underwater}
export(int)var command=0
export(int)var type=0
export(float,0.5,99999)var attack_time=0.5
export(float,0.5,99999)var damage=0.5
export(float,0,99999)var max_ang=15
var choiced = false
var path: Array = []
export(int) var SPEED: int = 40
var mvec:=Vector2.ZERO
var m_path=[]
var mpath=[]
var mpath_i=0
var pathing=false
export(NodePath) var patrule_pos=null
onready var patr_pos=null
onready var status=$stats
onready var hib= $att_pos
onready var hub= $hurt_box
#var tarcgets=[]
# тип для выбора управления
func get_init():
	return [self,filename]

func _ready():
	if gl.command==command:
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
	$nav_ag.set_navigation(gl._get_nav_path(type))
	if patrule_pos!=null and patrule_pos!="":
		patr_pos=get_node(patrule_pos)
func _input(event):
	if command==gl.command:
		if event is InputEventMouseButton:
			if event.pressed==true and in_==false and Input.is_action_pressed("shif")==false and event.button_index==1:
				choiced=false
		if Input.is_action_just_pressed("rbm") and not(Input.is_action_pressed("ctrl")) and choiced:
			if patr_pos!=null:
				patr_pos.queue_free()
			patr_pos=null
			m_path=[]
			m_path.append(get_global_mouse_position())
			mpath_i=0
		if Input.is_action_pressed("ctrl") and choiced:
			if Input.is_action_just_pressed("rbm"):
				if pathing==false:
					if patr_pos!=null:
						patr_pos.queue_free()
					patr_pos=null
					m_path=[]
					var point=Position2D.new()
					get_tree().current_scene.get_node("patr_zones").add_child(point)
					point.global_position=get_global_mouse_position()
					patr_pos=point
					mpath_i=0
				if len(m_path)>0 and m_path[len(m_path)-1]!=get_global_mouse_position() or m_path==[]:
					m_path.append(get_global_mouse_position()-patr_pos.global_position)
					pathing=true
		else: pathing=false
func _draw():
	if choiced and command==gl.command:
		var v=Vector2($c.shape.radius+1,$c.shape.radius+1)
		draw_rect(Rect2(-v,v*2),Color(50,200,50),false,0.5,true)
func _physics_process(delta):
	pass
	#if mpath!=[]:
		#rotation_degrees=rad2deg(-atan2(-mvec.y,mvec.x))+90
const angl=45/2
const arr=[-180,-135,-90,-45,0,45,90,135,180]

var step=0
func set_anim(ang:float,t:String):
	var type=0
	type=gl.get_ang_move(ang-180,45)+1
	if type!=0:
		var input=t+"-"+str(type)
		$spr.play(input)
		if t=="att":
			$spr.speed_scale=(attack_time)*1/step/15
func _integrate_forces(st):
	
	mvec=st.get_linear_velocity()
	step=st.get_step()
	mpath=[]
	if patr_pos!=null:
		for e in m_path:
			mpath.append(e+patr_pos.global_position)
	else:
		mpath=m_path
		mpath_i=0
	if mpath!=[]:
		$nav_ag.set_target_location(mpath[mpath_i])
	if $nav_ag.is_navigation_finished():
		mvec=mvec.move_toward(Vector2(0,0),SPEED*10*step)
		mpath=[]
		m_path=[]
		return
	if mpath!=[]:
		if attacked==true and $front.bs==[]:
			set_anim(rad2deg(gl.angle(mvec)),"wait")
			$front.rotation_degrees=rad2deg(gl.angle(mvec))-90
		path = $nav_ag.get_nav_path()
		mvec = mvec.move_toward(global_position.direction_to($nav_ag.get_next_location()) * SPEED,SPEED*5*step)
		if len(mpath)==1:
			if global_position.distance_to($nav_ag.get_final_location())<10:
				mpath=[]
				m_path=[]
		elif len(mpath)>1:
			if global_position.distance_to($nav_ag.get_final_location())<10:
				mpath_i=gl.circ(mpath_i+1,0,len(mpath)-1)
	else:
		mvec=mvec.move_toward(Vector2(0,0),SPEED*10*step)
	var len_l=[]
	for ent in bs:
		len_l.append(gl._sqrt(self.global_position-ent.global_position))
	for ent in bs:
		$front.rotation_degrees=rad2deg(gl.angle(ent.global_position-global_position))-90
		if len_l.min()==gl._sqrt(self.global_position-ent.global_position):
			nearst=ent
	if gl.i_search($front.bs,nearst)!=-1:
		attk(nearst.global_position)
	#mpath.append(ent.global_position)
	if attacked==true and nearst!=null and is_instance_valid(nearst) and m_path==[]:
		m_path=[nearst.global_position]
		mpath_i=0
	update()
	if bs==[]:nearst=null
	st.set_linear_velocity(mvec)
var nearst=null
func _on_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm") and command==gl.command:
		if choiced==false:
			choiced=true
		else:
			choiced=false
var in_=false
func _on_gr_mouse_entered():in_=true
func _on_gr_mouse_exited():in_=false

var bs=[]
func _on_watchout_body_entered(b):
	if b!=self and b.command!=command:
		bs.append(b)
func _on_watchout_body_exited(b):
	if b!=self and b.command!=command:
		bs.remove(gl.i_search(bs,b))

func end_att():
	attacked=true
	if $front.bs==[]:
		set_anim($front.rotation_degrees,"wait")

var attacked=true

func attk(target_pos):
	var t=target_pos-hib.global_position
	hib.rotation_degrees=rad2deg(gl.angle(t))
	hib.position=gl.move(hib.rotation_degrees)*10+Vector2(0,-36)
	$AP.play("att",0,attack_time)
	set_anim(rad2deg(gl.angle(target_pos-global_position)),"att")
	attacked=false

func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage
	if status.he<=0:
		dead()

func dead():
	queue_free()
