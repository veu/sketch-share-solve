local NUM_MAP = {
	[0] = "0", [1] = "1", [2] = "2", [3] = "3",
	[4] = "4", [5] = "5", [6] = "6", [7] = "7",
	[8] = "8", [9] = "9", [10] = "A", [11] = "B",
	[12] = "C", [13] = "D", [14] = "E", [15] = "F",
}
local NUM_MAP_BOLD = {
	[0] = "*0*", [1] = "*1*", [2] = "*2*", [3] = "*3*",
	[4] = "*4*", [5] = "*5*", [6] = "*6*", [7] = "*7*",
	[8] = "*8*", [9] = "*9*", [10] = "*A*", [11] = "*B*",
	[12] = "*C*", [13] = "*D*", [14] = "*E*", [15] = "*F*",
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

	self.background = GridNumbersBackground()
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

	self.background:enter(puzzle)
	self:add()
	self:redraw()
end

function GridNumbers:updateAll(solution)
	self.gridNumbers:updateAll(solution)
	self:redraw()
end

function GridNumbers:updateAllDone(solution)
	self.doneNumbers:updateAll(self.solutionNumbers, solution)
	self:redraw()
end

function GridNumbers:updateForPosition(solution, mode)
	if mode == MODE_CREATE then
		self.gridNumbers:updatePosition(solution, self.gridX, self.gridY)
	else
		self.solutionNumbers:updatePosition(solution, self.gridX, self.gridY)
		self.doneNumbers:updatePosition(
			self.solutionNumbers,
			solution,
			self.gridX,
			self.gridY
		)
	end

	self:redrawPosition()
	if not self.cursorHidden then
		self:redrawLeftCursor(self.gridY)
		self:redrawTopCursor(self.gridX)
	end
end

function GridNumbers:leave()
	self.background:leave()
	self:remove()
end

function GridNumbers:reset(solution, mode)
	if mode == MODE_CREATE then
		self.gridNumbers:updateAll(solution)
	else
		self.solutionNumbers = Numbers(self.puzzle, solution)
		self.doneNumbers:updateAll(self.solutionNumbers, solution)
	end

	self:redraw()
end

function GridNumbers:setCursor(x, y)
	if not self.cursorHidden then
		if self.gridX ~= x then
			self:redrawTopCursor(self.gridX, true)
			self:redrawTopCursor(x)
		end
		if self.gridY ~= y then
			self:redrawLeftCursor(self.gridY, true)
			self:redrawLeftCursor(y)
		end
	end

	self.gridX = x
	self.gridY = y
end

function GridNumbers:hideCursor()
	self.cursorHidden = true
	self:redraw()
end

function GridNumbers:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		gfx.setFont(fontGrid)
		gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)

		-- left numbers
		for y, numbers in ipairs(self.gridNumbers.left) do
			local done = self.doneNumbers.left[y]
			local lenNumbers = #numbers
			for i, v in ipairs(numbers) do
				gfx.drawText(
					done[i] and NUM_MAP[v] or NUM_MAP_BOLD[v],
					CELL * (i - 1 - lenNumbers),
					CELL * (y - 1) + 1
				)
			end
		end

		-- top numbers
		for x, numbers in ipairs(self.gridNumbers.top) do
			local done = self.doneNumbers.top[x]
			local lenNumbers = #numbers
			for i, v in ipairs(numbers) do
				gfx.drawText(
					done[i] and NUM_MAP[v] or NUM_MAP_BOLD[v],
					CELL * (x - 1) + 1,
					14 * (i - 1 - lenNumbers) - 2
				)
			end
		end

		-- cursor
		gfx.setColor(gfx.kColorBlack)
		if not self.cursorHidden then
			gfx.drawLine(CELL * -8 + 3, CELL * self.gridY - CELL, -2, CELL * self.gridY - CELL)
			gfx.drawLine(CELL * -8 + 3, CELL * self.gridY, -2, CELL * self.gridY)

			gfx.drawLine(CELL * self.gridX - CELL, CELL * -5 + 11, CELL * self.gridX - CELL, -2)
			gfx.drawLine(CELL * self.gridX, CELL * -5 + 11, CELL * self.gridX, -2)
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end

