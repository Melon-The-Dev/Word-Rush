@tool
extends Sprite2D

@onready var letter_sprite: Sprite2D = $Letter

@export var grid_size := 56
@export var letter : LETTERS:
	set(newl):
		letter = newl
		if Engine.is_editor_hint(): set_letter_texture()
		elif update_tiles: set_letter_texture()
	get: return letter

enum LETTERS {
	A,
	B,
	C,
	D,
	E,
	F,
	G,
	H,
	I,
	J,
	K,
	L,
	M,
	N,
	O,
	P,
	Q,
	R,
	S,
	T,
	U,
	V,
	W,
	X,
	Y,
	Z}

#Tile letters
var tile_points = {
	'A': 1,
	'B': 3,
	'C': 3,
	'D': 2,
	'E': 1,
	'F': 4,
	'G': 2,
	'H': 4,
	'I': 1,
	'J': 8,
	'K': 5,
	'L': 1,
	'M': 3,
	'N': 1,
	'O': 1,
	'P': 3,
	'Q': 10,
	'R': 1,
	'S': 1,
	'T': 1,
	'U': 1,
	'V': 4,
	'W': 4,
	'X': 8,
	'Y': 4,
	'Z': 10,
	# Blank tiles (wildcards) typically score 0
	' ': 0}
var textures_path = "res://assets/tiles/PNG/"
var color = "Brown"
var update_tiles = false

#Dragging
var dragging := false
var tile_offset := Vector2.ZERO
var from_rack = true

#rack
var rack : Node
var pos_in_rack : Vector2

#map
var map_pos

const TILE_SHADOW = preload("res://scenes/tile_shadow.tscn")

func _ready() -> void:
	if !Engine.is_editor_hint(): set_letter_texture()
	rack = get_tree().get_first_node_in_group("rack")
	update_tiles = true
	pos_in_rack = position

func set_letter_texture():
	letter_sprite.texture = load(textures_path + color + "/" + "letter_" + LETTERS.keys()[letter] + ".png")

#region Tile Drag/Snap
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_global_mouse_position().distance_to(global_position) < grid_size / 2:
				dragging = true
				var ts = TILE_SHADOW.instantiate()
				add_child(ts)
				tile_offset = global_position - get_global_mouse_position()
				get_viewport().set_input_as_handled()
				reparent(get_tree().current_scene.get_node("Tiles"))
			elif not event.pressed and dragging:
				dragging = false
				from_rack = true
				get_child(1).free()
				if event.position.y >= rack.y_position-(grid_size/2) and event.position.y <= rack.y_position+(grid_size/2):
					reparent(rack)
					position = pos_in_rack
					remove_from_map()
					return
				_snap_to_grid()
				add_to_map()

func add_to_map():
	if map_pos: remove_from_map()
	get_tree().current_scene.add_tile_in_map(round(global_position / grid_size), LETTERS.keys()[letter])
	map_pos = round(global_position / grid_size)

func remove_from_map():
	get_tree().current_scene.remove_tile_in_map(map_pos)

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + tile_offset

func _snap_to_grid():
	global_position.x = round(global_position.x / grid_size) * grid_size
	global_position.y = round(global_position.y / grid_size) * grid_size
