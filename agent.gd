extends Node2D

@onready var ship = get_parent()
@onready var debug_path = ship.get_node('../debug_path')

var ticks = 0
var spin = 0
var thrust = false

# This method is called on every tick to choose an action.  See README.md
# for a detailed description of its arguments and return value.
func action(_walls: Array[PackedVector2Array], _gems: Array[Vector2], 
			_polygons: Array[PackedVector2Array], _neighbors: Array[Array]):

	# This is a dummy agent that just moves around randomly.
	# Replace this code with your actual implementation.
	ticks += 1
	var closest_gem : Vector2 = _gems[0] 
	for gem : Vector2 in _gems:
		if ship.position.distance_to(gem) < ship.position.distance_to(closest_gem):
			closest_gem = gem
	
	debug_path.clear_points()
	debug_path.add_point(ship.position)
	debug_path.add_point(closest_gem)
	
	var my_polygon : int = -1
	var gem_polygon : int = -1
	for p in range(_polygons.size()):
		if _check_polygon(ship.position, _polygons[p]):
			my_polygon = p
		if _check_polygon(closest_gem, _polygons[p]):
			gem_polygon = p
	
	if my_polygon == gem_polygon or _find_if_neighbors(_neighbors[my_polygon], gem_polygon):
		if (closest_gem - (ship.position + ship.velocity)).length() > (ship.velocity).length() :
			thrust = true
		else:
			thrust = false
	
		if ship.position.angle_to_point(closest_gem) > (ship.rotation):
			spin = 1
		elif ship.position.angle_to_point(closest_gem) < (ship.rotation):
			spin = -1
		else:
			spin = 0
	else:
		spin = 0
		thrust = false
	
	return [spin, thrust, false]

func _check_polygon(point : Vector2, polygon : PackedVector2Array) -> bool:
	var is_inside := false
	var angle := 0.0
	for i in range(polygon.size()):
		var first_vertex : Vector2 = polygon[i]
		var second_vertex : Vector2 = polygon[(i + 1) % polygon.size()]
		angle += Vector2(point.x - first_vertex.x, point.y - first_vertex.y)\
		.angle_to(Vector2(point.x - second_vertex.x, point.y - second_vertex.y))
	if angle >= 2 * PI:
		return true
	return false

func _find_if_neighbors(one : Array, two : int) -> bool:
	for neigh in one:
		if neigh == two:
			return true
	return false

# Called every time the agent has bounced off a wall.
func bounce():
	return

# Called every time a gem has been collected.
func gem_collected():
	return
