extends Control
const TEMPLATE_FILE := "res://Scripts/Unistrokes/spells.json";
@onready var spell_control: SpellController = $SpellCanvas;
@onready var text_edit: LineEdit = $TextEdit

var recog = UnistrokeRecognizer.new();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	recog.load_templates(TEMPLATE_FILE);
	var button_size := Vector2(200,50);
	var start_x := 0.0;
	var start_y := 0.0;
	
	for template in recog.templates:
		var button := Button.new();
		button.name = "template";
		button.text = template;
		button.size = button_size;
		button.pressed.connect(_on_template_pressed.bind(button));
		button.mouse_entered.connect(_on_gui_mouse_entered);
		button.mouse_exited.connect(_on_gui_mouse_exited);
		$ScrollContainer/VBoxContainer.add_child(button);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spell_control.is_activated(): 
		recog.process_points(spell_control.spell_line.points);
		



func _on_button_pressed() -> void:
	recog.add_template(text_edit.text,recog.points);
	var button := Button.new();
	button.name = "template";
	button.text = text_edit.text;
	button.pressed.connect(_on_template_pressed.bind(button));
	button.mouse_entered.connect(_on_gui_mouse_entered);
	button.mouse_exited.connect(_on_gui_mouse_exited);
	$ScrollContainer/VBoxContainer.add_child(button);
	return;

func _on_save_button_pressed() -> void:
	recog.save_template(TEMPLATE_FILE)
	print("Reloading template files");
	recog.load_templates(TEMPLATE_FILE);
	return;
	
func _on_template_pressed(button: Button) -> void:
	spell_control.debug_line.points = recog.templates[button.text];
	
	return;


func _on_gui_mouse_entered() -> void:
	spell_control.drawing_enable_flag = false;
func _on_gui_mouse_exited() -> void:
	spell_control.drawing_enable_flag = true;
	
