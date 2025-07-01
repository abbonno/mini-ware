extends Node

# Extensions
const VIDEO_EXT = ".ogv"

# Scenes
const MUSIC_MANAGER_SCENE = "res://scenes/musicManager.tscn"
const SCENE_TRANSITION_SCENE = "res://scenes/sceneTransition.tscn"
const LEVEL_MANAGER_SCENE = "res://scenes/levelManager.tscn"
const TITLE_SCENE = "res://scenes/title.tscn"
const MAIN_MENU_SCENE = "res://scenes/mainMenu.tscn"
const CREDITS_SCENE = "res://scenes/credits.tscn"

# Folders and constant files (for developers)
const CONFIG_FILE = "res://data/settings.cfg"
const DATA_FILE = "res://data/data.json"
const IMG_PATH = "res://Public/Img/"
const MUSIC_PATH = "res://Public/Music/"
const LEVELS_PATH = "res://Levels/"

const MINIGAMES_DIR = "Minigames/"

# Resources' name (for users)
	# Title
const TITLE_BACKGROUND = "titleBg"
const TITLE_LOGO = "logo"
const TITLE_THEME = "titleTheme"

	# Credits
const CREDITS_PATH = "res://Public/credits.txt"
const CREDITS_THEME = "creditsTheme"

	# Main menu
const MAIN_MENU_BACKGROUND = "mainMenuBg"
const MAIN_MENU_LEVEL_PICTURE = "picture"
const MAIN_MENU_LEVEL_INFO = "info"
const MAIN_MENU_THEME = "mainMenuTheme"
const PLAY_ICON = "icon"

	# Level manager
const INTRO_VID = "intro"
const CONTROL_VID = "control"
const LOSE_VID = "loseVid"
const WIN_END_VID = "winEndVid"
const LOSE_END_VID = "loseEndVid"

const HEALTH_SPRITE = "healthSprite"
const SPEED_UP_POPUP = "speed_up"
# const INSTRUCTION # The instruction must be defined by the user depending on the instruction field on the minigames info.json
const MINIGAME_INFO = "info"

const WIN_SFX = "winSFX"
const LOSE_SFX = "loseSFX"
const LEVEL_THEME = "levelTheme"

# Secret Key for hash encoding
const SECRET_KEY = "n56?_58G8|+."
