VERSION = "2.0.2"

CELL = 16
TOP_NUMBER_HEIGHT = 14

MAX_UNDO = 51

GRID_OFFSET_X = 152
GRID_OFFSET_Y = 72
GRID_OFFSET_AVATAR_X = 132
GRID_OFFSET_AVATAR_Y = 39

MODE_PLAY = 1
MODE_CREATE = 2
MODE_SHARE = 3
MODE_UNDO = 4
MODE_OPTIONS = 5
MODE_AVATAR = 6
MODE_TUTORIAL = 7

Z_INDEX_FRAME = 4

Z_INDEX_GRID = 5
Z_INDEX_TITLE = 5
Z_INDEX_GRID_NUMBERS_BG = 10

Z_INDEX_GRID_NUMBERS = 10
Z_INDEX_GRID_SOLVED = 10
Z_INDEX_TIMER = 10
Z_INDEX_CREATOR = 10

Z_INDEX_DIALOG = 20
Z_INDEX_CURSOR = 20

Z_INDEX_SIDEBAR = 50

Z_INDEX_LIST = 60

Z_INDEX_TEXT_CURSOR = 70

Z_INDEX_MENU_BORDER = 80

Z_INDEX_AVATAR = 90

Z_INDEX_MODAL = 500

AVATAR_ID_NIL = 6
NUM_AVATARS = 5
AVATAR_NAMES = {
	"Suave Snail",
	"Charismatic Cat",
	"Mindful Mouse",
	"Reliable Raccoon",
	"Obscure Owl"
}

MAX_NAME_WIDTH = 147
SIDEBAR_WIDTH = 221
SEPARATOR_WIDTH = 24
AVATAR_OFFSET = SIDEBAR_WIDTH - SEPARATOR_WIDTH - 1

PLAYER_ID_RDK = "IHOMLFGGPUEOLDQY"
PLAYER_ID_QUICK_PLAY = "YWPAGTGGLDOLBBZL"

PLAYER_ID_SHOW_NAME = "NAME"
PLAYER_ID_SHOW_RENAME = "RENAME"

AVATAR_ID_CREATE_AVATAR = "CREATE_AVATAR"

OPTION_ID_RESET_PROGRESS = "RESET_PROGRESS"
OPTION_ID_RENAME_PROFILE = "RENAME_PROFILE"
OPTION_ID_CHANGE_AVATAR = "CHANGE_AVATAR"

HINTS_ID_OFF = 1
HINTS_ID_LINES = 2
HINTS_ID_BLOCKS = 3
HINTS_TEXT = {
	"off",
	"solved lines",
	"solved blocks",
}


ACTION_ID_ABOUT = "ABOUT"
ACTION_ID_CRANK_SPEED = "CRANK_SPEED"
ACTION_ID_DELETE_PUZZLES = "DELETE_PUZZLES"
ACTION_ID_EFFECTS = "EFFECTS"
ACTION_ID_FLIP = "FLIP"
ACTION_ID_FLIP_Y = "FLIP_Y"
ACTION_ID_FONT_TYPE = "FONT_TYPE"
ACTION_ID_HINT_STYLE = "HINT_STYLE"
ACTION_ID_INVERT_COLORS = "INVERT_COLORS"
ACTION_ID_MUSIC = "MUSIC"
ACTION_ID_NEW_PLAYER = "NEW_PLAYER"
ACTION_ID_RESET_GRID = "RESET_GRID"
ACTION_ID_ROTATE = "ROTATE"
ACTION_ID_QUICK_PLAY = "QUICK_PLAY"
ACTION_ID_SETTINGS = "SETTINGS"
ACTION_ID_SKETCH_TUTORIAL = "SKETCH_TUTORIAL"
ACTION_ID_SOLVE_TUTORIAL = "SOLVE_TUTORIAL"
ACTION_ID_TOGGLE_AUTOCROSS = "TOGGLE_AUTOCROSS"
ACTION_ID_TOGGLE_TIMER = "TOGGLE_TIMER"
ACTION_ID_TUTORIALS = "TUTORIALS"
ACTION_ID_UNDO = "UNDO"

GAME_NAME = "Sketch, Share, Solve"

DIR_EXPORT = "export"
DIR_IMPORT = "import"

FILE_SAVE = "save"

NUM_LIST_ITEMS = 6

NUM_STYLE_REGULAR = 1
NUM_STYLE_THIN = 2
NUM_STYLE_GRAY = 3
NUM_STYLE_INVERTED = 4

NUM_STYLE_NAMES = {
	"regular",
	"thin",
	"gray",
	"inverted",
}

NUM_STYLE_OFFSETS = { 21, 41, 61, 81 }

FONT_TYPE_THIN = 1
FONT_TYPE_BOLD = 2

FONT_TYPE_NAMES = {
	"thin",
	"bold",
}

AUDIO_LEVEL_NAMES = {
	"off",
	"1",
	"2",
	"3",
	"4",
	"5"
}

AUDIO_LEVEL_NAMES_REVERSED = {
	off = 1,
	["1"] = 2,
	["2"] = 3,
	["3"] = 4,
	["4"] = 5,
	["5"] = 6
}
