extends Line2D

var start_speed = 300.0
var speed = start_speed
var direction = Vector2.RIGHT

# Variables for dynamically created nodes
var head_area: Area2D
var collision_poly: CollisionPolygon2D

func _ready():
	self.hide()
	var viewport_size = get_viewport_rect().size
	var first_position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	add_point(first_position)
	# Start with a small snake
	for i in range(9):
		add_point(Vector2(first_position.x + i * 5, first_position.y))

	self.width = 8
	self.default_color = Color.LAWN_GREEN
	self.begin_cap_mode = Line2D.LINE_CAP_ROUND
	self.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	create_head_collision()
	adjust_width_curve()

	
func grow_width(size):
	if self.width < 16:
		self.width += 0.05 * size
		adjust_head_collision()

func create_head_collision():
	head_area = Area2D.new()
	head_area.name = "HeadArea"
	add_child(head_area)
	
	collision_poly = CollisionPolygon2D.new()
	collision_poly.name = "CollisionPolygon2D"
	
	adjust_head_collision()
	
	head_area.add_child(collision_poly)
	
func adjust_head_collision():
	var head_polygon = PackedVector2Array([
		Vector2((-width/2) - 1, 0),
		Vector2(0, (-width/2) - 1),
		Vector2((width/2) + 1, 0),
		Vector2(0, (width/2) + 1)
	])
	collision_poly.polygon = head_polygon

func _process(delta):
	# Move the snake's head
	var head_position = points[0] + direction * speed * delta
	points[0] = head_position
	
	# Move body segments to follow head
	for i in range(1, points.size()):
		var prev_position = points[i - 1]
		var current_position = points[i]
		points[i] = current_position.lerp(prev_position, delta * (speed/10.0))  # Smooth movement
	
	# Update head collision to follow the head's position
	update_head_collision()
	
	# Bounce off screen edges (if needed)
	var screen_size = get_viewport().get_visible_rect().size
	if head_position.x < 0 or head_position.x > screen_size.x:
		direction.x *= -1
	if head_position.y < 0 or head_position.y > screen_size.y:
		direction.y *= -1

func update_head_collision():
	if head_area and collision_poly:
		head_area.global_position = points[0]
		# Rotation might be needed if the snake can turn in different directions
		# For now, assuming it's always facing the direction it's moving
		head_area.global_rotation = direction.angle()
	else:
		push_error("Head area or collision polygon not found!")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP and direction != Vector2.DOWN:
			direction = Vector2.UP
		elif event.keycode == KEY_DOWN and direction != Vector2.UP:
			direction = Vector2.DOWN
		elif event.keycode == KEY_LEFT and direction != Vector2.RIGHT:
			direction = Vector2.LEFT
		elif event.keycode == KEY_RIGHT and direction != Vector2.LEFT:
			direction = Vector2.RIGHT

		if event.keycode == KEY_SPACE:
			if speed == 5:
				speed = start_speed
			else:
				speed = 5

func adjust_width_curve():
	if !width_curve:
		width_curve = Curve.new()

	var total_points = points.size()
	var head_portion = 0.12  # Percentage of the line where the head effect ends
	var tail_portion = 0.1  # Percentage of the line where the tail effect begins
	var body_portion = 1.0 - head_portion - tail_portion  # The rest is body

	# Calculate total length in pixels
	var total_length = 0.0
	for i in range(1, total_points):
		total_length += points[i - 1].distance_to(points[i])

	# Set a maximum head length in pixels, e.g., 20 pixels
	var max_head_length_pixels = 60

	# Calculate head length in pixels, capping it at max_head_length_pixels
	var head_length_pixels = min(total_length * head_portion, max_head_length_pixels)

	# Convert head length back to a proportion of total length for curve placement
	var head_proportion = head_length_pixels / total_length if total_length > 0 else 0

	# Clear existing points
	while width_curve.get_point_count() > 0:
		width_curve.remove_point(0)

	# Add points for head, using head_proportion for positioning
	width_curve.add_point(Vector2(0, 0.8))
	width_curve.add_point(Vector2(head_proportion * 0.25, 0.9))
	width_curve.add_point(Vector2(head_proportion * 0.5, 1))
	width_curve.add_point(Vector2(head_proportion * 0.75, 0.9))
	width_curve.add_point(Vector2(head_proportion, 0.7))

	# Add points for body
	var body_start = head_proportion
	var body_end = body_start + (body_portion * (1 - head_proportion))  # Adjust body portion
	width_curve.add_point(Vector2(body_start, 0.7))
	width_curve.add_point(Vector2(body_start + (body_end - body_start) / 2, 0.65))
	width_curve.add_point(Vector2(body_end, 0.25))

	# Add points for tail to make it taper
	var tail_start = body_end
	var tail_end = 1.0
	width_curve.add_point(Vector2(tail_start, 0.2))
	width_curve.add_point(Vector2(tail_end, 0.143))

func grow(times: int = 1):
	for i in range(times):
		if points.size() > 1:
			var tail_position = points[points.size() - 1]
			var second_last_position = points[points.size() - 2]
			var growth_direction = tail_position - second_last_position
			var new_tail_position = tail_position + growth_direction.normalized() * width
			add_point(new_tail_position)
		elif points.size() == 1:
			var new_tail_position = points[0] - direction.normalized() * width
			add_point(new_tail_position)
			
		if speed > 100:
			speed -= 2
			
		grow_width(get_point_count())
		
	adjust_width_curve()
