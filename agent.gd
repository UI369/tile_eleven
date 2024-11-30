extends CharacterBody2D
const TILE_SIZE = 16
var agent_tile: Vector2i
var terrain_tilemap: TileMapLayer
var resources_tilemap: TileMapLayer
var data_tilemap: TileMapLayer

func _ready() -> void:
	var tilemap = get_parent().get_node("tilemap")
	terrain_tilemap = tilemap.get_node("terrain")
	resources_tilemap = tilemap.get_node("resources")
	data_tilemap = tilemap.get_node("data")
	
	agent_tile = get_tile_position()
	print(agent_tile)

func _physics_process(delta: float) -> void:
	if terrain_tilemap.local_to_map(global_position) != agent_tile:
		global_position = terrain_tilemap.map_to_local(agent_tile)
		print("at:", agent_tile)
		get_terrain_data_at(agent_tile, "movement_cost")
		#velocity = Vector2i((terrain_tilemap.local_to_map(global_position).x - agent_tile.x)*20, (terrain_tilemap.local_to_map(global_position).y - agent_tile.y)*20)
		move_and_slide()
	else:
		velocity = Vector2.ZERO


#Get the current tile position based on global position
func get_tile_position() -> Vector2:
	return terrain_tilemap.local_to_map(global_position)


func _on_game_time_timeout() -> void:
	var possible_moves = {
			"right": {"target": agent_tile + Vector2i(1, 0), "movement_cost": get_terrain_data_at(agent_tile + Vector2i(1, 0), "movement_cost")},  # Right
			"left": {"target": agent_tile + Vector2i(-1, 0), "movement_cost": get_terrain_data_at(agent_tile + Vector2i(-1, 0), "movement_cost")}, # Left
			"down": {"target": agent_tile + Vector2i(0, 1), "movement_cost": get_terrain_data_at(agent_tile + Vector2i(0, 1), "movement_cost")},  # Down
			"up": {"target": agent_tile + Vector2i(0, -1), "movement_cost": get_terrain_data_at(agent_tile + Vector2i(0, -1), "movement_cost")}, # Up
		}
		
	print("pm:", possible_moves)
	
	
	# Get a random key
	var keys = possible_moves.keys()
	var random_index = randi() % keys.size()
	var random_move = possible_moves[keys[random_index]]
	while random_move["movement_cost"] > 0:
		# Cycle to the next index, wrapping around if needed
		random_index = (random_index + 1) % keys.size()
		random_move = possible_moves[keys[random_index]]
	
	agent_tile = random_move.target
	

func get_terrain_data_at(pos: Vector2, prop: String):
	var data = data_tilemap.get_cell_tile_data(pos)
	print(data)
	print (prop,":",data.get_custom_data(prop))
	return data.get_custom_data(prop)	
