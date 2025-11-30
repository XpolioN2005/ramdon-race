# entity.gd
extends RigidBody3D

@export var gravity := 9.8
@export var is_player := true
const BLOCK_SIZE := 2.0

var target: Vector3
var has_target := false
var is_jumping := false

var LUCK : float = 0
var luck_streak : int = 0

@onready var gm

func _ready():
	if is_player:
		add_to_group("player")
	else:
		add_to_group("bot")
	call_deferred("_init_gm")

func _init_gm():
	gm = get_tree().get_first_node_in_group("gm")


func jump_by_blocks(delta_blocks: int):
	if is_jumping:
		return

	var current_block := roundi(global_position.x / BLOCK_SIZE)
	var target_block := current_block + delta_blocks
	var target_pos := Vector3(target_block * BLOCK_SIZE, 0, global_position.z)

	target = target_pos
	has_target = true
	is_jumping = true

	var displacement := target_pos - global_position
	var horizontal := Vector3(displacement.x, 0, displacement.z)
	var distance := horizontal.length()
	if distance == 0:
		has_target = false
		is_jumping = false
		return

	var jump_height := distance * 0.5
	var v_y := sqrt(2.0 * gravity * jump_height)
	var t_total := 2.0 * v_y / gravity
	var v_horizontal := horizontal / t_total

	var velocity := v_horizontal
	velocity.y = v_y
	apply_central_impulse(velocity)


func start_turn():
	var base_chance := 0.0
	var bias : float = clamp(base_chance + LUCK, 0.05, 0.95)
	var success := RngGimmicks.coin_flip(bias)

	if success:
		luck_streak += 1
		LUCK = min(LUCK + 0.05, 0.5)
	else:
		luck_streak = 0
		LUCK = 0
		_end_turn()


func _end_turn():
	if luck_streak > 0:
		jump_by_blocks(luck_streak)
	else:
		SignalBus.emit_signal("entity_landed", self)


func _physics_process(_delta):
	if has_target and abs(global_position.x - target.x) < 0.1:
		global_position = target
		linear_velocity = Vector3.ZERO
		has_target = false
		is_jumping = false

		SignalBus.emit_signal("entity_landed", self)
