extends Node3D

var enemyScene: PackedScene;

func _ready() -> void:
	enemyScene = preload("res://Enemy.tscn");

func _process(delta: float) -> void:
	var randPos = Vector3(randf_range(-10.0, 10.0), 2, randf_range(-10.0, 10.0));
	position = randPos;
	if randf() < 0.005:
		var enemy : CharacterBody3D = enemyScene.instantiate();
		add_sibling(enemy);
		enemy.position = position;
	
