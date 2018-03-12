extends Polygon2D

var idx
var cur_rot
var age
var data_line = {"ba_time":0, "ba_position":0, "ba_ID":0, "ba_age":0} #, "ba_score":0
var coords = PoolVector2Array()
var cols = PoolColorArray()
var orders = [-1,1]
var is_collected = 0
var this_point

func _ready():
	add_to_group("hex_balls")
	offset = Vector2(0,global.side_offset)

func create(rot, ball_id): 
	position = global.centre
	cur_rot = int(rot)
	idx = ball_id
	coords.resize(3)
	cols.resize(3)
	coords[0] = Vector2(0,0)
	cols[0] = global.hex_color(0)
	rotation = float(rot)/3*PI
	
func run_collection(progress):
	if is_collected == 1:
		position = global.centre - progress*global.move_time_new/.1*$"/root/game/action_tween".drag_vel #.rotated(float(cur_rot)/3*PI)
		scale = Vector2(1,1)*(1-progress)#max(0,1-progress*36/this_point)
		get_tree().call_group("hint_balls", "dimmer",idx,1-progress)
		if progress == 1:
			log_data()
	
func set_shape(wave_age):
	age = wave_age-idx
	if age > 0:
		if age > 6 and age < 7:
			if !is_collected:
				$"/root/game/miss".play()
				is_collected = 1
			for i in range(3):
				var ang = float(i+(age-6))/3*PI*2
				coords[i] = Vector2(sin(ang)*(7-age),-cos(ang)*(7-age)+1)/sqrt(3)*global.poly_size*2*6
				cols[i] = global.hex_color((7-age-int(i == 0))*6)*(7-age) + global.hint_color((7-age-int(i == 0))*6)*(age-6)
			get_tree().call_group("hint_balls", "dimmer",idx,7-age)
		else:
			for i in range(2):
				coords[i+1] = Vector2((age*orders[i])/sqrt(3),age)*global.poly_size*2
				cols[i+1] = global.hex_color(age)
				#cols[i+1].a = .5
		polygon = coords
		vertex_colors = cols
	if age >= 7:
		log_data()
	
func log_data():
	data_line["ba_time"] = global.dt
	data_line["ba_ID"] = idx
	data_line["ba_position"] = cur_rot #redundant
	data_line["ba_age"] = age
	for key in data_line.keys():
		global.data[key].push_back(data_line[key])
	get_tree().call_group("hint_balls", "eliminate",idx)
	queue_free()

func get_collected(angle):
	if angle == cur_rot and age > 0 and age <= 6 and is_collected == 0:
		is_collected = 1
		get_node("/root/game/collect"+String(age)).play()
		#$String(["/root/game/collect",age]).play()
		var sw = $"/root/game/Spawner".sw
		var point_start = $"/root/game/Spawner".accum_points[-1] - $"/root/game/Spawner".accum_points[sw-1] - global.sw_score
		this_point = pow(age,2)
		global.sw_score += this_point
		global.score += this_point
		$"/root/game/score_poly".sw_outline = global.spiral_peel(1 - float($"/root/game/Spawner".accum_points[sw-1] + global.sw_score)/$"/root/game/Spawner".accum_points[-1])
		$"/root/game/score_poly".update()
