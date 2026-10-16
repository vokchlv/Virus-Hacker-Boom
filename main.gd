extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var inventory_grid = $HUD/HBoxContainer/InventoryGrid
@onready var inventory = $Player/Inventory

func _ready() -> void:
	player.health_changed.connect(hud.update_health)
	hud.update_health(player.current_health, player.max_health)
	
	player.processing_power_changed.connect(hud.update_processing_power)
	hud.update_processing_power(player.current_processing_power, player.max_processing_power)
	
	inventory_grid.inventory = inventory
