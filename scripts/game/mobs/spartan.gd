extends Mob
class_name Spartan


onready var attack_visual = $visual/body/kick_attack/visual
onready var attack_shape = $visual/body/kick_attack/shape
onready var jump_ray0 = $jump_ray_cast
onready var jump_ray1 = $jump_ray_cast2
onready var path_ray_left = $path_ray_cast_left
onready var path_ray_right = $path_ray_cast_right


func _ready():
	reaction_speed += rand_range(-0.05, 0.1)
	attack_speed += rand_range(-0.1, 0.2)
	attack_damage = round(stats_multiplier * attack_damage)
	$visual/body/kick_attack.damage = attack_damage


func attack():
	ms.sync_call(self, "attack")
	if _body.scale.x > 0:
		_anim_tree["parameters/attack_seek/seek_position"] = 0
		_anim_tree["parameters/attack_shot/active"] = true
	else:
		_anim_tree["parameters/attack_left_seek/seek_position"] = 0
		_anim_tree["parameters/attack_left_shot/active"] = true
	speed_cooficent *= 0.1
	can_turn = false
	yield(get_tree().create_timer(0.4, false), "timeout")
	$visual/body/kick_attack/swing.play()
	attack_visual.show()
	attack_visual.frame = 0
	attack_visual.play("attack")
	attack_shape.disabled = false
	speed_cooficent /= 0.1
	speed_cooficent *= 3
	yield(get_tree().create_timer(0.2, false), "timeout")
	attack_shape.disabled = true
	can_turn = true
	speed_cooficent /= 3


func _physics_process(delta):
	if current_health <= 0 or is_stunned:
		attack_shape.disabled = true
		attack_visual.hide()
		return
	if not MP.auth(self):
		return
	find_target()
	if not is_instance_valid(player):
		stop()
		return
	player_timer += delta
	if player_timer > reaction_speed:
		player_timer = 0
		player_distance = global_position.distance_squared_to(player.global_position)
		player_visible = player_distance < _vision_distance
		if not player_visible:
			stop()
			return
		if player.global_position.x > global_position.x and _is_move_safe(path_ray_right):
			move_right()
		elif player.global_position.x < global_position.x and _is_move_safe(path_ray_left):
			move_left()
		else:
			stop()
		if under_water and player_distance < _vision_distance / 4 and \
				player.global_position.y + 20 < global_position.y:
			jump()
		if under_water and breath_time < 2 and not immune_to_water:
			jump()
	
	if not player_visible:
		return
	attack_timer += delta
	if attack_timer > attack_speed and player_distance < _attack_distance:
		attack()
		attack_timer = 0
	lookup_timer += delta
	if lookup_timer > lookup_speed:
		if ray_colliding(jump_ray0) == Colliding.OK and _move_direction.x > 0 or \
				ray_colliding(jump_ray1) == Colliding.OK and _move_direction.x < 0:
			jump()
		if _move_direction.x > 0 and not _is_move_safe(path_ray_right):
			stop()
		elif _move_direction.x < 0 and not _is_move_safe(path_ray_left):
			stop()
