extends Node2D

# JUGADORES
var players = []
var current_player := 0
var tiles: Array = []

# ESCALERAS (inicio → destino)
var ladders := {
	8: 26,
	21: 79,
	50: 91,
	43: 77,
	62: 96,
	66: 87,
	54: 93,
	82: 100
}

# SERPIENTES (inicio → destino)
var snakes := {
	92: 51,
	95: 24,
	98: 28,
	83: 19,
	64: 36,
	69: 33,
	59: 17,
	44: 19,
	46: 5,
	48: 9,
	52: 11,
	73: 1
}

# ----------------------------------------------------
# READY
# ----------------------------------------------------
func _ready():
	randomize()

	players = [
		$Players/Player1,
		$Players/Player2
	]

	_load_tiles()

	if tiles.is_empty():
		push_error("❌ No se detectaron casillas. Asegúrate de que estén dentro de 'Board' y se llamen Tile_1, Tile_2, ...")
		return

	# Colocar jugadores en casilla 1 (índice 0)
	for p in players:
		p.tile_index = 0
		p.global_position = tiles[0].global_position

	# UI inicial
	$UI/TurnLabel.text = "Turno del Jugador 1"
	$UI/DiceResult.text = "Dado: -"


# ----------------------------------------------------
# CARGAR CASILLAS
# ----------------------------------------------------
func _load_tiles():
	tiles.clear()

	for child in $Board.get_children():
		if child.name.begins_with("Tile_"):
			tiles.append(child)

	# Ordenar por nombre
	tiles.sort_custom(func(a, b): return a.name < b.name)

	print("Tiles detectados:", tiles.size())


# ----------------------------------------------------
# TIRAR DADO
# ----------------------------------------------------
func roll_dice() -> int:
	var n = randi() % 6 + 1
	move_player(n)
	return n


# ----------------------------------------------------
# MOVER JUGADOR
# ----------------------------------------------------
func move_player(steps: int):
	var p = players[current_player]

	# Avanzar
	p.tile_index += steps

	# No salir del tablero
	if p.tile_index >= tiles.size():
		p.tile_index = tiles.size() - 1

	# Mover a la casilla normal
	p.global_position = tiles[p.tile_index].global_position

	await get_tree().process_frame

	# ESCALERAS
	if ladders.has(p.tile_index + 1):
		var dest = ladders[p.tile_index + 1] - 1
		p.tile_index = dest
		p.global_position = tiles[dest].global_position
		print("Subiste escalera a", dest + 1)

	# SERPIENTES
	elif snakes.has(p.tile_index + 1):
		var dest = snakes[p.tile_index + 1] - 1
		p.tile_index = dest
		p.global_position = tiles[dest].global_position
		print("Bajaste serpiente a", dest + 1)

	# Cambiar turno
	current_player = (current_player + 1) % players.size()

	# Actualizar UI de turno
	$UI/TurnLabel.text = "Turno del Jugador " + str(current_player + 1)
