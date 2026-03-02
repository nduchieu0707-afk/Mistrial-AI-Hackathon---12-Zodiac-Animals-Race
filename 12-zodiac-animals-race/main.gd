extends Node2D

var horses = []
var player_horse : Node
var ai_horses : Array = []
var racing : bool = false
var selected_index : int = 0

var GlobalData = preload("res://global.gd")

# Camera
var camera : Camera2D
var ui_layer : CanvasLayer

# Buttons
var boost_btn : Button
var regen_btn : Button
var ability_btn : Button
var rank_label : Label

# Commentator - THÊM BIẾN NÀY
var commentator : Node2D

# Stats from training
var trained_data = null

const FINISH_DISTANCE = 4900
const START_X = 100
const FINISH_X = 100 + FINISH_DISTANCE  # 5100 - VỊ TRÍ ĐÍCH TRONG GAME

func setup_race(horse_data, speed_bonus, stamina_bonus, intelligence, guts, willpower):
	trained_data = {
		"horse": horse_data,
		"speed": speed_bonus,
		"stamina": stamina_bonus,
		"intelligence": intelligence,
		"guts": guts,
		"willpower": willpower
	}
	call_deferred("_ready")

func _ready():
	# Tìm tất cả ngựa
	horses = []
	for i in range(1, 13):
		var horse_path = "Horse" + str(i)
		if has_node(horse_path):
			var horse = get_node(horse_path)
			horses.append(horse)
			print("Found: ", horse_path, " at: ", horse.position)
	
	# Tạo UI layer
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Lấy data
	var data_list = GlobalData.get_all()
	
	# Gán data
	for i in range(12):
		if horses[i] != null:
			horses[i].horse_name = data_list[i].name
			horses[i].base_speed = data_list[i].speed
			horses[i].max_stamina = data_list[i].stamina
	
	# Tạo camera
	camera = Camera2D.new()
	camera.zoom = Vector2(1, 1)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	camera.position = Vector2(576, 324)
	add_child(camera)
	camera.call_deferred("make_current")
	
	# Vẽ VẠCH ĐÍCH TRONG GAME
	draw_finish_line()
	
	# TẠO COMMENTATOR - THÊM DÒNG NÀY
	commentator = load("res://commemtator.gd").new()
	add_child(commentator)
	
	if trained_data != null:
		start_race_with_training()
	else:
		show_selection()

func draw_finish_line():
	# Vạch đích trong game - sẽ di chuyển theo camera nhưng ở tọa độ cố định FINISH_X
	var finish_line = Line2D.new()
	finish_line.name = "GameFinishLine"
	finish_line.add_point(Vector2(FINISH_X, 150))
	finish_line.add_point(Vector2(FINISH_X, 550))
	finish_line.width = 10
	finish_line.default_color = Color(1, 0, 0, 0.8)
	add_child(finish_line)
	
	# Cờ đích
	var flag_pole = Line2D.new()
	flag_pole.add_point(Vector2(FINISH_X, 150))
	flag_pole.add_point(Vector2(FINISH_X, 200))
	flag_pole.width = 3
	flag_pole.default_color = Color.WHITE
	add_child(flag_pole)
	
	var flag = ColorRect.new()
	flag.color = Color(1, 0, 0, 1)
	flag.size = Vector2(30, 20)
	flag.position = Vector2(FINISH_X, 150)
	add_child(flag)
	
	# Label FINISH trong game
	var finish_label = Label.new()
	finish_label.text = "🏁 FINISH 🏁"
	finish_label.position = Vector2(FINISH_X - 50, 120)
	finish_label.add_theme_font_size_override("font_size", 20)
	finish_label.add_theme_color_override("font_color", Color.RED)
	add_child(finish_label)

