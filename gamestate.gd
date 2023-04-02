extends Node


# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)
var world_name="MAIN"
# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 2

var peer = null

# Name for my player.
var player_name = "The Warrior"

# Names for remote players in id:name format.
var players = {}
var players_charters = {}
var players_ready = []


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/"+world_name): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	players_charters.merge({
		id:{
			"name":new_player_name,
			"hero":""
	}
	})
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	players_charters.erase(id)
	emit_signal("player_list_changed")

func get_command(i,p,c):
	var t=p/c
	for e in range(1,c+1):
		if i<t*e:
			return e

remote func pre_start_game(spawn_points):
	# Change scene.
	var world = load("res://main/world.tscn").instance()
	world_name=world.name
	get_tree().get_root().get_node("Lobby").hide()

	#var player_scene = load("res://main/player/rb2d.tscn")
	var i=0
	var b_i=0
	gm.gms=world
	for p_id in spawn_points:
		var player = preload("res://main/player/player.tscn").instance()
		player.set_name(str(p_id)) # Use unique ID as node name.
		player.set_network_master(p_id) #set unique id as master.
		#player.pid=p_id
		player.command=get_command(i,len(get_player_list())+1,2)
		player.global_position=world.get_node("map").get_child(0).get_node("spawnpoints").get_child(i).global_position
		player.target=world.get_node("map").get_child(0).get_node("spawnpoints").get_child(i).global_position
		player.start_pos=player.global_position
		if players_charters[p_id].hero!="":
			player.cd=gm.objs.heroes[players_charters[p_id].hero]
			player.get_node("s2").texture=load(player.cd.img)
		if players_charters[p_id].hero=="builder":
			world.get_node("map").get_child(0).get_node("PlayGround/mains").get_child(b_i).pid=p_id
			world.get_node("map").get_child(0).get_node("PlayGround/mains").get_child(b_i).set_network_master(p_id)
			b_i+=1
		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_name)
			gm.command_id=get_command(i,len(get_player_list())+1,2)
		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id])
		world.get_node("map").get_child(0).get_node("PlayGround").add_child(player)
		i+=1
	get_tree().get_root().add_child(world)
	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!


remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	players_charters.merge({
		1:{
			"name":new_player_name,
			"hero":""
	}
	})
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)


func join_game(ip, new_player_name):
	
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	players_charters.merge({
		peer.get_unique_id():{
			"name":new_player_name,
			"hero":""
	}
	})
	get_tree().set_network_peer(peer)


func get_player_list():
	return players.values()
func get_players_id_name():
	return players.duplicate()
func get_self_charter():
	for e in players_charters:
		if players_charters[e].name==get_player_name() and e==get_tree().get_network_unique_id():
			return players_charters[e]
	return

func get_player_name():
	return player_name


func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)


func end_game():
	if has_node("/root/"+world_name): # Game is in progress.
		# End it
		get_node("/root/"+world_name).queue_free()

	emit_signal("game_ended")
	players.clear()