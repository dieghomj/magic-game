class_name UnistrokeRecognizer
extends Node

const SAMPLE_SIZE := 64;
const BOUND_BOX_SIZE := 500;

var points: Array[Vector2];
var templates: Dictionary[String, Array];
var centroid: Vector2;

func process_points(user_points: Array[Vector2]) -> Array[float]:
	if user_points.size() <= 0: 
		return [];
		
	user_points = resample(SAMPLE_SIZE, user_points);
	translate_to(user_points, Vector2(0,0))
	rotate_to_zero(user_points);
	points = user_points;
	return vectorize(user_points);

func add_template(key: String, points: Array[Vector2]) -> void:
	templates.set(key, points);
	
func save_template(filename: String) -> bool:
	if FileAccess.file_exists(filename):
		var file = FileAccess.open(filename, FileAccess.WRITE);
		
		var templateJSONFormat : Dictionary[String, Array];
		
		for template in templates:
			var arr = [];
			for point in templates[template]:
				arr.append([point.x,point.y]);
			templateJSONFormat.set(template,arr);
		
		var json_str = JSON.stringify(templateJSONFormat, "\t");
		file.store_string(json_str);
		file.close;
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

func path_length(point_list: Array[Vector2]) -> float:
	var distance = 0;
	for i in range(point_list.size() - 1):
		distance += point_list[i].distance_to(point_list[i+1]);
	return distance;
#Resamples the points to the given sample size 
func resample(sample:int, point_list: Array[Vector2]) -> Array[Vector2]:
	var interval = path_length(point_list)/(sample-1);
	var distance = 0;
	var new_points : Array[Vector2] = [];
	new_points.append(point_list[0]);
	
	for i in range(1,point_list.size()):
		var d = point_list[i-1].distance_to(point_list[i]);
		if (distance + d) >= interval :
			var t = (interval - distance)/d;
			var px = point_list[i-1].x + t * (point_list[i].x - point_list[i-1].x);
			var py = point_list[i-1].y + t * (point_list[i].y - point_list[i-1].y);
			var newp = Vector2(px,py);
			new_points.append(newp);
			point_list.insert(i, newp);
			distance = 0;
		else:
			distance +- d;
			
	if new_points.size() < sample:
		new_points.append(point_list.back());
	return new_points;
	
#Calculates the center of the points and rotates each point so that first point is at 0 degrees from the center 
func rotate_to_zero(point_list: Array[Vector2]) -> void:
	centroid = calculate_centroid(point_list)
	var start := point_list[0];
	var vec :=  start - centroid ;
	var angle = vec.angle();

	for i in range(point_list.size()):
		point_list[i] = (point_list[i] - centroid).rotated(-angle) + centroid;

func rotate_by(point_list: Array[Vector2], angle: float) -> Array:
	var center = calculate_centroid(point_list);
	var new_points := [];
	
	for point in point_list:
		new_points.append((point - center).rotated(angle) + center);
		
	return new_points;

#Scale all the points in the list to the given size
func scale_to(point_list: Array[Vector2], size: int) -> void:
	
	var min_p = Vector2.INF;
	var max_p = -Vector2.INF;
	
	for p in point_list:
		min_p.x = min(min_p.x,p.x);
		min_p.y = min(min_p.y,p.y);
		max_p.x = max(max_p.x,p.x);
		max_p.y = max(max_p.y,p.y);
		
	var width = max_p.x - min_p.x;
	var height = max_p.y - min_p.y;
	
	if width == 0: width = 1
	if height == 0: height = 1
	
	for i in range(point_list.size()):
		point_list[i].x *= (size / width)
		point_list[i].y *= (size / height)
	
func translate_to(point_list: Array[Vector2], target: Vector2)->void:
	var current_centroid = calculate_centroid(point_list);
	
	for i in range(point_list.size()):
		point_list[i] = point_list[i] - current_centroid + target
		
func recognize(point_list: Array[Vector2]) -> Dictionary:
	var proc_points = process_points(point_list);
	var max_score = 0;
	var best_template = "unknown";
	
	print("COMPARISION TABLE");
	for template in templates:
		print("================");
		var distance = cosine_distance(proc_points,vectorize(templates[template]));
		var score = 1.0/distance;
		print(template,  " : ", (score) );
		print("================");
		if (score > max_score):
			max_score = score;
			best_template = template;
	
	if max_score < 0.1:
		return {"name": "unknown", "score": max_score};
	
	
	return {"name": best_template, "score": max_score};
	
	
func cosine_distance(points1: Array[float], points2: Array[float]) -> float:
	var a := 0.0;
	var b := 0.0;
	for i in range(0, points1.size(), 2):
		a += points1[i] * points2[i] + points1[i + 1] * points2[i+1];
		b += points1[i] * points2[i+1] - points1[i + 1] * points2[i];
	var angle = atan2(b,a);
	var cos_sim = a * cos(angle) + b * sin(angle);
	return cos_sim;
	
func vectorize(point_list: Array[Vector2]) -> Array[float]:
	var sum := 0.0;
	var vector : Array[float] = [];

	for point in point_list:
		vector.append(point.x);
		vector.append(point.y);
		sum+= point.x * point.x + point.y * point.y;
	var magnitude = sqrt(sum);
	
	for i in range(vector.size()):
		vector[i] /= magnitude;
		
	return vector;

func point_distance(points1: Array, points2: Array) -> float:
	var distance = 0.0
	
	for i in range(points1.size()):
		distance += points1[i].distance_to(points2[i])
	
	return distance / points1.size()
	
func calculate_centroid(point_list : Array[Vector2]) -> Vector2:
	var center = Vector2.ZERO;
	for point in point_list:
		center+=point;
	return center/point_list.size();
