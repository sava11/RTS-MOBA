extends Area2D
export(float) var damage=1
export(float) var scale_damage=1
var pid=1
var mvec=Vector2.ZERO
var speed=0
var command=0
func set_anim(ang:float,t:String):
	var type=0
	type=fnc.get_ang_move(ang-180,45)+1
	if type!=0:
		var input=t+"-"+str(type)
		$spr.play(input)
func _ready():
	if get_parent().get("command")!=null:
		command=get_parent().command
	if get_network_master()==1:
		set_network_master(pid)
	var ang=360
	if mvec!=Vector2.ZERO:
		ang=fnc.angle(mvec)
		rotation_degrees=ang
	if speed==0:
		set_physics_process(false)
func _physics_process(delta):
	global_position+=mvec*speed*delta


func _on_Timer_timeout():
	queue_free()
