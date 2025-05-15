extends Node2D

@export var easy_count := 10
@export var medium_count := 8
@export var hard_count := 6
@export var difficulty := "easy"  # "easy", "medium", "hard"

@export var tile_scene: PackedScene  # assign your tile scene in the editor
@export var y_position := 648  # vertical position of the rack on screen
@export var spacing := 8.0  # constant space between tiles

@export var left_margin := 20
@export var right_margin := 20
@export var bottom_margin := 20

@export var tile_width := 0.0
var tile_count = easy_count

func _ready():
	# Determine tile width once
	if tile_scene:
		var temp_tile := tile_scene.instantiate()
		tile_width = 51 if difficulty == "easy" else 64
		temp_tile.queue_free()
	var base_resolution := Vector2(648, 1152)
	var current_resolution := get_viewport().get_visible_rect().size
	var scale_ratio := current_resolution / base_resolution
	y_position = y_position*scale_ratio.y
	calculate_spacing_for_difficulty()
	create_rack()
	connect("child_entered_tree", Callable(self, "_on_child_updated"))
	connect("child_exiting_tree", Callable(self, "_on_child_updated"))

func calculate_spacing_for_difficulty():
	var screen_width := get_viewport().get_visible_rect().size.x
	match difficulty:
		"easy": tile_count = easy_count
		"medium": tile_count = medium_count
		"hard": tile_count = hard_count

	var available_width := screen_width - left_margin - right_margin
	var total_tiles_width = tile_count * tile_width

	if tile_count > 1:
		var total_spacing_available = available_width - total_tiles_width
		spacing = max(total_spacing_available / (tile_count - 1), 8.0)
	else:
		spacing = 8.0  # fallback for 1 or fewer tiles

func create_rack():
	match difficulty:
		"easy": tile_count = easy_count
		"medium": tile_count = medium_count
		"hard": tile_count = hard_count

	for i in range(tile_count):
		add_tile()

func add_tile():
	if not tile_scene:
		return
	var tile := tile_scene.instantiate()
	tile.letter = tile.LETTERS.values().pick_random()
	add_child(tile)
	arrange_tiles()

func _on_child_updated(child: Node) -> void:
	# Delay to ensure child removal/addition completes before arranging
	await get_tree().process_frame
	arrange_tiles()

func arrange_tiles():
	var tiles := get_children().filter(func(n): return n.has_method("get_rect"))
	if tiles.is_empty() or tile_width == 0:
		return
	var start_x := left_margin + tile_width / 2
	for i in range(tiles.size()):
		tiles[i].scale = Vector2(0.2,0.2)
		var x := start_x + i * (tile_width + spacing)
		tiles[i].position = Vector2(x, y_position)
