extends Node
var file=File.new()
func _ready():
	pause_mode=Node.PAUSE_MODE_PROCESS
func open_file(res,path,type):
	file.open(res+path,type)
	return file
func close_file():
	file.close()
func get_hero():
	return get_tree().current_scene.get_node("player")
func get_camera():
	return get_tree().current_scene.get_node("cam")
func get_view_win():
	return get_viewport().get_visible_rect().size
func get_prkt_win():
	return Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height"))
func get_viewport_win():
	return get_viewport().get_visible_rect().size
func in_area(p,point):
	var result = false;
	var size=len(p)
	var j = size - 1;
	for i  in range(0,size):
		if ( (p[i].y < point.y && p[j].y >= point.y or p[j].y < point.y && p[i].y >= point.y) and (p[i].x + (point.y - p[i].y) / (p[j].y - p[i].y) * (p[j].x - p[i].x) < point.x) ):
			result = !result;
		j = i;
	return result
func get_area(pol):
	var area=0
	for i in range(0, len(pol) -1):
		area+=pol[i].x*pol[i+1].y-pol[i+1].x*pol[i].y
	return abs(area)
func _rotate_vec(vec:Vector2,ang:float):
	return move(rad2deg(angle(vec))+ang)*_sqrt(vec)
func angle(V:Vector2):
	return rad2deg(-atan2(-V.y,V.x))
func _sqrt(v:Vector2):
	return sqrt(v.x*v.x+v.y*v.y)
func sqrtV(v:Vector2):
	return Vector2(sqrt(v.x),sqrt(v.y))
func move(ang):
	return Vector2(cos(deg2rad(ang)),sin(deg2rad(ang)))
func jos(a,b):
	if b!=0:
		return b*round(a/b)
	else:return 0
func circ(a,mn,mx):
	return a%(mx+1)+mn
func i_search(a,i):
	var inte=0
	for k in a:
		if k==i:
			return inte
		inte+=1
	return -1
static func sum(array):
	var sum = 0.0
	for element in array:
		 sum += element
	return sum
func centr(vect:PoolVector2Array):
	var _x_l=[]
	var _y_l=[]
	for v in vect:
		_x_l.append(v.x)
		_y_l.append(v.y)
	var _len=len(vect)
	var _x=sum(_x_l)/_len
	var _y=sum(_y_l)/_len
	return Vector2(_x,_y)
func search_in_txt(txt:String,word:String):
	for e in txt:
		if e==word[0]:
			var wrd=""
			for e1 in range(i_search(txt,e),i_search(txt,e)+len(word)):
				wrd+=txt[e1]
			if word==wrd:
				return txt
	return ""
func to_glb_PV(pv:PoolVector2Array,pos:Vector2,_scale=1,loc_pos=0):
	var pool=PoolVector2Array([])
	if loc_pos!=0:
		pool=Geometry.offset_polygon_2d(pv,loc_pos,0)[0]
	else:pool=pv
	var poolvec2=PoolVector2Array([])
	for e in pool:
		var t=move(angle(e))*(_sqrt(e*_scale))
		poolvec2.append((t+pos))
	return poolvec2
func to_glb_PV_and_rot(pv:PoolVector2Array,pos:Vector2,rot=0,_scale=1,loc_pos=0):
	var pool=PoolVector2Array([])
	if loc_pos!=0:
		pool=Geometry.offset_polygon_2d(pv,loc_pos,0)[0]
	else:pool=pv
	var poolvec2=PoolVector2Array([])
	for e in pool:
		var t=move(angle(e)+rot)*(_sqrt(e*_scale))
		poolvec2.append(t+pos)
	return poolvec2
func change_parent(where,what):
	what.get_parent().call_deferred("remove_child",what)
	where.call_deferred("add_child",what)
	yield(get_tree(),"idle_frame")
	#what.rotation_degrees=where.rotation_degrees
	#what.position=where.to_local(what.global_position)
func to_glob(pol:PoolVector2Array,pos:Vector2):
	for e in range(0,len(pol)):
		pol[e]=pol[e]+pos
	return pol
func to_loc(pol:PoolVector2Array,pos:Vector2):
	for e in range(0,len(pol)):
		pol[e]=pol[e]-pos
	return pol
func search(text:String):
	var i1=0
	var t=text
	t.erase(i1,6)
	for w1 in range(0,len(t)):
		if w1>=0 and w1<len(t) and t[w1]=="/":t.erase(0,w1+1)
		if w1<0:break
		#else: break
	var t1=text
	t1.erase(len(text)-len(t),len(t))
	var exito=t.split(".")
	exito.append(t1)
	exito.append(t1.split("/"))
	return exito
#func bac_his():
#	if len(menu_history)>1:
#		menu_history.remove(len(menu_history)-1)
func del_simb(txt:String,simbs:Array=[]):
	var word=""
	for s in txt:
		var can_add=true
		for e in simbs:
			if s==e:
				can_add=false
		if can_add==true:
			word+=s
	return word
func get_ang_move(angle:float,ex:float):
	var ang1=abs(ex)
	var le=int(360/ang1)
	var ang=int(abs(angle)+180+ang1/2)%360
	if ang>=0:
		for e in range(0,le):
			if ang>=e*ang1 and ang<(e+1)*ang1:
				return e
