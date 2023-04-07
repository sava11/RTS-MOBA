extends KinematicBody2D

#export var path_to_player := NodePath()
var cd={}
var command=0
var _velocity := Vector2.ZERO
puppet var pvec:=Vector2.ZERO
puppet var pgp=Vector2.ZERO
onready var _agent: NavigationAgent2D = $na
onready var _timer := $Timer
onready var status=$stats
puppet var pstatus_he=0
puppet var pstatus_m_he=0
onready var hub= $hurt_box
var hib={"collision_layer":0,"collision_mask":0}

var buffs={
	"aatt":0,
	"adef":0,
	}

var target=Vector2.ZERO
var objet_target=null
var not_in_target=true
var _temp_target=Vector2.ZERO
var start_pos=Vector2(0,0)
func _ready() -> void:
	#$rt.remote_path=gm.gms.get_node("cam").get_path()
	if cd.empty()==false:
		status.m_he=cd.hp
		status.he=cd.hp
	if gm.command_id==command:
		hib["collision_layer"]=0
		hib["collision_mask"]=4
		hub.collision_layer=2
		hub.collision_mask=0
		$vcont/pb.self_modulate=Color(0,1.0,0,1)
		$attray.collision_mask=4
	else:
		hib["collision_layer"]=0
		hib["collision_mask"]=2
		hub.collision_layer=4
		hub.collision_mask=0
		$s2.visible=false
		$vcont/pb.self_modulate=Color(1.0,0,0,1)
		$attray.collision_mask=2
	_timer.connect("timeout", self, "_update_pathfinding")
	_agent.connect("velocity_computed", self, "move")
	_agent.set_navigation(gm._get_nav_path(0))
	#set_network_master(pid)


func _physics_process(delta: float) -> void:
	if _velocity.x<0:
		$spr.play("left")
	elif _velocity.x>0:
		$spr.play("right")
	$vcont/pb.value=status.he
	$vcont/pb.max_value=status.m_he
	if is_network_master():
		if Input.is_action_just_pressed("rbm"):
			if not_in_target==false:objet_target=null
			target=get_global_mouse_position()
		if is_instance_valid(objet_target):
			target=objet_target.global_position
			$attray.cast_to=target-global_position
			if fnc._sqrt(global_position-$attray.get_collision_point())<35: 
				rpc("attk",target,get_network_master())
				_velocity=Vector2.ZERO
		rset("pgp",global_position)
		rset("pstatus_he",status.he)
		rset("pstatus_m_he",status.m_he)
		if _agent.is_navigation_finished():
			_velocity=Vector2.ZERO
			rset("pvec",_velocity)
			return
		var target_global_position := _agent.get_next_location()
		var direction := global_position.direction_to(target_global_position)
		var desired_velocity := direction * _agent.max_speed
		var steering := (desired_velocity - _velocity) * delta * 4.0
		_velocity += steering
		_agent.set_velocity(_velocity)
		rset("pvec",_velocity)
		#_update_pathfinding()
	else:
		global_position=pgp
		_velocity=pvec
		_agent.set_velocity(_velocity)
		status.he=pstatus_he
		status.m_he=pstatus_m_he



func end_att():
	pass
	#attacked=true
func add_att_zone():
	var att=preload("res://main/sys_parts/boxes/mhitbox.tscn").instance()
	att.command=command
	att.pid=get_network_master()
	att.speed=cd["dmgspd"]*get_physics_process_delta_time()
	if att.speed>0:
		att.get_node("spr").show()
		att.get_node("Timer").wait_time=fnc._sqrt(target-global_position)/(cd["dmgspd"]*2)
	att.mvec=target-global_position
	att.get_child(1).autostart=true
	att.get_child(0).polygon=PoolVector2Array([Vector2(0,-10),Vector2(0,10),Vector2(30,10),Vector2(30,-10)])
	att.collision_layer=hib["collision_layer"]
	att.collision_mask=hib["collision_mask"]
	att.damage=cd["dmg"]+buffs["aatt"]
	get_parent().call_deferred("add_child",att)
	att.global_position=global_position
	att.global_rotation_degrees=fnc.angle(target-global_position)
remotesync func attk(target_pos,pid_):
	$AP.play("att",0,cd["att_time"])
func move(velocity: Vector2) -> void:
	_velocity = move_and_slide(velocity)
	#_sprite.rotation = lerp_angle(_sprite.rotation, velocity.angle(), 10.0 * get_physics_process_delta_time())

func _update_pathfinding() -> void:
	_agent.set_target_location(target)

func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage*(float(area.damage*area.scale_damage)/(cd["def"]+buffs["adef"]))
	if status.he<=0:
		gm.commands[area.command]["money"]+=cd["money_to_enemy"]
		rpc("delete")

remotesync func delete():
	global_position=start_pos
	target=start_pos
	_velocity=Vector2(0,0)
	move_and_slide(_velocity)
	status.he=status.m_he
	objet_target=null
	not_in_target=true
	gm.gms.get_node("cam").global_position=global_position
	#queue_free()
func set_player_name(new_name):
	get_node("Label").set_text(new_name)

