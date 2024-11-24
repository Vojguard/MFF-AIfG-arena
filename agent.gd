extends Node2D

@onready var ship = get_parent()
@onready var debug_path = ship.get_node('../debug_path')

var ticks = 0
var spin = 0
var thrust = false
var _polys : Array[PackedVector2Array]

# This method is called on every tick to choose an action.  See README.md
# for a detailed description of its arguments and return value.
func action(_walls: Array[PackedVector2Array], _gems: Array[Vector2], 
			_polygons: Array[PackedVector2Array], _neighbors: Array[Array]):
	
	_polys = _polygons
	
	# This is a dummy agent that just moves around randomly.
	# Replace this code with your actual implementation.
	ticks += 1
	var closest_gem : Vector2 = _gems[0] 
	for gem : Vector2 in _gems:
		if ship.position.distance_to(gem) < ship.position.distance_to(closest_gem):
			closest_gem = gem
	
	
	
	var my_poly : int = -1
	var gem_poly : int = -1
	for p in range(_polygons.size()):
		if Geometry2D.is_point_in_polygon(ship.position, _polygons[p]):
			my_poly = p
		if Geometry2D.is_point_in_polygon(closest_gem, _polygons[p]):
			gem_poly = p
	
	var target_pos = Vector2.ZERO
	if my_poly == gem_poly or _find_if_neighbors(_neighbors[my_poly], gem_poly):
		target_pos = closest_gem
	else:
		target_pos = _calculate_poly_center(_polygons[_bfs(my_poly, gem_poly, _neighbors)])
	
	debug_path.clear_points()
	debug_path.add_point(_calculate_poly_center(_polygons[my_poly]))
	debug_path.add_point(ship.position)
	debug_path.add_point(target_pos)
	
	if ship.position.angle_to_point(target_pos) > (ship.rotation + 0.1):
		spin = 1
	elif ship.position.angle_to_point(target_pos) < (ship.rotation - 0.1):
		spin = -1
	else:
		spin = 0
	
	if (target_pos - (ship.position + ship.velocity)).length() * ship.ACCEL > (ship.velocity).length() :
		thrust = true
	else:
		thrust = false
	
	return [spin, thrust, false]

func _find_if_neighbors(one : Array, two : int) -> bool:
	for neigh in one:
		if neigh == two:
			return true
	return false

func _calculate_poly_center(polygon : PackedVector2Array) -> Vector2:
	var sum := Vector2.ZERO
	for vertex in polygon:
		sum += vertex
	return sum / polygon.size()

func _bfs(your_poly : int, target_poly : int, neighbors: Array[Array]) -> int:
	var queue := []
	var visited := {}
	var parent := {}
	
	queue.append(your_poly)
	visited[your_poly] = true
	parent[your_poly] = null
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current == target_poly:
			while parent[current] != your_poly:
				current = parent[current]
			return current
		
		for neighbor in neighbors[current]:
			if neighbor not in visited:
				queue.append(neighbor)
				visited[neighbor] = true
				parent[neighbor] = current
	return -1

# Called every time the agent has bounced off a wall.
func bounce():
	return

# Called every time a gem has been collected.
func gem_collected():
	return

# Called every time a new level has been reached.
func new_level():
	return
