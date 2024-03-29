extends CPUParticles2D


var player
var random_button_time = 2
var timer = 0
var command = ["move_left", "move_right", "jump", "attack", "jump", "attack"]


func _ready():
	player = $".." as Player
	player._soul.self_modulate = Color.black
	player.get_node("camera/gui/base/pause_menu/panel/restart").disabled = true
	player.custom_respawn_scene = "res://minigames/minigame2/minigame.tscn"
	player.connect("died", self, "hide")
	player.connect("healed", self, "show")


func _physics_process(delta):
	timer += delta
	if timer >= random_button_time:
		timer = 0
		random_button_time = rand_range(2, 5)
		command.shuffle()
		player.call_deferred(command[0])
