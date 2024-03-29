extends Control


export (Array, Resource) var plants_common = []
export (Array, Resource) var plants_epic = []
export (Array, Resource) var plants_legendary = []
export (Array, Resource) var plants_rare = []
var gen := RandomNumberGenerator.new()
var pack_c = load("res://minigames/minigame6/resources/seed_packet_common.png")
var pack_r = load("res://minigames/minigame6/resources/seed_packet_rare.png")
var pack_e = load("res://minigames/minigame6/resources/seed_packet_epic.png")
var pack_l = load("res://minigames/minigame6/resources/seed_packet_legendary.png")
signal next


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("next")


func _ready():
	gen.randomize()
	yield(self, "next")
	$box_screen/anim.play("open")


func open_box():
	$box_screen.hide()
	$water_screen.show()
	var water_get = 10*gen.randi_range(5, 20)
	$water_screen/water/label.text = "x " + str(water_get)
	G.addv("garden_water", water_get)
	$water_screen/anim.play("get")
	G.save()
	yield(self, "next")
	$water_screen.hide()
	$fert_screen.show()
	var fert_get_two = G.percent_chance(15)
	var fert_get = 1
	if fert_get_two:
		fert_get = 2
	$fert_screen/fert/label.text = "x " + str(fert_get)
	G.addv("garden_fert", fert_get)
	$fert_screen/anim.play("get")
	G.save()
	yield(self, "next")
	var common = G.percent_chance(90)
	var rare = G.percent_chance(25)
	var epic = G.percent_chance(15)
	var legendary = G.percent_chance(6.5)
	var plants = []
	if legendary:
		plants = plants_legendary
		$semen_screen/pack/rarity.add_color_override("font_color", Color.yellow)
		$semen_screen/pack.texture = pack_l
		$semen_screen/pack/glow.show()
	elif epic:
		$semen_screen/pack/rarity.add_color_override("font_color", Color.magenta)
		plants = plants_epic
		$semen_screen/pack.texture = pack_e
		$semen_screen/pack/rarity.text = tr("6.rarity.epic")
	elif rare:
		plants = plants_rare
		$semen_screen/pack/rarity.add_color_override("font_color", Color.green)
		$semen_screen/pack.texture = pack_r
		$semen_screen/pack/rarity.text = tr("6.rarity.rare")
	elif common:
		$semen_screen/pack/rarity.text = tr("6.rarity.common")
		plants = plants_common
		$semen_screen/pack.texture = pack_c
	else:
		get_tree().change_scene("res://minigames/minigame6/minigame.tscn")
		return
	$fert_screen.hide()
	$semen_screen.show()
	plants.shuffle()
	var got_plant := plants[0] as PlantResource
	G.addv("garden_plants", [got_plant.resource_path], [])
	$semen_screen/pack/plant.texture = got_plant.texture
	$semen_screen/pack/label.text = tr(got_plant.name)
	$semen_screen/anim.play("get")
	yield(self, "next")
	get_tree().change_scene("res://minigames/minigame6/minigame.tscn")
