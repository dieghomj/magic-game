class_name UnistrokeRecognizer
extends Resource

@export var SAMPLE_SIZE := 64;
@export var BOUND_BOX_SIZE := 250;

var templates: Dictionary[String, Array];
var processed_points : Array[Vector2];

func add_template(key: String, points: Array[Vector2]) -> void:
	templates.set(key, points.duplicate());
	
func save_template(filename: String) -> bool:
	if FileAccess.file_exists(filename):
		var file = FileAccess.open(filename, FileAccess.WRITE);
		
		var templateJSONFormat : Dictionary[String, Array];
		
		for template in templates:
			var arr = [];
			for i in range(templates[template].size()):
				arr.append([templates[template][i].x,templates[template][i].y]);
			templateJSONFormat.set(template,arr);
		
		var json_str = JSON.stringify(templateJSONFormat, "\t");
		file.store_string(json_str);
		file.close();
		return true;
	
	print("Error opening file ", filename ," for writing");
	return false;
		
func delete_template(key: String) -> bool:
	if templates.has(key):
		templates.erase(key);
		return true;
	return false

func get_template_list() -> Array:
	return templates.keys();

func load_templates(filename: String)->void:
	print("Loading templates...")
	if FileAccess.file_exists(filename):
		var file = FileAccess.open(filename, FileAccess.READ);
		var json_text = file.get_as_text();	
		
		var json = JSON.new();
		var error = json.parse(json_text);
		
		if error != OK:
			print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line());
			return;
		
		var data = json.data;
		
		for key in data:
			var p_arr : Array[Vector2];
			print( "----------", key, "-----------");
			for point in data[key]:
				print(point);
				var vec = Vector2(point[0], point[1]);
				p_arr.append(vec);
			print("---------------------------------");
			templates.set(key, p_arr);
	print("Templates loaded");
	return;

func get_vectorized_template(key: String) -> Array[float]:
	var vector : Array[float] = [];
	for p in templates[key]:
		vector.append(p.x);
		vector.append(p.y);
	return vector;

func process_points(points: Array[Vector2]) -> Array[float]:
	processed_points.clear();
	points = resample(points, SAMPLE_SIZE);
	var vector := vectorize(points);
	for i in range(0,vector.size(),2):
		processed_points.append(Vector2(vector[i], vector[i+1]));
	return vector;

func recognize(vector: Array[float]) -> Dictionary:
	var max_score := 0.0;
	var best_template := "unknown";
	for key in templates:
		var vector_template = get_vectorized_template(key);
		var distance := optimal_cos_distance(vector_template, vector);
		var score = 1 - distance;
		if score > max_score:
			max_score = score
			best_template = key;
	if max_score < 0.7 :
		return {"name": "unknown", "score": 0.0};
	return {"name": best_template, "score": max_score};
	
func optimal_cos_distance(vec1: Array[float], vec2: Array[float]) -> float:
	var a := 0.0; var b := 0.0;
	for i in range(0, vec1.size(), 2):
		a += vec1[i] * vec2[i] + vec1[i+1] * vec2[i+1];
		b += vec1[i] * vec2[i + 1] - vec1[i+1] * vec2[i];
	var angle = atan2(b,a);
	var val = a * cos(angle) + b * sin(angle);
	val = clamp(val, -1.0, 1.0);
	return acos(val);

func resample(points: Array[Vector2], sample: float) -> Array[Vector2]:
	var interval := path_length(points) / (sample - 1);
	var distance := 0.0;
	
	var new_points : Array[Vector2] = [points[0]];
	
	var i := 1;
	while i < points.size():
		var d := points[i-1].distance_to(points[i]);
		if (distance + d >= interval):
			var t := (interval - distance) / d;
			var q := points[i-1] + t * (points[i] - points[i-1]);
			new_points.append(q);
			points.insert(i, q); 
			distance = 0.0;
		else:
			distance += d;
		i += 1;
	if new_points.size() == sample - 1:
		new_points.append(points.back())
	return new_points;
	
	
func path_length(points: Array[Vector2]) -> float:
	var distance := 0.0;
	for i in range(1, points.size()):
		distance += points[i-1].distance_to(points[i]);
	return distance

func vectorize(points: Array[Vector2], orientation_sensitive: bool = false) -> Array[float]:
	var vector : Array[float] = [];
	var centroid := calculate_centroid(points);
	points = translate_to(points, Vector2.ZERO);
	var indicative_angle = atan2(points[0].y, points[0].x);
	var delta := 0.0;
	if orientation_sensitive:
		var base = (PI/4) * floor(indicative_angle + (PI/8))/(PI/4)
		delta = base - indicative_angle;
	else:
		delta = -indicative_angle;
	var sum := 0;
	for p in points:
		var rot_p = p.rotated(delta);
		vector.append(rot_p.x);
		vector.append(rot_p.y);
		sum+=rot_p.x * rot_p.x + rot_p.y * rot_p.y;
	var maginitude = sqrt(sum);
	for i in range(vector.size()):
		vector[i]/= maginitude;
	return vector;
	
func calculate_centroid(points: Array[Vector2]) -> Vector2:
	var centroid := Vector2.ZERO;
	for point in points:
		centroid += point;
	return centroid / points.size();
	
func translate_to(points: Array[Vector2], to: Vector2) -> Array[Vector2]:
	var c := calculate_centroid(points);
	var new_points : Array[Vector2];
	for p in points:
		var q := p + to - c;
		new_points.append(q);
	return new_points;
		
