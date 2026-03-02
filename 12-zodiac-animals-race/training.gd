extends Node2D

var selected_horse_data = null
var all_horses = []
var player_index = 0

var stats = {
	"speed": 0,
	"stamina": 0,
	"intelligence": 0,
	"guts": 0,
	"willpower": 0
}

var horse_name = ""
var base_speed = 0
var base_stamina = 0
var horse_sprite_texture = null

var ui_layer : CanvasLayer
var GlobalData = preload("res://global.gd")

var training_points = 10

# Tham chiếu đến các label để cập nhật nhanh
var speed_label : Label
var stamina_label : Label
var int_label : Label
var guts_label : Label
var will_label : Label
var points_label : Label

func _ready():
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	print("Training ready")

func setup(horse_data, all_horses_array, index):
	selected_horse_data = horse_data
	all_horses = all_horses_array
	player_index = index
	horse_name = horse_data.name
	base_speed = horse_data.speed
	base_stamina = horse_data.stamina
	
	if all_horses != null and all_horses.size() > player_index and all_horses[player_index] != null:
		var horse_node = all_horses[player_index]
		if horse_node and horse_node.has_node("Sprite2D"):
			var original_sprite = horse_node.get_node("Sprite2D")
			if original_sprite and original_sprite.texture:
				horse_sprite_texture = original_sprite.texture
	
	show_training_ui()

func show_training_ui():
	if ui_layer == null:
		ui_layer = CanvasLayer.new()
		add_child(ui_layer)
	
	for child in ui_layer.get_children():
		child.queue_free()
	
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.2, 1)
	bg.size = Vector2(1152, 648)
	bg.position = Vector2(0, 0)
	ui_layer.add_child(bg)
	
	# Title
	var title = Label.new()
	title.text = "TRAINING - " + horse_name
	title.position = Vector2(400, 30)
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color.GOLD)
	title.z_index = 100  # Đảm bảo hiển thị trên cùng
	ui_layer.add_child(title)
	
	# Points - Lưu lại để cập nhật
	points_label = Label.new()
	points_label.text = "Points: " + str(training_points)
	points_label.position = Vector2(500, 80)
	points_label.add_theme_font_size_override("font_size", 24)
	points_label.add_theme_color_override("font_color", Color.WHITE)
	points_label.z_index = 100
	ui_layer.add_child(points_label)
	
	# Horse sprite
	if horse_sprite_texture:
		var sprite = Sprite2D.new()
		sprite.texture = horse_sprite_texture
		sprite.scale = Vector2(2, 2)
		sprite.position = Vector2(576, 200)
		ui_layer.add_child(sprite)
	
	# Stats
	var y_pos = 300
	
	# SPEED
	var speed_bg = ColorRect.new()
	speed_bg.color = Color(0.2, 0.2, 0.3, 1)
	speed_bg.size = Vector2(300, 40)
	speed_bg.position = Vector2(390, y_pos - 5)
	ui_layer.add_child(speed_bg)
	
	speed_label = Label.new()
	speed_label.text = "SPEED: " + str(stats["speed"])
	speed_label.position = Vector2(400, y_pos)
	speed_label.add_theme_font_size_override("font_size", 24)
	speed_label.add_theme_color_override("font_color", Color.YELLOW)
	ui_layer.add_child(speed_label)
	
	var speed_plus = Button.new()
	speed_plus.text = "+"
	speed_plus.position = Vector2(620, y_pos - 10)
	speed_plus.size = Vector2(50, 40)
	speed_plus.modulate = Color.GREEN
	speed_plus.pressed.connect(_on_increase_stat.bind("speed"))
	ui_layer.add_child(speed_plus)
	
	var speed_minus = Button.new()
	speed_minus.text = "-"
	speed_minus.position = Vector2(680, y_pos - 10)
	speed_minus.size = Vector2(50, 40)
	speed_minus.modulate = Color.RED
	speed_minus.pressed.connect(_on_decrease_stat.bind("speed"))
	ui_layer.add_child(speed_minus)
	
	y_pos += 60
	
	# STAMINA
	var stamina_bg = ColorRect.new()
	stamina_bg.color = Color(0.2, 0.2, 0.3, 1)
	stamina_bg.size = Vector2(300, 40)
	stamina_bg.position = Vector2(390, y_pos - 5)
	ui_layer.add_child(stamina_bg)
	
	stamina_label = Label.new()
	stamina_label.text = "STAMINA: " + str(stats["stamina"])
	stamina_label.position = Vector2(400, y_pos)
	stamina_label.add_theme_font_size_override("font_size", 24)
	stamina_label.add_theme_color_override("font_color", Color.GREEN)
	ui_layer.add_child(stamina_label)
	
	var stamina_plus = Button.new()
	stamina_plus.text = "+"
	stamina_plus.position = Vector2(620, y_pos - 10)
	stamina_plus.size = Vector2(50, 40)
	stamina_plus.modulate = Color.GREEN
	stamina_plus.pressed.connect(_on_increase_stat.bind("stamina"))
	ui_layer.add_child(stamina_plus)
	
	var stamina_minus = Button.new()
	stamina_minus.text = "-"
	stamina_minus.position = Vector2(680, y_pos - 10)
	stamina_minus.size = Vector2(50, 40)
	stamina_minus.modulate = Color.RED
	stamina_minus.pressed.connect(_on_decrease_stat.bind("stamina"))
	ui_layer.add_child(stamina_minus)
	
	y_pos += 60
	
	# INTELLIGENCE
	var int_bg = ColorRect.new()
	int_bg.color = Color(0.2, 0.2, 0.3, 1)
	int_bg.size = Vector2(300, 40)
	int_bg.position = Vector2(390, y_pos - 5)
	ui_layer.add_child(int_bg)
	
	int_label = Label.new()
	int_label.text = "INT: " + str(stats["intelligence"])
	int_label.position = Vector2(400, y_pos)
	int_label.add_theme_font_size_override("font_size", 24)
	int_label.add_theme_color_override("font_color", Color.CYAN)
	ui_layer.add_child(int_label)
	
	var int_plus = Button.new()
	int_plus.text = "+"
	int_plus.position = Vector2(620, y_pos - 10)
	int_plus.size = Vector2(50, 40)
	int_plus.modulate = Color.GREEN
	int_plus.pressed.connect(_on_increase_stat.bind("intelligence"))
	ui_layer.add_child(int_plus)
	
	var int_minus = Button.new()
	int_minus.text = "-"
	int_minus.position = Vector2(680, y_pos - 10)
	int_minus.size = Vector2(50, 40)
	int_minus.modulate = Color.RED
	int_minus.pressed.connect(_on_decrease_stat.bind("intelligence"))
	ui_layer.add_child(int_minus)
	
	y_pos += 60
	
	# GUTS
	var guts_bg = ColorRect.new()
	guts_bg.color = Color(0.2, 0.2, 0.3, 1)
	guts_bg.size = Vector2(300, 40)
	guts_bg.position = Vector2(390, y_pos - 5)
	ui_layer.add_child(guts_bg)
	
	guts_label = Label.new()
	guts_label.text = "GUTS: " + str(stats["guts"])
	guts_label.position = Vector2(400, y_pos)
	guts_label.add_theme_font_size_override("font_size", 24)
	guts_label.add_theme_color_override("font_color", Color.ORANGE)
	ui_layer.add_child(guts_label)
	
	var guts_plus = Button.new()
	guts_plus.text = "+"
	guts_plus.position = Vector2(620, y_pos - 10)
	guts_plus.size = Vector2(50, 40)
	guts_plus.modulate = Color.GREEN
	guts_plus.pressed.connect(_on_increase_stat.bind("guts"))
	ui_layer.add_child(guts_plus)
	
	var guts_minus = Button.new()
	guts_minus.text = "-"
	guts_minus.position = Vector2(680, y_pos - 10)
	guts_minus.size = Vector2(50, 40)
	guts_minus.modulate = Color.RED
	guts_minus.pressed.connect(_on_decrease_stat.bind("guts"))
	ui_layer.add_child(guts_minus)
	
	y_pos += 60
	
	# WILLPOWER
	var will_bg = ColorRect.new()
	will_bg.color = Color(0.2, 0.2, 0.3, 1)
	will_bg.size = Vector2(300, 40)
	will_bg.position = Vector2(390, y_pos - 5)
	ui_layer.add_child(will_bg)
	
	will_label = Label.new()
	will_label.text = "WILL: " + str(stats["willpower"])
	will_label.position = Vector2(400, y_pos)
	will_label.add_theme_font_size_override("font_size", 24)
	will_label.add_theme_color_override("font_color", Color.PURPLE)
	ui_layer.add_child(will_label)
	
	var will_plus = Button.new()
	will_plus.text = "+"
	will_plus.position = Vector2(620, y_pos - 10)
	will_plus.size = Vector2(50, 40)
	will_plus.modulate = Color.GREEN
	will_plus.pressed.connect(_on_increase_stat.bind("willpower"))
	ui_layer.add_child(will_plus)
	
	var will_minus = Button.new()
	will_minus.text = "-"
	will_minus.position = Vector2(680, y_pos - 10)
	will_minus.size = Vector2(50, 40)
	will_minus.modulate = Color.RED
	will_minus.pressed.connect(_on_decrease_stat.bind("willpower"))
	ui_layer.add_child(will_minus)
	
	# Start button
	var race_btn = Button.new()
	race_btn.text = "START RACE"
	race_btn.position = Vector2(450, 600)
	race_btn.size = Vector2(200, 60)
	race_btn.modulate = Color.GOLD
	race_btn.pressed.connect(_on_start_race)
	ui_layer.add_child(race_btn)

