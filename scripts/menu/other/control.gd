extends CanvasItem


var is_dragging = false
var default_pos = Vector2()


func _ready():
	$"../../..".connect("reset", self, "reset")
	if name != "joystick" and name != "gadget":
		default_pos = self.position
	else:
		default_pos = $".".rect_position
	if name == "joystick" or name == "gadget":
		connect("gui_input", self, "gui_input")
	else:
		connect("pressed", self, "set", ["is_dragging", true])
		connect("released", self, "set", ["is_dragging", false])
	if name != "joystick" and name != "gadget":
		self.position = G.getv(name + "_position", $".".position)
	else:
		self.rect_position = G.getv(name + "_position", $".".rect_position)


func gui_input(e):
	if e is InputEventMouseButton:
		if e.pressed:
			is_dragging = true
		else:
			is_dragging = false


func _input(event):
	if event is InputEventMouseMotion and is_dragging:
		if name != "joystick" and name != "gadget":
			self.position += event.relative
		else:
			self.rect_position += event.relative


func _process(delta):
	if name != "joystick" and name != "gadget":
		G.setv(name + "_position", self.position)
	else:
		G.setv(name + "_position", $".".rect_position)


func reset():
	if name != "joystick" and name != "gadget":
		self.position = default_pos
	else:
		self.rect_position = default_pos
