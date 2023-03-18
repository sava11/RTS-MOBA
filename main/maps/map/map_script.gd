extends Node2D
var map_players_max=2
var building=load("res://main/objs/building/buildings/base.tscn")
var build_zone=load("res://main/maps/build_area/build_part.tscn") 
var polygon=[]
var path_points=[]
var scs=[1,1]
var l = [5,20]
var pause=true
func _ready():
	#get_tree().paused=true
	var rect=$ground
	var rect_size=rect.rect_size*rect.rect_scale
	gm.cam.limit_left=rect.rect_position.x
	gm.cam.limit_right=rect.rect_position.x+rect_size.x
	gm.cam.limit_top=rect.rect_position.y
	gm.cam.limit_bottom=rect.rect_position.y+rect_size.y
	_reload()
	for e in $PlayGround.get_children():
		if e is Line2D:
			path_points.append(fnc.to_glb_PV(e.points,e.position))
	pass # Replace with function body.
func get_min_points(gpos):
	var l=[]
	var min_len_id=0
	for e in path_points:
		var l1=[]
		for i in e:
			l1.append(fnc._sqrt(gpos-i))
			min_len_id=fnc.i_search(l1,l1.min())
		l.append(l1.min())
	#print(min_point)
	if 0==min_len_id:
		return path_points[fnc.i_search(l,l.min())]
	else:
		var p=path_points[fnc.i_search(l,l.min())]
		p.invert()
		return p
func get_nearst_enemy_base(gpos,command):
	var nds=get_tree().get_nodes_in_group("MBASE")
	for e in nds:
		if e.command==command:
			nds.remove(fnc.i_search(nds,e))
	var ps=[]
	for e in nds:
		ps.append(fnc._sqrt(e.global_position-gpos))
	if fnc.i_search(ps,ps.min())!=-1:
		return nds[fnc.i_search(ps,ps.min())]
	else: return null

func _reload():
	var pl=PoolVector2Array([Vector2(gm.cam.limit_left,gm.cam.limit_top),Vector2(gm.cam.limit_right,gm.cam.limit_top),Vector2(gm.cam.limit_right,gm.cam.limit_bottom),Vector2(gm.cam.limit_left,gm.cam.limit_bottom)])
	yield(get_tree(),"idle_frame")
	reload_map(pl,scs,l)
func reload_map(pl,scl,list):
	var p=pl
	for e in $PlayGround/ground.get_children():
		var id=fnc.i_search($PlayGround/ground.get_children(),e)
		e.get_node("n").navpoly=NavigationPolygon.new()
		#for e1 in get_tree().get_nodes_in_group("outOfBounds_del"):
		#	var t=Geometry.clip_polygons_2d(pl,fnc.to_glb_PV(e1.polygon,e1.global_position,1,0))
		#	if t!=[]:
		#		p=t
		e.get_node("n").navpoly.add_outline(p)
		e.get_node("n").navpoly.make_polygons_from_outlines()
		add_path(e.get_node("n"),scl[id],list[id])
func _merge_polygons(array:Array):
	var arr=array
	var i=0
	while i<len(arr):
		var i1=0
		while i1<len(arr):
			var loc_i=fnc.circ(i1+1,0,len(arr)-1)
			var poly=Geometry.merge_polygons_2d(arr[i1],arr[loc_i])
			if len(poly)==1:
				arr[i1]=poly[0]
				arr.remove(loc_i)
			i1+=1
		i+=1
	return arr
func add_path(path_nod:NavigationPolygonInstance,sc=1.0,eps=0.0):
	var bs=[]
	for e in get_tree().get_nodes_in_group("ground_build"):
		#print(e.get_parent())
		bs.append(fnc.to_glb_PV_and_rot(e.polygon,e.global_position,e.global_rotation,sc,eps))
	if len(bs)>1:
		bs=_merge_polygons(bs)
	for e in range(0,len(bs)):
		path_nod.navpoly.add_outline(bs[e])
		path_nod.navpoly.make_polygons_from_outlines()

func _physics_process(delta):
	if Input.is_action_just_pressed("s"):get_tree().paused=not get_tree().paused
	if len(get_tree().get_nodes_in_group("MBASE"))==1:
		get_tree().paused=true

func spawn_new_rebuild_area(PNode,pos:Vector2,rot:float,set_pos:Vector2,command:int):
	var obj=build_zone.instance()
	obj.command=command
	PNode.call_deferred("add_child",obj)
	yield(get_tree(),"idle_frame")
	obj.global_position=pos
	obj.rotation_degrees=rot
	obj.get_node("p").global_position=set_pos
	_reload()


func _on_pause_timer_timeout():
	#get_tree().paused=false
	pause=false
	get_parent().get_parent().get_node("cl").emit_signal("msg","game started")
	pass # Replace with function body.
