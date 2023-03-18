extends Node
var parametrs={
	"sword":{
		"HP":20,
		"speed":100,
		"command":-1,
		"type":0,
		"dmg":3,
		"attack_speed":1.2,
		"def":5,
		"money_to_enemy":5,
	},
	"bow":{
		"HP":15,
		"speed":100,
		"command":-1,
		"type":0,
		"dmg":6,
		"attack_speed":1.2,
		"def":3,
		"money_to_enemy":5,
	},
	"holy":{
		"HP":25,
		"speed":100,
		"command":-1,
		"type":0,
		"dmg":0,
		"attack_speed":1.2,
		"def":4.5,
		"add_att":2,
		"add_def":5,
		"money_to_enemy":0,
	},
}
var bparametrs={
	"MBASE":{
		"posx":0,
		"posy":0,
		"money_to_enemy":100,
		"command":-1,
		"p_id":-1,
		"money":50,
		"battled_by":-1,
		"color":{
			"r":0,
			"g":0,
			"b":0,
			"a":0,
			},
		"name":"",
		"HP":500,
		"holy_blessing":0.0,
	},
	"swords":{
		"money_to_enemy":25,
		"command":-1,
		"HP":200,
		"create_unit_time":10.0,
		"unit":"res://main/units/unit.tscn",
		"update_att":"res://main/img/updsword.png",
		"update_def":"res://main/img/updsheild.png",
	},
	"bows":{
		"money_to_enemy":25,
		"command":-1,
		"HP":175,
		"create_unit_time":10,
		"unit":"res://main/units/bowers/bower.tscn",
		"update_att":"res://main/img/upbow.png",
		"update_def":"res://main/img/updsheild.png",
	},
	"holys":{
		"money_to_enemy":25,
		"command":-1,
		"HP":225,
		"create_unit_time":30,
		"unit":"res://main/units/holys/holy.tscn",
		"update_att":"res://main/img/gift_money.png",
		"update_def":"res://main/img/updsheild.png",
	},
}
