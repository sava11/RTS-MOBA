extends Camera2D
export(int)var command=0
onready var tree=get_tree().current_scene
onready var cam=self
var event_pos=Vector2.ZERO

func _input(event: InputEvent) -> void:
	var w_size=Vector2(abs(limit_left)+abs(limit_right),abs(limit_top)+abs(limit_bottom))
	var w=fnc.get_view_win().x#ProjectSettings.get("display/window/size/width")
	var h=fnc.get_view_win().y#ProjectSettings.get("display/window/size/height")
	var _min=[(w_size.x/w),(w_size.y/h)].min()
	if event is InputEventScreenDrag:
		event_pos=event.position
	if event is InputEventMouseButton:
		var s=get_viewport().size
		var m=get_viewport().get_mouse_position()
		if w_size.x+1>w*cam.zoom.x and w_size.y+1>h*cam.zoom.y:
			if event.button_index==4 :
				cam.zoom=cam.zoom*0.9
				
			if event.button_index==5:
				cam.zoom=cam.zoom/0.9
		else:
			cam.zoom.x=_min
			cam.zoom.y=_min
	if not(w_size.x+1>w*cam.zoom.x and w_size.y+1>h*cam.zoom.y):
		cam.zoom.x=_min
		cam.zoom.y=_min

func _ready():
	var w_size=Vector2(abs(limit_left)+abs(limit_right),abs(limit_top)+abs(limit_bottom))
	var w=OS.window_size.x*cam.zoom.y#ProjectSettings.get("display/window/size/width")
	var h=OS.window_size.y*cam.zoom.y#ProjectSettings.get("display/window/size/height")
	var _min=[(w_size.x/w),(w_size.y/h)].min()
	if not(w_size.x+1>w*cam.zoom.x and w_size.y+1>h*cam.zoom.y):
		cam.zoom.x=_min
		cam.zoom.y=_min
func _process(delta):
	var w_size=Vector2(abs(limit_left)+abs(limit_right),abs(limit_top)+abs(limit_bottom))
	var vw=fnc.get_view_win().x#ProjectSettings.get("display/window/size/width")
	var vh=fnc.get_view_win().y#ProjectSettings.get("display/window/size/height")
	var _min=[(w_size.x/vw),(w_size.y/vh)].min()
	if not(w_size.x+1>vw*cam.zoom.x and w_size.y+1>vh*cam.zoom.y):
		cam.zoom.x=_min
		cam.zoom.y=_min
	update()
	
	
	var s=get_viewport().size
	var m=get_viewport().get_mouse_position()
	var a=m - s * 0.5
	var a1=get_local_mouse_position()
	var w=ProjectSettings.get("display/window/size/width")
	var h=ProjectSettings.get("display/window/size/height")
	if Input.is_action_just_pressed("cam_move"):
		v=position+a
	if Input.is_action_pressed("cam_move"):
		position=v-a
	position.x=clamp(position.x,limit_left+w/2*cam.zoom.x,limit_right-w/2*cam.zoom.x)
	position.y=clamp(position.y,limit_top+h/2*cam.zoom.y,limit_bottom-h/2*cam.zoom.y)

	#print((to_global(get_local_mouse_position())-global_position)+get_local_mouse_position())
	#offset=(get_global_mouse_position()-global_position)*tree.get_node("cam").zoom
var v=Vector2.ZERO
var pres_l=false
