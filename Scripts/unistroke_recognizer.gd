class_name UnistrokeRecognizer
extends Node

const SAMPLE_SIZE := 64;

var points: Array[Vector2];
var templates: Dictionary[String, Array];
var centroid: Vector2;

func set_user_points(user_points: Array[Vector2])->void:
	points.clear()
	
	if user_points.size() <= 0: 
		return;
		
	points = resample(SAMPLE_SIZE, user_points);
	rotate_to_zero(points);
	scale_to(points, 250);
	translate_to(points, Vector2(0,0))

func read_templates(filename: String)->void:
	return;

#Resamples the points to the given sample size 
func resample(sample:int, point_list: Array[Vector2]) -> Array[Vector2]:
	var ret_points: Array[Vector2];
	var length := 0.0
	for i in range(1, point_list.size()):
		length += point_list[i-1].distance_to(point_list[i]);

	var interval := length/(sample-1);
	var acum_dist := 0.0;
	ret_points.append(point_list[0]);
	
	var i := 1;
	while i < point_list.size():
		var cur_point := point_list[i];
		var prev_point := point_list[i-1];
		var d := prev_point.distance_to(cur_point);
		if (acum_dist + d) >= interval :
			var t = (interval - acum_dist / d);
			var new_point = prev_point.lerp(cur_point,t);
			ret_points.append(new_point);
			point_list.insert(i, new_point);
			acum_dist = 0.0;
		else:
			acum_dist += d;
		i+=1;
	
	while ret_points.size() < sample:
		ret_points.append(point_list.back());
	return ret_points;

#Calculates the center of the points and rotates each point so that first point is at 0 degrees from the center 
func rotate_to_zero(point_list: Array[Vector2]) -> void:
	
	var ave := Vector2(0,0);
	var size := point_list.size();
	var start := point_list[0];

	for point in point_list:
		ave += point;
	ave /= size;
	
	centroid = ave;
	var vec :=  start - centroid ;
	var angle = vec.angle();

	for i in range(point_list.size()):
		point_list[i] = (point_list[i] - centroid).rotated(-angle) + centroid;

#Scale all the points in the list to the given size
func scale_to(point_list: Array[Vector2], size: int) -> void:
	
	var max_x = point_list.reduce(func(mx,vec):\
			 	return vec if vec.x > mx.x else mx).x;
	var max_y = point_list.reduce(func(mx,vec):\
			 	return vec if vec.y > mx.y else mx).y;
	var min_x = point_list.reduce(func(mn,vec):\
			 	return vec if vec.x < mn.x else mn).x;
	var min_y = point_list.reduce(func(mn,vec):\
			 	return vec if vec.y < mn.y else mn).y;
	
	var width = max_x - min_x;
	var height = max_y - min_y;
	
	if width == 0: width = 1
	if height == 0: height = 1
	
	for i in range(point_list.size()):
		point_list[i].x *= (size / width)
		point_list[i].y *= (size / height)
	
func translate_to(point_list: Array[Vector2], target: Vector2)->void:
	var ave = Vector2.ZERO
	for p in point_list: ave += p
	var current_centroid = ave / point_list.size()
	centroid = current_centroid;
	
	for i in range(point_list.size()):
		point_list[i] = point_list[i] - current_centroid + target
