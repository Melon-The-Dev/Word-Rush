extends Node2D

@onready var bg: Sprite2D = $BG
@onready var tiles_collection: Node2D = $Tiles
@onready var camera_2d: Camera2D = $Camera2D
@onready var tile_rack: Node2D = $"CanvasLayer/tile rack"

# Dictionary where keys are grid positions, values are letters
var tile_map = {}
var placing_tile_map = {}:
	set(newptm):
		placing_tile_map = newptm
		print(placing_tile_map)
	get:return placing_tile_map
var placed_tile_map = {}

var dictionary := {}
var words_placed = []

func _ready() -> void:
	bg.show()
	load_dictionary("res://assets/words.txt")


#region Tile Placement
func load_dictionary(path):
	var file = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		dictionary[file.get_line().strip_edges().to_upper()] = true

func is_valid_word(word: String) -> bool:
	return dictionary.has(word.to_upper())

func update_map():
	placing_tile_map.clear()
	placed_tile_map.clear()
	for tile in %Tiles.get_children():
		#tile_map[tile.map_pos] = tile.letter_string
		placing_tile_map[tile.map_pos] = tile.letter_string
	for tile in %PlacedTiles.get_children():
		#tile_map[tile.map_pos] = tile.letter_string
		placed_tile_map[tile.map_pos] = tile.letter_string
	if placing_tile_map: camera_2d.focus_on_position(get_tiles_center_position())
	print(placing_tile_map)

func add_tile_in_map(pos, letter):
	tile_map[pos] = letter.capitalize()
	camera_2d.focus_on_position(get_tiles_center_position())
	#print("------ Placed ------")
	#print(tile_map)
	#print(check_words(placing_tile_map.keys()),"\n")

func remove_tile_in_map(pos):
	tile_map.erase(pos)
	#print("------ Removed ------")
	#print(tile_map)
	#print(check_words(placing_tile_map.keys()),"\n")

func get_word_from(start_pos: Vector2, dir: Vector2) -> String:
	var pos = start_pos
	while placing_tile_map.merged(placed_tile_map).has(pos - dir):
		pos -= dir

	var word := ""
	while placing_tile_map.merged(placed_tile_map).has(pos):
		word += placing_tile_map.merged(placed_tile_map)[pos]
		pos += dir
	return word

func get_word_positions(start_pos: Vector2, dir: Vector2) -> Array:
	var pos = start_pos
	while placing_tile_map.merged(placed_tile_map).has(pos - dir):
		pos -= dir

	var positions := []
	while placing_tile_map.merged(placed_tile_map).has(pos):
		positions.append(pos)
		pos += dir
	return positions


func check_words(placed_positions: Array) -> Array:
	var words: Array = []
	var visited_keys := {}
	var directions = [Vector2(1, 0), Vector2(0, 1)]  # horizontal and vertical
	for pos in placed_positions:
		for dir in directions:
			var word := get_word_from(pos, dir)
			$CanvasLayer/Control/Label2.text = str(word)
			if word.length() > 1:
				var positions := get_word_positions(pos, dir)
				var key := ",".join(positions.map(func(p): return str(p)))
				if not visited_keys.has(key):
					visited_keys[key] = true
					words.append(word)
	# Validate words
	for word in words:
		if not is_valid_word(word):
			print("Invalid word:", word)
			return []
	# Check for connection
	if not is_move_connected(placed_positions):
		print("Move not connected to board.")
		return []
	return words


func has_tile(pos: Vector2) -> bool:
	#return placing_tile_map.has(pos)
	return placing_tile_map.merged(placed_tile_map).has(pos)

# Make sure move is connected to the board (unless it's the first move)
func is_move_connected(placed_positions: Array) -> bool:
	var is_first_move = placed_tile_map.is_empty()
	var dirs = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	if is_first_move:
		var board_center = Vector2(0, 0)  # adjust based on your board size
		for pos in placing_tile_map.keys():
			var ncount = 0
			for dir in dirs:
				var neighbor = pos + dir
				if placing_tile_map.has(neighbor):
					ncount += 1
			if ncount == 0:return false
		return placed_positions.has(board_center)
	for pos in (placed_positions):
		var ncount = 0
		for dir in dirs:
			var neighbor = pos + dir
			if placed_tile_map.keys().has(neighbor) or placing_tile_map.keys().has(neighbor):
				ncount += 1
		if ncount == 0:return false
	return true




#endregion

func array_difference(arr1, arr2):
	var only_in_arr1 = []
	for v in arr1:
		if not (v in arr2):
			only_in_arr1.append(v)
	return only_in_arr1

func play_words():
	words_placed.append_array(check_words(placing_tile_map.keys()))
	for tile in %Tiles.get_children():
		tile_map[tile.map_pos] = tile.letter_string
	for tile in %PlacedTiles.get_children():
		tile_map[tile.map_pos] = tile.letter_string
	
	for tile in %Tiles.get_children():
		tile.reparent(%PlacedTiles)
	placing_tile_map.clear()
	refill_rack()

func get_tiles_center_position() -> Vector2:
	var total_x := 0.0
	var total_y := 0.0
	for tile in placing_tile_map.keys():
		total_x += round(tile.x*56)
		total_y += round(tile.y*56)
	var average_x := total_x / placing_tile_map.size()
	var average_y := total_y / placing_tile_map.size()
	return Vector2(average_x, average_y)  # Use rack's y-position

func refill_rack():
	for x in tile_rack.tile_count-tile_rack.get_child_count():
		tile_rack.add_tile()

func _process(delta: float) -> void:

	$CanvasLayer/Control/Label.text = "Words formed: "
	for i in array_difference(check_words(placing_tile_map.keys()), words_placed):
		$CanvasLayer/Control/Label.text += i + ", "
	if Input.is_action_just_pressed("ui_accept"):
		play_words()
