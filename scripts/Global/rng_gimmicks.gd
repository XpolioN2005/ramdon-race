# rng_gimmicks.gd
# Small utility for random chance-based gimmicks (coin flips, dice rolls) with luck modifier

extends Node
class_name RNGGimmicks

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()


# Coin flip with optional luck modifier
# luck: float in range [-1, 1]
#   -1 => always fail
#    0 => 50/50
#    1 => always succeed
# Returns: true or false
func coin_flip(luck: float = 0.0) -> bool:
	luck = clamp(luck, -1.0, 1.0)
	var threshold = 0.5 + (0.5 * luck)  # shift odds based on luck
	return rng.randf() < threshold


# Dice roll with optional luck modifier
# sides: number of sides on the die (default 6)
# luck: float in range [-1, 1] shifts roll toward high (+) or low (-) numbers
# Returns: integer in range [1, sides]
func dice_roll(sides: int = 6, luck: float = 0.0) -> int:
	sides = max(1, sides)
	luck = clamp(luck, -1.0, 1.0)
	var raw = rng.randf()  # 0.0 .. 1.0
	# bias formula: move raw toward 1 if luck >0, toward 0 if luck <0
	raw = pow(raw, 1.0 - luck)  # simple bias exponent
	return int(ceil(raw * sides))
