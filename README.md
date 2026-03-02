🏇 12 ZODIAC ANIMALS RACING - GODOT GAME

📝 PROJECT DESCRIPTION
12 Zodiac Animals Racing is a horse racing game inspired by the 12 Asian zodiac animals. Players select an animal, train its stats, and race against 11 other animals.

✨ KEY FEATURES
🎮 Gameplay
12 animals representing the 12 zodiac signs, each with unique base stats

Training System: 20 points to distribute across 5 different stats

Realistic racing mechanics: Speed changes based on stamina, with boost and regen abilities

Balanced AI: NPCs automatically boost and have stats balanced according to player's level

🏁 Race Track
1000px long finish line with red flag effects

Camera follow system tracking the player's horse

4 racing lanes with clear white boundary lines

🎤 AI Commentator - Mistral AI
Commentator positioned at the bottom right corner

20+ random commentary lines

Real-time comments based on ranking and position

🤖 AI COMMENTATOR SYSTEM - DETAILED EXPLANATION
🎤 OVERVIEW Mistral AI
The AI Commentator is a real-time racing announcer that provides dynamic commentary throughout the race. It's implemented in commentator.gd and adds immersion to the gameplay experience.

🧠 HOW IT WORKS
1. Commentator Class Structure
gdscript
extends Node2D

var ui_layer : CanvasLayer      # UI layer for display
var comment_label : Label       # Text display area
var comment_timer : float = 0.0 # Timing between comments
var race_started : bool = false # Race state
var player_horse : Node         # Reference to player
var ai_horses : Array = []      # List of AI horses
2. Comment Database
The commentator has two types of comment arrays:

General Comments (20+ lines):

gdscript
var comments = [
    "And they're off! The race has begun!",
    "Look at that incredible speed!",
    "They're neck and neck!",
    "What a magnificent performance!",
    "The crowd is going wild!",
    # ... 15 more lines
]
Position-Based Comments:

gdscript
var position_comments = [
    " is in the lead!",
    " is moving up through the pack!",
    " is holding strong in second!",
    " is making a late charge!",
    " is falling back a bit!",
    # ... more position comments
]
🔄 COMMENTARY LOGIC
Timing System
gdscript
func _process(delta):
    comment_timer += delta
    
    # Random comment every 3-5 seconds
    if comment_timer > randi_range(3, 5):
        comment_timer = 0.0
        generate_comment()
Comment Selection Algorithm
gdscript
func generate_comment():
    # 70% chance for random comment, 30% for position comment
    if randf() < 0.7:
        # Pick random from general comments
        var random_index = randi() % comments.size()
        set_comment("🗣️ " + comments[random_index])
    else:
        # Generate position-based comment
        analyze_race_position()
Race Position Analysis
gdscript
func analyze_race_position():
    var rank = 1
    var leader = player_horse
    
    # Find the current leader
    for ai in ai_horses:
        if ai != null and ai.distance > leader.distance:
            leader = ai
            rank += 1
    
    # Comment based on who's leading
    if leader == player_horse:
        set_comment("🗣️ YOU are in the lead!")
    else:
        var comment_index = randi() % position_comments.size()
        set_comment("🗣️ " + leader.horse_name + position_comments[comment_index])
🎯 SPECIAL RACE EVENTS
Progress-Based Commentary
gdscript
# Near finish line (80% of race)
if player_horse.distance > FINISH_DISTANCE * 0.8:
    set_comment("🗣️ THEY'RE APPROACHING THE FINISH LINE!")

# Halfway point
elif player_horse.distance > FINISH_DISTANCE * 0.5:
    set_comment("🗣️ Halfway point! The race is heating up!")
Race Start/End Events
gdscript
func start_race(player, ais):
    race_started = true
    set_comment("🏁 THE RACE HAS BEGUN! 🏁")

func race_finished(winner):
    race_started = false
    if winner == player_horse:
        set_comment("🎉 VICTORY! YOU ARE THE CHAMPION! 🎉")
    else:
        set_comment("😮 " + winner.horse_name + " wins! What a race!")

