class_name PlayerController
extends CharacterBody3D

enum State {
	IDLE = 0,
	RUN,
	JUMP_START,
	JUMP_IDLE,
	JUMP_LANDING,
	JUMP_LAND,
	ATTACK,
}

@onready var anim_player: AnimationPlayer = $skeleton_mage/AnimationPlayer;

var player_state: State = State.IDLE;
var forward: Vector3 = Vector3(0, 0, 1);
var jumped: bool = false; 

func _ready() -> void:
	return;

func _process(delta: float) -> void:
	
	if player_state == State.RUN:
		anim_player.play("Running_A");
	elif player_state == State.JUMP_START or\
		 player_state == State.JUMP_IDLE or\
	 	 player_state == State.JUMP_LAND or\
		 player_state == State.JUMP_LANDING:
		anim_player.play("Jump_Full_Short");
	else:
		anim_player.play("Idle_B");
	
	return;
	
func _physics_process(delta: float) -> void:
	
	var inputValue = get_input();
	
	var moveDir = forward * inputValue.x;
	var jumpDir = Vector3.UP;
	var rotDelta = PI/50 * inputValue.y;
	const velValue = 5.0;
	const jumpPower = 1.2;
	
	rotate(Vector3.UP,rotDelta);
	forward = forward.rotated(Vector3.UP,rotDelta);
	var velY = velocity.y;
	velocity = moveDir * velValue;
	velocity.y = velY;
	
	if is_on_floor():
		if player_state == State.JUMP_LANDING:
			player_state = State.JUMP_LAND;
		elif player_state == State.JUMP_START:
			velocity += jumpDir * jumpPower;
			player_state = State.JUMP_IDLE;
		elif moveDir.length() > 0.01:
			player_state = State.RUN;
		else:
			player_state = State.IDLE;
	else:
		if player_state == State.JUMP_IDLE and velocity.y <= 8.0:
			velocity += jumpDir * jumpPower;
		else:
			player_state = State.JUMP_LANDING;
			velocity.y -= 1.0;
	
	move_and_slide();
	return;

func get_input() -> Vector2:
	
	var rot = Input.get_axis("move_right","move_left");
	var vec = Input.get_axis("move_back","move_fwd");
	
	return Vector2(vec,rot);

func _unhandled_key_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("jump") and is_on_floor():
		player_state = State.JUMP_START;

	return;
