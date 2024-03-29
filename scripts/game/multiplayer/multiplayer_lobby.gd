extends WindowDialog
class_name Lobby

enum Reason {
	VERSION = 0,
	LEVEL = 1,
	BUSY = 2,
}

const PORT = 7415
var curr_suff = -1
var ip_preffix = ""
var current_ip = ""
var players_info = {}
var CLASS_ICONS = {
	"knight" : load("res://textures/classes/knight_helmet.png"),
	"butcher" : load("res://textures/classes/butcher_helmet.png"),
	"spearman" : load("res://textures/classes/spearman_helmet.png"),
	"wizard" : load("res://textures/classes/wizard_helmet.png"),
	"archer" : load("res://textures/classes/archer_helmet.png"),
	"player" : null,
}
onready var timer = $connect/timer
onready var try = $connect/try


func _ready():
	$connect/ip/ip.text = G.cached_ip
	get_tree().connect("connected_to_server", self, "connected_ok")
	get_tree().connect("network_peer_connected", self, "player_connected")
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")
	get_tree().connect("server_disconnected", self, "server_disconnected")
	get_close_button().connect("pressed", self, "do_disconnect")


func create():
	for i in $lobby/scroll/list.get_children():
		i.queue_free()
	popup_centered()
	MP.create_server(PORT, 4)
	init_multiplayer()


func join():
	popup_centered()
	$connect.show()
	$lobby.hide()
	var parts_of_level = G.current_level.split("_")
	$connect/title.text = tr("lobby.connect_to") + parts_of_level[0] + "-" + parts_of_level[1] + "..."


func connect_ip():
	if timer.time_left > 0:
		return
	var ip = $connect/ip/ip.text
	if not ip.is_valid_ip_address():
		show_alert(tr("lobby.bad_ip"))
		return
	current_ip = ip
	MP.create_client(ip, PORT)


# Здесь начинается спизженный код.
func connect_auto():
	if not $connect/ip/ip.text.empty():
		connect_ip()
		return
	if timer.time_left > 0:
		return
	var ips = IP.get_local_addresses()
	ip_preffix = ips[0]
	for i in ips:
		if i.begins_with("192.168."):
			ip_preffix = i
			break
	ip_preffix = ip_preffix.get_basename() + "."
	timer.start()
	curr_suff = -1


func do_disconnect():
	if MP.is_active:
		MP.close_network()
	hide()
	$"../select_level_dialog".show_d(G.current_level)


func connected_ok():
	G.cached_ip = current_ip
	$connect/ip/ip.text = G.cached_ip
	init_multiplayer()


func player_connected(id):
	var my_info = {
		"name" : G.getv("name", ""),
		"class" : G.getv("selected_class", "player"),
		"level" : G.current_level,
		"power" : G.getv(G.getv("selected_class", "player") + "_level", 0),
		"ulti_power" : G.getv(G.getv("selected_class", "player") + "_ulti_level", 1),
		"version" : (G.VERSION + " " + G.VERSION_STATUS + " " + G.VERSION_STATUS_NUMBER).strip_edges(),
		"version_code" : G.VERSION_CODE
	}
	yield(get_tree(), "idle_frame")
	$"/root/mg".rpc_id(id, "register_player", my_info)


func player_disconnected(id):
	players_info.erase(id)
	update_start_game_button()
	if $lobby/scroll/list.has_node(str(id)):
		$lobby/scroll/list.get_node(str(id)).queue_free()


func server_disconnected():
	do_disconnect()
	show_alert(tr("menu.disconnected"))


func refused(reason, data):
	do_disconnect()
	match reason:
		Reason.BUSY:
			show_alert(tr("lobby.refuse.busy"))
		Reason.LEVEL:
			var parts_of_level = data.split("_")
			var level_name = parts_of_level[0] + "-" + parts_of_level[1]
			show_alert(tr("lobby.refuse.level") % level_name)
		Reason.VERSION:
			var my_version = (G.VERSION + " " + G.VERSION_STATUS + " " + G.VERSION_STATUS_NUMBER).strip_edges()
			show_alert(tr("lobby.refuse.version") % [data, my_version])


