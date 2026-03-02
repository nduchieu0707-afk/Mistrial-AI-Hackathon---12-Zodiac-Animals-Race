extends Node

static func get_all() -> Array:
	return [
		{"name": "Rat", "speed": 120, "stamina": 80, "ability": "Tiny - Boosts speed when surrounded"},
		{"name": "Ox", "speed": 70, "stamina": 130, "ability": "Sturdy - Double recovery for 5s"},
		{"name": "Tiger", "speed": 110, "stamina": 90, "ability": "Fierce - 30% speed boost"},
		{"name": "Rabbit", "speed": 100, "stamina": 100, "ability": "Nimble - 50% less stamina on boost"},
		{"name": "Dragon", "speed": 105, "stamina": 95, "ability": "Soaring - 50% boost at start"},
		{"name": "Snake", "speed": 115, "stamina": 85, "ability": "Gliding - 10% base speed increase"},
		{"name": "Horse", "speed": 100, "stamina": 100, "ability": "Wild - +5% per nearby horse"},
		{"name": "Goat", "speed": 90, "stamina": 110, "ability": "Mountain - 30% boost when tired"},
		{"name": "Monkey", "speed": 108, "stamina": 92, "ability": "Clever - Copies leader's ability"},
		{"name": "Rooster", "speed": 112, "stamina": 88, "ability": "Alert - Wakes up slow teammates"},
		{"name": "Dog", "speed": 95, "stamina": 105, "ability": "Hunter - 20% boost when chasing"},
		{"name": "Pig", "speed": 85, "stamina": 115, "ability": "Sturdy - 20% max stamina increase"}
	]
