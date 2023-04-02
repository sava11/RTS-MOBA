extends Control


func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]
	var win=fnc.get_prkt_win()
	var list=gm.objs.heroes.keys()
	var sizex=min(win.x,win.y)*0.09
	var otstup=10
	for e in list:
		var btn=Button.new()
		btn.name=str(e)
		btn.expand_icon=true
		btn.rect_size=Vector2(sizex,sizex)
		$charters/hrs.add_child(btn)
		btn.set_name(e)
		btn.icon=load(gm.objs.heroes.get(e)["img"])
		btn.connect("button_down",self,"_set_hero",[e])
		#btn.text=e[0]+e[1]
		btn.focus_mode=Control.FOCUS_NONE
		btn.mouse_filter=Control.MOUSE_FILTER_PASS
		btn.rect_position=Vector2((btn.rect_size.x+otstup)*fnc.i_search(list,e)+otstup/2,otstup/2)
func _set_hero(e:String):
	for e1 in gamestate.players.keys():
		rpc_id(e1,"sent_to_server_hero",e)
	sent_to_server_hero(e)
remote func upd_ch_l(d:Dictionary):
	gamestate.players_charters=d
	refresh_lobby()
remote func sent_to_server_hero(e:String):
	if get_tree().get_rpc_sender_id()!=0:
		gamestate.players_charters[get_tree().get_rpc_sender_id()].hero=e
		rpc_id(get_tree().get_rpc_sender_id(),"upd_ch_l",gamestate.players_charters)
	else:
		gamestate.players_charters[1].hero=e
	refresh_lobby()

func _on_host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""

	var player_name = $Connect/Name.text
	gamestate.host_game(player_name)
	refresh_lobby()


func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true

	var player_name = $Connect/Name.text
	gamestate.join_game(ip, player_name)


func _on_connection_success():
	$Connect.hide()
	$Players.show()


func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")


func _on_game_ended():
	show()
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(gamestate.get_player_name() + " (You)")
	var charter=gamestate.get_self_charter()
	if charter!=null and charter.hero!="":
		$Players/List.set_item_icon(0,load(gm.objs.heroes[charter.hero].img))
	var i=1
	for p in players:
		for id in gamestate.players.keys():
			if gamestate.players[id]==p:
				charter=gamestate.players_charters[id]
				break
		
		$Players/List.add_item(p)
		if charter!=null and charter.hero!="":
			$Players/List.set_item_icon(i,load(gm.objs.heroes[charter.hero].img))
		i+=1

	$Players/Start.disabled = not get_tree().is_network_server()


func _on_start_pressed():
	$charters.hide()
	$Players.hide()
	gamestate.begin_game()


func _on_find_public_ip_pressed():
	OS.shell_open("https://icanhazip.com/")


func _physics_process(delta):
	pass#$Players/List.


func _on_show_charters_button_down():
	$Players.hide()
	$charters.show()


func _on_show_players_button_down():
	$Players.show()
	$charters.hide()
