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
	
	if (closest_gem - (ship.position + ship.velocity)).length() > 10 :
		thrust = 1
	else:
		thrust = 0
	
	if ship.position.angle_to_point(closest_gem) > (ship.rotation):
		spin = 1
	elif ship.position.angle_to_point(closest_gem) < (ship.rotation):
		spin = -1
	else:
		spin = 0
	
	return [spin, thrust, false]

# Called every time the agent has bounced off a wall.
func bounce():
	return

# Called every time a gem has been collected.
func gem_collected():
	return