func show_selection():
	# Xóa UI cũ
	for child in ui_layer.get_children():
		child.queue_free()
	
	camera.position = Vector2(576, 324)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.9)
	bg.size = Vector2(1152, 648)
	ui_layer.add_child(bg)
	
	var title = Label.new()
	title.text = "SELECT YOUR ZODIAC ANIMALS"
	title.position = Vector2(210, 50)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color.GOLD)
	ui_layer.add_child(title)
	
	var data_list = GlobalData.get_all()
	
	for i in range(12):
		if horses[i] == null:
			continue
		
		var btn = Button.new()
		btn.size = Vector2(140, 140)
		btn.position = Vector2(200 + (i%4)*200, 120 + floor(i/4)*180)
		ui_layer.add_child(btn)
		
		if horses[i].has_node("Sprite2D"):
			var original_sprite = horses[i].get_node("Sprite2D")
			if original_sprite and original_sprite.texture:
				var sprite = TextureRect.new()
				sprite.texture = original_sprite.texture
				sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH
				sprite.custom_minimum_size = Vector2(120, 80)
				sprite.position = Vector2(20, 10)
				btn.add_child(sprite)
		
		var name_label = Label.new()
		name_label.text = data_list[i].name
		name_label.position = Vector2(60, 100)
		name_label.add_theme_font_size_override("font_size", 14)
		btn.add_child(name_label)
		
		var stats_label = Label.new()
		stats_label.text = "S:" + str(data_list[i].speed) + " ST:" + str(data_list[i].stamina)
		stats_label.position = Vector2(30, 130)
		stats_label.add_theme_font_size_override("font_size", 10)
		btn.add_child(stats_label)
		
		btn.pressed.connect(_on_horse_selected.bind(i))

func _on_horse_selected(index):
	selected_index = index
	
	for child in ui_layer.get_children():
		child.queue_free()
	
	var training_scene = load("res://training.tscn").instantiate()
	training_scene.setup(GlobalData.get_all()[index], horses, index)
	add_child(training_scene)
	visible = false

func start_race_with_training():
	selected_index = -1
	for i in range(12):
		if horses[i] != null and horses[i].horse_name == trained_data["horse"].name:
			selected_index = i
			break
	
	if selected_index == -1:
		selected_index = 0
	
	var player = horses[selected_index]
	player.base_speed = trained_data["speed"]
	player.max_stamina = trained_data["stamina"]
	player.intelligence = trained_data["intelligence"]
	player.guts = trained_data["guts"]
	player.willpower = trained_data["willpower"]
	
	# Cân bằng NPC
	for i in range(12):
		if i != selected_index and horses[i] != null:
			var factor = 0.7 + randf() * 0.3
			horses[i].base_speed = player.base_speed * factor
			horses[i].max_stamina = player.max_stamina * factor
			horses[i].intelligence = int(player.intelligence * factor)
			horses[i].guts = int(player.guts * factor)
			horses[i].willpower = int(player.willpower * factor)
	
	for child in ui_layer.get_children():
		child.queue_free()
	
	player.is_player = true
	self.player_horse = player
	
	ai_horses.clear()
	for i in range(12):
		if i != selected_index and horses[i] != null:
			horses[i].is_player = false
			ai_horses.append(horses[i])
	
	# Reset positions
	for i in range(12):
		if horses[i] != null:
			horses[i].position.x = START_X + (i * 10)
			horses[i].start_race()
	
	create_control_ui()
	racing = true
	
	# KHỞI ĐỘNG COMMENTATOR - THÊM DÒNG NÀY
	if commentator and commentator.has_method("start_race"):
		commentator.start_race(player, ai_horses)

func create_control_ui():
	boost_btn = Button.new()
	boost_btn.text = "🚀 BOOST"
	boost_btn.position = Vector2(50, 550)
	boost_btn.size = Vector2(120, 50)
	boost_btn.pressed.connect(_on_boost_pressed)
	ui_layer.add_child(boost_btn)
	
	regen_btn = Button.new()
	regen_btn.text = "💚 REGEN"
	regen_btn.position = Vector2(180, 550)
	regen_btn.size = Vector2(120, 50)
	regen_btn.pressed.connect(_on_regen_pressed)
	ui_layer.add_child(regen_btn)
	
	rank_label = Label.new()
	rank_label.position = Vector2(900, 20)
	rank_label.add_theme_font_size_override("font_size", 24)
	rank_label.add_theme_color_override("font_color", Color.WHITE)
	ui_layer.add_child(rank_label)

