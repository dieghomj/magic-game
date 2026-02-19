extends Node3D

@onready var spell_control: SpellCanvas = $SpellCanvas;
@onready var debug_centroid: ColorRect = $debugCentroid

var unistroke_rec = UnistrokeRecognizer.new();

func _ready() -> void:
	unistroke_rec.load_templates("res://Scripts/Unistrokes/spells.json");
	return;

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("open_spells"):
		spell_control.visible = !spell_control.visible;
		spell_control.drawing_enable_flag = true;
	
	if spell_control.is_activated() and spell_control.visible:
		process_spell();
	else:
		debug_centroid.size = Vector2(5,5);
	return;
	
func process_spell() -> void:
	
	var vector := unistroke_rec.process_points(spell_control.spell_line.points);
	print(unistroke_rec.recognize(vector));

	#print("NEW DRAWING");
	#for p in unistroke_rec.points:
		#print(p);
	#	spell_control.debug_line.add_point(p);
	#debug_centroid.position = unistroke_rec.centroid;
	#debug_centroid.visible = true;


	return;
