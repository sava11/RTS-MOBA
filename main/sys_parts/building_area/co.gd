extends Area2D
enum t{nill,sword,bow}
export(NodePath)var add_node_path
export(t)var start_build=t.nill
export(int)var command=-1
export(float,0,50)var otstup=10

onready var cntrl=$z_ingx
onready var posy=cntrl.position.y
var building
var pid=0
var choiced=false
puppet var pchoiced=false

func _draw():
	if command==gm.command_id and gamestate.player_name.hero!="visitor":
		if choiced==true:
			var area=$c.shape.extents
			var r=Rect2(-area*1.25,area*2.5)
			draw_rect(r,Color(1.0,1.0,1.0,1.0),false,2.0,true)
			#draw_arc(Vector2.ZERO,fnc._sqrt(area),0,PI*2,360,Color(1.0,1.0,1.0,1.0),2.0,true)
			#draw_circle($p.position,5,Color(0.0,1.0,0.0,1.0))
			cntrl.visible=true
		else:
			var area=$c.shape.extents
			var r=Rect2(-area-Vector2(1,1),area*2+Vector2(2,2))
			draw_rect(r,Color(0.0,1.0,0.0,1.0),false,2.0,true)
			cntrl.visible=false
var tree={}
func _updeate_ready():
	#yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	if (building!=null and is_instance_valid(building)!=false) and building.get("command")!=null:command=building.command
	if (building==null or is_instance_valid(building)==false) or building.get("tree")==null:
			tree={
		t.sword:{
			"img":"res://main/img/sword.png",
			"obj_name":"swords",
			"value":50,
				},
		t.bow:{
			"img":"res://main/img/bow.png",
			"obj_name":"bows",
			"value":50,
				}}
	else:
		if building.get("tree")!={}:
			if building.type>0:
				tree={
					"rebuild":{
						"img":"res://main/img/rebuild.png",
						"fnc":"rebuild",
						"value":-abs(building.cd.rebuild_value)
						}
					}
			tree.merge(building.get("tree"))
	cntrl.visible=false
	var win=fnc.get_prkt_win()
	var sizex=min(win.x,win.y)*0.05
	var list=tree.keys()
	for e in cntrl.get_child(0).get_children():
		e.queue_free()
	for e in list:
		var btn=Button.new()
		btn.name=str(e)
		btn.expand_icon=true
		btn.rect_size=Vector2(sizex,sizex)
		cntrl.get_child(0).add_child(btn)
		btn.icon=load(tree.get(e)["img"])
		btn.connect("button_down",self,"_set_btn",[e])
		#btn.text=e[0]+e[1]
		btn.focus_mode=Control.FOCUS_NONE
		btn.mouse_filter=Control.MOUSE_FILTER_PASS
		btn.rect_position=Vector2((btn.rect_size.x+otstup)*fnc.i_search(list,e)+otstup/2,otstup/2)
	
var battle_path=PoolVector2Array([])
func _ready():
	pid=get_network_master()
	for e in get_parent().get_children():
		if e is Line2D:
			battle_path=fnc.to_glb_PV_and_rot(e.points,e.global_position,e.global_rotation_degrees)
			e.hide()
			break
	_updeate_ready()
	yield(get_tree(),"idle_frame")
	if start_build!=t.nill:
		cr_obj(tree[start_build]["obj_name"],pid)

var mouse_in_area=false
func _on_mouse_entered():
	mouse_in_area=true
func _on_mouse_exited():
	mouse_in_area=false
var in_but_area=false
func _on_but_mouse_entered():
	in_but_area=true
func _on_butt_mouse_exited():
	in_but_area=false


func _physics_process(delta):
	update()
	for e in get_parent().get_children():
		if e is Line2D:
			battle_path=fnc.to_glb_PV_and_rot(e.points,e.global_position,e.global_rotation_degrees)
			break
	if is_network_master() and gamestate.player_name.hero=="builder":
		var win=fnc.get_prkt_win()
		var sizex=min(win.x,win.y)*0.05
		cntrl.global_rotation_degrees=0
		cntrl.get_child(0).rect_size=Vector2((sizex+otstup)*len(tree.keys()),sizex+otstup)
		cntrl.global_position.x=-cntrl.get_child(0).rect_size.x/2+global_position.x
		cntrl.global_position.y=posy+global_position.y-cntrl.get_child(0).rect_size.y
		if mouse_in_area==false and in_but_area==false and Input.is_action_just_pressed("lbm"):
			choiced=false


func _set_btn(e):
	if is_network_master():
		rpc("logic",e,pid)
	#logic(e,get_tree().get_network_unique_id())
remotesync func logic(e,id):
	if tree[e].has("value") and not(gm.can_change_money(command,-tree[e]["value"])):
		return
	if tree[e].has("obj_name"):
		cr_obj(tree[e]["obj_name"],id)
	if tree[e].has("fnc"):
		if tree[e].has("fnc_path"):
			get_node(tree[e]["fnc_path"]).call_deferred(tree[e]["fnc"])
		else:
			call_deferred(tree[e]["fnc"])
	
remotesync func cr_obj(objn:String,id):
	building=load("res://main/Base/rb2d.tscn").instance()
	building.preset_name=objn
	building.global_position=global_position
	building.global_rotation_degrees=global_rotation_degrees
	building.command=command
	building.pid=id
	building.battle_path=battle_path
	building.build_area=self
	#obj.auto_cr_time=-1
	#obj.set_pos=$p.global_position
	if get_node_or_null(add_node_path)!=null:get_node(add_node_path).call_deferred("add_child",building)
	else:get_parent().call_deferred("add_child",building)
	yield(get_tree(),"idle_frame")
	_updeate_ready()
	building.get_node("pos").global_position=$ps.global_position
	gm.gms._reload()
remotesync func rebuild():
	if building!=null:
		building.queue_free()
		building=null
		_updeate_ready()
		gm.gms._reload()
remotesync func upd_build():
	if building!=null:
		var v1=building.updpreset_name
		building.queue_free()
		building=null
		gm.gms._reload()
		cr_obj(v1,pid)
		_updeate_ready()
func _on_s_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm") and command==gm.command_id and gamestate.player_name.hero=="builder":
		if choiced==false:
			choiced=true
		else:
			choiced=false
