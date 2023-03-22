extends Node2D

onready var txt=$cv/rt

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

remotesync func add_new_sts(pos,id):
	var a=load("res://main/Base/rb2d.tscn").instance()
	a.set_network_master(id)
	$Players.add_child(a)
	a.global_position=pos
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if gm.commands.has(gm.command_id):
		txt.text=str(gm.commands[gm.command_id]["money"])
	#if is_network_master():
		#if Input.is_action_just_pressed("rbm"):
			#rpc("add_new_sts", Vector2(500,500),get_tree().get_network_unique_id())
