class("GridNumbersLeft").extends(gfx.sprite)

function GridNumbersLeft:init()
	GridNumbersLeft.super.init(self, gfx.image.new(CELL * 8, CELL * 10 + 1))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_GRID_NUMBERS)
end

function GridNumbersLeft:enter(puzzle, gridNumbers, doneNumbers, x, y, showHints)
	self.puzzle = puzzle
	self.gridNumbers = gridNumbers
	self.doneNumbers = doneNumbers
	self.gridX = x
	self.gridY = y

	self:moveTo(SEPARATOR_WIDTH, GRID_OFFSET_Y)
	self:add()
	self:redraw()
end

function GridNumbersLeft:updateForPosition()
	self:redrawPosition()
	if not self.cursorHidden then
		self:redrawLeftCursor(self.gridY)
	end
end

function GridNumbersLeft:leave()
	self:remove()
end

function GridNumbersLeft:setCursor(x, y)
	if not self.cursorHidden and self.gridY ~= y then
		self:redrawLeftCursor(self.gridY, true)
		self:redrawLeftCursor(y)
	end

	self.gridX = x
	self.gridY = y
end

function GridNumbersLeft:hideCursor()
	self.cursorHidden = true
	self:redraw()
end

function GridNumbersLeft:redraw()
	self:getImage():clear(gfx.kColorClear)
	gfx.lockFocus(self:getImage())
	do
		gfx.setFont(fontGrid)
		gfx.setDrawOffset(GRID_OFFSET_X - SEPARATOR_WIDTH + CELL * (15 - self.puzzle.width), 0)

		-- numbers
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

		-- cursor
		gfx.setColor(gfx.kColorBlack)
		if not self.cursorHidden then
			gfx.drawLine(CELL * -8 + 3, CELL * self.gridY - CELL, -3, CELL * self.gridY - CELL)
			gfx.drawLine(CELL * -8 + 3, CELL * self.gridY, -3, CELL * self.gridY)
		end
	end
	gfx.unlockFocus()
end

function GridNumbersLeft:redrawPosition()
	gfx.lockFocus(self:getImage())
	gfx.setFont(fontGrid)
	gfx.setColor(gfx.kColorClear)
	gfx.fillRect(27, CELL * (self.gridY - 1), -2 - (CELL * -8 + 3), CELL + 1)
	gfx.setDrawOffset(GRID_OFFSET_X - SEPARATOR_WIDTH + CELL * (15 - self.puzzle.width), 0)
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
	gfx.unlockFocus()
end

function GridNumbersLeft:redrawLeftCursor(gridY, hide)
	gfx.lockFocus(self:getImage())
	do
		gfx.setDrawOffset(GRID_OFFSET_X - SEPARATOR_WIDTH + CELL * (15 - self.puzzle.width), 0)
		gfx.setColor(hide and gfx.kColorClear or gfx.kColorBlack)
		gfx.drawLine(CELL * -8 + 3, CELL * gridY - CELL, -3, CELL * gridY - CELL)
		gfx.drawLine(CELL * -8 + 3, CELL * gridY, -3, CELL * gridY)
	end
	gfx.unlockFocus()
end