func _on_boost_pressed():
	if racing and player_horse:
		player_horse.use_boost()

func _on_regen_pressed():
	if racing and player_horse:
		player_horse.regen_stamina(1)

func _on_ability_pressed():
	if racing and player_horse and player_horse.has_method("use_ability"):
		var used = player_horse.use_ability()
		if used and ability_btn:
			ability_btn.disabled = true
			ability_btn.text = "⏳ COOLDOWN"

func _on_ability_available(available):
	if ability_btn:
		ability_btn.disabled = not available
		if available:
			ability_btn.text = "✨ ABILITY READY"

func _process(delta):
	if not racing or not player_horse: return
	
	# Camera follow
	camera.position = Vector2(player_horse.position.x + 400, 324)
	
	# Update rank
	var rank = 1
	for ai in ai_horses:
		if ai != null and ai.distance > player_horse.distance:
			rank += 1
	rank_label.text = "Rank: " + str(rank) + "/12"
	
	# Kiểm tra về đích
	if player_horse.distance >= FINISH_DISTANCE:
		horse_finished(player_horse)
		return
	
	for ai in ai_horses:
		if ai != null and ai.distance >= FINISH_DISTANCE:
			horse_finished(ai)
			return

func horse_finished(horse):
	if not racing: return
	racing = false
	
	# THÔNG BÁO CHO COMMENTATOR - THÊM DÒNG NÀY
	if commentator and commentator.has_method("race_finished"):
		commentator.race_finished(horse)
	
	for child in ui_layer.get_children():
		child.queue_free()
	
	# Xóa vạch đích game cũ
	for child in get_children():
		if child.name == "GameFinishLine" or child is ColorRect or (child is Label and "FINISH" in child.text):
			child.queue_free()
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.9)
	bg.size = Vector2(1152, 648)
	ui_layer.add_child(bg)
	
	# HIỂN THỊ KẾT QUẢ VỚI VẠCH ĐÍCH
	var finish_display = ColorRect.new()
	finish_display.color = Color(1, 0, 0, 0.8)
	finish_display.size = Vector2(400, 200)
	finish_display.position = Vector2(376, 150)
	ui_layer.add_child(finish_display)
	
	var finish_text = Label.new()
	finish_text.text = "🏁 FINISHED 🏁"
	finish_text.position = Vector2(450, 200)
	finish_text.add_theme_font_size_override("font_size", 40)
	finish_text.add_theme_color_override("font_color", Color.YELLOW)
	ui_layer.add_child(finish_text)
	
	var result = Label.new()
	if horse == player_horse:
		result.text = "🏆 YOU WIN! 🏆"
	else:
		result.text = "😭 " + horse.horse_name + " WINS! 😭"
	result.position = Vector2(400, 280)
	result.add_theme_font_size_override("font_size", 36)
	result.add_theme_color_override("font_color", Color.GOLD)
	ui_layer.add_child(result)
	
	var replay = Button.new()
	replay.text = "PLAY AGAIN"
	replay.position = Vector2(500, 380)
	replay.size = Vector2(150, 50)
	replay.pressed.connect(_on_replay)
	ui_layer.add_child(replay)

func _on_replay():
	for child in ui_layer.get_children():
		child.queue_free()
	
	# Vẽ lại vạch đích
	draw_finish_line()
	
	var data_list = GlobalData.get_all()
	for i in range(12):
		if horses[i] != null:
			horses[i].is_player = false
			horses[i].racing = false
			horses[i].base_speed = data_list[i].speed
			horses[i].max_stamina = data_list[i].stamina
			horses[i].intelligence = 0
			horses[i].guts = 0
			horses[i].willpower = 0
			horses[i].position.x = START_X + (i * 10)
	
	trained_data = null
	visible = true
	show_selection()
