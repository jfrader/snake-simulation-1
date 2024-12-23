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

func _process(_delta):
	check_collision()
	update_ui()
	
func create_ui():
	ui_score = Label.new()
	update_ui()
	ui_score.set_position(Vector2(20, 10))
	add_child(ui_score)
	
func update_ui():
	ui_score.text = str(score)

func create_snake():
	snake = Line2D.new()
	snake.name = "SnakeBody"
	var snake_script = load("res://Snake.gd") 
	snake.set_script(snake_script)
	add_child(snake)

func create_food():
	food = Polygon2D.new()
	food.set_script(load("res://Food.gd"))
	add_child(food)

func check_collision():
	if food && snake:
		var food_collision_poly = food.get_node_or_null("CollisionArea/CollisionPolygon2D")
		var snake_head_poly = snake.get_node_or_null("HeadArea/CollisionPolygon2D")
		
		if food_collision_poly && snake_head_poly:
			var global_food_polygon = PackedVector2Array()
			for point in food_collision_poly.polygon:
				global_food_polygon.append(point + food.global_position)
			
			var global_snake_polygon = PackedVector2Array()
			for point in snake_head_poly.polygon:
				global_snake_polygon.append(point.rotated(snake_head_poly.global_rotation) + snake_head_poly.global_position)

			if Geometry2D.intersect_polygons(global_snake_polygon, global_food_polygon).size() > 0:
				snake.grow(food.score)
				score += food.score
				food.respawn()
