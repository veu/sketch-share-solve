import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "input"
import "levels"
import "utils"
import "model/level"
import "screen/screen"
import "screen/grid-list"
import "screen/grid-play"
import "screen/title"
import "ui/board"
import "ui/cursor"
import "ui/numbers"
import "ui/sidebar"
import "ui/title"
import "utils/ui"

local gfx <const> = playdate.graphics

fontGrid = gfx.font.new("font/grid")
assert(fontGrid)
fontText = gfx.font.new("font/text")
assert(fontText)
imgAvatars, err = gfx.imagetable.new("img/avatars")
assert(imgAvatars, err)

-- globals
CELL = 16
BOARD_OFFSET_X = 9.5
BOARD_OFFSET_Y = 4.5

local gridPlay = GridPlay()
local gridList = GridList()
local title = TitleScreen()
local screen = title
local avatar = nil

gridList.onSelectLevel = function(level)
	gridList:leave()
	gridPlay:enter(level, avatar)
	screen = gridPlay
end

gridPlay.onBackToList = function()
	gridPlay:leave()
	gridList:enter()
	screen = gridList
end

title.onSelected = function(selectedAvatar)
	avatar = selectedAvatar
	title:leave()
	gridList:enter()
	screen = gridList
end

function playdate.crankDocked()
	screen:crankDocked()
end

function playdate.crankUndocked()
	screen:crankUndocked()
end

function playdate.cranked(change, acceleratedChange)
	screen:cranked(change, acceleratedChange)
end

function playdate.AButtonDown()
	screen:AButtonDown()
end

screen:enter()

function playdate.update()
	screen:update()

	gfx.sprite.update()
	--playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end
