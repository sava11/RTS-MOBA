extends RigidBody2D
enum types{space,sky,ground,water,underwater}
export(int)var comand=0
export(int)var type=0
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
func _ready():
	$nav_ag.set_navigation(gl._get_nav_path(type))
	#-ПЕРЕДЕЛАТЬ ПОД ЭТО
	if patrule_pos!=null and patrule_pos!="":
		patr_pos=get_node(patrule_pos)
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed==true and in_==false and event.button_index!=3 and event.button_index!=2 and event.button_index!=4 and event.button_index!=5:
			choiced=false
	if Input.is_action_just_pressed("rbm") and not(Input.is_action_pressed("ctrl")) and choiced:
		m_path=[]
		m_path.append(get_global_mouse_position())
		mpath_i=0
	if Input.is_action_pressed("ctrl") and choiced:
		if Input.is_action_just_pressed("rbm"):
			if pathing==false:
				if patr_pos!=null:
					patr_pos.queue_free()
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
	if choiced:
		var v=Vector2($c.shape.radius+1,$c.shape.radius+1)
		draw_rect(Rect2(-v,v*2),Color(50,200,50),false,0.5,true)
func _physics_process(delta):
	pass
	#if mpath!=[]:
		#rotation_degrees=rad2deg(-atan2(-mvec.y,mvec.x))+90
func _integrate_forces(st):
	mvec=st.get_linear_velocity()
	var step=st.get_step()
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
				
	update()
	st.set_linear_velocity(mvec)
func _on_KinematicBody2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm"):
		if choiced==false:
			choiced=true
		else:
			choiced=false
var in_=false
func _on_gr_mouse_entered():in_=true
func _on_gr_mouse_exited():in_=false
