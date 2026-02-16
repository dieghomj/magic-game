class_name SpellController
extends ColorRect

#Child Objects
@onready var spell_particles:GPUParticles2D = $SpellParticles ;
@onready var spell_line:Line2D = $SpellLine;
@onready var debug_line: Line2D = $debugLine

#Properties
var one_time_flag: bool;
var is_activate: bool;
var mouse_pressed:bool;
var mouse_pos_list:Array[Vector2];

func _ready() -> void:
	debug_line.clear_points();
	return;
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			clear_points()
			mouse_pressed = true;
		else:
			mouse_pressed = false;
			one_time_flag = false;
			for point in mouse_pos_list:
				spell_line.add_point(point);
	if event is InputEventMouseMotion and mouse_pressed:
		move_particles(event.position);
		mouse_pos_list.append( event.position );
		
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if spell_line.points.size() > 0 and !one_time_flag:
		is_activate = true;
		one_time_flag = true;
	else:
		is_activate = false;
	return;
	
func is_activated() -> bool :
	return is_activate;

func clear_points() -> void:
	spell_line.clear_points();
	debug_line.clear_points();
	mouse_pos_list.clear();
	return;
	
func move_particles(new_pos: Vector2) -> void:
	spell_particles.position = new_pos;
	return
