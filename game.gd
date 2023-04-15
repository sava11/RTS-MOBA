extends Node

var objs={
	"buildings":{
		"MBASE":{
			"color":{"r":0,"g":0,"b":0,"a":0},
			"img":"res://main/img/buildings/main/",
			#"command":-1,
			"money":50.0,
			"name":"",
			"ucrt":5,
			"hp":500,
			"money_to_enemy":100,
			"rem_value":50,
			"battled_by":-1,
			#"curent_unit_name":"builder1",
			#"units":{
			#	"builder1":{
			#		"unit_path":"null",
			#		"ucrt":20,
			#		},
			#	},
		},
		"swords":{
			"command":-1,
			"img":"res://main/img/buildings/main/",
			"hp":90,
			"update_att":"res://main/img/updsword.png",
			"update_def":"res://main/img/updsheild.png",
			"money_to_enemy":25,
			"rem_value":25,
			"rebuild_value":15,
			"next_lvl":"swords1",
			#"curent_unit_name":"sword1",
			"unit":{
				"add_value":25,
				"img":"res://main/img/sword.png",
				"unit_path":"res://main/sys_parts/units/unit1/unit.tscn",
				"ucrt":10,
				"att_time":2,#scale
				"hp":50,
				"dmg":5,
				"dmgspd":0,
				"def":5,
				"money_to_enemy":5,
				},
			},
		"swords1":{
			"command":-1,
			"img":"res://main/img/buildings/main/",
			"hp":130,
			"update_att":"res://main/img/updsword.png",
			"update_def":"res://main/img/updsheild.png",
			"money_to_enemy":30,
			"rem_value":30,
			"rebuild_value":25,
			#"next_lvl":"",
			#"curent_unit_name":"sword1",
			"unit":{
					"add_value":25,
					"img":"res://main/img/sword.png",
					"unit_path":"res://main/sys_parts/units/unit1/unit.tscn",
					"ucrt":15,
					"att_time":2,#scale
					"hp":70,
					"dmg":7,
					"dmgspd":0,
					"def":10,
					"money_to_enemy":7,
					},
			},
		"bows":{
			"command":-1,
			"img":"res://main/img/buildings/main/",
			"hp":70,
			"update_att":"res://main/img/updbow.png",
			"update_def":"res://main/img/updsheild.png",
			"money_to_enemy":25,
			"rem_value":25,
			"rebuild_value":15,
			#"curent_unit_name":"bow1",
			"unit":{
					"add_value":20,
					"img":"res://main/img/bow.png",
					"unit_path":"res://main/sys_parts/units/unit1/unit.tscn",
					"ucrt":20,
					"att_time":1,#scale
					"hp":20,
					"dmg":10,
					"dmgspd":100,
					"def":2,
					"money_to_enemy":5,
					},
			},
		},
	"heroes":{
		"visitor":{
		"img":"res://main/img/eye.png",
			},
		"warior":{
			"img":"res://main/img/sword.png",
			"hp":100,
			"def":25,
			"dmg":25,
			"dmgspd":0,
			"att_time":2,#scale
			"money_to_enemy":30
			},
		"builder":{
			"img":"res://main/img/molot.png",
			"hp":100,
			"def":50,
			"dmg":10,
			"dmgspd":0,
			"att_time":2,#scale
			"money_to_enemy":30
			},
	},
	
}

enum players_types{spectator,builder,hero}
var commands={}
puppet var pcommands={} 
var command_id=1
onready var gms=get_node("/root/MAIN")
func _get_nav_path(t):
	return gms.get_node("map").get_child(0).get_node("PlayGround/ground").get_child(t)
func can_change_money(lcommand:int,value):
	if (value<0 and commands[lcommand].money>=abs(value)) or value>0:
		commands[lcommand].money+=value
		return true
	return false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_tree().network_peer!=null:
		if get_tree().is_network_server():
			rset("pcommands", commands)
		else:
			commands=pcommands
	pass
