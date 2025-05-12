extends Sprite2D

var grid_size := 0.0

func _ready() -> void:
	grid_size = get_parent().grid_size
	z_index = 0
	top_level = true

func _process(delta: float) -> void:
	scale = get_parent().scale
	texture = get_parent().get_child(0).texture
	global_position.x = round(get_parent().global_position.x / grid_size) * grid_size
	global_position.y = round(get_parent().global_position.y / grid_size) * grid_size