func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	var my_id = get_tree().get_network_unique_id()
	if id > 1:
		if info["version_code"] != players_info[my_id]["version_code"]:
			if get_tree().is_network_server():
				$"/root/mg".rpc_id(id, "refused", Reason.VERSION, players_info[my_id]["version"])
			return
		elif info["level"] != players_info[my_id]["level"]:
			if get_tree().is_network_server():
				$"/root/mg".rpc_id(id, "refused", Reason.LEVEL, players_info[my_id]["level"])
			return
	players_info[id] = info
	var hboxcont = HBoxContainer.new()
	hboxcont.size_flags_horizontal = SIZE_EXPAND_FILL
	hboxcont.name = str(id)
	$lobby/scroll/list.add_child(hboxcont)
	var icon = TextureRect.new()
	icon.texture = CLASS_ICONS[info["class"]]
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = SIZE_FILL
	hboxcont.add_child(icon)
	var label = Label.new()
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.valign = VALIGN_CENTER
	label.text = info["name"] + ": " + tr(G.CLASSES[info["class"]]) + tr("lobby.info.power") + str(info["power"]) + tr("lobby.info.ulti") + str(info["ulti_power"])
	hboxcont.add_child(label)
	update_start_game_button()


func register_player_self():
	var id = get_tree().get_network_unique_id()
	var info = {
		"name" : G.getv("name", ""),
		"class" : G.getv("selected_class", "player"),
		"level" : G.current_level,
		"power" : G.getv(G.getv("selected_class", "player") + "_level", 0),
		"ulti_power" : G.getv(G.getv("selected_class", "player") + "_ulti_level", 1),
		"version" : (G.VERSION + " " + G.VERSION_STATUS + " " + G.VERSION_STATUS_NUMBER).strip_edges(),
		"version_code" : G.VERSION_CODE
	}
	players_info[id] = info
	var hboxcont = HBoxContainer.new()
	hboxcont.size_flags_horizontal = SIZE_EXPAND_FILL
	hboxcont.name = str(id)
	$lobby/scroll/list.add_child(hboxcont)
	var icon = TextureRect.new()
	icon.texture = CLASS_ICONS[info["class"]]
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = SIZE_FILL
	hboxcont.add_child(icon)
	var label = Label.new()
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.valign = VALIGN_CENTER
	label.text = tr("lobby.info.you") + info["name"] + ": " + tr(G.CLASSES[info["class"]]) + tr("lobby.info.power") + str(info["power"]) + tr("lobby.info.ulti") + str(info["ulti_power"])
	hboxcont.add_child(label)


func init_multiplayer():
	for i in $lobby/scroll/list.get_children():
		i.queue_free()
	$connect.hide()
	$lobby.show()
	if get_tree().is_network_server():
		$lobby/ip.show()
		$lobby/more.show()
		$lobby/start_game.show()
		var ip = ""
		var ips = IP.get_local_addresses()
		ip = ips[0]
		for i in ips:
			if i.begins_with("192.168."):
				ip = i
				break
		if not ip.begins_with("192.168."):
			ip += tr("lobby.strange_ip")
		$lobby/ip.text = tr("lobby.your_ip") + ip
	else:
		$lobby/ip.show()
		$lobby/more.hide()
		$lobby/ip.text = tr("lobby.start_warn")
		$lobby/start_game.hide()
	$lobby/start_game.disabled = true
	var parts_of_level = G.current_level.split("_")
	$lobby/level.text = tr("lobby.level") + parts_of_level[0] + "-" + parts_of_level[1]
	register_player_self()
	var node = MultiplayerGame.new()
	node.name = "mg"
	node.connect("player_registered", self, "register_player")
	node.connect("refused", self, "refused")
	get_tree().root.add_child(node)


func show_more_ips():
	var ips = IP.get_local_addresses()
	var text = ""
	var counter = 0
	for i in ips:
		counter += 1
		text += i
		text += ", "
		if counter == 3:
			counter = 0
			text += "\n"
	text = text.trim_suffix("\n")
	text = text.trim_suffix(", ")
	show_alert(text, tr("lobby.your_ips"))


func start_game():
	$"/root/mg".begin_game()


func update_start_game_button():
	if not get_tree().is_network_server():
		$lobby/start_game.disabled = true
		return
	$lobby/start_game.disabled = not get_tree().get_network_connected_peers().size() > 0


func show_alert(text, title = tr("lobby.error")):
	var pop = AcceptDialog.new()
	$"../alert_layer".add_child(pop)
	pop.dialog_text = text
	pop.window_title = title
	pop.theme = theme
	pop.connect("popup_hide", pop, "queue_free", [], CONNECT_ONESHOT)
	pop.popup_centered()


func _on_timer_timeout():
	if $lobby.visible or not visible:
		timer.stop()
		try.text = ""
		return
	if curr_suff > 254:
		timer.stop()
		show_alert(tr("lobby.no_server"))
		try.text = ""
		curr_suff = 0
	else:
		curr_suff += 1
		current_ip = ip_preffix + str(curr_suff)
		MP.create_client(current_ip, PORT)
		try.text = tr("lobby.trying") + current_ip
