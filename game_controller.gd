extends Node3D

@onready var spell_control: SpellController = $SpellCanvas;
@onready var debug_centroid: ColorRect = $debugCentroid

var recog = UnistrokeRecognizer.new();

func _ready() -> void:
	recog.load_templates("res://Scripts/Unistrokes/spells.json");
	return;

func _process(delta: float) -> void:
	
	if spell_control.is_activated():
		process_spell();
	else:
		debug_centroid.size = Vector2(5,5);
	return;
	
func process_spell() -> void:
	print(recog.recognize(spell_control.spell_line.points));


	#print("NEW DRAWING");
	for p in recog.points:
		#print(p);
		spell_control.debug_line.add_point(p);
	debug_centroid.position = recog.centroid;
	debug_centroid.visible = true;


	return;
