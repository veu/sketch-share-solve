local gfx <const> = playdate.graphics

class("GridNumbers").extends(gfx.sprite)

function GridNumbers:init()
	GridNumbers.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:setZIndex(Z_INDEX_GRID_NUMBERS)
end

function GridNumbers:enter(puzzle, solution, crossed, x, y, withHints)
	self.puzzle = puzzle
	self.gridNumbers = Numbers(puzzle, puzzle.grid)
	self.solutionNumbers = Numbers(puzzle, solution)
	self.doneNumbers = withHints and DoneNumbers(
		puzzle,
		self.gridNumbers,
		self.solutionNumbers,
		crossed,
		solution,
		withHints
	) or DoneNumbersDisabled(puzzle)
	self.x = x
	self.y = y

	self:add()
	self:redraw()
end

function GridNumbers:updateForPosition(solution, crossed)
	self.solutionNumbers = Numbers(self.puzzle, solution)
	self.doneNumbers:updatePosition(
		self.solutionNumbers,
		crossed,
		solution,
		self.x,
		self.y
	)

	self:redraw()
end

function GridNumbers:leave()
	self:remove()
end

function GridNumbers:setCursor(x, y)
	self.x = x
	self.y = y
	self:redraw()
end

function GridNumbers:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		gfx.setFont(fontGrid)
		self:drawLeft()
		self:drawTop()
	end
	gfx.unlockFocus()
	self:markDirty()
end

local NUM_MAP = {
	[0] = "0", [1] = "1", [2] = "2", [3] = "3",
	[4] = "4", [5] = "5", [6] = "6", [7] = "7",
	[8] = "8", [9] = "9", [10] = "A", [11] = "B",
	[12] = "C", [13] = "D", [14] = "E", [15] = "F",
}

function GridNumbers:drawLeft()
	gfx.pushContext()
	gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)
	do
		for y, numbers in pairs(self.gridNumbers.left) do
			for i, v in pairs(numbers) do
				gfx.drawText(
					self.doneNumbers.left[y][i] and NUM_MAP[v] or "*" .. NUM_MAP[v] .. "*",
					CELL * (i - 1 - rawlen(numbers)),
					CELL * (y - 1) + 1
				)
			end
		end
		for y = 0, rawlen(self.gridNumbers.left) do
			gfx.setColor(gfx.kColorBlack)
			if y ~= self.y and y ~= self.y - 1 then
				gfx.setDitherPattern(0.9)
			end
			gfx.drawLine(CELL * -8 + 3, CELL * y, -2, CELL * y)
		end
	end
	gfx.popContext()
end

function GridNumbers:drawTop()
	gfx.pushContext()
	gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)
	do
		for x, numbers in pairs(self.gridNumbers.top) do
			for i, v in pairs(numbers) do
				gfx.drawText(
					self.doneNumbers.top[x][i] and NUM_MAP[v] or "*" .. NUM_MAP[v] .. "*",
					CELL * (x - 1) + 1,
					14 * (i - 1 - rawlen(numbers)) - 2
				)
			end
		end
		for x = 0, rawlen(self.gridNumbers.top) do
			gfx.setColor(gfx.kColorBlack)
			if x ~= self.x and x ~= self.x - 1 then
				gfx.setDitherPattern(0.85)
			end
			gfx.drawLine(CELL * x, CELL * -5 + 11, CELL * x, -2)
		end
	end
	gfx.popContext()
end
