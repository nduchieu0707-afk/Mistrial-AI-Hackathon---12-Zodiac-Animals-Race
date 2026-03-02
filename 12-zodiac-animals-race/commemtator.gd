extends Node2D

var ui_layer : CanvasLayer
var comment_label : Label
var comment_timer : float = 0.0
var race_started : bool = false
var player_horse : Node
var ai_horses : Array = []
const FINISH_DISTANCE = 5500

var comments = [
	"And they're off! The race has begun!",
	"Look at that incredible speed!",
	"They're neck and neck going into the final stretch!",
	"What a magnificent performance!",
	"The crowd is going wild!",
	"This is absolutely thrilling!",
	"He's making a move!",
	"She's closing in on the leader!",
	"Unbelievable acceleration!",
	"They're battling for position!",
	"The finish line is in sight!",
	"This is anyone's race now!",
	"What a photo finish this will be!",
	"The champion is pulling away!",
	"Don't count them out just yet!",
	"This is the most exciting race I've ever seen!",
	"They're giving it everything they've got!",
	"The spirit of competition is alive today!",
	"What a magnificent creature!",
	"Pure poetry in motion!"
]

var position_comments = [
	" is in the lead!",
	" is moving up through the pack!",
	" is holding strong in second!",
	" is making a late charge!",
	" is falling back a bit!",
	" is right on their heels!",
	" is showing incredible stamina!",
	" is digging deep!"
]

func _ready():
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Background cho commentator - DỜI XUỐNG DƯỚI VÀ SANG PHẢI
	var comment_bg = ColorRect.new()
	comment_bg.color = Color(0, 0, 0, 0.7)
	comment_bg.size = Vector2(400, 80)  # To hơn một chút
	comment_bg.position = Vector2(700, 550)  # Góc phải phía dưới
	ui_layer.add_child(comment_bg)
	
	# Label bình luận
	comment_label = Label.new()
	comment_label.text = "Select your horse to begin the race!"
	comment_label.position = Vector2(720, 570)
	comment_label.size = Vector2(360, 60)
	comment_label.add_theme_font_size_override("font_size", 16)  # Nhỏ hơn
	comment_label.add_theme_color_override("font_color", Color.GOLD)
	comment_label.add_theme_color_override("font_outline_color", Color.BLACK)
	comment_label.add_theme_constant_override("outline_size", 2)
	comment_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	ui_layer.add_child(comment_label)

func start_race(player, ais):
	race_started = true
	player_horse = player
	ai_horses = ais
	comment_timer = 0.0
	set_comment("🏁 THE RACE HAS BEGUN! 🏁")

func set_comment(text):
	if comment_label:
		comment_label.text = text

func _process(delta):
	if not race_started or not player_horse:
		return
	
	comment_timer += delta
	
	# Random comment mỗi 3-5 giây
	if comment_timer > randi_range(3, 5):
		comment_timer = 0.0
		
		# 70% random comment, 30% comment về vị trí
		if randf() < 0.7:
			var random_index = randi() % comments.size()
			set_comment("🗣️ " + comments[random_index])
		else:
			# Comment về thứ hạng
			var rank = 1
			var leader = player_horse
			for ai in ai_horses:
				if ai != null and ai.distance > leader.distance:
					leader = ai
					rank += 1
			
			if leader == player_horse:
				set_comment("🗣️ YOU are in the lead!")
			else:
				var comment_index = randi() % position_comments.size()
				set_comment("🗣️ " + leader.horse_name + position_comments[comment_index])
		
		# Comment đặc biệt khi gần đích
		if player_horse.distance > FINISH_DISTANCE * 0.8:
			set_comment("🗣️ THEY'RE APPROACHING THE FINISH LINE!")
		elif player_horse.distance > FINISH_DISTANCE * 0.5:
			set_comment("🗣️ Halfway point! The race is heating up!")

func race_finished(winner):
	race_started = false
	if winner == player_horse:
		set_comment("🎉 VICTORY! YOU ARE THE CHAMPION! 🎉")
	else:
		set_comment("😮 " + winner.horse_name + " wins! What a race!")
