extends Node2D
onready var cam=get_node("cam")
var choised_units=[]
onready var pol=get_tree().current_scene.get_node("pol_ground")
var scs=[1,2]
var l = [5,47]
# Called when the node enters the scene tree for the first time.
func _ready():
	pol.polygon=PoolVector2Array([Vector2(cam.limit_left,cam.limit_top),Vector2(cam.limit_right,cam.limit_top),Vector2(cam.limit_right,cam.limit_bottom),Vector2(cam.limit_left,cam.limit_bottom)])
	reload_map(pol.polygon,[1,1],l)


func reload_map(p,scl,list):
	for e in $ground.get_children():
		var np=NavigationPolygon.new()
		np.add_outline(p)
		np.make_polygons_from_outlines()
		e.get_node("n").navpoly=np
		var id=gl.i_search($ground.get_children(),e)
		add_path(e.get_node("n"),scl[id],list[id])
var zone=[]
func add_patrol(ent):
	if ent.is_in_group("unit"):
		ent.patr_zone=zone

func reload(path_nod):
	clear_path(path_nod)
	add_path(path_nod,1,2)
	
	
func to_glb_PV(pv:PoolVector2Array,pos:Vector2,_scale=1,loc_pos=0):
	var pool=Geometry.offset_polygon_2d(pv,loc_pos+1,0)[0]
	var poolvec2=PoolVector2Array([])
	for e in pool:
		var t=gl.move(rad2deg(gl.angle(e)))*(gl._sqrt(e*_scale))
		poolvec2.append((t+pos))
	return poolvec2


func _merge_polygons(array:Array):
	var arr=array
	var exit_array=[]
	var i=0
	while i<len(arr):
		var i1=0
		while i1<len(arr):
			var loc_i=gl.circ(i1+1,0,len(arr)-1)
			var poly=Geometry.merge_polygons_2d(arr[i1],arr[loc_i])
			if len(poly)==1:
				arr[i1]=poly[0]
				arr.remove(loc_i)
			i1+=1
		i+=1
	return arr

func add_path(path_nod:NavigationPolygonInstance,sc=1,eps=0):
	var bs=[]
	for e in get_tree().get_nodes_in_group("ground_build"):
		bs.append(to_glb_PV(e.get_node("c").polygon,e.global_position,sc,eps))
	if len(bs)>1:
		bs=_merge_polygons(bs)
	else:pass
	if path_nod.navpoly==null:
		var np=NavigationPolygon.new()
		np.add_outline(pol.polygon)
		np.make_polygons_from_outlines()
		path_nod.navpoly=np
	var navpol=path_nod.navpoly
	for e in range(0,len(bs)):
		navpol.add_outline(bs[e])
		navpol.make_polygons_from_outlines()
func clear_path(path_nod):
	var bs=get_tree().get_nodes_in_group("ground_build")
	path_nod.navpoly=null
