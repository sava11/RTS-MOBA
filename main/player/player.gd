extends KinematicBody2D
#export var path_to_player := NodePath()
var cd={}
export(float,1,9999) var see_range=250
export(float,1,9999) var speed=120
var command=0
var _velocity := Vector2.ZERO
puppet var pvec:=Vector2.ZERO
puppet var pgp=Vector2.ZERO
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
puppet var pterg=Vector2.ZERO
var objet_target=null
var not_in_target=true
var _temp_target=Vector2.ZERO
var start_pos=Vector2(0,0)
var points=0
var llvl=1
var lvl=1
var to_next_lvl=0
puppet var plvl=1
func _upd_lvl():
	if cd.empty()==false:
		status.m_he=cd.lvls[lvl].hp
		status.he=cd.lvls[lvl].hp
		to_next_lvl+=cd.lvls[lvl].to_next_lvl

var ico=null
func _ready() -> void:
	ico=preload("res://main/sys_parts/minimap_icon.tscn").instance()
	ico.name=name
	gm.gms.get_node("cv/c/vc/v/players").add_child(ico)
	_upd_lvl()
	if is_network_master():
		$rt.remote_path=gm.gms.get_node("cam").get_path()
		gm.gms.get_node("cam").set("smoothing_enabled",true)
		var pl=PoolVector2Array([
			Vector2(gm.gms.rect.rect_position.x,gm.gms.rect.rect_position.y),
			Vector2(gm.gms.rect.rect_position.x+gm.gms.gr_size.x,gm.gms.rect.rect_position.y+gm.gms.gr_size.y)
		])
		gm.gms.get_node("cam").set("limit_left",pl[0].x)
		gm.gms.get_node("cam").set("limit_top",pl[0].y)
		gm.gms.get_node("cam").set("limit_right",pl[1].x)
		gm.gms.get_node("cam").set("limit_bottom",pl[1].y)
	#fnc.change_parent(get_parent().get_parent(),$lo)
	$s2.texture=load(cd.img)
	#$Light2D.scale=fnc.get_prkt_win()/$Light2D.texture.get_size()
	#$rt.remote_path=gm.gms.get_node("cam").get_path()
	#connect("die",gamestate,"clear_target")
	
	if gm.command_id==command:
		hib["collision_layer"]=0
		hib["collision_mask"]=4
		hub.collision_layer=2
		hub.collision_mask=0
		$vcont/pb.self_modulate=Color(0,1.0,0,1)
		$attray.collision_mask=4
		if not is_network_master():
			ico.modulate=Color(0.0,1.0,0.0,1.0)
	else:
		hib["collision_layer"]=0
		hib["collision_mask"]=2
		hub.collision_layer=4
		hub.collision_mask=0
		ico.hide()
		ico.modulate=Color(1.0,0.0,0.0,1.0)
		$s2.visible=false
		$vcont/pb.self_modulate=Color(1.0,0,0,1)
		$attray.collision_mask=2
	#set_network_master(pid)
	

var right=false
puppet var pright=false
var targeted=false
onready var max_lvl=cd.lvls.keys().max()

