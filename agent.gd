extends Node2D

@onready var ship = get_parent()
@onready var debug_path = ship.get_node('../debug_path')
@onready var debug_sprite = ship.get_node('../debug_sprite')

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
	
	var my_poly : int = -1
	var gem_poly : int = -1
	for p in range(_polygons.size()):
		if Geometry2D.is_point_in_polygon(ship.position, _polygons[p]):
			my_poly = p
		if Geometry2D.is_point_in_polygon(closest_gem, _polygons[p]):
			gem_poly = p
	
	debug_path.add_point(_calculate_poly_center(_polygons[my_poly]))
	debug_path.add_point(ship.position)
	
	var target_pos = Vector2.ZERO
	if my_poly == gem_poly or _find_if_neighbors(_neighbors[my_poly], gem_poly):
		target_pos = closest_gem
	else:
		var path_to_gem := _bfs(my_poly, gem_poly, _neighbors)
		var center_next := _calculate_poly_center(_polygons[path_to_gem[0]])
		debug_path.add_point(center_next)
		
		path_to_gem.append(-1)
		for step in path_to_gem:
			var poly_center : Vector2
			if step == -1:
				poly_center = closest_gem
			else:
				poly_center = _calculate_poly_center(_polygons[step])
			debug_path.add_point(poly_center)
			if not _wall_in_path(PackedVector2Array([ship.position,poly_center]), _walls):
				target_pos = poly_center
			else:
				break
	debug_path.add_point(closest_gem)
		
		#target_pos = center_next
		#if path_to_gem.size() > 1:
			#var center_after := _calculate_poly_center(_polygons[path_to_gem[1]])
			#debug_path.add_point(center_after)
			#var angle : float = Vector2(ship.position - center_next).angle_to(Vector2(center_after - center_next))
			#if  angle < 2 * PI / 5 or angle > 8 * PI / 5:
				#if not _wall_in_path(PackedVector2Array([Vector2(ship.position), Vector2(center_after)]), _walls):
					#target_pos = center_after
		#else:
			#debug_path.add_point(closest_gem)
			#var angle : float = Vector2(ship.position - center_next).angle_to(Vector2(closest_gem - center_next))
			#if  angle < 2 * PI / 5 or angle > 8 * PI / 5:
				#if not _wall_in_path(PackedVector2Array([Vector2(ship.position), Vector2(closest_gem)]), _walls):
					#target_pos = closest_gem
	
	if ship.position.angle_to_point(target_pos - ship.velocity) > (ship.rotation + 0.1):
		spin = 1
	elif ship.position.angle_to_point(target_pos - ship.velocity) < (ship.rotation - 0.1):
		spin = -1
	else:
		spin = 0
	
	debug_sprite.position = (target_pos - ship.velocity)
	
	if spin != 0 and ship.velocity != Vector2.ZERO:
		thrust = false
	else:
		if (target_pos - (ship.position + ship.velocity)).length() > (ship.velocity).length() :
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

func _bfs(your_poly : int, target_poly : int, neighbors: Array[Array]) -> Array[int]:
	var queue := []
	var visited := {}
	var parent := {}
	
	queue.append(your_poly)
	visited[your_poly] = true
	parent[your_poly] = null
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current == target_poly:
			var path : Array[int] = []
			while parent[current] != your_poly:
				current = parent[current]
				path.append(current)
			path.reverse()
			return path
		
		for neighbor in neighbors[current]:
			if neighbor not in visited:
				queue.append(neighbor)
				visited[neighbor] = true
				parent[neighbor] = current
	return [-1]

func _wall_in_path(path: PackedVector2Array, walls: Array[PackedVector2Array]) -> bool:
	for wall in walls:
		if not Geometry2D.intersect_polyline_with_polygon(path, wall).is_empty():
			return true
	return false

# Called every time the agent has bounced off a wall.
func bounce():
	return

# Called every time a gem has been collected.
func gem_collected():
	return

# Called every time a new level has been reached.
func new_level():
	return
