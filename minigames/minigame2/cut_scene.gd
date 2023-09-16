extends Node2D

var got_death = true

func _ready():
	randomize()


func reward():
	G.setv("hated_death", got_death)
	G.addv("dyh_completed", 1)
	G.ach.complete(Achievements.CLEARED)
	get_tree().change_scene("res://scenes/menu/menu.tscn")
	G.receive_loot({"gold_box" : 1})