func _physics_process(delta: float) -> void:
	$vcont/pb.value=status.he
	$vcont/pb.max_value=status.m_he
	if right==false:
		$spr.play("left")
	else:
		$spr.play("right")
	if is_network_master():
		var vec=Vector2(Input.get_action_strength("r")-Input.get_action_strength("l"),Input.get_action_strength("d")-Input.get_action_strength("u"))
		if vec.x>0:
			right=true
		elif vec.x<0:
			right=false
		_velocity=speed*vec.normalized()
		if llvl!=lvl:
			_upd_lvl()
			llvl=lvl
		if to_next_lvl!=0 and points>to_next_lvl:
			lvl=((points-points%to_next_lvl)/to_next_lvl)+1
			if lvl>max_lvl:
				lvl=max_lvl
				to_next_lvl=0
		if Input.is_action_just_pressed("rbm"):
			if not_in_target==false:objet_target=null
			target=get_global_mouse_position()
			targeted=true
		if is_instance_valid(objet_target) and fnc._sqrt(objet_target.global_position-global_position)>see_range:
			objet_target=null
		if is_instance_valid(objet_target):
			target=objet_target.global_position
			$attray.cast_to=target-global_position
			if fnc._sqrt(global_position-$attray.get_collision_point())<35 and $attray.get_collider()!=null and $attray.get_collider().get_parent()==objet_target.get_parent(): 
				rpc("attk",target,get_network_master())
				#_velocity=Vector2.ZERO
				if targeted==true:
					right=target.x>0
		else:
			$attray.cast_to=Vector2(0,0)
		position.x=clamp(position.x,-gm.gms.gr_size.x/2,gm.gms.gr_size.x/2)
		position.y=clamp(position.y,-gm.gms.gr_size.y/2,gm.gms.gr_size.y/2)
		rset("pvec",_velocity)
		rset("pright",right)
		rset("pgp",global_position)
		rset("pstatus_he",status.he)
		rset("pstatus_m_he",status.m_he)
		rset("pterg",target)
		rset("plvl",lvl)
		move(_velocity)
		#_update_pathfinding()
	else:
		right=pright
		global_position=pgp
		_velocity=pvec
		move_and_slide(_velocity)
		status.he=pstatus_he
		status.m_he=pstatus_m_he
		target=pterg
		lvl=plvl
	$lvl.text=str(lvl)
	ico.position=global_position+gm.gms.gr_size/2



func end_att():
	pass
	#attacked=true
func add_att_zone():
	var att=preload("res://main/sys_parts/boxes/mhitbox.tscn").instance()
	att.command=command
	att.pid=get_network_master()
	att.owner_=self
	att.speed=cd.lvls[lvl]["dmgspd"]*get_physics_process_delta_time()
	if att.speed>0:
		att.get_node("spr").show()
		att.get_node("Timer").wait_time=fnc._sqrt(target-global_position)/(cd.lvls[lvl]["dmgspd"]*2)
	att.mvec=target-global_position
	att.get_child(1).autostart=true
	att.get_child(0).polygon=PoolVector2Array([Vector2(0,-10),Vector2(0,10),Vector2(30,10),Vector2(30,-10)])
	att.collision_layer=hib["collision_layer"]
	att.collision_mask=hib["collision_mask"]
	att.damage=cd.lvls[lvl]["dmg"]+buffs["aatt"]
	get_parent().call_deferred("add_child",att)
	att.global_position=global_position
	att.global_rotation_degrees=fnc.angle(target-global_position)
remotesync func attk(target_pos,pid_):
	$AP.play("att",0,cd.lvls[lvl]["att_time"])
func move(velocity: Vector2) -> void:
	_velocity = move_and_slide(velocity)
	#_sprite.rotation = lerp_angle(_sprite.rotation, velocity.angle(), 10.0 * get_physics_process_delta_time())

func _on_hurt_box_area_entered(area):
	status.he-=area.damage*area.scale_damage*(float(area.damage*area.scale_damage)/(cd.lvls[lvl]["def"]+buffs["adef"]))
	if is_instance_valid(area.owner_):
		area.owner_.points+=cd.lvls[lvl]["help_points"]
	if status.he<=0:
		if is_instance_valid(area.owner_):
			area.owner_.points+=cd.lvls[lvl]["kill_points"]
		gm.commands[area.command]["money"]+=cd.lvls[lvl]["money_to_enemy"]
		if is_network_master():
			rpc("delete",area.pid)

remotesync func delete(id:int):
	$ready.start(4)
	hide()
	$c.disabled=true
	ico.hide()
	global_position=start_pos
	target=start_pos
	_velocity=Vector2(0,0)
	move_and_slide(_velocity)
	status.he=status.m_he
	objet_target=null
	not_in_target=true
	$choice_area.free()
	var cha=preload("res://main/sys_parts/boxes/choice_area.tscn").instance()
	cha.call_deferred("set_name","choice_area")
	call_deferred("add_child",cha)
	#queue_free()
func set_player_name(new_name):
	get_node("Label").set_text(new_name)


func _on_ready_timeout():
	show()
	if gm.command_id==command:
		ico.show()
	$c.disabled=false
