extends CharacterBody2D
const TILE_SIZE = 16
var agent_tile: Vector2i
var terrain_tilemap: TileMapLayer
var resources_tilemap: TileMapLayer

func _ready() -> void:
	var tilemap = get_parent().get_node("tilemap")
	terrain_tilemap = tilemap.get_node("terrain")
	resources_tilemap = tilemap.get_node("resources")
	
	agent_tile = get_tile_position()
	print(agent_tile)

func _physics_process(delta: float) -> void:
	if terrain_tilemap.local_to_map(global_position) != agent_tile:
		velocity = Vector2i((terrain_tilemap.local_to_map(global_position).x - agent_tile.x)*20, (terrain_tilemap.local_to_map(global_position).y - agent_tile.y)*20)
		move_and_slide()
	else:
		velocity = Vector2.ZERO


#Get the current tile position based on global position
func get_tile_position() -> Vector2:
	return terrain_tilemap.local_to_map(global_position)


func _on_game_time_timeout() -> void:
	var possible_moves = [
			Vector2i(1, 0),  # Right
			Vector2i(-1, 0), # Left
			Vector2i(0, 1),  # Down
			Vector2i(0, -1)  # Up
		]
		
	var random_direction = possible_moves[randi() % possible_moves.size()]
	var new_tile = agent_tile + random_direction
	agent_tile = new_tile
