extends Area2D

@export var horse_name : String = ""
@export var base_speed : float = 100
@export var max_stamina : float = 100
@export var is_player : bool = false
@export var ability_name : String = ""
@export var ability_id : String = ""
@export var ability_description : String = ""
@export var ability_icon : String = ""

@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var bar = $ProgressBar

var stamina : float
var distance : float = 0.0
var current_speed : float = 0.0
var racing : bool = false

# Boost variables
var boosting : bool = false
var boost_power : float = 1.0
var boost_time : float = 0.0

# Regen variables
var regen_timer : float = 0.0
var regen_amount : float = 20

# Animation
var bounce_offset : float = 0.0
var bounce_speed : float = 10.0
var bounce_height : float = 5.0

# Stats từ training
var intelligence : int = 0
var guts : int = 0
var willpower : int = 0

# Ability variables
var ability_cooldown : float = 0.0
var ability_active : bool = false
var ability_effect_timer : float = 0.0
var ability_ready : bool = true

const FINISH_DISTANCE = 5000

# Thêm signal để thông báo ability sẵn sàng
signal ability_available(available)

func _ready():
	stamina = max_stamina
	bar.max_value = max_stamina
	bar.value = stamina
	label.text = horse_name
	
	# Gán ability dựa trên tên
	match horse_name:
		"Tý":
			ability_id = "ty"
			ability_name = "Tí Hon"
			ability_description = "Tăng tốc khi bị 3 đối thủ dồn"
			ability_icon = "🐭"
		"Sửu":
			ability_id = "suu"
			ability_name = "Trâu Bền"
			ability_description = "Hồi phục gấp đôi trong 5s"
			ability_icon = "🐮"
		"Dần":
			ability_id = "dan"
			ability_name = "Hổ Báo"
			ability_description = "Tăng 30% tốc độ ở 20% cuối"
			ability_icon = "🐯"
		"Mão":
			ability_id = "mao"
			ability_name = "Mèo Nhanh"
			ability_description = "Giảm 50% stamina khi boost"
			ability_icon = "🐱"
		"Thìn":
			ability_id = "thin"
			ability_name = "Rồng Bay"
			ability_description = "Tăng 50% tốc độ khi xuất phát"
			ability_icon = "🐲"
		"Tỵ":
			ability_id = "ty"
			ability_name = "Rắn Lướt"
			ability_description = "Tăng 10% tốc độ cơ bản"
			ability_icon = "🐍"
		"Ngọ":
			ability_id = "ngo"
			ability_name = "Ngựa Hoang"
			ability_description = "+5% tốc độ mỗi ngựa xung quanh"
			ability_icon = "🐴"
		"Mùi":
			ability_id = "mui"
			ability_name = "Dê Núi"
			ability_description = "Tăng 30% tốc độ khi mệt"
			ability_icon = "🐐"
		"Thân":
			ability_id = "than"
			ability_name = "Khỉ Tinh"
			ability_description = "Copy ability người dẫn đầu"
			ability_icon = "🐵"
		"Dậu":
			ability_id = "dau"
			ability_name = "Gà Trống"
			ability_description = "Đánh thức đồng đội chậm"
			ability_icon = "🐔"
		"Tuất":
			ability_id = "tuat"
			ability_name = "Chó Săn"
			ability_description = "Tăng 20% khi đuổi theo"
			ability_icon = "🐶"
		"Hợi":
			ability_id = "hoi"
			ability_name = "Lợn Rừng"
			ability_description = "Tăng 20% stamina max"
			ability_icon = "🐷"

func start_race():
	racing = true
	distance = 0
	stamina = max_stamina
	boosting = false
	boost_power = 1.0
	regen_timer = 0.0
	bounce_offset = 0.0
	ability_cooldown = 0.0
	ability_active = false
	ability_effect_timer = 0.0
	ability_ready = true
	emit_signal("ability_available", true)

