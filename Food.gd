extends Polygon2D

var collision_area: Area2D
var collision_poly: CollisionPolygon2D

# Dictionary to hold different food types and their options
var food_types = {
	"apple": {
		"polygon": [
			Vector2(-5, -5),
			Vector2(5, -5),
			Vector2(5, 5),
			Vector2(-5, 5)
		],
		"color": Color.RED,
		"score": 1,
		"size": 10,
		"spawn_chance": 0.6  # 50% chance
	},
	"banana": {
		"polygon": [
			Vector2(-7, -3),
			Vector2(7, -3),
			Vector2(7, 3),
			Vector2(3, 3),
			Vector2(3, 7),
			Vector2(-3, 7),
			Vector2(-3, 3),
			Vector2(-7, 3)
		],
		"color": Color.YELLOW,
		"score": 2,
		"size": 16,
		"spawn_chance": 0.3  # 30% chance
	},
	"orange": {
		"polygon": [  # Example shape for an orange
			Vector2(-6, -6),
			Vector2(6, -6),
			Vector2(6, 6),
			Vector2(-6, 6)
		],
		"color": Color.ORANGE,
		"score": 3,
		"size": 12,
		"spawn_chance": 0.1  # 20% chance
	}
	# Add more food types as needed
}

var score: int = 1
var current_type: String

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	respawn(true)

func choose_random_food_type():
	var random_value = randf()
	var cumulative_chance = 0.0
	
	for type in food_types:
		cumulative_chance += food_types[type]["spawn_chance"]
		if random_value <= cumulative_chance:
			return type
	
	# This should theoretically never happen if probabilities sum to 1, but:
	push_error("Failed to choose a food type, probabilities might not sum to 1.")
	return "apple"  # Default to apple if something goes wrong

func set_food_type(type: String):
	if food_types.has(type):
		# Set the visual representation of the food
		polygon = food_types[type]["polygon"]
		color = food_types[type]["color"]
		score = food_types[type]["score"]
	else:
		push_error("Unknown food type: " + type)

func create_collision(vec):
	collision_area = Area2D.new()
	collision_area.name = "CollisionArea"  # Name it for reference
	add_child(collision_area)
	
	collision_poly = CollisionPolygon2D.new()
	collision_poly.name = "CollisionPolygon2D"  # Name it for reference
	collision_poly.polygon = vec
	
	collision_area.add_child(collision_poly)

# Optional: Function to respawn food in a new location
func respawn(do_create_collision: bool):
	var viewport_size = get_viewport().get_visible_rect().size
	current_type = choose_random_food_type()  # Change type on respawn with different chances
	set_food_type(current_type)
	
	var random_x = randf_range(0 + food_types[current_type]["size"], viewport_size.x - food_types[current_type]["size"])
	var random_y = randf_range(0 + food_types[current_type]["size"], viewport_size.y - food_types[current_type]["size"])
	position = Vector2(random_x, random_y)
	
	if do_create_collision:
		create_collision(food_types[current_type]["polygon"])
	
	# Update the collision polygon to match the new position and type
	if collision_poly:
		collision_poly.polygon = food_types[current_type]["polygon"]
	else:
		push_error("Collision polygon not found during respawn!")
