extends CharacterBody2D
const TILE_SIZE = 16
const TIMER_INTERVAL = 1.0

var agent_tile: Vector2i
var terrain_tilemap: TileMapLayer
var resources_tilemap: TileMapLayer
var data_tilemap: TileMapLayer
var fog_tilemap: TileMapLayer
var movement_strategy: Callable

@export var inv: Inv

func _ready() -> void:
	var tilemap = get_parent().get_node("tilemap")
	terrain_tilemap = tilemap.get_node("terrain")
	resources_tilemap = tilemap.get_node("resources")
	data_tilemap = tilemap.get_node("data")
	fog_tilemap = tilemap.get_node("fog")
	
	set_movement_strategy(random_movement_strategy)
	agent_tile = get_tile_position()
	clear_surrounding_fog(agent_tile)

func _physics_process(delta: float) -> void:
	if terrain_tilemap.local_to_map(global_position) != agent_tile:
		global_position = terrain_tilemap.map_to_local(agent_tile)
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func move_agent(target_position : Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(
		self, "global_position", 
		terrain_tilemap.map_to_local(target_position), 
		0.5 * TIMER_INTERVAL
	)
	agent_tile = target_position;

#Get the current tile position based on global position
func get_tile_position() -> Vector2:
	return terrain_tilemap.local_to_map(global_position)

func _on_game_time_timeout() -> void:
	agent_tile = movement_strategy.call()
	clear_surrounding_fog(agent_tile)  
	move_agent(agent_tile)
	
func set_movement_strategy(strategy: Callable):
	movement_strategy = strategy
	
func idle_movement_strategy():
	return agent_tile

func random_movement_strategy():
	var possible_moves = {
			"right": {"target": agent_tile + Vector2i(1, 0), "movement_cost": get_terrain_data_at(agent_tile + Vector2i(1, 0), "movement_cost")},  # Right
			"left": {"target": agent_tile + Vector2i(-1, 0), "movement_cost": get_terrain_data_at(agent_tile + Vector2i(-1, 0), "movement_cost")}, # Left
			"down": {"target": agent_tile + Vector2i(0, 1), "movement_cost": get_terrain_data_at(agent_tile + Vector2i(0, 1), "movement_cost")},  # Down
			"up": {"target": agent_tile + Vector2i(0, -1), "movement_cost": get_terrain_data_at(agent_tile + Vector2i(0, -1), "movement_cost")}, # Up
		}
		
	# Get a random key
	var keys = possible_moves.keys()
	var random_index = randi() % keys.size()
	var random_move = possible_moves[keys[random_index]]
	while random_move["movement_cost"] > 0:
		# Cycle to the next index, wrapping around if needed
		random_index = (random_index + 1) % keys.size()
		random_move = possible_moves[keys[random_index]]
	
	return random_move.target
	
func clear_surrounding_fog(pos: Vector2i):
	var fog = fog_tilemap.get_surrounding_cells(pos);
	for cell in fog:
		fog_tilemap.set_cell(cell, -1)
	
	#fog_tilemap.set_cell(pos + Vector2i(1, 1), -1)
	reveal_tile(pos + Vector2i(1, 1))
	fog_tilemap.set_cell(pos + Vector2i(-1, -1), -1)
	fog_tilemap.set_cell(pos + Vector2i(-1, 1), -1)
	fog_tilemap.set_cell(pos + Vector2i(1, -1), -1)
	fog_tilemap.set_cell(pos, -1)

func reveal_tile(pos: Vector2i):
	var shader_material = fog_tilemap.material as ShaderMaterial
	if shader_material:
		var tween = get_tree().create_tween()
		tween.tween_property(
			shader_material, "shader_parameter/opacity", 
			0, 
			0.5 * TIMER_INTERVAL
		)

func get_terrain_data_at(pos: Vector2, prop: String):
	var data = data_tilemap.get_cell_tile_data(pos)
	return data.get_custom_data(prop)	

func collect(item):
	inv.insert(item)
