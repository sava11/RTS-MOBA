extends Area2D
enum t{nill,sword,bow,holy}
export(NodePath)var add_node_path
export(t)var start_build=t.nill
export(int)var command=-1
export(float,0,50)var otstup=10
var choiced=false
puppet var pchoiced=false
onready var cntrl=$z_ingx
onready var posy=cntrl.position.y
var building=null
func _draw():
	if command==gm.command_id:
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
	yield(get_tree(),"idle_frame")
	
	if (building!=null and is_instance_valid(building)!=false) and building.get("command")!=null:command=building.command
	if (building==null or is_instance_valid(building)==false) or building.get("tree")==null:
			tree={
		t.sword:{
			"img":"res://main/img/sword.png",
			"name":"sword",
			"obj_name":"swords",
			"value":50,
				},
		t.bow:{
			"img":"res://main/img/bow.png",
			"name":"bow",
			"obj_name":"bows",
			"value":50,
				},
		t.holy:{
			"img":"res://main/img/holy.png",
			"name":"holy",
			"obj_name":"holys",
			"value":50,
				},}
	else:
		if building.get("tree")!={}:
			if building.type!=0:
				tree={
					"rebuild":{
						"img":"res://main/img/rebuild.png",
						"fnc":"rebuild",
						"value":-25,
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
	
	
func _ready():
	_updeate_ready()
	yield(get_tree(),"idle_frame")
	if start_build!=t.nill:
		print(tree)
		cr_obj(tree[start_build]["obj_name"],tree[start_build]["name"],get_network_master())

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
	if is_network_master():
		var win=fnc.get_prkt_win()
		var sizex=min(win.x,win.y)*0.05
		cntrl.global_rotation_degrees=0
		cntrl.get_child(0).rect_size=Vector2((sizex+otstup)*len(tree.keys()),sizex+otstup)
		cntrl.global_position.x=-cntrl.get_child(0).rect_size.x/2+global_position.x
		cntrl.global_position.y=posy+global_position.y-cntrl.get_child(0).rect_size.y
		if mouse_in_area==false and in_but_area==false and Input.is_action_just_pressed("lbm"):
			choiced=false
		rset("pchoiced",choiced)
	else:
		choiced=pchoiced


func _set_btn(e):
	if is_network_master():
		rpc("logic",e,get_tree().get_network_unique_id())
	#logic(e,get_tree().get_network_unique_id())
remotesync func logic(e,id):
	if tree[e].has("name") and gm.commands[command]["money"]>=tree[e]["value"]:
		cr_obj(tree[e]["obj_name"],tree[e]["name"],id)
	if tree[e].has("unit") and gm.commands[command]["money"]>=tree[e]["value"]:
		building.call_deferred("add_unit",tree[e].unit,id)
	if tree[e].has("fnc"):
		if tree[e].has("fnc_path"):
			#get_node(tree[e]["fnc_path"]).set_network_master(id)
			get_node(tree[e]["fnc_path"]).call_deferred(tree[e]["fnc"])
		else:
			call_deferred(tree[e]["fnc"])
	if tree[e].has("value") and gm.can_change_money(command,-tree[e]["value"]):
		pass
remotesync func cr_obj(objn:String,n:String,id):
	building=load("res://main/Base/rb2d.tscn").instance()
	#obj.set_network_master(get_tree().get_network_unique_id())
	building.preset_name=objn
	building.upreset_name=n
	building.global_position=global_position
	building.global_rotation_degrees=global_rotation_degrees
	building.command=command
	building.pid=id
	building.get_node("pos").global_position=$ps.global_position
	#obj.auto_cr_time=-1
	#obj.set_pos=$p.global_position
	if get_node_or_null(add_node_path)!=null:
		get_node(add_node_path).call_deferred("add_child",building)
	else:get_parent().call_deferred("add_child",building)
	yield(get_tree(),"idle_frame")
	_updeate_ready()
	
	gm.gms._reload()
	#if get_parent().filename=="res://main/Base/rb2d.tscn":
	#	get_parent().queue_free()
	#else:
	#	queue_free()
func _on_s_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm") and command==gm.command_id:
		if choiced==false:
			choiced=true
		else:
			choiced=false
remotesync func rebuild():
	#map.call_deferred("spawn_new_rebuild_area",get_parent().get_parent(),global_position,rotation_degrees,$p.global_position,command)
	
	building.queue_free()
	building=null
	_updeate_ready()
	gm.gms._reload()
