# root.gd
extends Node3D

@onready var player = %player
@onready var bot = %bot

var is_player_turn := true
var turn_number := 1

var player_block := 0
var bot_block := 0

var bot_turn_active := false

func _ready():
	add_to_group("gm")
	SignalBus.connect("entity_landed", Callable(self, "_on_entity_landed"))
	start_turn()


func start_turn():
	print("Turn %d: %s's turn" % [
		turn_number,
		"Player" if is_player_turn else "Bot"
	])

	if not is_player_turn:
		bot_turn_active = true
		run_bot_roll()
	# player waits for input


func run_bot_roll():
	if not bot_turn_active:
		return

	bot.start_turn()

	# If bot failed, entity already ended turn
	if bot.luck_streak == 0:
		bot_turn_active = false
		return

	# Decide AFTER this roll whether to continue
	var push_luck := RngGimmicks.coin_flip()
	
	# wait so we don't stack logic and also looks good
	await get_tree().create_timer(0.5).timeout
	if push_luck:
		print("Bot decides to reroll")
		run_bot_roll()
	else:
		print("Bot decides to stop")
		bot_turn_active = false
		bot._end_turn()



func _on_entity_landed(entity):
	if is_player_turn and entity != player:
		return
	if not is_player_turn and entity != bot:
		return

	if entity == player:
		player_block += entity.luck_streak
		entity.luck_streak = 0
	else:
		bot_block += entity.luck_streak
		entity.luck_streak = 0

	print("Player:", player_block, "| Bot:", bot_block)

	is_player_turn = not is_player_turn
	if is_player_turn:
		turn_number += 1

	start_turn()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_player:
		print("player won")
	else:
		print("bot won")