📊 Stats System
Stat	Effect
SPEED	Base running speed
STAMINA	Energy management, affects how long horse can maintain speed
INTELLIGENCE	Affects AI boost chance
GUTS	Affects recovery rate when tired
WILLPOWER	Boost in final 20% of race
🎯 HOW TO PLAY
1. Select Your Horse
Choose from 12 zodiac animals

Each has different base Speed and Stamina

2. Training Phase
20 training points available

Distribute points among 5 stats:

SPEED: Increases maximum speed

STAMINA: Increases stamina pool

INT: Increases boost chance

GUTS: Faster recovery

WILL: Final sprint boost

Max 10 points per stat

3. Racing Phase
BOOST button: Temporary speed boost (consumes stamina)

REGEN button: Restore 1 stamina point

Watch your stamina bar - don't let it run out!

Camera follows your horse automatically

Commentator provides race updates

4. Winning
First to reach the finish line wins

Victory screen shows with celebration

Option to play again

🎮 CONTROLS
Control	Action
Left Click	Select horse / Press buttons
Drag	Not applicable (menu navigation)
BOOST button	🚀 Temporary speed boost
REGEN button	💚 Restore stamina
📁 PROJECT STRUCTURE
text
res://
├── assets/                 # Animal sprite images (horse_1.png to horse_12.png)
├── main.gd                  # Main game script
├── horse.gd                 # Horse character script
├── training.gd              # Training scene script
├── commentator.gd           # AI commentator script
├── global.gd                # Animal data storage
├── main.tscn                # Main game scene
├── training.tscn            # Training scene
└── icon.svg                 # Game icon
🔧 TECHNICAL DETAILS
Core Constants
gdscript
const FINISH_DISTANCE = 4900     # Total race distance
const START_X = 100              # Starting line X position
const FINISH_X = 100 + FINISH_DISTANCE  # Finish line position
const MAX_STAT = 10               # Maximum training points per stat
Stat Calculation
text
Final Speed = Base Speed + (Speed Stat × 5)
Final Stamina = Base Stamina + (Stamina Stat × 5)
NPC Balancing
NPC stats are calculated as:

gdscript
factor = 0.7 + random(0, 0.3)  # 70-100% of player stats
NPC_speed = player_speed × factor
🎨 VISUAL DESIGN
Menu: Dark background (0.1, 0.1, 0.2) with gold text

Stats: Color-coded for easy reading

SPEED: Yellow

STAMINA: Green

INT: Cyan

GUTS: Orange

WILL: Purple

Finish Line: Red with white flags, 1000px tall

Commentator: Black panel with gold text at bottom right

🚀 HOW TO RUN
Install Godot Engine 4.x or later

Clone or download this project

Open Godot, click "Import" and select the project folder

Run the project (F5) or click the play button

🛠️ CUSTOMIZATION
Adjust Race Distance
In main.gd, find:

gdscript
const FINISH_DISTANCE = 4900  # Change this value
Modify Training Points
In training.gd, find:

gdscript
var training_points = 20  # Change this value
Add More Commentary
In commentator.gd, add to the comments array:

gdscript
var comments = [
    "Your new comment here!",
    # ... existing comments
]
Adjust Button Size in Selection Menu
In main.gd, show_selection() function:

gdscript
btn.size = Vector2(160, 160)  # Change these values
📋 REQUIREMENTS
Godot Engine: 4.0 or higher

Resolution: 1152×648 (can be adjusted)

Input: Mouse only

🐛 KNOWN ISSUES
Camera smoothing may cause slight delay in following

NPCs sometimes get clustered at start

Training points reset after race (intended)

📜 LICENSE
Free to use, modify, and distribute. Credit appreciated but not required.

👨‍💻 CREDITS
Game Design: Based on Uma Musume concept

Development: Custom Godot Engine implementation

Assets: Placeholder sprites - replace with your own artwork

📞 CONTACT
For questions or suggestions, please open an issue on GitHub.

Enjoy the race! 🏆
