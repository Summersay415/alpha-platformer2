extends Control
class_name Garden


var RARITY_COLORS = [Color.white, Color.green, Color.magenta, Color.yellow]
var going_to_plant = false
var going_to_fertilize = false
var going_to_dig_up = false
var selected_plant = ""
var plant_element = load("res://minigames/minigame6/element_of_plant_list.tscn")
signal plant_selected(canceled)


func _ready():
	$base_list_of_plants/list_of_plants.get_close_button().connect("pressed", self, "select_plant", [""])
	$base_buy/buy.get_cancel().text = tr("menu.cancel")
	$base_buy/buy.get_ok().text = tr("shop.buy")


func open_box():
	$base_buy/buy.dialog_text = tr("6.buy.text") + str(G.getv("tickets", 0))
	$base_buy/buy.popup_centered()


func buy_box():
	if G.getv("tickets", 0) < 5:
		show_warning(tr("6.no.tickets"))
		return
	G.addv("tickets", -5, 0)
	get_box()


func get_box():
	get_tree().change_scene("res://minigames/minigame6/plant_box_open.tscn")


func exit():
	get_tree().change_scene("res://scenes/menu/levels.tscn")


func _process(delta):
	$fert.text = str(G.getv("garden_fert", 0))
	$water.text = str(G.getv("garden_water", 0))


func plant_pressed():
	going_to_fertilize = false
	going_to_dig_up = false
	going_to_plant = not going_to_plant
	if not going_to_plant:
		$tip.hide()
		return
	open_list_of_plants()
	var canceled = yield(self, "plant_selected")
	if canceled:
		going_to_plant = false
		return
	$tip.text = tr("6.tip.plant")
	$tip.visible = going_to_plant


func dig_up_pressed():
	going_to_fertilize = false
	going_to_plant = false
	going_to_dig_up = not going_to_dig_up
	$tip.text = tr("6.tip.remove")
	$tip.visible = going_to_dig_up


func fert_up_pressed():
	going_to_plant = false
	going_to_dig_up = false
	going_to_fertilize = not going_to_fertilize
	$tip.text = tr("6.tip.fert")
	$tip.visible = going_to_fertilize


func open_list_of_plants():
	for i in $base_list_of_plants/list_of_plants/scroll/grid.get_children():
		i.queue_free()
	var plant_showed = []
	var plants = G.getv("garden_plants", []) as Array
	for i in plants:
		if i in plant_showed:
			continue
		if i.get_extension() != "res" and i.get_extension() != "tres":
			var new_plants = plants.duplicate(true)
			new_plants.erase(i)
			G.setv("garden_plants", new_plants)
			open_list_of_plants()
			break
		if i.get_extension() == "res":
			var new_plants = plants.duplicate(true)
			new_plants.erase(i)
			new_plants.append((i as String).get_basename() + ".tres")
			G.setv("garden_plants", new_plants)
			open_list_of_plants()
			break
		plant_showed.append(i)
		var plant_data = load(i) as PlantResource
		var node = plant_element.instance()
		node.get_node("tex").texture_normal = plant_data.texture
		node.get_node("name").text = tr(plant_data.name) + " x " + str(G.getv("garden_plants", []).count(i))
		node.get_node("name").add_color_override("font_color", RARITY_COLORS[plant_data.rarity])
		node.get_node("tex").connect("pressed", self, "select_plant", [i])
		$base_list_of_plants/list_of_plants/scroll/grid.add_child(node)
	$base_list_of_plants/list_of_plants.popup_centered()


func select_plant(plant):
	$base_list_of_plants/list_of_plants.hide()
	if plant.empty():
		selected_plant = ""
		emit_signal("plant_selected", true)
		return
	selected_plant = plant
	emit_signal("plant_selected", false)


func show_warning(text = ""):
	$warn.text = text
	for i in get_tree().get_processed_tweens():
		i.kill()
	var tween = create_tween()
	tween.tween_property($warn, "self_modulate", Color.red, 0.25)
	tween.tween_property($warn, "self_modulate", Color(1,0,0,0), 1).set_delay(1)
