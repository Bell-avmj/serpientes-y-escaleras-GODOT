extends Button

func _on_pressed():
	var game = get_tree().root.get_node("Game")

	var result = game.roll_dice()

	# Actualizar UI
	game.get_node("UI/DiceResult").text = "Dado: " + str(result)
