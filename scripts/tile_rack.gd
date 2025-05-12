extends Node2D

@export var easy_count := 10
@export var medium_count := 8
@export var hard_count := 6
@export var difficulty := "easy"  # "easy", "medium", "hard"

@export var tile_scene: PackedScene  # assign your tile scene in the editor
@export var y_position := 648  # vertical position of the rack on screen
@export var spacing := 8.0  # minimum space between tiles

@export var left_margin := 20  # Left margin in pixels
@export var right_margin := 20  # Right margin in pixels
@export var bottom_margin := 20  # Bottom margin in pixels

func _ready():
	create_rack()

func create_rack():
	var tile_count = easy_count
	match difficulty:
		"easy": tile_count = easy_count
		"medium": tile_count = medium_count
		"hard": tile_count = hard_count
	
	var screen_width := get_viewport_rect().size.x
	print(screen_width)
	# Estimate tile size (you could also use a known size)
	var temp_tile = tile_scene.instantiate()
	var tile_width = temp_tile.get_rect().size.x*temp_tile.scale.x
	temp_tile.queue_free()
	
	var total_tiles_width = tile_count * tile_width
	
	# Calculate the available space after accounting for margins
	var available_width := screen_width - left_margin - right_margin
	
	# Calculate the remaining space to distribute as spacing between tiles
	var total_spacing = available_width - total_tiles_width
	var spacing = total_spacing / (tile_count - 1)
	
	# Make sure the spacing doesn't go below a minimum value (to avoid tiles being too close)
	spacing = max(spacing, 8)  # Minimum spacing of 8 pixels
	
	# Calculate the starting position so the rack is centered (with margins)
	var start_x = (left_margin + (available_width - total_tiles_width - (tile_count - 1) * spacing) / 2) + (tile_width/2)
	
	# Create and position the tiles
	for i in range(tile_count):
		var tile := tile_scene.instantiate()
		#print(tile.LETTERS.keys().pick_random())
		tile.letter = tile.LETTERS.values().pick_random()
		var x = start_x + i * (tile_width + spacing)
		tile.position = Vector2(x, y_position)
		add_child(tile)
