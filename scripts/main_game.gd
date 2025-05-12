extends Node2D

# Dictionary where keys are grid positions, values are letters
var tile_map = {
	#Vector2(5, 3): "C",
	#Vector2(6, 3): "A",
	#Vector2(7, 3): "T",
	#Vector2(7, 2): "A",
	#Vector2(7, 1): "H",
	#Vector2(7, 0): "T",
}

var dictionary := {}

func _ready() -> void:
	load_dictionary("res://assets/words.txt")

func load_dictionary(path):
	var file = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		dictionary[file.get_line().strip_edges().to_upper()] = true

func is_valid_word(word: String) -> bool:
	return dictionary.has(word.to_upper())

func add_tile_in_map(pos, letter):
	tile_map[pos] = letter.capitalize()
	print(check_words(tile_map.keys()))

func remove_tile_in_map(pos):
	tile_map.erase(pos)
	print(tile_map)
	print(check_words(tile_map.keys()))

func check_words(placed_positions: Array) -> Array:
	var words = []
	for pos in placed_positions:
		var h_word = get_word_from(pos, Vector2(1, 0))
		if h_word.length() > 1 and is_valid_word(h_word) and !words.has(h_word):
			words.append(h_word)
		var v_word = get_word_from(pos, Vector2(0, 1))
		if v_word.length() > 1 and is_valid_word(v_word) and !words.has(v_word):
			words.append(v_word)
	return words

func get_word_from(start_pos: Vector2, dir: Vector2) -> String:
	var word = ""
	var pos = start_pos
	while tile_map.has(pos - dir):
		pos -= dir
	while tile_map.has(pos):
		word += tile_map[pos]
		pos += dir
	return word

func aray_difference(arr1, arr2):
	var only_in_arr1 = []
	for v in arr1:
		if not (v in arr2):
			only_in_arr1.append(v)
	return only_in_arr1