func _process(delta):
	if not racing: return
	
	# Hiệu ứng nhảy
	bounce_offset += delta * bounce_speed
	var bounce = sin(bounce_offset) * bounce_height
	sprite.position.y = bounce
	
	# Cooldown ability
	if ability_cooldown > 0:
		ability_cooldown -= delta
		if ability_cooldown <= 0:
			ability_ready = true
			emit_signal("ability_available", true)
	
	if ability_effect_timer > 0:
		ability_effect_timer -= delta
	else:
		ability_active = false
	
	if distance < FINISH_DISTANCE:
		# Xử lý boost
		if boosting:
			boost_time += delta
			boost_power = 1.0 + (boost_time * 2.0)
			bounce_speed = 20.0
			bounce_height = 8.0
			if boost_time > 2.0 or stamina <= 0:
				boosting = false
				boost_power = 1.0
				bounce_speed = 10.0
				bounce_height = 5.0
		else:
			bounce_speed = 10.0
			bounce_height = 5.0
		
		# GUTS ảnh hưởng hồi phục
		var guts_bonus = 1.0 + (guts * 0.05)
		regen_timer += delta * guts_bonus
		if regen_timer >= 3.0:
			stamina = min(stamina + regen_amount, max_stamina)
			regen_timer = 0.0
		
		# WILLPOWER ảnh hưởng cuối race
		var willpower_bonus = 1.0
		if distance > FINISH_DISTANCE * 0.8:
			willpower_bonus = 1.0 + (willpower * 0.03)
			bounce_height = 10.0
		
		# Tính speed
		if stamina > 20:
			current_speed = base_speed * boost_power * willpower_bonus
			if not boosting:
				stamina -= 5 * delta
		else:
			current_speed = base_speed * 0.4 * boost_power * willpower_bonus
			stamina += 8 * delta * guts_bonus
			bounce_height = 3.0
		
		if boosting:
			stamina -= 15 * delta
		
		stamina = clamp(stamina, 0, max_stamina)
		distance += current_speed * delta
		position.x = distance
		
		# Update bar
		bar.value = stamina
		if stamina < 30:
			bar.modulate = Color.RED
		elif stamina < 60:
			bar.modulate = Color.YELLOW
		else:
			bar.modulate = Color.GREEN
		
		# NPC tự boost
		if not is_player:
			var ai_boost_chance = 0.01 + (intelligence * 0.002)
			if stamina > 60 and randf() < ai_boost_chance and not boosting:
				use_boost()
	else:
		racing = false
		get_parent().horse_finished(self)

# Hàm để player bấm nút ability
func use_ability():
	if not ability_ready or not racing:
		return false
	
	ability_ready = false
	ability_cooldown = 15.0
	ability_active = true
	ability_effect_timer = 5.0
	
	match ability_id:
		"ty":
			# Tý - Tí Hon: Tăng tốc khi bị dồn
			var behind_count = 0
			for ai in get_parent().ai_horses:
				if ai.distance > distance:
					behind_count += 1
			if behind_count >= 3:
				current_speed *= 1.3
			sprite.modulate = Color.YELLOW
			
		"suu":
			# Sửu - Trâu Bền: Hồi phục gấp đôi
			regen_amount = 40
			sprite.modulate = Color.GREEN
			
		"dan":
			# Dần - Hổ Báo: Tăng tốc ngay lập tức
			current_speed *= 1.3
			sprite.modulate = Color.ORANGE
			
		"mao":
			# Mão - Mèo Nhanh: Giảm tốn stamina
			stamina += 20
			sprite.modulate = Color.CYAN
			
		"thin":
			# Thìn - Rồng Bay: Tăng tốc mạnh
			current_speed *= 1.5
			sprite.modulate = Color.PURPLE
			
		"ty":
			# Tỵ - Rắn Lướt: Tăng speed cơ bản
			base_speed *= 1.1
			sprite.modulate = Color.BLUE
			
		"ngo":
			# Ngọ - Ngựa Hoang: Tăng theo số ngựa xung quanh
			var nearby = 0
			for ai in get_parent().ai_horses:
				if abs(ai.distance - distance) < 100:
					nearby += 1
			current_speed *= (1.0 + nearby * 0.1)
			sprite.modulate = Color.BROWN
			
		"mui":
			# Mùi - Dê Núi: Hồi stamina
			stamina = max_stamina
			sprite.modulate = Color.DARK_GREEN
			
		"than":
			# Thân - Khỉ Tinh: Copy người dẫn đầu
			var leader = null
			var max_dist = 0
			for ai in get_parent().ai_horses:
				if ai.distance > max_dist:
					max_dist = ai.distance
					leader = ai
			if leader:
				current_speed = leader.current_speed
			sprite.modulate = Color.PINK
			
		"dau":
			# Dậu - Gà Trống: Boost đồng đội
			for ai in get_parent().ai_horses:
				if ai.distance < distance - 200:
					ai.current_speed *= 1.1
			sprite.modulate = Color.YELLOW
			
		"tuat":
			# Tuất - Chó Săn: Đuổi nhanh
			current_speed *= 1.2
			sprite.modulate = Color.ORANGE
			
		"hoi":
			# Hợi - Lợn Rừng: Tăng max stamina
			max_stamina *= 1.2
			stamina = max_stamina
			sprite.modulate = Color.BROWN
	
	await get_tree().create_timer(0.5).timeout
	sprite.modulate = Color.WHITE
	emit_signal("ability_available", false)
	return true

func use_boost():
	if stamina >= 30 and not boosting:
		boosting = true
		boost_time = 0
		boost_power = 1.0

func regen_stamina(amount):
	stamina = min(stamina + amount, max_stamina)
