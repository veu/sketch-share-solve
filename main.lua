import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"


import "input"
import "levels"
import "utils"
import "ui/board"
import "ui/cursor"
import "ui/numbers"

local gfx <const> = playdate.graphics

local fontGrid = gfx.font.new("font/grid")
assert(fontGrid)

gfx.setFont(fontGrid)

-- globals
CELL = 16
BOARD_OFFSET_X = 9.5
BOARD_OFFSET_Y = 4.5

local level = LEVELS[2]
local height = 10
local width = 15

local board = Board()
board:loadLevel(level, width, height)

local cursor = Cursor()
cursor:loadLevel(level, width, height)

local numbers = Numbers()
numbers:loadLevel(level, width, height)
numbers:redraw()

function cross(isStart)
	board:toggleCross(cursor:getIndex(), isStart)
end

function fill(isStart)
	board:toggle(cursor:getIndex(), isStart)

	printSolution()
end

function printSolution()
	local s = "{"

	for _, v in pairs(board.solution) do
		s = s .. v .. ","
	end

	print(s .. "}")
end

function playdate.update()
	if not board:isSolved() then
		handleFill(fill)
		handleCross(cross)
		handleCursorDir(fill, cross, playdate.kButtonRight, function () cursor:moveBy(1, 0) end)
		handleCursorDir(fill, cross, playdate.kButtonDown, function () cursor:moveBy(0, 1) end)
		handleCursorDir(fill, cross, playdate.kButtonLeft, function () cursor:moveBy(-1, 0) end)
		handleCursorDir(fill, cross, playdate.kButtonUp, function () cursor:moveBy(0, -1) end)
	end

	gfx.sprite.update()
	playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end