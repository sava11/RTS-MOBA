extends Control
var allplayers=0
const c_builders=1
const c_other_heroes=4
var builders=Vector2.ZERO
var other_heroes=Vector2.ZERO


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
	list.remove(list.find("visitor"))
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
remote func upd_ch_l():
	refresh_lobby()
remote func sent_to_server_hero(e:String):
	if get_tree().get_rpc_sender_id()!=get_tree().get_network_unique_id() and get_tree().get_rpc_sender_id()!=0 :
		gamestate.players[get_tree().get_rpc_sender_id()].hero=e
		rpc_id(get_tree().get_rpc_sender_id(),"upd_ch_l")
	else:
		gamestate.player_name.hero=e
	refresh_lobby()

func _on_host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""

	var playername = $Connect/Name.text
	gamestate.host_game(playername)
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
	gm.commands={}
	show()
	$Connect.show()
	$Players.hide()
	$charters.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$charters.hide()


var can_start_game=false
func search_in_list(id):
	var list=gamestate.players.keys()
	list.insert(0,gamestate.peer.get_unique_id())
	for e in range(0,list.size()):
		if list[e]==id:
			return e
	return -1
func _chh(peer_id:int,ch:Dictionary,postname=""):
	$Players/List.add_item(ch.name+postname)
	$Players/List.set_item_icon(search_in_list(peer_id),load(gm.objs.heroes[ch.hero].img))
	if ch.hero!="visitor":
		if ch.hero=="builder":
			if ch.command==1:
				builders.x+=1
				allplayers+=1
			else:
				allplayers+=1
				builders.y+=1
		elif ch.hero=="warrior":
			if ch.command==1:
				allplayers+=1
				other_heroes.x+=1
			else:
				allplayers+=1
				other_heroes.y+=1
		
		if ch.command==1:
			$Players/c1/l.add_item(ch.name+postname)
			var id=search_in_list(peer_id)
			$Players/c1/l.set_item_icon($Players/c1/l.get_item_count()-1,load(gm.objs.heroes[ch.hero].img))
			$Players/c1/m/t.text=str(builders.x)+"|"+str(c_builders)
			if builders.x>c_builders:
				$Players/c1/m/t.self_modulate=Color(1.0,0.0,0.0,1.0)
			else:
				$Players/c1/m/t.self_modulate=Color(1.0,1.0,1.0,1.0)
			$Players/c1/w/t.text=str(other_heroes.x)+"|"+str(c_other_heroes)
			if other_heroes.x>c_other_heroes:
				$Players/c1/w/t.self_modulate=Color(1.0,0.0,0.0,1.0)
			else:
				$Players/c1/w/t.self_modulate=Color(1.0,1.0,1.0,1.0)
		elif ch.command==2:
			$Players/c2/l.add_item(ch.name+postname)
			var id=search_in_list(peer_id)
			$Players/c2/l.set_item_icon($Players/c2/l.get_item_count()-1,load(gm.objs.heroes[ch.hero].img))
			$Players/c2/m/t.text=str(builders.y)+"|"+str(c_builders)
			if builders.y>c_builders:
				$Players/c2/m/t.self_modulate=Color(1.0,0.0,0.0,1.0)
			else:
				$Players/c2/m/t.self_modulate=Color(1.0,1.0,1.0,1.0)
			$Players/c2/w/t.text=str(other_heroes.y)+"|"+str(c_other_heroes)
			if other_heroes.y>c_other_heroes:
				$Players/c2/w/t.self_modulate=Color(1.0,0.0,0.0,1.0)
			else:
				$Players/c2/w/t.self_modulate=Color(1.0,1.0,1.0,1.0)
	else:
		ch.command=0
func refresh_lobby():
	var players = gamestate.players
	allplayers=0
	builders=Vector2.ZERO
	other_heroes=Vector2.ZERO
	$Players/List.clear()
	$Players/c1/m/t.text="0|"+str(c_builders)
	$Players/c1/w/t.text="0|"+str(c_other_heroes)
	$Players/c2/m/t.text="0|"+str(c_builders)
	$Players/c2/w/t.text="0|"+str(c_other_heroes)
	$Players/c2/l.clear()
	$Players/c1/l.clear()
	_chh(gamestate.peer.get_unique_id(),gamestate.player_name," (You)")
	for p in players.keys():
		_chh(p,players[p])
	if (builders.x==builders.y and builders.y==c_builders) and (other_heroes.x==other_heroes.y and other_heroes.y<=c_other_heroes):
		can_start_game=true
	else:
		can_start_game=false
	$Players/Start.disabled = not (get_tree().is_network_server() and can_start_game==true and players<c_builders*2+c_other_heroes*2)
func clear_commandles_players():
	var players=gamestate.players
	if gamestate.player_name.command==0:
		gamestate.player_name.hero="visitor"
	for p in players.keys():
		_chh(p,players[p])
		if players[p].command==0:
			players[p].hero="visitor"

func _on_start_pressed():
	$charters.hide()
	$Players.hide()
	gamestate.begin_game()


func _on_find_public_ip_pressed():
	OS.shell_open("https://icanhazip.com/")


func _on_show_charters_button_down():
	$Players.hide()
	$charters.show()


func _on_show_players_button_down():
	$Players.show()
	$charters.hide()

remotesync func sent_to_server_hero_command(e:int):
	if get_tree().get_rpc_sender_id()!=get_tree().get_network_unique_id() and get_tree().get_rpc_sender_id()!=0:
		gamestate.players[get_tree().get_rpc_sender_id()].command=e
		rpc_id(get_tree().get_rpc_sender_id(),"upd_ch_l")
	else:
		gamestate.player_name.command=e
	refresh_lobby()
func _on_c1b_button_down():
	rpc("sent_to_server_hero_command",1)
	if (builders.x<c_builders and gamestate.player_name.hero=="builder") or (other_heroes.x<c_other_heroes 
	and gamestate.player_name.hero!="builder"):
		gamestate.player_name.command=1


func _on_c2b_button_down():
	rpc("sent_to_server_hero_command",2)
	if (builders.y<c_builders and gamestate.player_name.hero=="builder") or (other_heroes.y<c_other_heroes 
	and gamestate.player_name.hero!="builder"):
		gamestate.player_name.command=2


func _on_watch_button_down():
	_set_hero("visitor")
	pass
