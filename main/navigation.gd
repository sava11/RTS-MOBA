extends Navigation2D
var navpol=null
var sc=1
var pols=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(),"idle_frame")
	cr()
	pass # Replace with function body.

func to_glb_PV(pv:PoolVector2Array,pos:Vector2,_scale:float):
	var poolvec2=PoolVector2Array([])
	for e in pv:
		poolvec2.append((e*_scale+pos))
	return poolvec2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
func cr():
	var bs=get_tree().get_nodes_in_group("ground_build")
	var pol=[]
	var i=0
	while (i < len(bs)):
		if len(bs)>1:
			var pol_a=to_glb_PV(bs[i].get_node("c").polygon,bs[i].global_position,sc)
			var pol_b=to_glb_PV(bs[i+1].get_node("c").polygon,bs[i+1].global_position,sc)
			var poly=Geometry.merge_polygons_2d(pol_a,pol_b)
			if len(poly)==1:
				bs.remove(i+1)
				bs.remove(i)
				pol.append(poly[0])
			else:
				bs.remove(i+1)
				bs.remove(i)
				pol.append(pol_a)
				pol.append(pol_b)
		else:
			pol.append(to_glb_PV(bs[i].get_node("c").polygon,bs[i].global_position,sc))
			bs.remove(i)
	navpol=$n.navpoly
	for e in range(0,len(pol)):
		navpol.add_outline(pol[e])
		navpol.make_polygons_from_outlines()
func del():
	var bs=get_tree().get_nodes_in_group("ground_build")
	navpol=$n.navpoly
	for e in range(0,len(bs)-1):
		for ei in range(0,navpol.get_outline_count()):
			if navpol.get_outline(ei) == to_glb_PV(bs[e].get_node("c").polygon,bs[e].global_position,sc):
				navpol.remove_outline(ei)
		navpol.make_polygons_from_outlines()
	queue_free()
