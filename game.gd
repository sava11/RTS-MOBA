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
			"kill_points":40,
			"help_points":3,
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
			"kill_points":15,
			"help_points":1,
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
				"help_points":2,
				"kill_points":3,
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
			"kill_points":22,
			"help_points":2,
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
					"help_points":3,
					"kill_points":4,
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
			"next_lvl":"bows1",
			"kill_points":17,
			"help_points":1,
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
					"help_points":2,
					"kill_points":3,
				},
			},
		"bows1":{
			"command":-1,
			"img":"res://main/img/buildings/main/",
			"hp":70,
			"update_att":"res://main/img/updbow.png",
			"update_def":"res://main/img/updsheild.png",
			"money_to_enemy":25,
			"rem_value":25,
			"rebuild_value":25,
			"kill_points":25,
			"help_points":2,
			#"curent_unit_name":"bow1",
			"unit":{
					"add_value":20,
					"img":"res://main/img/bow.png",
					"unit_path":"res://main/sys_parts/units/unit1/unit.tscn",
					"ucrt":20,
					"att_time":1,#scale
					"hp":25,
					"dmg":14,
					"dmgspd":120,
					"def":5,
					"money_to_enemy":5,
					"help_points":4,
					"kill_points":5,
				},
			},
		},
	"heroes":{
		"visitor":{
			"img":"res://main/img/eye.png",
			},
		"warrior":{
			"img":"res://main/img/sword.png",
			"lvls":{
				1:{
					"hp":100,
					"def":25,
					"dmg":25,
					"dmgspd":0,
					"att_time":2,#scale
					"money_to_enemy":30,
					"help_points":2,
					"kill_points":5,
					"to_next_lvl":20,
					},
				2:{
					"hp":110,
					"def":25,
					"dmg":30,
					"dmgspd":0,
					"att_time":1.8,#scale
					"money_to_enemy":30,
					"help_points":4,
					"kill_points":7,
					"to_next_lvl":30,
					},
				},
			},
		"builder":{
			"img":"res://main/img/molot.png",
			"lvls":{
				1:{
					"hp":100,
					"def":50,
					"dmg":10,
					"dmgspd":0,
					"att_time":2,#scale
					"money_to_enemy":30,
					"help_points":3,
					"kill_points":5,
					"to_next_lvl":20,
					},
				2:{
					"hp":100,
					"def":55,
					"dmg":15,
					"dmgspd":0,
					"att_time":2.5,#scale
					"money_to_enemy":40,
					"kill_points":6,
					"help_points":4,
					"to_next_lvl":30,
					},
				},
			},
	},
}

enum players_types{spectator,builder,hero}
var commands={}
puppet var pcommands={} 
var command_id=1
onready var gms=get_node("/root/MAIN")
func _get_nav_path():
	return gms.get_node("map").get_child(0).get_node("ground/nav")
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
