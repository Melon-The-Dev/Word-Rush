extends Camera2D

# Zoom limits
var min_zoom = Vector2(0.25, 0.25)
var max_zoom = Vector2(2, 2)

# Dragging support
var dragging = false
var last_mouse_pos = Vector2()

# Auto-focus target
var target_position = position
var lerp_speed = 5.0

func _unhandled_input(event):
	# --- Dragging ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				last_mouse_pos = event.position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		var delta = last_mouse_pos - event.position
		position += delta / zoom  # Account for zoom scale
		target_position = position  # Override auto-move while dragging
		last_mouse_pos = event.position

	# --- Pinch Zoom (Multitouch) or Scrollwheel Zoom ---
	if event is InputEventMagnifyGesture:
		var zoom_factor = 1.0 - event.factor
		zoom = (zoom * zoom_factor).clamped(min_zoom, max_zoom)

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom = (zoom * 1.05).clamp(min_zoom, max_zoom)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom = (zoom * 0.95).clamp(min_zoom, max_zoom)

func _process(delta):
	# Smooth camera follow to the target position (auto-focus)
	position = position.lerp(target_position, lerp_speed * delta)

# Call this method from game logic when a new word is placed
func focus_on_position(pos: Vector2):
	target_position = pos
