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

fontGrid = gfx.font.new("font/grid")
assert(fontGrid)

gfx.setFont(fontGrid)

-- globals
height = 10
width = 15

local SOLUTION = {}
for i = 1, width * height do
	SOLUTION[i] = 0
end
local MARKED = {}
local CELL = 16
local level = LEVELS[2]

function isSolved()
	for i, v in pairs(level) do
		if v ~= SOLUTION[i] then
			return false
		end
	end

	return true
end

local cursor = Cursor()

function cross(start, last)
	local index = cursor:getIndex()
	if SOLUTION[index] == 1 then
		return
	end

	if start or (not MARKED[index]) == last then
		MARKED[index] = not MARKED[index]
	end

	return MARKED[index]
end
function fill(start, last)
	local index = cursor:getIndex()
	if MARKED[index] then
		return
	end

	if start or SOLUTION[index] ~= last then
		SOLUTION[index] = SOLUTION[index] == 1 and 0 or 1
	end

	printSolution()

	return SOLUTION[index]
end

function printSolution()
	local s = "{"

	for _, v in pairs(SOLUTION) do
		s = s .. v .. ","
	end

	print(s .. "}")
end

local board = Board()
local numbers = Numbers()
numbers:calculate(level)
numbers:redraw()

function playdate.update()
	if not isSolved() then
		handleFill(fill)
		handleCross(cross)
		handleCursorDir(fill, cross, playdate.kButtonRight, function () cursor:moveBy(1, 0) end)
		handleCursorDir(fill, cross, playdate.kButtonDown, function () cursor:moveBy(0, 1) end)
		handleCursorDir(fill, cross, playdate.kButtonLeft, function () cursor:moveBy(-1, 0) end)
		handleCursorDir(fill, cross, playdate.kButtonUp, function () cursor:moveBy(0, -1) end)
	end

	board:redraw(level, SOLUTION, MARKED)

	gfx.sprite.update()
	playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end