import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "input"
import "levels"
import "utils"
import "model/level"
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

local screen = GridPlay()
screen:enter()

function playdate.gameWillTerminate()
	screen:leave()
end

function playdate.update()
	screen:update()

	gfx.sprite.update()
	--playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end
