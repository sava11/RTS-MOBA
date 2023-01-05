extends "res://main/objs/building/base/s.gd"
onready var max_build_y=Array($c.polygon).max().y
onready var to_vec:=Vector2.DOWN*10+Vector2(0,max_build_y)
onready var line=$Line2D
export(int) var comand=0
export(Color)var c_com=Color(1,1,1,1)
enum mode{nill,to_pos,add_test_unit}
var u_mode=mode.nill
var varible=null
func _ready():
	#print(mode.values())
	pass
func _input(ev):
	var m=gl.get_camera().get_local_mouse_position()+gl.get_prkt_win()/2
	#print(m)
	if ev is InputEventMouseButton:
		if varible!=null and not(varible.rect_size.x<m.x and varible.rect_position.x<m.x):
			if ev.pressed==true and in_==false and ev.button_index!=2 and ev.button_index!=3 and ev.button_index!=4 and ev.button_index!=5:
				choiced=false
	
func _physics_process(delta):
	if choiced==true :
		if varible==null:
			varible=preload("res://main/objs/building/main/menu.tscn").instance()
			varible.par=self
			varible.vars=PoolStringArray(["set_point","add_unit"])
			get_tree().current_scene.get_node("cl").add_child(varible)
			line.show()
	else:
		if varible!=null:
			varible.queue_free()
			line.hide()
			varible=null
	match u_mode:
		mode.nill:
			pass
		mode.to_pos:
			if Input.is_action_just_pressed("rbm") and choiced==true:
				to_vec=get_global_mouse_position()-global_position
				line.points=PoolVector2Array([Vector2.ZERO,to_vec])
				u_mode=mode.nill
		mode.add_test_unit:
			var t=preload("res://main/units/unit.tscn").instance()
			if t.type==0:
				get_tree().current_scene.get_node("map/PlayGround").add_child(t)
			t.global_position=global_position+Vector2(0,max_build_y+t.get_node("c").shape.radius)
			t.m_path=[to_vec+global_position]
			t.comand=comand
			t.self_modulate=c_com
			t.get_node("s").self_modulate=c_com
			u_mode=mode.nill
			pass
var timers=[]
func add_unit():
	u_mode=mode.add_test_unit
	pass
func set_point():
	u_mode=mode.to_pos
	pass

var in_=false
func _on_main_mouse_entered():in_=true
func _on_main_mouse_exited():in_=false
#func _on_s_input_event(viewport, event, shape_idx):
	#if Input.is_action_just_pressed("lbm"):
		
