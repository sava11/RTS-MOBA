extends Area2D
export(int)var command=-1
export(float,0,50)var otstup=10
var choiced=false
onready var cntrl=$z_ingx
onready var posy=cntrl.position.y
var node=null
enum t{nill,sword,bow,holy}
export(t)var start_buid=t.nill
var container=null
onready var path=get_parent().get_path()
onready var map=get_tree().current_scene.get_node("map").get_child(0)
var com_data={}
var tree={}

func _ready():
	
	com_data=gm.commands[command]
	if get_parent().get("command")!=null:command=get_parent().command
	if get_parent().get("tree")==null:
			tree={t.sword:{
			"img":"res://main/img/sword.png",
			"obj":load("res://main/objs/building/sworders/swh_0/base.tscn"),
			"value":50,
				},
		t.bow:{
			"img":"res://main/img/aca49daec57b423d08d2462a1bc90413.png",
			"value":50,
				},
		t.holy:{
			"img":"res://main/img/aca49daec57b423d08d2462a1bc90413.png",
			"value":50,
				},}
	else:
		if get_parent().get("tree")!={}:
			tree=get_parent().get("tree")
	cntrl.visible=false
	var win=fnc.get_prkt_win()
	var sizex=min(win.x,win.y)*0.05
	var list=tree.keys()
	for e in list:
		var btn=Button.new()
		btn.name=str(e)
		btn.expand_icon=true
		btn.rect_size=Vector2(sizex,sizex)
		cntrl.add_child(btn)
		btn.icon=load(tree.get(e)["img"])
		btn.connect("button_down",self,"_set_btn",[e])
		#btn.text=e[0]+e[1]
		btn.focus_mode=Control.FOCUS_NONE
		btn.mouse_filter=Control.MOUSE_FILTER_PASS
		btn.rect_position=Vector2((btn.rect_size.x+otstup)*fnc.i_search(list,e)+otstup/2,otstup/2)
	if start_buid!=t.nill:
		cr_obj(tree[start_buid]["obj"].instance())
func _draw():
	if command==gm.command:
		if choiced==true:
			var area=$c.shape.extents
			#draw_rect(r,Color(1.0,1.0,1.0,1.0),false,2.0,true)
			draw_arc(Vector2.ZERO,fnc._sqrt(area),0,PI*2,360,Color(1.0,1.0,1.0,1.0),2.0,true)
			draw_circle($p.position,5,Color(0.0,1.0,0.0,1.0))
			cntrl.visible=true
		else:
			var area=$c.shape.extents
			var r=Rect2(-area,area*2)
			draw_rect(r,Color(0.0,1.0,0.0,1.0),false,2.0,true)
			cntrl.visible=false
func _physics_process(delta):
	var win=fnc.get_prkt_win()
	var sizex=min(win.x,win.y)*0.05
	cntrl.global_rotation_degrees=0
	cntrl.get_child(0).rect_size=Vector2(sizex+otstup,sizex/len(tree.keys())/1.5+otstup)*len(tree.keys())
	cntrl.global_position.x=-cntrl.get_child(0).rect_size.x/2+global_position.x
	cntrl.global_position.y=posy+global_position.y-cntrl.get_child(0).rect_size.y
	if gm.command==command:
		update()
		if mouse_in_area==false and in_but_area==false and Input.is_action_just_pressed("lbm"):
			choiced=false
	
func _on_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("lbm"):
		choiced=not choiced
	pass # Replace with function body.

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

func _set_btn(e):
	var obj=null
	if tree[e].has("obj") and gm.commands[gm.command]["money"]>=tree[e]["value"]:
		obj=tree[e]["obj"].instance()
		cr_obj(obj)
		gm.commands[gm.command]["money"]-=tree[e]["value"]
	if tree[e].has("unit") and gm.commands[gm.command]["money"]>=tree[e]["value"]:
		get_parent().add_unit(preload("res://main/units/unit.tscn"))
		gm.commands[gm.command]["money"]-=tree[e]["value"]
	if tree[e].has("fnc"):
		if tree[e].has("fnc_path"):
			get_node(tree[e]["fnc_path"]).call_deferred(tree[e]["fnc"])
		else:
			call_deferred(tree[e]["fnc"])
	pass
func cr_obj(obj):
	obj.position=position
	obj.rotation_degrees=rotation_degrees
	obj.command=command
	obj.get_node("a1").command=command
	#obj.auto_cr_time=-1
	obj.set_pos=$p.global_position
	get_parent().call_deferred("add_child",obj)
	yield(get_tree(),"idle_frame")
	map._reload()
	queue_free()
