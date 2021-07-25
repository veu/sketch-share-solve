local gfx <const> = playdate.graphics

local NUM_MAP = {
	[0] = "0", [1] = "1", [2] = "2", [3] = "3",
	[4] = "4", [5] = "5", [6] = "6", [7] = "7",
	[8] = "8", [9] = "9", [10] = "A", [11] = "B",
	[12] = "C", [13] = "D", [14] = "E", [15] = "F",
}

local DONE_NUMBERS = {
	DoneNumbersDisabled,
	DoneNumbersLine,
	DoneNumbers,
}

class("GridNumbers").extends(gfx.sprite)

function GridNumbers:init()
	GridNumbers.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:setZIndex(Z_INDEX_GRID_NUMBERS)
end

function GridNumbers:enter(puzzle, solution, x, y, showHints)
	self.puzzle = puzzle
	self.gridNumbers = Numbers(puzzle, puzzle.grid)
	self.solutionNumbers = Numbers(puzzle, solution)

	self.doneNumbers = DONE_NUMBERS[showHints](
		puzzle,
		self.gridNumbers,
		self.solutionNumbers,
		solution,
		showHints
	)
	self.gridX = x
	self.gridY = y

	self:add()
	self:redraw()
end

function GridNumbers:updateForPosition(solution)
	self.solutionNumbers:updatePosition(solution, self.gridX, self.gridY)
	self.doneNumbers:updatePosition(
		self.solutionNumbers,
		solution,
		self.gridX,
		self.gridY
	)

	self:redrawPosition()
end

function GridNumbers:leave()
	self:remove()
end

function GridNumbers:reset(solution)
	self.solutionNumbers = Numbers(self.puzzle, solution)
	self.doneNumbers:updateAll(self.solutionNumbers, solution)
	self:redraw()
end

function GridNumbers:setCursor(x, y)
	self.gridX = x
	self.gridY = y
	self:redrawPosition()
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

function GridNumbers:redrawPosition()
	-- left numbers
	gfx.pushContext(self.image)
	gfx.setFont(fontGrid)
	gfx.setColor(gfx.kColorClear)
	gfx.fillRect(27, GRID_OFFSET_Y + CELL * (self.gridY - 2), -2 - (CELL * -8 + 3), CELL * 3 + 1)
	gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)
	do
		for y = math.max(1, self.gridY - 1), math.min(#self.gridNumbers.left, self.gridY + 1) do
			local numbers = self.gridNumbers.left[y]
			for i, v in ipairs(numbers) do
				gfx.drawText(
					self.doneNumbers.left[y][i] and NUM_MAP[v] or "*" .. NUM_MAP[v] .. "*",
					CELL * (i - 1 - rawlen(numbers)),
					CELL * (y - 1) + 1
				)
			end
		end
		for y = math.max(0, self.gridY - 2), self.gridY + 1 do
			gfx.setColor(gfx.kColorBlack)
			if y ~= self.gridY and y ~= self.gridY - 1 then
				gfx.setDitherPattern(0.9)
			end
			gfx.drawLine(CELL * -8 + 3, CELL * y, -2, CELL * y)
		end
	end
	gfx.popContext()
	self.addDirtyRect(
		self.x + 27,
		self.y + GRID_OFFSET_Y + CELL * (self.gridY - 2),
		-2 - (CELL * -8 + 3),
		CELL * 3 + 1
	)

	-- top numbers
	gfx.pushContext(self.image)
	gfx.setFont(fontGrid)
	gfx.setColor(gfx.kColorClear)
	gfx.fillRect(
		GRID_OFFSET_X + CELL * (15 - self.puzzle.width) + CELL * (self.gridX - 2),
		0,
		CELL * 3 + 1,
		CELL * 4 + 7
	)
	gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)
	do
		for x = math.max(1, self.gridX - 1), math.min(#self.gridNumbers.top, self.gridX + 1) do
			local numbers = self.gridNumbers.top[x]
			for i, v in ipairs(numbers) do
				gfx.drawText(
					self.doneNumbers.top[x][i] and NUM_MAP[v] or "*" .. NUM_MAP[v] .. "*",
					CELL * (x - 1) + 1,
					14 * (i - 1 - rawlen(numbers)) - 2
				)
			end
		end
		for x = math.max(0, self.gridX - 2), self.gridX + 1 do
			gfx.setColor(gfx.kColorBlack)
			if x ~= self.gridX and x ~= self.gridX - 1 then
				gfx.setDitherPattern(0.85)
			end
			gfx.drawLine(CELL * x, CELL * -5 + 11, CELL * x, -2)
		end
	end
	gfx.popContext()
	self.addDirtyRect(
		self.x + GRID_OFFSET_X + CELL * (15 - self.puzzle.width) + CELL * (self.gridX - 2),
		self.y,
		CELL * 3 + 1,
		CELL * 4 + 7
	)
end

function GridNumbers:drawLeft()
	gfx.pushContext()
	gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)
	do
		for y, numbers in ipairs(self.gridNumbers.left) do
			for i, v in ipairs(numbers) do
				gfx.drawText(
					self.doneNumbers.left[y][i] and NUM_MAP[v] or "*" .. NUM_MAP[v] .. "*",
					CELL * (i - 1 - rawlen(numbers)),
					CELL * (y - 1) + 1
				)
			end
		end
		for y = 0, rawlen(self.gridNumbers.left) do
			gfx.setColor(gfx.kColorBlack)
			if y ~= self.gridY and y ~= self.gridY - 1 then
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
		for x, numbers in ipairs(self.gridNumbers.top) do
			for i, v in ipairs(numbers) do
				gfx.drawText(
					self.doneNumbers.top[x][i] and NUM_MAP[v] or "*" .. NUM_MAP[v] .. "*",
					CELL * (x - 1) + 1,
					14 * (i - 1 - rawlen(numbers)) - 2
				)
			end
		end
		for x = 0, rawlen(self.gridNumbers.top) do
			gfx.setColor(gfx.kColorBlack)
			if x ~= self.gridX and x ~= self.gridX - 1 then
				gfx.setDitherPattern(0.85)
			end
			gfx.drawLine(CELL * x, CELL * -5 + 11, CELL * x, -2)
		end
	end
	gfx.popContext()
end
