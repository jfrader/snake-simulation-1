extends Node2D

var snake = null
var food = null
var score = 0

var ui_score: Label

func _ready():
	create_snake()
	create_food()	
	create_ui()
	await get_tree().create_timer(0.4).timeout
	food.show()
	snake.show()

func _process(delta):
	check_collision()
	update_ui()
	
func create_ui():
	var viewport_size = get_viewport().get_visible_rect().size
	ui_score = Label.new()
	update_ui()
	ui_score.set_position(Vector2(20, 10))
	add_child(ui_score)
	
func update_ui():
	ui_score.text = str(score)

func create_snake():
	# Create Line2D node
	snake = Line2D.new()
	snake.name = "SnakeBody"  # Give it a name if needed
	
	# Attach the Snake script
	var snake_script = load("res://Snake.gd")  # Replace with the actual path to your Snake script
	snake.set_script(snake_script)
	
	# Add the snake to the scene tree
	add_child(snake)

func create_food():
	food = Polygon2D.new()
	food.set_script(load("res://Food.gd"))  # Replace with the actual path to your Food script
	add_child(food)

func check_collision():
	if food && snake:
		var food_collision_poly = food.get_node_or_null("CollisionArea/CollisionPolygon2D")
		var snake_head_poly = snake.get_node_or_null("HeadArea/CollisionPolygon2D")
		
		if food_collision_poly && snake_head_poly:
			# Both are now CollisionPolygon2D, so no need for shape conversion
			var global_food_polygon = PackedVector2Array()
			for point in food_collision_poly.polygon:
				global_food_polygon.append(point + food.global_position)
			
			var global_snake_polygon = PackedVector2Array()
			for point in snake_head_poly.polygon:
				global_snake_polygon.append(point.rotated(snake_head_poly.global_rotation) + snake_head_poly.global_position)
			
			# Check for intersection directly with polygons
			if Geometry2D.intersect_polygons(global_snake_polygon, global_food_polygon).size() > 0:
				snake.grow(food.score)
				score += food.score
				food.respawn()
