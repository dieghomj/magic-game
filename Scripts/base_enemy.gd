extends CharacterBody3D

var target := Vector3.ZERO;

func _process(delta: float) -> void:
	pass;
	
func _physics_process(delta: float) -> void:
	velocity.y -= 2.0;
	move_and_slide();

func set_target(to: Vector3) -> void: target = to;
