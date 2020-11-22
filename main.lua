import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "input"
import "levels"
import "utils"
import "model/level"
import "screen/grid-list"
import "screen/grid-play"
import "ui/board"
import "ui/cursor"
import "ui/numbers"
import "ui/sidebar"

local gfx <const> = playdate.graphics

local fontGrid = gfx.font.new("font/grid")
assert(fontGrid)
imgAvatars, err = gfx.imagetable.new("img/avatars")
assert(imgAvatars, err)

gfx.setFont(fontGrid)

-- globals
CELL = 16
BOARD_OFFSET_X = 9.5
BOARD_OFFSET_Y = 4.5

local gridPlay = GridPlay()
local gridList = GridList()
local screen = gridList

gridList.onSelectLevel = function(level)
	gridList:leave()
	gridPlay:enter(level)
	screen = gridPlay
end

gridPlay.onBackToList = function()
	gridPlay:leave()
	gridList:enter()
	screen = gridList
end

function playdate.gameWillTerminate()
	screen:leave()
end

screen:enter()

function playdate.update()
	screen:update()

	gfx.sprite.update()
	--playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end
