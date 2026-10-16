extends CanvasLayer

@export var health_alive: Texture2D
@export var health_dead: Texture2D

@export var processing_power_full: Texture2D
@export var processing_power_empty: Texture2D

@export var segment_frame: Texture2D
@export var segment_fill: Texture2D
@export var end_frame: Texture2D
@export var end_fill: Texture2D

@onready var health_bar: HBoxContainer = $HBoxContainer/BarsContainer/HealthBar
@onready var processing_power_bar: HBoxContainer = $HBoxContainer/BarsContainer/ProcessingPowerBar

func setup_hp_bar(max_health: int) -> void:
	for child in health_bar.get_children():
		child.queue_free()
	
	for i in max_health:
		var frame_texture : Texture2D
		var fill_texture: Texture2D
		
		if i == 0:
			frame_texture = health_dead
			fill_texture = health_alive
		elif i + 1 == max_health:
			frame_texture = end_frame
			fill_texture = end_fill
		else:
			frame_texture = segment_frame
			fill_texture = segment_fill
		
		var frame := TextureRect.new()
		frame.texture = frame_texture
		frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		var fill := TextureRect.new()
		fill.texture = fill_texture
		fill.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fill.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		frame.add_child(fill)
		health_bar.add_child(frame)
		
func setup_processing_power_bar(max_processing_power) -> void:
	for child in processing_power_bar.get_children():
		child.queue_free()
	
	for i in max_processing_power:
		var frame_texture : Texture2D
		var fill_texture: Texture2D
		
		if i == 0:
			frame_texture = processing_power_empty
			fill_texture = processing_power_full
		elif i + 1 == max_processing_power:
			frame_texture = end_frame
			fill_texture = end_fill
		else:
			frame_texture = segment_frame
			fill_texture = segment_fill
		
		var frame := TextureRect.new()
		frame.texture = frame_texture
		frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		var fill := TextureRect.new()
		fill.texture = fill_texture
		fill.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fill.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		frame.add_child(fill)
		processing_power_bar.add_child(frame)
		
func update_health(current_health: int, max_health: int) -> void:
	if health_bar.get_child_count() != max_health:
		setup_hp_bar(max_health)
	for i in health_bar.get_child_count():
		var is_full := i + 1 <= current_health
		health_bar.get_child(i).get_child(0).visible = is_full
		
func update_processing_power(current_processing_power: int, max_processing_power: int) -> void:
	if processing_power_bar.get_child_count() != max_processing_power:
		setup_processing_power_bar(max_processing_power)
	for i in processing_power_bar.get_child_count():
		var is_full := i + 1 <= current_processing_power
		processing_power_bar.get_child(i).get_child(0).visible = is_full
