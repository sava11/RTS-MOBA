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
			#"curent_unit_name":"sword1",
			"units":{
				"sword1":{
					"unit_path":"null",
					"ucrt":10,
					},
				},
			},
		"bows":{
			"command":-1,
			"hp":70,
			"path_to_enemy":[],
			"update_att":"res://main/img/updbow.png",
			"update_def":"res://main/img/updsheild.png",
			},
			#"curent_unit_name":"bow1",
			"units":{
				"bow1":{
					"unit_path":"null",
					"ucrt":7.5,
					},
				},
		"holys":{
			"command":-1,
			"hp":120,
			"path_to_enemy":[],
			"update_att":"res://main/img/upd____.png",
			"update_def":"res://main/img/updsheild.png",
			#"curent_unit_name":"sword1",
			"units":{
				"holy1":{
					"unit_path":"null",
					"ucrt":12,
					},
				},
			},
	},
	"units":{
		"sword":{
			"color":{"r":0,"g":0,"b":0,"a":0},
			"command_id":-1,
			"hp":20,
			"att":5,
			"def":0,
			},
		"bow":{
			"color":{"r":0,"g":0,"b":0,"a":0},
			"command_id":-1,
			"hp":20,
			"att":5,
			"def":0,
			},
		"holy":{
			"color":{"r":0,"g":0,"b":0,"a":0},
			"command_id":-1,
			"hp":20,
			"att":5,
			"def":0,
			},
		
	},
}
