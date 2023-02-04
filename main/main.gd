extends Node2D
onready var cam=get_node("cam")
#onready var pol=get_tree().current_scene.get_node("map/pol_ground")
var scs=[1,1]
var l = [5,20]
export(Vector2)var vc=Vector2.ZERO
onready var ysort=$map/PlayGround/ground
var polygon=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("reloadmap",self,"_reload")
	var rect=$map/ground
	rect.rect_position=Vector2(cam.limit_left+vc.x,cam.limit_top+vc.y)
	rect.rect_size=(Vector2(abs(cam.limit_left+vc.x),abs(cam.limit_top+vc.y))+Vector2(abs(cam.limit_right-vc.x),abs(cam.limit_bottom-vc.y)))*1/rect.rect_scale#Vector2(cam.limit_right-vc.x,cam.limit_top+vc.y),Vector2(cam.limit_right-vc.x,cam.limit_bottom-vc.y),Vector2(cam.limit_left+vc.x,cam.limit_bottom-vc.y)
	_reload()
signal reloadmap;
func _reload():
	var pl=PoolVector2Array([Vector2(cam.limit_left+vc.x,cam.limit_top+vc.y),Vector2(cam.limit_right-vc.x,cam.limit_top+vc.y),Vector2(cam.limit_right-vc.x,cam.limit_bottom-vc.y),Vector2(cam.limit_left+vc.x,cam.limit_bottom-vc.y)])
	yield(get_tree(),"idle_frame")
	reload_map(pl,scs,l)
func reload_map(pl,scl,list):
	var p=pl
	for e in ysort.get_children():
		var id=gl.i_search(ysort.get_children(),e)
		var np=NavigationPolygon.new()
		for e1 in get_tree().get_nodes_in_group("outOfBounds_del"):
			var t=Geometry.clip_polygons_2d(pl,to_glb_PV(e1.polygon,e1.global_position,scl[id],list[id]))
			if t!=[]:
				p=t
		np.add_outline(p)
		np.make_polygons_from_outlines()
		e.get_node("n").navpoly=np
		add_path(e.get_node("n"),scl[id],list[id])
func _physics_process(delta):
	if Input.is_action_just_pressed("a"):
		_reload()
var zone=[]
func add_patrol(ent):
	if ent.is_in_group("unit"):
		ent.patr_zone=zone
func reload(path_nod):
	clear_path(path_nod)
	add_path(path_nod,1,2)
func to_glb_PV(pv:PoolVector2Array,pos:Vector2,_scale=1,loc_pos=-1):
	var pool=Geometry.offset_polygon_2d(pv,loc_pos+1,0)[0]
	var poolvec2=PoolVector2Array([])
	for e in pool:
		var t=gl.move(rad2deg(gl.angle(e)))*(gl._sqrt(e*_scale))
		poolvec2.append((t+pos))
	return poolvec2
func _merge_polygons(array:Array):
	var arr=array
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
		bs.append(to_glb_PV(e.polygon,e.global_position,sc,eps))
	if len(bs)>1:
		bs=_merge_polygons(bs)
	var navpol=path_nod.navpoly
	for e in range(0,len(bs)):
		navpol.add_outline(bs[e])
		navpol.make_polygons_from_outlines()
func clear_path(path_nod):
	path_nod.navpoly=null