func _on_increase_stat(stat):
	if training_points > 0:
		stats[stat] += 1
		training_points -= 1
		update_ui()
		print("Increased ", stat, " to ", stats[stat])

func _on_decrease_stat(stat):
	if stats[stat] > 0:
		stats[stat] -= 1
		training_points += 1
		update_ui()
		print("Decreased ", stat, " to ", stats[stat])

func update_ui():
	# Cập nhật trực tiếp các label đã lưu
	if points_label:
		points_label.text = "Points: " + str(training_points)
	
	if speed_label:
		speed_label.text = "SPEED: " + str(stats["speed"])
	
	if stamina_label:
		stamina_label.text = "STAMINA: " + str(stats["stamina"])
	
	if int_label:
		int_label.text = "INT: " + str(stats["intelligence"])
	
	if guts_label:
		guts_label.text = "GUTS: " + str(stats["guts"])
	
	if will_label:
		will_label.text = "WILL: " + str(stats["willpower"])

func _on_start_race():
	var final_speed = base_speed + stats["speed"] * 5
	var final_stamina = base_stamina + stats["stamina"] * 5
	
	print("Final speed: ", final_speed, " stamina: ", final_stamina)
	
	var racing_scene = load("res://node_2d.tscn").instantiate()
	racing_scene.setup_race(
		selected_horse_data,
		final_speed,
		final_stamina,
		stats["intelligence"],
		stats["guts"],
		stats["willpower"]
	)
	
	get_tree().root.add_child(racing_scene)
	get_tree().current_scene = racing_scene
	queue_free()
