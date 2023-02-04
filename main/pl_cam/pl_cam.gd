extends Camera2D
export(int)var command=0
onready var tree=get_tree().current_scene
onready var cam=tree.get_node("cam")
var event_pos=Vector2.ZERO

func _input(event: InputEvent) -> void:
	var w_size=Vector2(abs(limit_left)+abs(limit_right),abs(limit_top)+abs(limit_bottom))
	var w=gl.get_view_win().x#ProjectSettings.get("display/window/size/width")
	var h=gl.get_view_win().y#ProjectSettings.get("display/window/size/height")
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
	pass # Replace with function body.
var choise_rect_pos=Vector2.ZERO
var can_take_pos=Vector2.ZERO
func _process(delta):
	update()
	
	
	var s=get_viewport().size
	var m=get_viewport().get_mouse_position()
	m=(-(m/2-s/4))
	var a=get_local_mouse_position() - s * 0.5
	var a1=get_local_mouse_position()
	var w=ProjectSettings.get("display/window/size/width")
	var h=ProjectSettings.get("display/window/size/height")
	var s1=Vector2(w,h)/s
	if Input.is_action_just_pressed("lbm"):
		can_take_pos=get_global_mouse_position()
	if Input.is_action_just_pressed("cam_move"):
		v=position+a*s1
	if Input.is_action_pressed("cam_move"):
		position=-a*s1+v
	position.x=clamp(position.x,limit_left+w/2*cam.zoom.x,limit_right-w/2*cam.zoom.x)
	position.y=clamp(position.y,limit_top+h/2*cam.zoom.y,limit_bottom-h/2*cam.zoom.y)

	#print((to_global(get_local_mouse_position())-global_position)+get_local_mouse_position())
	#offset=(get_global_mouse_position()-global_position)*tree.get_node("cam").zoom
func _draw():
	if Input.is_action_pressed("lbm"):
		if tree.get_node("ar").get_child_count()==0:
			if choise_rect_pos!=get_global_mouse_position():
				choise_rect_pos=get_global_mouse_position()
				var a=Area2D.new()
				var c=CollisionShape2D.new()
				a.add_child(c)
				a.name="ar"
				c.name="col"
				c.shape=RectangleShape2D.new()
				tree.get_node("ar").add_child(a)
				a.collision_layer=5
				a.set_script(preload("res://main/choise_script.gd"))
				a.connect("body_entered",a,"b_in")
				a.connect("body_exited",a,"b_out")
		if tree.get_node("ar").get_child_count()>0:
			var c=tree.get_node("ar/ar/col")
			var a=tree.get_node("ar/ar")
			c.get_parent().collision_layer=8
			c.get_parent().collision_mask=8
			a.global_position=(get_global_mouse_position()-choise_rect_pos)/2+choise_rect_pos
			c.shape.extents=(get_global_mouse_position()-choise_rect_pos)/2
			draw_rect(Rect2(get_local_mouse_position()-c.shape.extents*2,c.shape.extents*2),Color(50,200,50), false, 0.1,true)
	else:
		choise_rect_pos=get_global_mouse_position()
		if tree.get_node("ar").get_child_count()>0:
			tree.get_node("ar/ar").disconnect("body_entered",tree.get_node("ar/ar"),"b_in")
			tree.get_node("ar/ar").disconnect("body_exited",tree.get_node("ar/ar"),"b_out")
			tree.get_node("ar/ar").queue_free()
var v=Vector2.ZERO
var pres_l=false
