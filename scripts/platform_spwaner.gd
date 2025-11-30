extends Node3D

@export var platform_scene: PackedScene = preload("res://scenes/tamplate_platform.tscn")

@export var count := 100
@export var spacing := 2.0
@export var z_offset := 1.0

func _ready():
	for i in range(count):
		_spawn_platform("player_%d" % i, Vector3(i * spacing, -0.5,  z_offset))
		_spawn_platform("bot_%d" % i,    Vector3(i * spacing, -0.5, -z_offset))

func _spawn_platform(_local_name: String, pos: Vector3):
	var p = platform_scene.instantiate()
	p.name = _local_name
	add_child(p)
	p.global_position = pos