extends Node

var objs={
	"buildings":{
		"MBASE":{
			"color":{"r":0,"g":0,"b":0,"a":0},
			"command":-1,
			"money":500.0,
			"name":"",
			"ucrt":5,
			"hp":500,
			"money_to_enemy":100,
			#"curent_unit_name":"builder1",
			#"units":{
			#	"builder1":{
			#		"unit_path":"null",
			#		"ucrt":20,
			#		},
			#	},
			"path_to_enemy":[],
		},
		"swords":{
			"command":-1,
			"hp":90,
			"path_to_enemy":[],
			"update_att":"res://main/img/updsword.png",
			"update_def":"res://main/img/updsheild.png",
			"money_to_enemy":25,
			#"curent_unit_name":"sword1",
			"units":{
				"sword1":{
					"add_value":25,
					"unit_path":"res://main/sys_parts/units/unit1/unit.tscn",
					"ucrt":5,
					"att_time":2,#scale
					"hp":20,
					"dmg":5,
					"def":5,
					"money_to_enemy":5,
					},
				},
			},
		"bows":{
			"command":-1,
			"hp":70,
			"path_to_enemy":[],
			"update_att":"res://main/img/updbow.png",
			"update_def":"res://main/img/updsheild.png",
			"money_to_enemy":25,
			#"curent_unit_name":"bow1",
			"units":{
				"bow1":{
					"add_value":20,
					"unit_path":"null",
					"ucrt":7.5,
					"money_to_enemy":5,
					},
				},
			},
		"holys":{
			"command":-1,
			"hp":120,
			"path_to_enemy":[],
			"update_att":"res://main/img/gift_money.png",
			"update_def":"res://main/img/updsheild.png",
			"money_to_enemy":5,
			#"curent_unit_name":"sword1",
			"units":{
				"holy1":{
					"add_value":30,
					"unit_path":"null",
					"ucrt":12,
					"money_to_enemy":0,
					},
				},
			},
	},
	"player":{
		"id":0,
		"type":players_types.spectator,
		"unit":"",
	}
}

var players={}
enum players_types{spectator,builder,hero}
var commands={}
var command={}
puppet var pcommands={} 
var command_id=2
onready var gms=get_node("/root/MAIN")
func _get_nav_path(t):
	return gms.get_node("map").get_child(0).get_node("PlayGround/ground").get_child(t)
func can_change_money(lcommand:int,value):
	if (value<0 and commands[lcommand].money>=abs(value)) or value>0:
		commands[lcommand].money+=value
		return true
	else:return false
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
