extends Node2D

var polygon=[]
var scs=[1,1]
var pause=true
onready var cv=$cv
onready var cam=$cam
onready var rect=$map.get_child(0).get_node("ground")
onready var gr_size=rect.rect_size*rect.rect_scale
func _ready():
	#get_tree().paused=true
	#cam.limit_left=rect.rect_position.x
	#cam.limit_right=rect.rect_position.x+rect_size.x
	#cam.limit_top=rect.rect_position.y
	#cam.limit_bottom=rect.rect_position.y+rect_size.y
	_reload()

func _reload():
	var pl=PoolVector2Array([
		Vector2(rect.rect_position.x,rect.rect_position.y),
		Vector2(rect.rect_position.x+gr_size.x,rect.rect_position.y),
		Vector2(rect.rect_position.x+gr_size.x,rect.rect_position.y+gr_size.y),
		Vector2(rect.rect_position.x,rect.rect_position.y+gr_size.y)
	])
	yield(get_tree(),"idle_frame")
	reload_map(pl)
func reload_map(pl):
	var p=pl
	var e=$map.get_child(0).get_node("PlayGround/ground").get_child(0)
	e.get_child(0).navpoly=NavigationPolygon.new()
	#for e1 in get_tree().get_nodes_in_group("outOfBounds_del"):
	#	var t=Geometry.clip_polygons_2d(pl,fnc.to_glb_PV(e1.polygon,e1.global_position,1,0))
	#	if t!=[]:
	#		p=t
	e.get_child(0).navpoly.add_outline(p)
	e.get_child(0).navpoly.make_polygons_from_outlines()
	add_path(e.get_child(0))
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

func scl(p:PoolVector2Array,v:Vector2):
	var po=PoolVector2Array([])
	for e in p:
		po.append(e*v)
	return po

func add_path(path_nod:NavigationPolygonInstance):
	var bs=[]
	for e in get_tree().get_nodes_in_group("ground_build"):
		bs.append(fnc.to_glb_PV_and_rot(scl(e.polygon,e.global_scale),e.global_position*e.global_scale,e.global_rotation_degrees,1,15))
	if len(bs)>1:
		bs=_merge_polygons(bs)
	for e in range(0,len(bs)):
		path_nod.navpoly.add_outline(bs[e])
	path_nod.navpoly.make_polygons_from_outlines()

#func _physics_process(delta):
#	for e in gm.commands.keys():
#		if gm.commands.get(e)==null:print(gm.commands," ",e)
#		if gm.commands.get(e)!=null and gm.commands.get(e).battled_by!=-1:
#			gamestate.end_game()
			#get_tree().paused=true


#func get_nearst_enemy_base(gpos,command):
#	var nds=get_tree().get_nodes_in_group("MBASE")
#	for e in nds:
#		if e.command==command:
#			nds.remove(fnc.i_search(nds,e))
#	var ps=[]
#	for e in nds:
#		ps.append(fnc._sqrt(e.global_position-gpos))
#	if fnc.i_search(ps,ps.min())!=-1:
#		return nds[fnc.i_search(ps,ps.min())]
#	else: return null


#func find_nearst_path(gpos,ps):
#	var l=[]
#	for e in ps:
#		var l1=[]
#		var min_dot_id=0
#		for i in e:
#			l1.append(fnc._sqrt(i-gpos))
#		if l1[fnc.i_search(l1,l1.min())]<l1[min_dot_id]:
#			min_dot_id=fnc.i_search(l1,l1.min())
#		l.append(l1[min_dot_id])
#	return fnc.i_search(l,l.min())
#func find_nearst_dot_in_path(gpos,path):
#	var l=[]
#	for i in path:
#		l.append(fnc._sqrt(i-gpos))
#	return fnc.i_search(l,l.min())

#func get_min_points(gpos):
#	var curnet_path_id=find_nearst_path(gpos,path_points)
#	var min_len_id=find_nearst_dot_in_path(gpos,path_points[curnet_path_id])
#	#print(min_point)
#	if 0==min_len_id:
#		return path_points[curnet_path_id]
#	else:
#		var p=path_points[curnet_path_id]
#		p.invert()
#		return p


