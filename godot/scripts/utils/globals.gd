extends Node

# Scenes
const MUSIC_MANAGER_SCENE = "res://scenes/musicManager.tscn"
const SCENE_TRANSITION_SCENE = "res://scenes/sceneTransition.tscn"
const LEVEL_MANAGER_SCENE = "res://scenes/levelManager.tscn"
const TITLE_SCENE = "res://scenes/title.tscn"
const MAIN_MENU_SCENE = "res://scenes/mainMenu.tscn"
const CREDITS_SCENE = "res://scenes/credits.tscn"

# Folders and constant files
const CONFIG_FILE = "res://data/settings.cfg"
const DATA_FILE = "res://data/data.json"
const LEVELS_PATH = "res://Public/Levels/"
const TITLE_PATH = "res://Public/Title/"
const MAIN_MENU_PATH = "res://Public/MainMenu/"
const CREDITS_PATH = "res://Public/Credits/"

const MINIGAMES_DIR = "Minigames/"
const VIDEOS_DIR = "Videos/"
const POPUPS_DIR = "Popups/"
const CLOCK_DIR = "Clock/"

# Resources' name (for users)
	# Title
const TITLE_BACKGROUND = "titleBg"
const TITLE_LOGO = "logo"
const TITLE_THEME = "titleTheme"

	# Credits
const CREDITS_BACKGROUND = "creditsBg"
const CREDITS = "credits.txt"
const CREDITS_THEME = "creditsTheme"

	# Main menu
const MAIN_MENU_BACKGROUND = "mainMenuBg"
const MAIN_MENU_LEVEL_PICTURE = "picture"
const MAIN_MENU_THEME = "mainMenuTheme"
const PLAY_ICON = "icon"
const MAIN_MENU_LEVEL_INFO = "info.json"

		# Level info.json
const DESCRIPTION_FIELD = "description"
const LEVEL_NAME_FIELD = "level_name"
const MAX_LIVES_FIELD = "max_lives"
const GOAL_SCORE_FIELD = "goal_score"
const SPEED_UP_SCORE_FIELD = "speed_up_score"

		# Level stored data
const SCORE_FIELD = "score"
const ENDLESS_SCORE_FIELD = "endless_score"
const COMPLETE_FIELD = "complete"

	# Level manager
const INTRO_VID = "intro"
const CONTROL_VID = "control"
const LOSE_VID = "loseVid"
const WIN_END_VID = "winEndVid"
const LOSE_END_VID = "loseEndVid"

const HEALTH_SPRITE = "healthSprite"
const SPEED_UP_POPUP = "speedUp"
const LEVEL_THEME = "levelTheme"
const SPEEDUP_SFX = "speedUpSFX"
const GAME_SCENE = "Game.tscn"
const MINIGAME_INFO = "info.json"

		# Minigame info.json
const INSTRUCTION_FIELD = "instruction"
const SURVIVAL_FIELD = "survival"
const DURATION_FIELD = "duration"

# Secret Key for hash encoding
const SECRET_KEY = "n56?_58G8|+."
