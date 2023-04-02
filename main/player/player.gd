extends KinematicBody2D

#export var path_to_player := NodePath()
var cd={}
var command=0
var _velocity := Vector2.ZERO
puppet var pvec:=Vector2.ZERO
puppet var pgp=Vector2.ZERO
onready var _agent: NavigationAgent2D = $na
onready var _timer := $Timer
var pid=1#get_tree().get_network_unique_id()
#onready var _sprite := $Sprite
onready var status=$stats
onready var hub= $hurt_box
var hib={"collision_layer":0,"collision_mask":0}

var buffs={
	"att":0,
	"def":0,
	}

var target=Vector2.ZERO
var _temp_target=Vector2.ZERO
var start_pos=Vector2(0,0)
func _ready() -> void:
	if cd.empty()==false:
		status.m_he=cd.hp
		status.he=cd.hp
		buffs["att"]=cd.att
		buffs["def"]=cd.def
	if gm.command_id==command:
		hib["collision_layer"]=0
		hib["collision_mask"]=4
		hub.collision_layer=2
		hub.collision_mask=0
	else:
		hib["collision_layer"]=0
		hib["collision_mask"]=2
		hub.collision_layer=4
		hub.collision_mask=0
	_timer.connect("timeout", self, "_update_pathfinding")
	_agent.connect("velocity_computed", self, "move")
	_agent.set_navigation(gm._get_nav_path(0))
	#set_network_master(pid)


func _physics_process(delta: float) -> void:
	if is_network_master():
		if Input.is_action_just_pressed("rbm"):
			target=get_global_mouse_position()
		if _agent.is_navigation_finished():
			_velocity=Vector2.ZERO
			return
		var target_global_position := _agent.get_next_location()
		var direction := global_position.direction_to(target_global_position)
		var desired_velocity := direction * _agent.max_speed
		var steering := (desired_velocity - _velocity) * delta * 4.0
		_velocity += steering
		_agent.set_velocity(_velocity)
		rset("pvec",_velocity)
		rset("pgp",global_position)
		#_update_pathfinding()
	else:
		global_position=pgp
		_velocity=pvec
		_agent.set_velocity(_velocity)


func end_att():
	pass
	#attacked=true
func add_att_zone(apos:Vector2,avec:Vector2,aspeed:int,pid_:int):
	var att=preload("res://main/sys_parts/boxes/hitbox.tscn").instance()
	att.command=command
	att.pid=pid_
	att.speed=aspeed
	att.mvec=avec
	att.get_child(1).autostart=true
	att.get_child(0).polygon=PoolVector2Array([Vector2(0,-10),Vector2(0,10),Vector2(35,10),Vector2(35,-10)])
	att.collision_layer=hib["collision_layer"]
	att.collision_mask=hib["collision_mask"]
	att.damage=cd["dmg"]+buffs["aatt"]
	get_parent().call_deferred("add_child",att)
	att.global_position=global_position
	att.global_rotation_degrees=fnc.angle(apos-global_position)
remotesync func attk(target_pos,pid_):
	var t=target_pos-global_position
	$AP.get_animation("att").track_set_key_value(0,0,[target_pos,Vector2(0,0),0,pid_])
	$AP.play("att",0,cd["att_time"])
#	set_anim(fnc.angle(t),"att")
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
	#queue_free()

#func set_anim(ang:float,t:String):
#	var type=0
#	type=fnc.get_ang_move(ang-180,45)+1
	#if type!=0:
		#var input=t+"-"+str(type)
		#$spr.play(input)
		#if t=="att":
		#	$spr.speed_scale=(parametrs["attack_speed"])*1/step/15


func set_player_name(new_name):
	get_node("Label").set_text(new_name)


func _on_a_input_event(viewport, event, shape_idx):
	pass # Replace with function body.