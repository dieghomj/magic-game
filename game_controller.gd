extends Node3D

@onready var spell_control: SpellController = $SpellCanvas;
@onready var debug_centroid: ColorRect = $debugCentroid

var recog = UnistrokeRecognizer.new();

func _ready() -> void:
	return;

func _process(delta: float) -> void:
	
	if spell_control.is_activated():
		process_spell();
	else:
		debug_centroid.size = Vector2(5,5);
	return;
	
func process_spell() -> void:
	recog.set_user_points(spell_control.spell_line.points);
	print("NEW DRAWING");
	for p in recog.points:
		print(p);
		spell_control.debug_line.add_point(p);
	debug_centroid.position = recog.centroid;
	debug_centroid.visible = true;
	return;
