extends Area2D


export (float) var jump_power = 500
var bodies = []


func add_body(body):
	if body.has_method("jump"):
		bodies.append(body)


func remove_body(body):
	if body in bodies:
		bodies.erase(body)
		$effect.restart()


func _physics_process(delta):
	for i in bodies:
		i._move.y = -jump_power * i.GRAVITY_SCALE
