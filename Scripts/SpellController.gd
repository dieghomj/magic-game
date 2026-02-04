extends ColorRect

#Child Objects
var SpellParticles:GPUParticles2D;
var SpellLine:Line2D;

#Properties
var mousePressed:bool;
var mousePosList:Array[Vector2];

func _ready() -> void:
	SpellParticles = $SpellParticles;
	SpellLine = $SpellLine;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			SpellLine.clear_points();
			mousePosList.clear();
			mousePressed = true;
		else:
			mousePressed = false;
			for point in mousePosList:
				SpellLine.add_point(point);
	if event is InputEventMouseMotion and mousePressed:
		SpellParticles.position = event.position;
		mousePosList.append( event.position );
	
func _process(delta: float) -> void:
	return;