function GridNumbers:redrawPosition()
	-- left numbers
	gfx.pushContext(self.image)
	gfx.setFont(fontGrid)
	gfx.setColor(gfx.kColorClear)
	gfx.fillRect(27, GRID_OFFSET_Y + CELL * (self.gridY - 1), -2 - (CELL * -8 + 3), CELL + 1)
	gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)
	do
		local numbers = self.gridNumbers.left[self.gridY]
		local done = self.doneNumbers.left[self.gridY]
		local lenNumbers = #numbers
		for i, v in ipairs(numbers) do
			gfx.drawText(
				done[i] and NUM_MAP[v] or NUM_MAP_BOLD[v],
				CELL * (i - 1 - lenNumbers),
				CELL * (self.gridY - 1) + 1
			)
		end
	end
	gfx.popContext()
	self.addDirtyRect(
		self.x + 27,
		self.y + GRID_OFFSET_Y + CELL * (self.gridY - 1),
		-2 - (CELL * -8 + 3),
		CELL + 1
	)

	-- top numbers
	gfx.pushContext(self.image)
	gfx.setFont(fontGrid)
	gfx.setColor(gfx.kColorClear)
	gfx.fillRect(
		GRID_OFFSET_X + CELL * (15 - self.puzzle.width) + CELL * (self.gridX - 1),
		0,
		CELL + 1,
		CELL * 4 + 7
	)
	gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)
	do
		local numbers = self.gridNumbers.top[self.gridX]
		local done = self.doneNumbers.top[self.gridX]
		local lenNumbers = #numbers
		for i, v in ipairs(numbers) do
			gfx.drawText(
				done[i] and NUM_MAP[v] or NUM_MAP_BOLD[v],
				CELL * (self.gridX - 1) + 1,
				14 * (i - 1 - lenNumbers) - 2
			)
		end
	end
	gfx.popContext()
	self.addDirtyRect(
		self.x + GRID_OFFSET_X + CELL * (15 - self.puzzle.width) + CELL * (self.gridX - 1),
		self.y,
		CELL + 1,
		CELL * 4 + 7
	)
end

function GridNumbers:redrawLeftCursor(gridY, hide)
	gfx.pushContext(self.image)
	do
		gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)
		gfx.setColor(hide and gfx.kColorClear or gfx.kColorBlack)
		gfx.drawLine(CELL * -8 + 3, CELL * gridY - CELL, -2, CELL * gridY - CELL)
		gfx.drawLine(CELL * -8 + 3, CELL * gridY, -2, CELL * gridY)
	end
	gfx.popContext()
	self.addDirtyRect(
		self.x + GRID_OFFSET_X + CELL * (15 - self.puzzle.width) + CELL * -8 + 3,
		self.y + GRID_OFFSET_Y + CELL * (gridY - 1),
		-2 - (CELL * -8 + 3),
		CELL + 1
	)
end

function GridNumbers:redrawTopCursor(gridX, hide)
	gfx.pushContext(self.image)
	do
		gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)
		gfx.setColor(hide and gfx.kColorClear or gfx.kColorBlack)
		gfx.drawLine(CELL * gridX - CELL, CELL * -5 + 11, CELL * gridX - CELL, -2)
		gfx.drawLine(CELL * gridX, CELL * -5 + 11, CELL * gridX, -2)
	end
	gfx.popContext()
	self.addDirtyRect(
		self.x + GRID_OFFSET_X + CELL * (15 - self.puzzle.width) + CELL * (gridX - 1),
		self.y + GRID_OFFSET_Y + CELL * -5 + 11,
		CELL + 1,
		-2 - (CELL * -5 + 11)
	)
end
