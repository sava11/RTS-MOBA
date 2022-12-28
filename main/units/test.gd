extends RigidBody2D
enum types{space,sky,ground,water,underwater}
var unit_type=null
export(int)var comand=0
var choiced = false
var path: Array = []
export(int) var SPEED: int = 40
var mvec:=Vector2.ZERO
var cb_ch=true
var m_path=[]
var mpath=[]
var mpath_i=0
var pathing=false
export(NodePath) var patrule_pos=null
onready var patr_pos=null

func _ready():
	if patrule_pos!=null:
		patr_pos=get_node(patrule_pos)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed==true and event.button_index!=1 and event.button_index!=2 and event.button_index!=4 and event.button_index!=5:
			choiced=false
	if Input.is_action_just_pressed("rbm") and not(Input.is_action_pressed("ctrl")) and choiced and cb_ch==true:
		m_path=[]
		m_path.append(get_global_mouse_position())
		mpath_i=0
	if Input.is_action_pressed("ctrl") and choiced and cb_ch==true:
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
	if mpath!=[]:
		rotation_degrees=rad2deg(-atan2(-mvec.y,mvec.x))+90
func _integrate_forces(st):
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
		return
	mvec=st.get_linear_velocity()
	var step=st.get_step()
		#choiced=false
	if Input.is_action_just_pressed("lbm") and cb_ch==true and not(Input.is_action_pressed("shif")):
		choiced=false
	if Input.is_action_just_released("lbm"):
		cb_ch=true
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
	if Input.is_action_just_pressed("lbm")==true and choiced==true:
		choiced=false
		get_tree().current_scene.choised_units.remove(get_tree().current_scene.choised_units.find(self))
	elif Input.is_action_just_pressed("lbm")==true and choiced==false:
		choiced=true
		get_tree().current_scene.choised_units.append(self)
	
