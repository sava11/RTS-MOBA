extends OptionButton


var persons={
"Разум":"https://gamerwall.pro/uploads/posts/2023-03/thumbs/1678438641_gamerwall-pro-p-umnii-kot-vkontakte-11.jpg",
#"Шум":"https://tlgrm.ru/_/stickers/ca6/e60/ca6e601f-be4d-4a11-85c1-9a5bf60ce7f3/21.jpg",
#"Кавай":"https://i.playground.ru/i/pix/2135814/image.jpg",
#"Гром":"https://i.ytimg.com/vi/nycZ5Cyd7Dg/maxresdefault.jpg",
#"Нани":"https://telegram.org.ru/uploads/posts/2021-11/1635850272_file_1708993.jpg",
"Аморька":"https://e7.pngegg.com/pngimages/754/586/png-clipart-grayscale-of-man-s-face-dota-2-forsen-twitch-emote-kappa-pug-miscellaneous-face.png",
#"Телек":"https://img2.freepng.ru/20180420/iee/kisspng-television-emoji-display-device-sticker-sms-barber-pole-5ad9c9bb332a09.4379871215242223952096.jpg",
#"ESC":"https://ih1.redbubble.net/image.783183798.9061/st,small,507x507-pad,600x600,f8f8f8.u1.jpg",
"Сириус":"https://creazilla-store.fra1.digitaloceanspaces.com/emojis/49749/snake-emoji-clipart-md.png",
#"Пингвин":"https://onlyhdwallpapers.com/wallpaper/flowers-animals-happy-pinguin-5Xaw.jpg",
}

func _ready():
	for person_name in persons.keys():
		var splt=persons[person_name].split(".")
		var type=splt[len(splt)-1]
		if !gm.dir.file_exists("res://persons/"+person_name+"."+type):
			gm.get_net_image(person_name,persons[person_name],type)
		else:
			gm.persons.merge({person_name:load("res://persons/"+person_name+"."+type)})
		add_item(person_name)
	icon=gm.persons[items[items.find(0)-3]]
	get_parent().get_node("txt").text=items[items.find(0)-3]
		

func _physics_process(delta):
	for person_name in persons.keys():
		var splt=persons[person_name].split(".")
		var type=splt[len(splt)-1]
		if gm.dir.file_exists("res://persons/"+person_name+"."+type):
			#var t=load("res://persons/"+person_name+"."+type)
			
			#5add_icon_item(t,person_name)
			persons.erase(person_name)


func _on_op_item_selected(index):
	icon=gm.persons[items[items.find(index)-3]]
