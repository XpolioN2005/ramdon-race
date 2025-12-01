extends RigidBody3D

@export var gravity := 9.8
@export var is_player := true
const BLOCK_SIZE := 2.0

var target: Vector3
var has_target := false
var is_jumping := false

var LUCK: float = 0.0
var luck_streak: int = 0

var outline_size_current: float = 0.0
var outline_tween: Tween

@onready var gm
@onready var mesh: MeshInstance3D = $MeshInstance3D
var mat: ShaderMaterial


func _ready():
	# --- MATERIAL SETUP (PER ENTITY) ---
	var base_mat := mesh.get_active_material(0)
	if base_mat == null:
		push_error("No material found on mesh")
		return

	mat = base_mat.duplicate()
	mesh.set_surface_override_material(0, mat)

	# --- BASE COLOR ---
	if is_player:
		add_to_group("player")
		mat.set_shader_parameter("mesh_color", Color(0, 1, 0)) # green
	else:
		add_to_group("bot")
		mat.set_shader_parameter("mesh_color", Color(0, 0, 1)) # blue

	outline_size_current = 0.0
	mat.set_shader_parameter("outline_size", 0.0)

	_update_outline()
	call_deferred("_init_gm")


func _init_gm():
	gm = get_tree().get_first_node_in_group("gm")


# ---------------- TURN / LUCK ----------------

func start_turn():
	var base_chance := 0.0
	var bias : float= clamp(base_chance + LUCK, 0.05, 0.95)
	var success := RngGimmicks.coin_flip(bias)

	if success:
		luck_streak += 1
		LUCK = min(LUCK + 0.05, 0.5)
	else:
		luck_streak = 0
		LUCK = 0
		_end_turn()

	_update_outline()


func _update_outline(custom_size: float = -1.0):
	var luck_local := float(luck_streak)

	# Target outline size
	var target_size: float
	if custom_size < 0.0:
		target_size = clamp(luck_local * 0.3, 0.0, 1.0)
	else:
		target_size = custom_size

	# Kill previous tween if still running
	if outline_tween and outline_tween.is_running():
		outline_tween.kill()

	# Create smooth transition
	outline_tween = create_tween()
	outline_tween.set_trans(Tween.TRANS_BACK)   # punchy
	outline_tween.set_ease(Tween.EASE_OUT)

	outline_tween.tween_method(
		func(value):
			outline_size_current = value
			mat.set_shader_parameter("outline_size", value),
		outline_size_current,
		target_size,
		0.25 # duration in seconds
	)

	# --- outline color (instant is fine) ---
	if luck_streak >= 4:
		mat.set_shader_parameter("outline_color", Color(1, 0, 0))
	elif luck_streak >= 2:
		mat.set_shader_parameter("outline_color", Color(1, 0.6, 0))
	else:
		mat.set_shader_parameter("outline_color", Color(1, 1, 0))


# ---------------- MOVEMENT ----------------

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
		_update_outline(0)
		
		SignalBus.emit_signal("entity_landed", self)
