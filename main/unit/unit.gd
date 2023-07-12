extends KinematicBody2D

#export var path_to_player := NodePath()
var cd={}
var command=0
var ranger=false
var ico=null
var _velocity := Vector2.ZERO
puppet var pvec:=Vector2.ZERO
puppet var pgp=Vector2.ZERO
onready var _agent: NavigationAgent2D = $na
onready var _timer := $Timer
var pid=1
onready var status=$stats
onready var hub= $hurt_box
var hib={"collision_layer":0,"collision_mask":0}

var buffs={
	"aatt":0,
	"adef":0,
	}

var target=Vector2.ZERO
puppet var ptarget=Vector2.ZERO
var _temp_target=Vector2.ZERO
var battle_path=PoolVector2Array([])
func _ready() -> void:
	ico=preload("res://main/sys_parts/minimap_u_icon.tscn").instance()
	ico.name=name
	gm.gms.get_node("cv/c/vc/v/players").add_child(ico)
	$na.target_desired_distance=100*int(ranger)
	var color=gm.commands[command].color
	modulate=Color(color.r,color.g,color.b,color.a)
	if command==gm.command_id:
		ico.modulate=Color(0.0,1.0,0.0,1.0)
		hib["collision_layer"]=0
		hib["collision_mask"]=4
		hub.collision_layer=2
		hub.collision_mask=0
		$attray.collision_mask=4
		$s2.visible=true
		$pb.modulate=Color(0.0,1.0,0.0,1.0)
		#collision_layer=9
		#collision_mask=collision_layer
		#$rc.collision_mask=16
	else:
		ico.modulate=Color(1.0,0.0,0.0,1.0)
		hib["collision_layer"]=0
		hib["collision_mask"]=2
		hub.collision_layer=4
		hub.collision_mask=0
		$attray.collision_mask=2
		$s2.visible=false
		$pb.self_modulate=Color(1.0,0,0,1)
		#collision_layer=17
		#collision_mask=collision_layer
	_timer.connect("timeout", self, "_update_pathfinding")
	_agent.connect("velocity_computed", self, "move")
	_agent.set_navigation(gm._get_nav_path())

var right=false
func _physics_process(delta: float) -> void:
	$pb.max_value=status.m_he
	$pb.value=status.he
	if is_network_master():
		lll()
		var target_global_position := _agent.get_next_location()
		var direction := global_position.direction_to(target_global_position)
		var desired_velocity := direction * _agent.max_speed
		var steering := (desired_velocity - _velocity) * delta * 4.0
		_velocity += steering
		var mn=[]
		if bs!=[]:
			for e in bs:mn.append(global_position.distance_to(e.global_position))
			target=bs[fnc.i_search(mn,mn.min())].global_position
			$attray.cast_to=target-global_position
			if fnc._sqrt(global_position-$attray.get_collision_point())<20+160*int(ranger): 
				rpc("attk")
				_velocity=Vector2.ZERO
				right=target.x>0
		else:
			target=_temp_target
		rset("pgp",global_position)
		rset("ptarget",target)
		rset("pvec",_velocity)
		if _agent.is_navigation_finished():return
		_agent.set_velocity(_velocity)
		
	else:
		_velocity=pvec
		global_position=pgp
		move_and_slide(_velocity)
		target=ptarget
	ico.position=global_position+gm.gms.gr_size/2
	$l2d.points=[Vector2(0,0),target-global_position]

func lll():
	var v=[]
	var id=0
	for e in battle_path:
		if fnc._sqrt(e-global_position)<25:
			battle_path.remove(fnc.i_search(battle_path,e))
	if len(battle_path)>0:
		_temp_target=battle_path[clamp(id,0,len(battle_path)-1)]

func end_att():
	pass

func add_att_zone():
	var att=preload("res://main/sys_parts/boxes/mhitbox.tscn").instance()
	att.command=command
	att.pid=pid
	att.speed=cd["dmgspd"]*get_physics_process_delta_time()
	if att.speed>0:
		att.get_node("spr").show()
		att.get_node("Timer").wait_time=fnc._sqrt(target-global_position)/(cd["dmgspd"]*3.5)
	att.mvec=target-global_position
	att.get_child(1).autostart=true
	att.get_child(0).polygon=PoolVector2Array([Vector2(0,-10),Vector2(0,10),Vector2(30,10),Vector2(30,-10)])
	att.collision_layer=hib["collision_layer"]
	att.collision_mask=hib["collision_mask"]
	att.damage=cd["dmg"]+buffs["aatt"]
	get_parent().add_child(att)
	att.global_position=global_position
	att.global_rotation_degrees=fnc.angle(target-global_position)
	#att.get_node("spr").position.y=cos(deg2rad(att.global_rotation_degrees))*-25

remotesync func attk():
	$AP.play("att",0,cd["att_time"])

func move(velocity: Vector2) -> void:
	_velocity = move_and_slide(velocity)
	if _velocity.x<0:
		right=false
	elif _velocity.x>0:
		right=true
	#_sprite.rotation = lerp_angle(_sprite.rotation, velocity.angle(), 10.0 * get_physics_process_delta_time())

func _update_pathfinding() -> void:
	_agent.set_target_location(target)

func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage*(float(area.damage*area.scale_damage)/(cd["def"]+buffs["adef"]))
	if is_instance_valid(area.owner_):
		area.owner_.points+=cd["help_points"]
	if status.he<=0:
		if is_instance_valid(area.owner_):
			area.owner_.points+=cd["kill_points"]
		gm.commands[area.command]["money"]+=cd["money_to_enemy"]
		if is_network_master():
			rpc("delete")

sync func delete():
	ico.queue_free()
	queue_free()

var bs=[]
func _on_a_body_entered(b):
	if b.get("command") and b.command!=command:
		bs.append(b)

func _on_a_body_exited(b):
	if (b.get("command") and b.command!=command) :
		bs.remove(fnc.i_search(bs,b))
